; Chapter 16 Exercise 3 V3
; Called by ex3v3.c
;
; v3 does block matrix multiplication
; it takes the n x n inputs matrix1 and matrix2 and
; splits them into four equal sized matrixes.
; then it uses matrix_multiply from v2 on the quarter matrixes.
; the goal is to find the best value for n where caching makes 
; the block matrix multiplication faster than the reguler
; matrix multiplication.

global matrix_multiply,block_matrix_multiply

; block_matrix_multiply multiplies two n x n matrixes
; using block matrix multiplication
; Arguments:
; rdi - n
; rsi - pointer to first n x n matrix of floats
; rdx - pointer to second n x n matrix of floats
; rcx - pointer to n x n results matrix of floats
; Variables:

segment .data

n dq 0                           ; saved n
m1ptr dq 0                       ; pointer to first matrix
m2ptr dq 0                       ; pointer to second matrix
resptr dq 0                      ; pointer to results matrix
ndiv2 dq 0                       ; n/2
qm1ptr dq 0                      ; pointer to quarter matrix 1
qm2ptr dq 0                      ; pointer to quarter matrix 2
qrtempptr dq 0                   ; pointer to temp quarter results matrix
qrpermptr dq 0                   ; pointer to perm quarter results matrix

segment .text

block_matrix_multiply:	         
    push rbp                     
    mov rbp,rsp
; save arguments in data segment
    mov qword [n],rdi
    mov qword [m1ptr],rsi
    mov qword [m2ptr],rdx
    mov qword [resptr],rcx
; calculate n/2 and save
    xor rdx,rdx                  ; clear rdx for division
    mov rax,qword [n]            ; load n
    mov r8,2                     ; load 2
    idiv r8                      ; divide by 2
    mov qword [ndiv2],rax        ; save n/2
; allocate the needed quarter matrixes
    mov rdi,qword [ndiv2]        ; matrix size n/2
    call matrix_alloc
    mov qword [qm1ptr],rax       ; save pointer to new matrix
    mov rdi,qword [ndiv2]        ; matrix size n/2
    call matrix_alloc
    mov qword [qm2ptr],rax       ; save pointer to new matrix
    mov rdi,qword [ndiv2]        ; matrix size n/2
    call matrix_alloc
    mov qword [qrtempptr],rax    ; save pointer to new matrix
    mov rdi,qword [ndiv2]        ; matrix size n/2
    call matrix_alloc
    mov qword [qrpermptr],rax    ; save pointer to new matrix
; calculate top left matrix in final result
;
; top left quarter matrix 1 times
; top left quarter matrix 2
    mov rdi,qword [m1ptr]
    call top_left
    mov qword [qm1ptr], rax      ; store first quarter matrix
    mov rdi,qword [m2ptr]
    call top_left
    mov qword [qm2ptr], rax      ; store second quarter matrix
; multiply quarter matrixes
    mov rdi,qword [ndiv2]
    mov rsi,qword [qm1ptr]
    mov rdx,qword [qm2ptr]
    mov rcx,qword [qrpermptr]
    call matrix_multiply
; top right quarter matrix 1 times
; bottom left quarter matrix 2
    mov rdi,qword [m1ptr]
    call top_right
    mov qword [qm1ptr], rax      ; store first quarter matrix
    mov rdi,qword [m2ptr]
    call bottom_left
    mov qword [qm2ptr], rax      ; store second quarter matrix
; multiply quarter matrixes
    mov rdi,qword [ndiv2]
    mov rsi,qword [qm1ptr]
    mov rdx,qword [qm2ptr]
    mov rcx,qword [qrtempptr]
    call matrix_multiply    
; add the two products
    mov rdi,qword [ndiv2]
    mov rsi,qword [qrpermptr]
    mov rdx,qword [qrtempptr]
    call matrix_add
; save quarter matrix result top left final result
    mov rdi,qword [ndiv2]
    mov rsi,qword [qrpermptr]
    mov rdx,qword [resptr]
    call save_top_left
; calculate bottom left matrix in final result
;
; bottom left quarter matrix 1 times
; top left quarter matrix 2
    mov rdi,qword [m1ptr]
    call bottom_left
    mov qword [qm1ptr], rax      ; store first quarter matrix
    mov rdi,qword [m2ptr]
    call top_left
    mov qword [qm2ptr], rax      ; store second quarter matrix
