@SCREEN
D=A

@pos
M=D

(black)
    @pos
    A=M
    M=-1

    @pos
    M=M+1

    @KBD
    D=M

    @black
    D;JNE

    @SCREEN
    D=A

    @pos
    M=D

    @white
    0;JMP


(white)
    @pos
    A=M
    M=0

    @pos
    M=M+1

    @KBD
    D=M

    @white
    D;JEQ

    @SCREEN
    D=A

    @pos
    M=D

    @black
    0;JMP

(end)
    @end
    0;JMP