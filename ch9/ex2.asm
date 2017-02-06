; fill an array with random integers
; and sort with bubble sort
       segment .bss
a      resq 100                ; array of quads
       segment .data
asiz   dq 10                   ; array size
i      dq 0                    ; array index
maxpr  dq 20                   ; max size array to print 
prnfmt db "%ld",0x0a,0         ; array element 
       segment .text
       global main
       global fillarray
       global sortarray
       global printarray
       extern random
       extern printf
main:
       xor rax,rax              ; make debugger happy
       push rbp
       mov rbp,rsp
       call fillarray           ; fill array with random integers
       call printarray          ; print the array
       call sortarray           ; sort the array
       call printarray          ; print the array
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
sortarray:
; sort array a using bubble sort
       push rbp
       mov rbp,rsp 
       mov r8,[asiz]        ; load size of array
       dec r8               ; subtract 1 - max index of bubble sort element compare
nextpass:
       xor rax,rax          ; rax is 0 if no elements were swapped in this pass
       xor rbx,rbx          ; rbx is index into array start at 0 = i
nextelement:
       mov rcx,[a+8*rbx]    ; rcx = a[i]
       mov rdx,[a+8*rbx+8]  ; rdx = a[i+1]
       cmp rcx,rdx          ; compare a[i] and a[i+1]
       jle noswap           ; if a[i]<=a[i+1] don't swap
       inc rax              ; rax has count of swaps
       mov [a+8*rbx+8],rcx  ; swap using values in registers
       mov [a+8*rbx],rdx    ; a[i] and a[i+1] swapped
noswap:
       inc rbx              ; i++
       cmp rbx,r8           ; index max is asize-2
       jl nextelement       ; move to next element
       cmp rax,0            ; see if any swaps were done
       jg  nextpass         ; make another pass through array
       leave
       ret
printarray:
       push rbp
       mov rbp,rsp 
       mov rax,[asiz]
       cmp rax,[maxpr]
       jg pdone
       xor rbx,rbx          ; rbx is index into array start at 0 = i
pnext:
       lea rdi,[prnfmt]     ; setting up read of one line fmt arg 1
       mov rsi,[a+8*rbx]    ; pointer to array element arg 2
       xor eax,eax          ; no floating point args
       call printf          ; read a line
       inc rbx              ; next array element
       cmp rbx,[asiz]      ; make sure index < asize
       jl pnext
pdone:
       leave
       ret
