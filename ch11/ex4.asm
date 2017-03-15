; ch 11 ex4 derivate and integral of polynomial

; Non-float arguments in these registers:
; rdi, rsi, rdx, rcx, r8 and r9
; rax contains the number of floating point arguments
; xmm0 to xmm7 contain the float arguments
; These registers must be preserved across function calls:
; rbx, rsp, rbp, r12-r15
; rax and rdx are the integer return registers
; xmm0 and xmm1 are the float return resgisters
; http://www.nasm.us/links/unix64abi

global main                     
global get_degree                     
global alloc_array                     
global read_poly                     
global read_a_b                     
global calc_poly                     
global calc_deriv   
global calc_integ
extern scanf
extern malloc
extern printf

segment .data

degree dq 0                      ; degree of polynomial
poly_ptr dq 0                    ; pointer to array of polynomial coefficients - double floats
a dq 0.0                         ; bottom of range for integral
b dq 0.0                         ; top of range
a_sum dq 0.0                     ; sum of poly terms for a
b_sum dq 0.0                     ; ditto for b
a_exp dq 0.0                     ; exponentiated value of a - i.e. a^k
b_exp dq 0.0                     ; ditto for b
term_num dq 0                    ; term number in poly - 0,1,2,...,degree+1
a_term dq 0.0                    ; value of current term for a
b_term dq 0.0                    ; ditto b
d_one dq 1.0                     ; constant 1.0 as a double
d_zero dq 0.0                    ; constant 0.0 as a double

segment .text

main:	                         
    push rbp                     
    mov rbp,rsp                  

    call get_degree                     
    call alloc_array                     
    call read_poly                     
    call read_a_b                     
    call calc_poly                     
    call calc_deriv   
    call calc_integ

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
segment .data

degreefmt db "%ld",0             ; read in degree as quad word integer      

segment .text

get_degree:	                         
    push rbp                     
    mov rbp,rsp                  

    lea rdi,[degreefmt]          ; one qword int
    lea rsi,[degree]             ; ptr to degree
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

alloc_array:	                         
    push rbp                     
    mov rbp,rsp                  

    mov rdi,[degree]             ; load degree
    inc rdi		         ; add 1
    imul rdi,8                   ; convert to bytes (8 bytes for double)
    call malloc                  ; allocate memory
    mov [poly_ptr],rax           ; store pointer to array of poly coeffcients

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

segment .data

polyfmt db "%lf",0               ; read one coefficient per line as double float      

segment .text

read_poly:	                         
    push rbp                     
    mov rbp,rsp      
    
    xor rbx,rbx                  ; entry 0
    mov r12,[poly_ptr]           ; load array pointer
    mov r13,[degree]             ; load degree
    inc r13                      ; degree+1    
.nextpoint:
    cmp rbx,r13                  ; check if we are past end of array
    jge .donereading
    lea rdi,[polyfmt]            ; read one coefficient
    lea rsi,[r12+rbx*8]          ; array entry
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
    inc rbx                      ; next array element
    jmp .nextpoint               ; top of loop
.donereading:

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

segment .data

abfmt db "%lf %lf",0             ; read a and b as two doubles one line 

segment .text

read_a_b:	                         
    push rbp                     
    mov rbp,rsp      
    
    lea rdi,[abfmt]              ; two doubles
    lea rsi,[a]                  ; ptr to a
    lea rdx,[b]                  ; ptr to b
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

segment .data

sumfmt db "f(%lf)=%lf",0xa,0

segment .text

calc_poly:	                         
    push rbp                     
    mov rbp,rsp   

    movsd xmm0,[d_zero]          ; load 0.0 to init variables
    movsd [a_sum],xmm0           ; a_sum=b_sum=0.0
    movsd [b_sum],xmm0
    movsd xmm0,[d_one]           ; load 1.0 to init variables
    movsd [a_exp],xmm0           ; a_exp=b_exp=1.0
    movsd [b_exp],xmm0
    xor rax,rax
    mov qword [term_num],rax     ; term_num=0
