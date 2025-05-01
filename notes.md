- ticket
https://github.com/llvm/llvm-project/issues/132158

- fails assert at /mlir/include/mlir/IR/Matchers.h
```c++
    SmallVector<OpFoldResult, 1> foldedOp;
    LogicalResult result = op->fold(/*operands=*/std::nullopt, foldedOp);
    (void)result;
    assert(succeeded(result) && "expected ConstantLike op to be foldable");
```

- reproduce error with
```sh
./build/bin/mlir-opt -test-convert-to-spirv example.mlir
```

- What op did it crash on?
```mlir
%1 = "arith.constant"() : () -> memref<1xi32, strided<[?], offset: ?>>
```
Note that this op is the result of some transformations

Relevant files?
/mlir/include/mlir/Conversion/ArithToSPIRV/ArithToSPIRV.h
/mlir/lib/Conversion/ArithToSPIRV/ArithToSPIRV.cpp

/mlir/lib/Dialect/SPIRV/Transforms/SPIRVConversion.cpp ?
```c++
  addConversion([this](IntegerType intType) -> std::optional<Type> {
    if (auto scalarType = dyn_cast<spirv::ScalarType>(intType))
      return convertScalarType(this->targetEnv, this->options, scalarType);
    if (intType.getWidth() < 8)
      return convertSubByteIntegerType(this->options, intType);
    return Type();
  });
```

- Dialect docs:
https://mlir.llvm.org/docs/Dialects/ArithOps/
https://mlir.llvm.org/docs/Dialects/MemRef/
https://mlir.llvm.org/docs/Dialects/Builtin/#functiontype
https://mlir.llvm.org/docs/Dialects/Builtin/#memreftype

- Debugging tips
https://mlir.llvm.org/getting_started/Debugging/

- result originates from /projects/rkchang/fork-llvm-project/mlir/lib/IR/Operation.cpp
```c++
  auto *interface = dyn_cast<DialectFoldInterface>(dialect);
  if (!interface)
    return failure();
```

- Test case that converts arith to spirv:
`mlir/test/Conversion/ConvertToSPIRV/arith.mlir`

# Questions:
- Is example.mlir a valid program?
- Are we supposed to be able to fold a `memref` op?
- What does fold mean in this context?
- Where is the start?
- How to trace ops through the passes?
There's some stuff here that I haven't been able to do yet https://mlir.llvm.org/getting_started/Debugging/
- What does this flag do?
This pass?: mlir/test/lib/Pass/TestConvertToSPIRVPass.cpp
- How would you approach this?


Hi Jakub,

We've been looking for a good starter issue that's MLIR related.
We had a tough time finding one labeled (good first issue).
So during one of the office hours, the engineer mentioned we could pick any one of them!

We landed on https://github.com/llvm/llvm-project/issues/132158 which is SPIRV related.
While looking through the git blame, we noticed that you've worked in this area in the past.
Would you be willing to give any general advice on solving this issue?
Or if you have any easier issues as well that we could do that would also be great!

# Tasks
- What does the op do?
