; Count all of the 1 bits in a byte
; input is the byte. output is the 
; number of 1 bits.
    section .data
input  dw 255             ; Has to be 16 bits for bt
output dq 0
       section .text
       global start
start:
       xor rax,rax       ; Clear rax and rbx
       xor rbx,rbx
; Do next three lines for each bit in byte
       bt word[input],0  ; Check bit 0
       setc bl           ; 1 in bl if bit set
       add rax,rbx       ; Add 1 to rax if set
       bt word[input],1  ; Check bit 1
       setc bl           ; 1 in bl if bit set
       add rax,rbx       ; Add 1 to rax if set
       bt word[input],2  ; Check bit 2
       setc bl           ; 1 in bl if bit set
       add rax,rbx       ; Add 1 to rax if set
       bt word[input],3  ; Check bit 3
       setc bl           ; 1 in bl if bit set
       add rax,rbx       ; Add 1 to rax if set
       bt word[input],4  ; Check bit 4
       setc bl           ; 1 in bl if bit set
       add rax,rbx       ; Add 1 to rax if set
       bt word[input],5  ; Check bit 5
       setc bl           ; 1 in bl if bit set
       add rax,rbx       ; Add 1 to rax if set
       bt word[input],6  ; Check bit 6
       setc bl           ; 1 in bl if bit set
       add rax,rbx       ; Add 1 to rax if set
       bt word[input],7  ; Check bit 7
       setc bl           ; 1 in bl if bit set
       add rax,rbx       ; Add 1 to rax if set
; Save count of 1 bits
       mov [output],rax
; exit with return code 0
       mov eax,60
       mov edi,0
       syscall
       end
