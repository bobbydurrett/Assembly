; fill an array with random 4 byte integers
; and sort with bubble sort
       segment .data
asize  dq 0                     ; array size
aptr   dq 0                     ; pointer to array
i      dq 0                     ; array index
       segment .text
       global main
       global fillarray
       global sortarray
       global compare
       extern atol
       extern malloc
       extern random
       extern qsort
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
; Fill the array
       call fillarray           ; fill array with random integers
; Sort the array
       call sortarray           ; sort the array
.done:
       xor eax,eax              ; return code 0
       leave                    ; fix stack
       ret                      ; return
fillarray:
; add asize entries into array pointed to by aptr
; call unix function random() 
       push rbp
       mov rbp,rsp 
.looptop:
       call random              ; get random int in rax
       mov r8,[i]               ; load array index
       mov r9,[aptr]            ; load array pointer
       mov dword [r9+4*r8],eax  ; save in array only bottom 4 bytes
       inc r8                   ; increment array index
       mov [i],r8               ; save index
       cmp r8,[asize]           ; check if max number of entries
       jl .looptop
       leave
       ret
compare:
; compare two integers
; pointers in rdi, rsi
; return value in eax
       push rbp
       mov rbp,rsp 
       mov eax,[rdi]            ; load first integer
       sub eax,[rsi]            ; subtract second integer
       leave
       ret
sortarray:
; sort array a using qsort
       push rbp
       mov rbp,rsp 
; qsort(array,n,4,compare)
       mov rdi,[aptr]           ; pointer to array arg1
       mov rsi,[asize]          ; array size arg 2
       mov rdx,4                ; number of bytes per entry - 4
       lea rcx,[compare]        ; address of my compare function
       call qsort
       leave
       ret