@R0
D=M

@orig
M=D

@R1
D=M

@dest
M=D

@R2
D=M

@end
D;JEQ

@N
M=D

(loop)
    @orig
    D=M
    M=M+1

    A=D
    D=M

    @dest
    A=M
    M=D
    
    @dest
    M=M+1

    @N
    M=M-1
    D=M

    @loop
    D;JNE

@orig
M=0
@dest
M=0
@N
M=0

(end)
    @end
    0;JMP