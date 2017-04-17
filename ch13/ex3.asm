; Chapter 13 Exercise 3
; Based on all C version ex3conly.c
; Writing a structure based implementation for positive integers
; that are large enough to hold 50!
; x86-64 nasm linux

; Non-float arguments in these registers:
; rdi, rsi, rdx, rcx, r8 and r9
; rax contains the number of floating point arguments
; xmm0 to xmm7 contain the float arguments
; These registers must be preserved across function calls:
; rbx, rsp, rbp, r12-r15
; rax and rdx are the integer return registers
; xmm0 and xmm1 are the float return registers
; http://www.nasm.us/links/unix64abi 

global bigposint_to_string,set_bigposint,add_bigposint,mult_bigposit
extern sprintf

segment .data

; all of the elements are 64 bits so should be no alignment issues

    struc bigposint              ; Structure for a big positive integer
numqwords resq 1                 ; number of qwords in array that are in use
qwords resq 4                    ; 50! fits in 4 qwords
    endstruc

fmt1 db "%ld",0
fmt2 db "%018ld",0

; bigposint_to_string takes a bigposit and converts it to a null terminated string.
; Arguments:
; rdi - qword pointer to bigposint structure
; rsi - qword pointer to a buffer for the string
; This routine assumes that the buffer has enough space for the output.
; Preserved registers taking the place of variables in the C version:
; rbx bigptr
; r12 buffer
; r13 bufferlocation
; r14 i
; no need to preserve charswritten. use rax which is returned from sprintf.

segment .text

bigposint_to_string:	         
    push rbp                     
    mov rbp,rsp
    
; push saved registers
    push rbx
    push r12
    push r13
    push r14
; save arguments
    mov rbx,rdi
    mov r12,rsi
; bufferlocation = 0
    xor r13,r13
; for (i=(bigptr->numqwords)-1;i>=0;i--)
    mov r14,[rbx+numqwords]
    dec r14                      ; i=(bigptr->numqwords)-1
.topforloop:
    cmp r14,0                    ; i>=0
    jl .doneforloop
; if (i == ((bigptr->numqwords)-1))
    mov r8,[rbx+numqwords]
    dec r8
    cmp r14,r8
    jne .notfirstqword
; charswritten=sprintf(buffer+bufferlocation,"%ld",bigptr->qwords[i]);
    mov rdi,r12
    add rdi,r13                   ; buffer+bufferlocation
    lea rsi,[fmt1]                ; "%ld"
    mov rdx,[rbx+qwords+8*r14]    ; bigptr->qwords[i]
    xor rax,rax
    call sprintf
    jmp .donesprintf
.notfirstqword:
; charswritten=sprintf(buffer+bufferlocation,"%018ld",bigptr->qwords[i]);
    mov rdi,r12
    add rdi,r13                   ; buffer+bufferlocation
    lea rsi,[fmt2]                ; "%018ld"
    mov rdx,[rbx+qwords+8*r14]    ; bigptr->qwords[i]
    xor rax,rax
    call sprintf  
.donesprintf:
; bufferlocation = bufferlocation + charswritten
    add r13,rax                   ; charswritten in rax
; i--
    dec r14
    jmp .topforloop

.doneforloop:    

; restore saved registers
    pop r14
    pop r13
    pop r12
    pop rbx
    
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

; set_bigposint takes a bigposit and sets it to a qword value
; Arguments:
; rdi - qword pointer to bigposint structure
; rsi - qword value

set_bigposint:	         
    push rbp                     
    mov rbp,rsp
; bigptr->numqwords = 1
    mov rax,1
    mov [rdi+numqwords],rax
; bigptr->qwords[0] = value;
    mov [rdi+qwords],rsi
; bigptr->qwords[1] = 0;
    xor rax,rax                  ; rax = 0
    mov [rdi+qwords+8],rax
; bigptr->qwords[2] = 0;
    mov qword [rdi+qwords+16],rax
; bigptr->qwords[3] = 0;    
    mov [rdi+qwords+24],rax
    leave                        ; fix stack
    ret                          ; return

; add_bigposint adds two bigposints and
; sets the target to the new value
; Arguments:
; rdi - qword pointer to target bigposint structure
; rsi - qword pointer to source bigposint structure
; variables:
; r9 tentothe18
; rcx maxi
; r10 i
; r8 x
; r11 extra

add_bigposint:	         
    push rbp                     
    mov rbp,rsp
; tentothe18 = 1000000000000000000
    mov r9,1000000000000000000
; if ((targetptr->numqwords) > (sourceptr->numqwords))
    mov rcx,[rdi+numqwords]
    cmp rcx,[rsi+numqwords]
    jg .usedtargetnumqwords      ; maxi = targetptr->numqwords
    mov rcx,[rsi+numqwords]      ; maxi = sourceptr->numqwords
.usedtargetnumqwords:
; for (i=1;i<=maxi;i++)
    mov r10,1
.forlooptop:
    cmp r10,rcx
    jg .doneforloop
; x = targetptr->qwords[i-1]+sourceptr->qwords[i-1]
    mov r8,[rdi+qwords+8*r10-8]
    add r8,[rsi+qwords+8*r10-8]
; if (i < 4)
    cmp r10,4
    jge .endofthreeifs
; extra = x/tentothe18
    xor rdx,rdx
    mov rax,r8
    div r9
    mov r11,rax
; if (extra > 0)
    cmp r11,0
    jle .endofthreeifs
; x = x - (extra * tentothe18);
    xor rdx,rdx
    mov rax,r11
    mul r9
    sub r8,r9
; targetptr->qwords[i] = targetptr->qwords[i] + extra
    mov rax,[rdi+qwords+8*r10]
    add rax,r11
    mov [rdi+qwords+8*r10],rax
; if ((i+1) > maxi)
    mov rax,r10
    inc rax
    cmp rax,rcx
    jle .endofthreeifs
; targetptr->numqwords = i+1
    mov [rdi+numqwords],rax
.endofthreeifs:
; targetptr->qwords[i-1] = x;
    mov [rdi+qwords+8*r10-8],r8
; i++
    inc r10
    jmp .forlooptop
.doneforloop:    
    xor rax,rax                  ; rc 0
    leave                        ; fix stack
    ret                          ; return

; mult_bigposit takes a bigposint and a qword and
; multiplies them putting the result back in the bigposint
; Arguments:
; rdi - qword pointer to bigposint structure
; rsi - qword small to multiply with
; variables
; rbx = i
; r12 = bigptr
; r13 = small

segment .data

curval: 
    istruc bigposint 
        at numqwords, dq 0
        at qwords, dq 0,0,0,0
    iend

segment .text

mult_bigposit:	         
    push rbp                     
    mov rbp,rsp
    push rbx
    push r12
    push r13
    push r13
    mov r12,rdi                  ; save bigptr
    mov r13,rsi                  ; save small
; set_bigposint(&curval,0);    
    lea rdi,[curval]
    xor rsi,rsi
    call set_bigposint
; add_bigposint(&curval,bigptr);
    lea rdi,[curval]
    mov rsi,r12
    call add_bigposint
; for (i=1;i < small;i++) /* add small-1 times */
    mov rbx,1                    ; i=1
.forlooptop:
    cmp rbx,r13
    jge .forloopdone             ; i < small
; add_bigposint(bigptr,&curval)    
    mov rdi,r12
    lea rsi,[curval]
    call add_bigposint
    inc rbx                      ; i++
    jmp .forlooptop
.forloopdone:
    pop r13
    pop r13
    pop r12
    pop rbx
    leave                        ; fix stack
    ret                          ; return