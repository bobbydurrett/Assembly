; fill an array with random 4 byte integers
; and sort with bubble sort
       segment .data
asize  dq 0                     ; array size
       segment .text
       global main
       extern atol
main:
       push rbp
       mov rbp,rsp
; Get array size from command line arguments
       cmp rdi,2                ; check for two arguments, second is size
       jl .done
       mov rdi,qword [rsi+8]          ; load pointer to string which is array size number
       call atol
       mov [asize],rax                ; save array size 
.done:
       xor eax,eax              ; return code 0
       leave                    ; fix stack
       ret                      ; return
