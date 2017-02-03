; Fibonacci numbers
; f(0) = 0
; f(1) = 1
; f(i) = f(i-1) + f(i-2) where i > 1
; 12200160415121876738 seems to be the largest unsigned
; Fib. number that can fit in an 8 byte integer.
; I think this is f(93)
;
    
       segment .bss
       align 8
f      resq 10000
       segment .data
n      dq 10000   ; n is the number of elements in the array
       segment .text
       global start
start:
; load the first two numbers
       xor rbx,rbx
       mov [f],rbx          ; f(0) = 0
       inc rbx
       mov [f+8*rbx],rbx    ; f(1) = 1
       mov rax,[n]          ; load n in rax
       mov rbx,2            ; rbx index of next f entry = i
ltop:
       mov rcx,[f+8*rbx-16] ; rcx has f(i-2) 
       add rcx,[f+8*rbx-8]  ; rcx has f(i-1)+f(i-2)
       jc done              ; end if it overflows
       mov [f+8*rbx],rcx    ; store f(i)
       inc rbx              ; i++
       cmp rbx,rax          ; stop if i reaches n
       jge done
       jmp ltop
done:
; exit with return code 0
       mov eax,60
       mov edi,0
       syscall
       end