; multiply quarter matrixes
    mov rdi,qword [ndiv2]
    mov rsi,qword [qm1ptr]
    mov rdx,qword [qm2ptr]
    mov rcx,qword [qrpermptr]
    call matrix_multiply
; bottom right quarter matrix 1 times
; bottom left quarter matrix 2
    mov rdi,qword [m1ptr]
    call bottom_right
    mov qword [qm1ptr], rax      ; store first quarter matrix
    mov rdi,qword [m2ptr]
    call bottom_left
    mov qword [qm2ptr], rax      ; store second quarter matrix
; multiply quarter matrixes
    mov rdi,qword [ndiv2]
    mov rsi,qword [qm1ptr]
    mov rdx,qword [qm2ptr]
    mov rcx,qword [qrtempptr]
    call matrix_multiply    
; add the two products
    mov rdi,qword [ndiv2]
    mov rsi,qword [qrpermptr]
    mov rdx,qword [qrtempptr]
    call matrix_add
; save quarter matrix result bottom left final result
    mov rdi,qword [ndiv2]
    mov rsi,qword [qrpermptr]
    mov rdx,qword [resptr]
    call save_bottom_left    
; calculate top right matrix in final result
;
; top left quarter matrix 1 times
; top right quarter matrix 2
    mov rdi,qword [m1ptr]
    call top_left
    mov qword [qm1ptr], rax      ; store first quarter matrix
    mov rdi,qword [m2ptr]
    call top_right
    mov qword [qm2ptr], rax      ; store second quarter matrix
; multiply quarter matrixes
    mov rdi,qword [ndiv2]
    mov rsi,qword [qm1ptr]
    mov rdx,qword [qm2ptr]
    mov rcx,qword [qrpermptr]
    call matrix_multiply
; top right quarter matrix 1 times
; bottom right quarter matrix 2
    mov rdi,qword [m1ptr]
    call top_right
    mov qword [qm1ptr], rax      ; store first quarter matrix
    mov rdi,qword [m2ptr]
    call bottom_right
    mov qword [qm2ptr], rax      ; store second quarter matrix
; multiply quarter matrixes
    mov rdi,qword [ndiv2]
    mov rsi,qword [qm1ptr]
    mov rdx,qword [qm2ptr]
    mov rcx,qword [qrtempptr]
    call matrix_multiply    
; add the two products
    mov rdi,qword [ndiv2]
    mov rsi,qword [qrpermptr]
    mov rdx,qword [qrtempptr]
    call matrix_add
; save quarter matrix result top right final result
    mov rdi,qword [ndiv2]
    mov rsi,qword [qrpermptr]
    mov rdx,qword [resptr]
    call save_top_right    
; calculate bottom right matrix in final result
;
; bottom left quarter matrix 1 times
; top right quarter matrix 2
    mov rdi,qword [m1ptr]
    call bottom_left
    mov qword [qm1ptr], rax      ; store first quarter matrix
    mov rdi,qword [m2ptr]
    call top_right
    mov qword [qm2ptr], rax      ; store second quarter matrix
; multiply quarter matrixes
    mov rdi,qword [ndiv2]
    mov rsi,qword [qm1ptr]
    mov rdx,qword [qm2ptr]
    mov rcx,qword [qrpermptr]
    call matrix_multiply
; bottom right quarter matrix 1 times
; bottom right quarter matrix 2
    mov rdi,qword [m1ptr]
    call bottom_right
    mov qword [qm1ptr], rax      ; store first quarter matrix
    mov rdi,qword [m2ptr]
    call bottom_right
    mov qword [qm2ptr], rax      ; store second quarter matrix
; multiply quarter matrixes
    mov rdi,qword [ndiv2]
    mov rsi,qword [qm1ptr]
    mov rdx,qword [qm2ptr]
    mov rcx,qword [qrtempptr]
    call matrix_multiply    
; add the two products
    mov rdi,qword [ndiv2]
    mov rsi,qword [qrpermptr]
    mov rdx,qword [qrtempptr]
    call matrix_add
; save quarter matrix result bottom right final result
    mov rdi,qword [ndiv2]
    mov rsi,qword [qrpermptr]
    mov rdx,qword [resptr]
    call save_bottom_right    

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

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
