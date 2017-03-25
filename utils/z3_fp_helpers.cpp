#include "z3_fp_helpers.h"
#include "llvm/IR/Instruction.h"
#include "llvm/IR/Metadata.h"
#include "llvm/IR/Module.h"
#include "llvm/Support/raw_ostream.h"
#include "mk_debug.h"

#include <cmath>
#include <iomanip>
#include <sstream>

using namespace llvm;

static std::map<llvm::Value *, unsigned> value_cacheG;

z3::func_decl z3_fp_helpers::getBVBVFuncDecl(z3::context &ctx, const char *name
    , const unsigned bvSize) {
  z3::sort bvSort = ctx.bv_sort(bvSize);
  z3::sort boolSort = ctx.bool_sort();
  z3::sort domain[2] = {bvSort, bvSort};
  z3::func_decl decl = ctx.function(ctx.str_symbol(name)
                                       , 2
                                       , domain
                                       , boolSort);
  return decl;
}

z3::func_decl z3_fp_helpers::getBVFuncDecl(z3::context &ctx, const char *name
    , const unsigned bvSize) {
  z3::sort bvSort = ctx.bv_sort(bvSize);
  z3::sort boolSort = ctx.bool_sort();
  z3::sort domain[1] = {bvSort};
  z3::func_decl decl = ctx.function(ctx.str_symbol(name)
                                       , 1
                                       , domain
                                       , boolSort);
  return decl;
}

void z3_fp_helpers::addFact2(z3::context &ctx
            , Z3_fixedpoint &zfp
            , z3::func_decl fd
            , z3::expr v1
            , z3::expr v2) {
  try {
    z3::expr args[2] = {v1, v2};
    z3::expr app = fd(2, args);
    Z3_fixedpoint_add_rule(ctx, zfp, app, NULL);
  }
  catch (z3::exception e) {
    errs() << "[ERROR] Error adding fact: " << e.msg() << '\n';
    exit(EXIT_FAILURE);
  }
}

void z3_fp_helpers::addFact2Sz(z3::context &ctx
            , Z3_fixedpoint &zfp
            , z3::func_decl fd
            , Value *v1
            , Value *v2
            , unsigned bvSize) {
  z3::expr v1ID = getValueBVIDSz(ctx, v1, bvSize);
  z3::expr v2ID = getValueBVIDSz(ctx, v2, bvSize);
  addFact2(ctx, zfp, fd, v1ID, v2ID);
}


void z3_fp_helpers::addFact1(z3::context &ctx
            , Z3_fixedpoint &zfp
            , z3::func_decl fd
            , z3::expr v) {
  try {
    z3::expr args[1] = {v};
    z3::expr app = fd(1, args);
    Z3_fixedpoint_add_rule(ctx, zfp, app, NULL);
  }
  catch (z3::exception e) {
    errs() << "[ERROR] Error adding fact: " << e.msg() << '\n';
    exit(EXIT_FAILURE);
  }
}

// Same as addFact2Sz but for a func_decl with only argument.
void z3_fp_helpers::addFact1Sz(z3::context &ctx
            , Z3_fixedpoint &zfp
            , z3::func_decl fd
            , llvm::Value *v
            , unsigned bvSize) {
  z3::expr vID = getValueBVIDSz(ctx, v, bvSize);
  addFact1(ctx, zfp, fd, vID);
}

z3::expr z3_fp_helpers::getValueBVIDSz(z3::context &ctx, Value *v, unsigned bvSize) {
  // NOTE: might be able to use one of the int/unsigned mk_ functions but in
  // general we do not know the size of a pointer
  // We make use of casting pointers to LLVM objects into bitvectors for Z3.
  // The size of the pointers must be able to fit into one of the Z3 apis.
  //
  // NOTE: If you get an error here, you can use the context::bv_val()
  // function taking a string instead of an integer, e.g.:
  //  z3::expr ret = ctx.bv_val(std::to_string((uintptr_t)v).c_str(),
  //                           Z3_BV_SIZE);
  //
  // z3 defines  __uint64 as unsigned long long (as of right now)
  //static_assert(sizeof(uintptr_t) <= sizeof(__uint64)
  //    , "unable to convert pointer to value");
  //__uint64 ptrVal = (__uint64) v;
  //z3::expr ret = ctx.bv_val(ptrVal, Z3_BV_SIZE);
  //return ret;

  assert(sizeof(unsigned) * 8 >= bvSize && 
      "Bitvector size cannot fit in unsigned");
  auto hit = value_cacheG.find(v);
  unsigned id;
  if (hit != value_cacheG.end()) {
    id = hit->second;
  }
  else {
    id = value_cacheG.size();
    DEBUG_MSG("New ID:\n\tvalue: " << *v << "\n\tID: " << id << '\n');
    if (std::ceil((std::log(id) / std::log(2))) > bvSize) {
      errs() << "[ERROR] Overflowing Bitvector size, increase it: "
             << "current size: " << bvSize << '\n';
      exit(EXIT_FAILURE);
    }
    value_cacheG[v] = id;
  }
  z3::expr ret = ctx.bv_val(id, bvSize);
  return ret;
}

