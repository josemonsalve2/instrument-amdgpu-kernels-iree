!A_TYPE = tensor<64x64xi16>
!B_TYPE = tensor<64x64xi16>
!C_TYPE = tensor<64x64xi16>
func.func @simple_mul(%arg0: !A_TYPE, %arg1: !B_TYPE) -> !C_TYPE {
  %0 = arith.muli %arg0, %arg1 : !C_TYPE
  return %0 : !C_TYPE
}
