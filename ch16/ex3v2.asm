; Chapter 16 Exercise 3
; Called by ex3v2.c
;
; similar to this c code from v1
; void
; matrix_multiply(long n,float matrix1[][2*N],float matrix2[][2*N],float result[][2*N])
; {
; long i,j,k;
; 
; for (i=0;i<n;i++)
;     for (j=0;j<n;j++)
;     {
;         result[i][j] = 0;
;         for (k=0;k<n;k++)
;         {
;             result[i][j] += (matrix1[i][k]*matrix2[k][j]);
; 	  }
;     }


global matrix_multiply

; matrix_multiply multiplies two n x n matrixes
; Arguments:
; rdi - n
; rsi - pointer to first n x n matrix of floats
; rdx - pointer to second n x n matrix of floats
; rcx - pointer to n x n results matrix of floats
; Variables:
; r8 - i
; r9 - j
; r10 - k
; rax - offset calculations
; r11 - offset calculations

segment .data

zero dd 0.0

segment .text

matrix_multiply:	         
    push rbp                     
    mov rbp,rsp
    
; start of i for loop
    xor r8,r8                    ; i=0
.topiloop:                       ; jump here for each i loop
    cmp r8,rdi                   ; i<n
    jge .endiloop                ; i loop done
    xor r9,r9                    ; j=0
.topjloop:                       ; jump here for each j loop
    cmp r9,rdi                   ; j<n
    jge .endjloop                ; j loop done
    mov rax,rdi                  ; load n
    imul rax,r8                  ; n*i
    add rax,r9                   ; n*i+j
    mov r11,4                    ; load 4
    imul rax,r11                 ; 4*(n*i+j) - byte offset of [i,j]
    movss xmm0,[zero]            ; load 0.0
    movss [rcx+rax],xmm0         ; result[i][j] = 0;
    xor r10,r10                  ; k=0
.topkloop:                       ; jump here for each k loop
    cmp r10,rdi                  ; k<n
    jge .endkloop                ; k loop done
; load matrix1[i][k]
    mov rax,rdi                  ; load n
    imul rax,r8                  ; n*i
    add rax,r10                  ; n*i+k
    mov r11,4                    ; load 4
    imul rax,r11                 ; 4*(n*i+k) - byte offset of [i,k]
    movss xmm0,[rsi+rax]         ; load matrix1[i][k]
; load matrix2[k][j]
    mov rax,rdi                  ; load n
    imul rax,r10                 ; n*k
    add rax,r9                   ; n*k+j
    mov r11,4                    ; load 4
    imul rax,r11                 ; 4*(n*k+j) - byte offset of [k,j]
    movss xmm1,[rdx+rax]         ; load matrix2[k][j]    
    mulss xmm0,xmm1              ; matrix1[i][k]*matrix2[k][j]
; load result[i][j]
    mov rax,rdi                  ; load n
    imul rax,r8                  ; n*i
    add rax,r9                   ; n*i+j
    mov r11,4                    ; load 4
    imul rax,r11                 ; 4*(n*i+j) - byte offset of [i,j]
    movss xmm1,[rcx+rax]         ; result[i][j]
    addss xmm0,xmm1              ; result[i][j]+(matrix1[i][k]*matrix2[k][j])
    movss [rcx+rax],xmm0         ; save new result[i][j]
; end k loop
    inc r10                      ; k++
    jmp .topkloop                ; next k loop
.endkloop:                       ; done with k loop
    inc r9                       ; j++
    jmp .topjloop                ; next j loop
.endjloop:                       ; done with j loop
    inc r8                       ; i++
    jmp .topiloop                ; next i loop
.endiloop:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
