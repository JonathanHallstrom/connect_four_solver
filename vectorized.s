.intel_syntax
.LCPI0_0:
        .quad   1
        .quad   7
        .quad   6
        .quad   8
.LCPI0_1:
        .quad   4363416223614
        .quad   4398046511103
        .quad   2181708111807
        .quad   4363416223614
.LCPI0_2:
        .quad   2
        .quad   14
        .quad   12
        .quad   16
.LCPI0_3:
        .quad   4294155648636
        .quad   4398046510976
        .quad   1073538912128
        .quad   4294155648512
isWon:
        push    rbp
        mov     rbp, rsp
        vpbroadcastq    ymm0, rdi
        vpsllvq ymm1, ymm0, ymmword ptr [rip + .LCPI0_0]
        vpand   ymm0, ymm0, ymm1
        vpand   ymm1, ymm0, ymmword ptr [rip + .LCPI0_1]
        vpand   ymm0, ymm0, ymmword ptr [rip + .LCPI0_3]
        vpsllvq ymm1, ymm1, ymmword ptr [rip + .LCPI0_2]
        vptest  ymm0, ymm1
        setne   al
        pop     rbp
        vzeroupper
        ret