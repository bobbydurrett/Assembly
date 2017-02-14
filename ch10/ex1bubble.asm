; fill an array with random 4 byte integers
; and sort with bubble sort
       segment .data
asize  dq 0                     ; array size
aptr   dq 0                     ; pointer to array
       segment .text
       global main
       extern atol
       extern malloc
main:
       push rbp
       mov rbp,rsp
; Get array size from command line arguments
       cmp rdi,2                ; check for two arguments, second is size
       jl .done
       mov rdi,qword [rsi+8]          ; load pointer to string which is array size number
       call atol                      ; convert character string to integer.
       mov [asize],rax                ; save array size 
; Call malloc to allocate the array memory
       mov rdi,[asize]                ; load array size
       imul rdi,4                     ; convert to bytes
       call malloc                    ; allocate memory
       mov [aptr],rax                 ; store pointer to array
.done:
       xor eax,eax              ; return code 0
       leave                    ; fix stack
       ret                      ; return
