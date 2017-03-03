; ch 11 ex 1 - sin function

global main                      
global mysin                      
extern scanf
extern printf

segment .data

scanf_fmt db "%lf %ld",0            ; read x and num_terms as double and long
x dq 0.0
num_terms dq 0
printf_fmt db "sin(%lf)=%lf",0xa,0  ; print sin(x)

segment .text

main:	                         
    push rbp                     
    mov rbp,rsp                  
.read_again:
    lea rdi,[scanf_fmt]          ; read a number
    lea rsi,[x]                  ; read x
    lea rdx,[num_terms]          ; read num_terms
    mov eax,eax                  ; no floating point args
    call scanf                   ; read a line, x in xmm0
    cmp eax,2                    ; check for 2 return arguments
    jne .done                    ; done if 2 values not read
; call sin function here
    movsd xmm0,[x]               ; load x for first float argument
    mov rdi,qword [num_terms]    ; load num terms first int argument
    call mysin
; print xmm0 here
    lea rdi,[printf_fmt]         ; read a number
    movsd xmm1,xmm0              ; sin(x) is second float argument
    movsd xmm0,[x]               ; x is first float argument
    mov rax,2                    ; 2 fload arguments
    call printf                  ; print line
    jmp .read_again
.done:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
; mysin is sin function based on 
; taylor series in book
; register   variable
; xmm0       x and returned sin(x)
; rdi        num_terms
; r8         term_num
; r9         sign
; xmm1       term
; xmm2       sum
; xmm3       k
; xmm4       x_k (x/k)
segment .data
oned dq 1.0
segment .text
mysin:	                         
    push rbp                     
    mov rbp,rsp      
    mov r8,1                     ; term_num = 1
    movsd xmm3,[oned]            ; k = 1
    movsd xmm1,xmm0              ; term = x
    movsd xmm2,xmm0              ; sum = x
    mov r9,1                     ; sign = 1
.nextterm:
    inc r8                       ; term_num++
    cmp r8,rdi                   ; term_num > num_terms
    jg .returnsum                ; we are done
    neg r9                       ; sign = -sign
    addsd xmm3,[oned]            ; k++
    movsd xmm4,xmm0              ; load x
    divsd xmm4,xmm3              ; x/k
    mulsd xmm1,xmm4              ; term = term * (x/k)
    addsd xmm3,[oned]            ; k++
    movsd xmm4,xmm0              ; load x
    divsd xmm4,xmm3              ; x/k
    mulsd xmm1,xmm4              ; term = term * (x/k)
    cmp r9,1                     ; sign == 1
    jl .dosubtract               ; subtract if sign of term is -1
    addsd xmm2,xmm1              ; sum = sum + term
    jmp .nextterm                ; next term
.dosubtract:
    subsd xmm2,xmm1              ; sum = sum - term
    jmp .nextterm                ; next term
.returnsum:
    movsd xmm0,xmm2              ; return sum
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
