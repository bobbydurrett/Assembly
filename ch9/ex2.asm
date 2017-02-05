; fill an array with random integers
; and sort with bubble sort
       segment .bss
a      resq 100                ; array of quads
       segment .data
asiz   dq 20                   ; array size
i      dq 0                    ; array index
       segment .text
       global main
       global fillarray
       extern random
main:
       xor rax,rax              ; make debugger happy
       push rbp
       mov rbp,rsp
       call fillarray           ; fill array with random integers
       xor eax,eax              ; return code 0
       leave                    ; fix stack
       ret                      ; return
fillarray:
; add asiz entries into array a
; call unix function random() 
       xor rax,rax              ; make debugger happy
       push rbp
       mov rbp,rsp 
.looptop
       call random              ; get random int in rax
       mov r8,[i]               ; load array index
       mov [a+8*r8],rax         ; save in array
       inc r8                   ; increment array index
       mov [i],r8               ; save index
       cmp r8,[asiz]            ; check if max number of entries
       jl .looptop
       leave
       ret