.looptop:
    mov rax,qword [term_num]
    mov rbx,qword [degree]
    cmp rax,rbx                  ; if term_num > degree jmp .done
    jg .doneloop
    mov rax,qword [poly_ptr]
    mov rbx,qword [term_num]
    movsd xmm0,[rax+rbx*8]       ; load the term_num element of the poly array
    movsd xmm1,[a_exp]           ; load exponentiated version of a
    mulsd xmm1,xmm0              ; poly[term_num]*a_exp
    movsd [a_term],xmm1          ; a_term = poly[term_num]*a_exp    
    movsd xmm2,[b_exp]           ; load exponentiated version of b
    mulsd xmm2,xmm0              ; poly[term_num]*b_exp
    movsd [b_term],xmm2          ; b_term = poly[term_num]*b_exp
    movsd xmm3,[a_sum]
    addsd xmm3,xmm1              ; xmm1 still has a_term in it
    movsd [a_sum],xmm3           ; a_sum=a_sum+a_term
    movsd xmm4,[b_sum]
    addsd xmm4,xmm2              ; xmm2 still has b_term in it
    movsd [b_sum],xmm4           ; b_sum=b_sum+b_term
    mov rax,qword [term_num]
    inc rax
    mov qword [term_num],rax     ; term_num++
    movsd xmm0,[a_exp]
    movsd xmm1,[a]
    mulsd xmm0,xmm1
    movsd [a_exp],xmm0           ; a_exp = a_exp * a
    movsd xmm0,[b_exp]
    movsd xmm1,[b]
    mulsd xmm0,xmm1
    movsd [b_exp],xmm0           ; b_exp = b_exp * b
    jmp .looptop
.doneloop:
    lea rdi,[sumfmt]             ; printf format f(x)=
    movsd xmm0,[a]
    movsd xmm1,[a_sum]
    mov rax,2
    call printf
    lea rdi,[sumfmt]             ; printf format f(x)=
    movsd xmm0,[b]
    movsd xmm1,[b_sum]
    mov rax,2
    call printf

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

segment .data

derivfmt db "derivative of f(%lf)=%lf",0xa,0

segment .text

calc_deriv:	                         
    push rbp                     
    mov rbp,rsp                  

    movsd xmm0,[d_zero]          ; load 0.0 to init variables
    movsd [a_sum],xmm0           ; a_sum=b_sum=0.0
    movsd [b_sum],xmm0
    movsd xmm0,[d_one]           ; load 1.0 to init variables
    movsd [a_exp],xmm0           ; a_exp=b_exp=1.0
    movsd [b_exp],xmm0
    xor rax,rax
    mov qword [term_num],rax     ; term_num=0
.looptop:
    mov rax,qword [term_num]
    mov rbx,qword [degree]
    dec rbx
    cmp rax,rbx                  ; if term_num > degree-1 jmp .done
    jg .doneloop
    mov rax,qword [poly_ptr]
    mov rbx,qword [term_num]
    inc rbx                      ; term_num+1
    movsd xmm0,[rax+rbx*8]       ; load the term_num+1 element of the poly array
    cvtsi2sd xmm5,rbx            ; convert term_num+1 to double float in xmm5
    movsd xmm1,[a_exp]           ; load exponentiated version of a
    mulsd xmm1,xmm0              ; poly[term_num+1]*a_exp
    mulsd xmm1,xmm5              ; (term_num+1)*poly[term_num+1]*a_exp
    movsd [a_term],xmm1          ; a_term = (term_num+1)*poly[term_num+1]*a_exp  
    movsd xmm2,[b_exp]           ; load exponentiated version of b
    mulsd xmm2,xmm0              ; poly[term_num+1]*b_exp
    mulsd xmm2,xmm5              ; (term_num+1)*poly[term_num+1]*b_exp
    movsd [b_term],xmm2          ; b_term=(term_num+1)*poly[term_num+1]*b_exp
    movsd xmm3,[a_sum]
    addsd xmm3,xmm1              ; xmm1 still has a_term in it
    movsd [a_sum],xmm3           ; a_sum=a_sum+a_term
    movsd xmm4,[b_sum]
    addsd xmm4,xmm2              ; xmm2 still has b_term in it
    movsd [b_sum],xmm4           ; b_sum=b_sum+b_term
    mov rax,qword [term_num]
    inc rax
    mov qword [term_num],rax     ; term_num++
    movsd xmm0,[a_exp]
    movsd xmm1,[a]
    mulsd xmm0,xmm1
    movsd [a_exp],xmm0           ; a_exp = a_exp * a
    movsd xmm0,[b_exp]
    movsd xmm1,[b]
    mulsd xmm0,xmm1
    movsd [b_exp],xmm0           ; b_exp = b_exp * b
    jmp .looptop
