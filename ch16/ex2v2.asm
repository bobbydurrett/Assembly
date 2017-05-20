; Chapter 16 Exercise 2
; Called by ex2v2.c
;
; exterm void calc_mv(long n,float matrix[][4],float vector[],float mv[]);
;

global calc_mv

; calc_mv multiplies an n x 4 matrix by a 4 element vector
; Arguments:
; rdi - n
; rsi - pointer to n x 4 matrix of floats
; rdx - pointer to vector (4 floats)
; rcx - pointer to mv array - n elements
; Variables:
; r8 - index into matrix - i
; r9 - byte offset into matrix
; xmm0 - vector - 4 floats

segment .bss

float_buffer resd 4              ; holds four floats

segment .text

calc_mv:	         
    push rbp                     
    mov rbp,rsp
    
    xor r8,r8                    ; i=0
    movups xmm0,[rdx]            ; load vector
.nextrow:
    cmp r8,rdi
    jge .doneloop
    mov r9,16                    ; 16 bytes per matrix row, 4 32 bit floats
    imul r9,r8                   ; get byte offset
    movups xmm1,[rsi+r9]         ; load 4 matrix values
    mulps xmm1,xmm0              ; multiply vector times matrix row
    movups [float_buffer],xmm1   ; save four products
    addss xmm1,[float_buffer+4]  ; add second product to first
    addss xmm1,[float_buffer+8]  ; add third product
    addss xmm1,[float_buffer+12] ; add fourth product
    movss [rcx+r8*4],xmm1        ; save element of mv
    inc r8
    jmp .nextrow
        
.doneloop:    
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

