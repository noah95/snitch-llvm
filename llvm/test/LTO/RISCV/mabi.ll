; Test target-abi module flag generate correct elf flags.

; Check with regular LTO
; RUN: rm -f %t*
; RUN: llvm-as < %s >%t1
; RUN: llvm-as < %p/Inputs/mabi.ll >%t2
; Check old API
; RUN: llvm-lto -exported-symbol=main  -o %t3 %t1 %t2
; RUN: llvm-readelf -h %t3 | FileCheck %s
; Check new API
; RUN: llvm-lto2 run -r %t1,foo, -r %t1,main,plx -r %t2,foo,plx -o %t3.o %t1 %t2
; RUN: llvm-readelf -h %t3.o.0 | FileCheck %s

; Check with ThinLTO.
; RUN: rm -f %t*
; RUN: opt -module-summary -o %t1 %s
; RUN: opt -module-summary -o %t2 %p/Inputs/mabi.ll
; Check old API
; RUN: llvm-lto -thinlto -thinlto-action=run %t1 %t2 -exported-symbol=main
; RUN: llvm-readelf -h %t1.thinlto.o | FileCheck %s
; RUN: llvm-readelf -h %t2.thinlto.o | FileCheck %s
; Check new API
; RUN: llvm-lto2 run -r %t1,foo, -r %t1,main,plx -r %t2,foo,plx -o %t3.o %t1 %t2
; RUN: llvm-readelf -h %t3.o.1 | FileCheck %s
; RUN: llvm-readelf -h %t3.o.2 | FileCheck %s

; CHECK: Flags: 0x2, single-float ABI

target datalayout = "e-m:e-p:32:32-i64:64-n32-S128"
target triple = "riscv32-unknown-linux-gnu"

declare float @foo(float) #1

define float @main(float %x) #0 {
  %retval = call float @foo(float 10.0)
  ret float %retval
}

attributes #0 = { nounwind "target-features"="+a,+c,+f,+m,+relax" }
attributes #1 = { nounwind "target-features"="+a,+c,+f,+m,+relax" }

!llvm.module.flags = !{!0}
!0 = !{i32 1, !"target-abi", !"ilp32f"}

