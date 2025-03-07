.intel_syntax
        push    rbp
        mov     rbp, rsp
        mov     rax, rdi
        rorx    rsi, rdi, 57
        mov     r9, rdi
        shl     r9, 8
        shr     rax
        movabs  rdx, 2181708111807
        movabs  r8, 531921213849600
        movabs  r10, 66490151976960
        and     rdx, rax
        and     rsi, rdi
        and     r9, rdi
        movabs  rax, 519454312335
        mov     rcx, rdx
        rorx    r11, rsi, 57
        shl     rdx, 7
        and     rcx, rdi
        and     r8, r9
        shl     r9, 16
        and     rax, rcx
        shr     rcx, 2
        and     rdx, rdi
        and     r11, rsi
        and     r8, r9
        and     r10, rdx
        shl     rdx, 5
        and     rax, rcx
        or      r8, r11
        and     r10, rdx
        or      r8, rax
        or      r8, r10
        setne   al
        pop     rbp