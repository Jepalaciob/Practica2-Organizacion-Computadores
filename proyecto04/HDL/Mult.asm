@R0
D=M

@cl
D;JEQ

@R1
D=M

@cl
D;JEQ

@j
M=D

(mult)
    @R0
    D=M

    @resultado
    M=D+M

    @j
    M=M-1
    D=M

    @mult
    D;JNE

@resultado
D=M
@R2
M=D

(cl)
    @resultado
    M=0
    @j
    M=0

(end)
    @end
    0;JMP