void z3_fp_helpers::valueCacheToMetadata(Module &M, unsigned bvSize) {
  static constexpr char const *const METADATA_NAME = "BVID";

  if (value_cacheG.size() == 0) {
    // Nothing to dump
    return;
  }

  for (auto pr : value_cacheG) {
    Value *v = pr.first;
    unsigned id = pr.second;
    std::string bvstr = to_const_bitvec(id, bvSize);
    MDString *mds = MDString::get(M.getContext(), bvstr);

    if (Instruction *inst = dyn_cast<Instruction>(v)) {
      DEBUG_MSG("Dumping instruction to module\n");
      DEBUG_MSG("\t" << *inst << '\n');
      
      // Instruction metadata is attached to the instruction itself
      MDNode *mdn = MDNode::get(M.getContext(), mds);
      inst->setMetadata(METADATA_NAME, mdn);
    }
    // Handle other types of values here
    else {
      errs() << "[WARNING] Value not dumped to metadata: " << *v << '\n';
      errs() << "\ttype not handled\n";
    }
  }
}
std::string z3_fp_helpers::to_const_bitvec(unsigned i, unsigned sz) {
  std::stringstream stream;

  // sz is in bits
  assert(i < std::pow((double)2.0, sz) && "value bigger than size");

  DEBUG_MSG("to_const_bitvec(): " << i << '\n');

  // Ensure that the constant is padded with zeros equal to the number of hex
  // digits (i.e., the number of nibbles)
  unsigned num_nibbles = std::ceil(sz / (double)4.0);
  stream << "#x" << std::setfill('0') << std::setw(num_nibbles) 
         << std::hex << i;

  std::string ret( stream.str() );

  return ret;
}

void z3_fp_helpers::addBVBVRelation(z3::context &ctx, Z3_fixedpoint &zfp
    , const char * const name, const unsigned bvSize) {
  z3::func_decl funcDecl = getBVBVFuncDecl(ctx, name, bvSize);
  Z3_fixedpoint_register_relation(ctx, zfp, funcDecl);
}

void z3_fp_helpers::addTransRuleBVBV(z3::context &ctx, Z3_fixedpoint &zfp
    , z3::func_decl fd, unsigned bvSize) {
  z3::sort bvSort = ctx.bv_sort(bvSize);
  //Z3_ast a = Z3_mk_const(ctx, Z3_mk_string_symbol(ctx, "a"), bvSort);
  //Z3_ast b = Z3_mk_const(ctx, Z3_mk_string_symbol(ctx, "b"), bvSort);
  //Z3_ast c = Z3_mk_const(ctx, Z3_mk_string_symbol(ctx, "c"), bvSort);
  z3::expr a = z3::expr(ctx, Z3_mk_bound(ctx, 0, bvSort));
  z3::expr b = z3::expr(ctx, Z3_mk_bound(ctx, 1, bvSort));
  z3::expr c = z3::expr(ctx, Z3_mk_bound(ctx, 2, bvSort));

  // (fd a b)
  z3::expr args2[2] = {a, b};
  z3::expr aFdB = fd(2, args2);
  // (fd b c)
  args2[0] = b;
  args2[1] = c;
  z3::expr bFdC = fd(2, args2);
  // (fd a c)
  args2[0] = a;
  args2[1] = c;
  z3::expr aFdC = fd(2, args2);
  // (and (fd a b) (fd b c))
  //args2[0] = aFdB;
  //args2[1] = bFdC;
  z3::expr fdAbAndBc = aFdB && bFdC;
  // (=> (and (fd a b) (fd b c)) (fd a c))
  z3::expr fdTrans = z3::implies(fdAbAndBc, aFdC);
  Z3_fixedpoint_add_rule(ctx, zfp, fdTrans, NULL);
}

// Add a rule that: fd1 ==> fd2, that is being a member of fd1 implies being a
// member of fd2
void z3_fp_helpers::addRelImplicationRule(z3::context &ctx
    , Z3_fixedpoint &zfp, z3::func_decl fd1, z3::func_decl fd2, unsigned bvSize) {
  z3::sort bvSort = ctx.bv_sort(bvSize);
  z3::expr a = z3::expr(ctx, Z3_mk_bound(ctx, 0, bvSort));
  z3::expr b = z3::expr(ctx, Z3_mk_bound(ctx, 1, bvSort));

  // fd1(a, b)
  z3::expr args2[2] = {a, b};
  z3::expr fd1AB = fd1(2, args2);

  // fd2(a, b)
  z3::expr fd2AB = fd1(2, args2);

  // (=> (fd1 a b) (fd2 a b))
  z3::expr imp = z3::implies(fd1AB, fd2AB);
  Z3_fixedpoint_add_rule(ctx, zfp, imp, NULL);
}
