module {
  func.func @test(%arg0: memref<1xi32, strided<[?], offset: ?>>, %arg1: memref<1xi32, strided<[?], offset: ?>>) -> memref<1xi32> {
    %c1 = arith.constant 1 : index
    %c0 = arith.constant 0 : index
    %c31_i32 = arith.constant 31 : i32
    %c0_i32 = arith.constant 0 : i32
    %alloc = memref.alloc() {alignment = 64 : i64} : memref<1xi32>
    cf.br ^bb1(%c0 : index)
  ^bb1(%0: index):  // 2 preds: ^bb0, ^bb2
    %1 = arith.cmpi slt, %0, %c1 : index
    cf.cond_br %1, ^bb2, ^bb3
  ^bb2:  // pred: ^bb1
    %2 = memref.load %arg1[%0] : memref<1xi32, strided<[?], offset: ?>>
    %3 = arith.cmpi sgt, %2, %c31_i32 : i32
    %4 = arith.select %3, %c31_i32, %c0_i32 : i32
    memref.store %4, %alloc[%0] : memref<1xi32>
    %5 = arith.addi %0, %c1 : index
    cf.br ^bb1(%5 : index)
  ^bb3:  // pred: ^bb1
    %alloc_0 = memref.alloc() {alignment = 64 : i64} : memref<1xi32>
    cf.br ^bb4(%c0 : index)
  ^bb4(%6: index):  // 2 preds: ^bb3, ^bb5
    %7 = arith.cmpi slt, %6, %c1 : index
    cf.cond_br %7, ^bb5, ^bb6
  ^bb5:  // pred: ^bb4
    %8 = memref.load %arg0[%6] : memref<1xi32, strided<[?], offset: ?>>
    %9 = memref.load %alloc[%6] : memref<1xi32>
    %10 = arith.divsi %8, %9 : i32
    memref.store %10, %alloc_0[%6] : memref<1xi32>
    %11 = arith.addi %6, %c1 : index
    cf.br ^bb4(%11 : index)
  ^bb6:  // pred: ^bb4
    return %alloc_0 : memref<1xi32>
  }
}