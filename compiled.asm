eliminate:
        addiu   $sp,$sp,-72
        sw      $31,68($sp)
        sw      $fp,64($sp)
        sw      $18,60($sp)
        sw      $17,56($sp)
        sw      $16,52($sp)
        move    $fp,$sp
        sw      $4,72($fp)
        sw      $5,76($fp)
        sw      $6,80($fp)
        lw      $3,76($fp)
        lw      $2,80($fp)
        nop
        div     $0,$3,$2
        bne     $2,$0,1f
        nop
        break   7
        mfhi    $2
        mflo    $2
        sw      $2,44($fp)
        sw      $0,36($fp)
        b       $L2
        nop

$L15:
        sw      $0,40($fp)
        b       $L3
        nop

$L14:
        sw      $0,32($fp)
        b       $L4
        nop

$L13:
        lw      $3,36($fp)
        lw      $2,44($fp)
        nop
        mult    $3,$2
        lw      $2,32($fp)
        mflo    $3
        slt     $2,$2,$3
        bne     $2,$0,$L5
        nop

        lw      $2,36($fp)
        nop
        addiu   $3,$2,1
        lw      $2,44($fp)
        nop
        mult    $3,$2
        lw      $2,32($fp)
        mflo    $3
        slt     $2,$2,$3
        beq     $2,$0,$L5
        nop

        lw      $2,32($fp)
        nop
        addiu   $4,$2,1
        lw      $3,40($fp)
        lw      $2,44($fp)
        nop
        mult    $3,$2
        mflo    $5
        jal     Max
        nop

        sw      $2,28($fp)
        b       $L6
        nop

$L7:
        lw      $2,32($fp)
        nop
        sll     $2,$2,2
        lw      $3,72($fp)
        nop
        addu    $2,$3,$2
        lw      $3,0($2)
        lw      $2,28($fp)
        nop
        sll     $2,$2,3
        addu    $2,$3,$2
        lw      $3,4($2)
        lw      $2,0($2)
        lw      $4,32($fp)
        nop
        sll     $4,$4,2
        lw      $5,72($fp)
        nop
        addu    $4,$5,$4
        lw      $5,0($4)
        lw      $4,32($fp)
        nop
        sll     $4,$4,3
        addu    $4,$5,$4
        lw      $5,4($4)
        lw      $4,0($4)
        lw      $6,32($fp)
        nop
        sll     $6,$6,2
        lw      $7,72($fp)
        nop
        addu    $6,$7,$6
        lw      $7,0($6)
        lw      $6,28($fp)
        nop
        sll     $6,$6,3
        addu    $16,$7,$6
        move    $7,$5
        move    $6,$4
        move    $5,$3
        move    $4,$2
        jal     __divdf3
        nop

        sw      $3,4($16)
        sw      $2,0($16)
        lw      $2,28($fp)
        nop
        addiu   $2,$2,1
        sw      $2,28($fp)
$L6:
        lw      $2,40($fp)
        nop
        addiu   $3,$2,1
        lw      $2,44($fp)
        nop
        mult    $3,$2
        lw      $2,28($fp)
        mflo    $3
        slt     $2,$2,$3
        bne     $2,$0,$L7
        nop

        lw      $3,28($fp)
        lw      $2,76($fp)
        nop
        bne     $3,$2,$L5
        nop

        lw      $2,32($fp)
        nop
        sll     $2,$2,2
        lw      $3,72($fp)
        nop
        addu    $2,$3,$2
        lw      $3,0($2)
        lw      $2,32($fp)
        nop
        sll     $2,$2,3
        addu    $4,$3,$2
        lui     $2,%hi($LC0)
        lw      $3,%lo($LC0+4)($2)
        lw      $2,%lo($LC0)($2)
        sw      $3,4($4)
        sw      $2,0($4)
$L5:
        lw      $2,32($fp)
        nop
        addiu   $4,$2,1
        lw      $3,36($fp)
        lw      $2,44($fp)
        nop
        mult    $3,$2
        mflo    $5
        jal     Max
        nop

        sw      $2,24($fp)
        b       $L8
        nop

$L12:
        lw      $2,32($fp)
        nop
        addiu   $4,$2,1
        lw      $3,40($fp)
        lw      $2,44($fp)
        nop
        mult    $3,$2
        mflo    $5
        jal     Max
        nop

        sw      $2,28($fp)
        b       $L9
        nop

