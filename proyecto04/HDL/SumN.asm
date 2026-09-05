@R0
D=M

@end
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

@sum
D=M
M=0
@R1
M=D


(end)
    @end
    0;JMP