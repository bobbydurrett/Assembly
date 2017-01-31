; Exclusive or of the 8 bytes
; of a quad word
    section .data
input  dq 0x1234567812345679             
output dq 0
       section .text
       global start
start:
       xor rcx,rcx       ; clear rcx for result
       mov rax,[input]   ; Load input
       mov rbx,rax       ; Copy to rbx 
       and rbx,0xFF      ; Only keep byte
       xor rcx,rbx       ; xor the byte
       ror rax,8         ; Get next byte
       mov rbx,rax       ; Copy to rbx 
       and rbx,0xFF      ; Only keep byte
       xor rcx,rbx       ; xor the byte
       ror rax,8         ; Get next byte
       mov rbx,rax       ; Copy to rbx 
       and rbx,0xFF      ; Only keep byte
       xor rcx,rbx       ; xor the byte
       ror rax,8         ; Get next byte
       mov rbx,rax       ; Copy to rbx 
       and rbx,0xFF      ; Only keep byte
       xor rcx,rbx       ; xor the byte
       ror rax,8         ; Get next byte
       mov rbx,rax       ; Copy to rbx 
       and rbx,0xFF      ; Only keep byte
       xor rcx,rbx       ; xor the byte
       ror rax,8         ; Get next byte
       mov rbx,rax       ; Copy to rbx 
       and rbx,0xFF      ; Only keep byte
       xor rcx,rbx       ; xor the byte
       ror rax,8         ; Get next byte
       mov rbx,rax       ; Copy to rbx 
       and rbx,0xFF      ; Only keep byte
       xor rcx,rbx       ; xor the byte
       ror rax,8         ; Get next byte
       mov rbx,rax       ; Copy to rbx 
       and rbx,0xFF      ; Only keep byte
       xor rcx,rbx       ; xor the byte
       mov [output],rcx  ; mov result to output 
; exit with return code 0
       mov eax,60
       mov edi,0
       syscall
       end