$L10:
        lw      $2,24($fp)
        nop
        sll     $2,$2,2
        lw      $3,72($fp)
        nop
        addu    $2,$3,$2
        lw      $3,0($2)
        lw      $2,28($fp)
        nop
        sll     $2,$2,3
        addu    $2,$3,$2
        lw      $17,4($2)
        lw      $16,0($2)
        lw      $2,24($fp)
        nop
        sll     $2,$2,2
        lw      $3,72($fp)
        nop
        addu    $2,$3,$2
        lw      $3,0($2)
        lw      $2,32($fp)
        nop
        sll     $2,$2,3
        addu    $2,$3,$2
        lw      $3,4($2)
        lw      $2,0($2)
        lw      $4,32($fp)
        nop
        sll     $4,$4,2
        lw      $5,72($fp)
        nop
        addu    $4,$5,$4
        lw      $5,0($4)
        lw      $4,28($fp)
        nop
        sll     $4,$4,3
        addu    $4,$5,$4
        lw      $5,4($4)
        lw      $4,0($4)
        move    $7,$5
        move    $6,$4
        move    $5,$3
        move    $4,$2
        jal     __muldf3
        nop

        move    $5,$3
        move    $4,$2
        lw      $2,24($fp)
        nop
        sll     $2,$2,2
        lw      $3,72($fp)
        nop
        addu    $2,$3,$2
        lw      $3,0($2)
        lw      $2,28($fp)
        nop
        sll     $2,$2,3
        addu    $18,$3,$2
        move    $7,$5
        move    $6,$4
        move    $5,$17
        move    $4,$16
        jal     __subdf3
        nop

        sw      $3,4($18)
        sw      $2,0($18)
        lw      $2,28($fp)
        nop
        addiu   $2,$2,1
        sw      $2,28($fp)
$L9:
        lw      $2,40($fp)
        nop
        addiu   $3,$2,1
        lw      $2,44($fp)
        nop
        mult    $3,$2
        lw      $2,28($fp)
        mflo    $3
        slt     $2,$2,$3
        bne     $2,$0,$L10
        nop

        lw      $3,28($fp)
        lw      $2,76($fp)
        nop
        bne     $3,$2,$L11
        nop

        lw      $2,24($fp)
        nop
        sll     $2,$2,2
        lw      $3,72($fp)
        nop
        addu    $2,$3,$2
        lw      $3,0($2)
        lw      $2,32($fp)
        nop
        sll     $2,$2,3
        addu    $2,$3,$2
        sw      $0,4($2)
        sw      $0,0($2)
$L11:
        lw      $2,24($fp)
        nop
        addiu   $2,$2,1
        sw      $2,24($fp)
$L8:
        lw      $2,36($fp)
        nop
        addiu   $3,$2,1
        lw      $2,44($fp)
        nop
        mult    $3,$2
        lw      $2,24($fp)
        mflo    $3
        slt     $2,$2,$3
        bne     $2,$0,$L12
        nop

        lw      $2,32($fp)
        nop
        addiu   $2,$2,1
        sw      $2,32($fp)
$L4:
        lw      $2,36($fp)
        nop
        addiu   $3,$2,1
        lw      $2,44($fp)
        nop
        mult    $3,$2
        mflo    $2
        addiu   $4,$2,-1
        lw      $2,40($fp)
        nop
        addiu   $3,$2,1
        lw      $2,44($fp)
        nop
        mult    $3,$2
        mflo    $2
        addiu   $2,$2,-1
        move    $5,$2
        jal     Min
        nop

        move    $3,$2
        lw      $2,32($fp)
        nop
        slt     $2,$3,$2
        beq     $2,$0,$L13
        nop

        lw      $2,40($fp)
        nop
        addiu   $2,$2,1
        sw      $2,40($fp)
$L3:
        lw      $3,40($fp)
        lw      $2,80($fp)
        nop
        slt     $2,$3,$2
        bne     $2,$0,$L14
        nop

        lw      $2,36($fp)
        nop
        addiu   $2,$2,1
        sw      $2,36($fp)
$L2:
        lw      $3,36($fp)
        lw      $2,80($fp)
        nop
        slt     $2,$3,$2
        bne     $2,$0,$L15
        nop

        nop
        nop
        move    $sp,$fp
        lw      $31,68($sp)
        lw      $fp,64($sp)
        lw      $18,60($sp)
        lw      $17,56($sp)
        lw      $16,52($sp)
        addiu   $sp,$sp,72
        jr      $31
        nop

$LC0:
        .word   1072693248
        .word   0