.doneloop:
    lea rdi,[derivfmt]           ; printf format der f(a)=
    movsd xmm0,[a]
    movsd xmm1,[a_sum]
    mov rax,2
    call printf
    lea rdi,[derivfmt]           ; printf format der f(b)=
    movsd xmm0,[b]
    movsd xmm1,[b_sum]
    mov rax,2
    call printf

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

segment .data

integfmt db "integral of f(x) between %lf and %lf = %lf",0xa,0

segment .text

calc_integ:	                         
    push rbp                     
    mov rbp,rsp                  

    movsd xmm0,[d_zero]          ; load 0.0 to init variables
    movsd [a_sum],xmm0           ; a_sum=b_sum=0.0
    movsd [b_sum],xmm0
    movsd xmm0,[a]               ; 
    movsd [a_exp],xmm0           ; a_exp=a
    movsd xmm0,[b]           
    movsd [b_exp],xmm0           ; b_exp=b
    xor rax,rax
    mov qword [term_num],rax     ; term_num=0
.looptop:
    mov rax,qword [term_num]
    mov rbx,qword [degree]
    cmp rax,rbx                  ; if term_num > degree jmp .doneloop
    jg .doneloop
    mov rax,qword [poly_ptr]
    mov rbx,qword [term_num]
    movsd xmm0,[rax+rbx*8]       ; load the term_num element of the poly array
    inc rbx
    cvtsi2sd xmm5,rbx            ; convert term_num+1 to double float in xmm5
    movsd xmm1,[a_exp]           ; load exponentiated version of a
    mulsd xmm1,xmm0              ; poly[term_num]*a_exp
    divsd xmm1,xmm5              ; poly[term_num]*a_exp/(term_num+1)
    movsd [a_term],xmm1          ; a_term = poly[term_num]*a_exp/(term_num+1) 
    movsd xmm2,[b_exp]           ; load exponentiated version of b
    mulsd xmm2,xmm0              ; poly[term_num]*b_exp
    divsd xmm2,xmm5              ; poly[term_num]*b_exp/(term_num+1)
    movsd [b_term],xmm2          ; b_term=poly[term_num]*b_exp/(term_num+1)
    movsd xmm3,[a_sum]
    addsd xmm3,xmm1              ; xmm1 still has a_term in it
    movsd [a_sum],xmm3           ; a_sum=a_sum+a_term
    movsd xmm4,[b_sum]
    addsd xmm4,xmm2              ; xmm2 still has b_term in it
    movsd [b_sum],xmm4           ; b_sum=b_sum+b_term
    mov rax,qword [term_num]
    inc rax
    mov qword [term_num],rax     ; term_num++
    movsd xmm0,[a_exp]
    movsd xmm1,[a]
    mulsd xmm0,xmm1
    movsd [a_exp],xmm0           ; a_exp = a_exp * a
    movsd xmm0,[b_exp]
    movsd xmm1,[b]
    mulsd xmm0,xmm1
    movsd [b_exp],xmm0           ; b_exp = b_exp * b
    jmp .looptop
.doneloop:
    lea rdi,[integfmt]           ; printf format der f(a)=
    movsd xmm0,[a]
    movsd xmm1,[b]
    movsd xmm2,[b_sum]
    movsd xmm3,[a_sum]
    subsd xmm2,xmm3              ; arg 3 = b_sum-a_sum
    mov rax,3
    call printf

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

