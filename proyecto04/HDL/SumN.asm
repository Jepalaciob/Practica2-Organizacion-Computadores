@R0
D=M

@cl
D;JEQ

@N
M=D

(loop)
    @N
    D=M
    M=M-1

    @sum
    M=D+M

    @N
    D=M
    
    @loop
    D;JNE

(cl)
    @sum
    D=M
    M=0
    @R1
    M=D


(end)
    @end
    0;JMP