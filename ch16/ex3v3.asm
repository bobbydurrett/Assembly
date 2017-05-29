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

global block_matrix_multiply
global matrix_multiply
global bottom_left
global bottom_right
global top_left
global top_right
global matrix_add
global matrix_alloc
global save_bottom_left
global save_bottom_right
global save_top_left
global save_top_right
global free
global malloc

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
    mov rsi,qword [qm1ptr]
    call top_left
    mov rdi,qword [m2ptr]
    mov rsi,qword [qm2ptr]
    call top_left
; multiply quarter matrixes
    mov rdi,qword [ndiv2]
    mov rsi,qword [qm1ptr]
    mov rdx,qword [qm2ptr]
    mov rcx,qword [qrpermptr]
    call matrix_multiply
; top right quarter matrix 1 times
; bottom left quarter matrix 2
    mov rdi,qword [m1ptr]
    mov rsi,qword [qm1ptr]
    call top_right
    mov rdi,qword [m2ptr]
    mov rsi,qword [qm2ptr]
    call bottom_left
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
    mov rdi,qword [resptr]
    mov rsi,qword [qrpermptr]
    call save_top_left
; calculate bottom left matrix in final result
;
; bottom left quarter matrix 1 times
; top left quarter matrix 2
    mov rdi,qword [m1ptr]
    mov rsi,qword [qm1ptr]
    call bottom_left
    mov rdi,qword [m2ptr]
    mov rsi,qword [qm2ptr]
    call top_left
; multiply quarter matrixes
    mov rdi,qword [ndiv2]
    mov rsi,qword [qm1ptr]
    mov rdx,qword [qm2ptr]
    mov rcx,qword [qrpermptr]
    call matrix_multiply
; bottom right quarter matrix 1 times
; bottom left quarter matrix 2
    mov rdi,qword [m1ptr]
    mov rsi,qword [qm1ptr]
    call bottom_right
    mov rdi,qword [m2ptr]
    mov rsi,qword [qm2ptr]
    call bottom_left
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
    mov rdi,qword [resptr]
    mov rsi,qword [qrpermptr]
    call save_bottom_left    
; calculate top right matrix in final result
;
; top left quarter matrix 1 times
; top right quarter matrix 2
    mov rdi,qword [m1ptr]
    mov rsi,qword [qm1ptr]
    call top_left
    mov rdi,qword [m2ptr]
    mov rsi,qword [qm2ptr]
    call top_right
; multiply quarter matrixes
    mov rdi,qword [ndiv2]
    mov rsi,qword [qm1ptr]
    mov rdx,qword [qm2ptr]
    mov rcx,qword [qrpermptr]
    call matrix_multiply
; top right quarter matrix 1 times
; bottom right quarter matrix 2
    mov rdi,qword [m1ptr]
    mov rsi,qword [qm1ptr]
    call top_right
    mov rdi,qword [m2ptr]
    mov rsi,qword [qm2ptr]
    call bottom_right
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
    mov rdi,qword [resptr]
    mov rsi,qword [qrpermptr]
    call save_top_right    
; calculate bottom right matrix in final result
;
; bottom left quarter matrix 1 times
; top right quarter matrix 2
    mov rdi,qword [m1ptr]
    mov rsi,qword [qm1ptr]
    call bottom_left
    mov rdi,qword [m2ptr]
    mov rsi,qword [qm2ptr]
    call top_right
; multiply quarter matrixes
    mov rdi,qword [ndiv2]
    mov rsi,qword [qm1ptr]
    mov rdx,qword [qm2ptr]
    mov rcx,qword [qrpermptr]
    call matrix_multiply
; bottom right quarter matrix 1 times
; bottom right quarter matrix 2
    mov rdi,qword [m1ptr]
    mov rsi,qword [qm1ptr]
    call bottom_right
    mov rdi,qword [m2ptr]
    mov rsi,qword [qm2ptr]
    call bottom_right
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
    mov rdi,qword [resptr]
    mov rsi,qword [qrpermptr]
    call save_bottom_right
; free malloced quarter matrixes
    mov rdi,[qm1ptr]
    call free
    mov rdi,[qm2ptr]
    call free
    mov rdi,[qrtempptr]
    call free
    mov rdi,[qrpermptr]
    call free
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

; bottom_left - copies the bottom left quarter of the main matrix
; into an array large enough to hold it.
; Arguments:
; rdi - pointer to full sized matrix
; rsi - pointer to quarter size target array
; Variables:
; r8 - i
; r9 - j
; rax - offset calculations
; r10 - offset calculations

bottom_left:	         
    push rbp                     
    mov rbp,rsp
; in main array i ranges from 0 to n-1 and so does j
; bottom left i ranges from n/2 to n-1
; j ranges from 0 to n/2-1
    mov r8,qword [ndiv2]         ; i = n/2
.topiloop:                       ; go here each loop
    cmp r8,qword [n]             ; i < n
    jge .doneiloop               ; exit loop
    xor r9,r9                    ; j=0
.topjloop:
    cmp r9,qword [ndiv2]         ; j < n/2
    jge .donejloop
; calculate offset into main array
    mov rax,qword [n]            ; load n
    imul rax,r8                  ; n*i
    add rax,r9                   ; n*i+j
    movss xmm0,[rdi+4*rax]       ; load float from main array
; calculate offset into quarter array
    mov rax,r8
    sub rax,qword [ndiv2]        ; i-n/2
    mov r10,qword [ndiv2]
    imul rax,r10                 ; n/2*(i-n/2)
    add rax,r9                   ; n/2*(i-n/2)+j
    movss [rdi+4*rax],xmm0       ; store float into quarter array
; next loop j
    inc r9
    jmp .topjloop
; next loop i
.donejloop:
    inc r8
    jmp .topiloop
.doneiloop:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

; bottom_right - copies the bottom right quarter of the main matrix
; into an array large enough to hold it.
; Arguments:
; rdi - pointer to full sized matrix
; rsi - pointer to quarter size target array
; Variables:
; r8 - i
; r9 - j
; rax - offset calculations
; r10 - offset calculations

bottom_right:	         
    push rbp                     
    mov rbp,rsp
; in main array i ranges from 0 to n-1 and so does j
; bottom right i ranges from n/2 to n-1
; j ranges from n/2 to n-1
    mov r8,qword [ndiv2]         ; i = n/2
.topiloop:                       ; go here each loop
    cmp r8,qword [n]             ; i < n
    jge .doneiloop               ; exit loop
    mov r9,qword [ndiv2]         ; j = n/2
.topjloop:
    cmp r9,qword [n]             ; j < n
    jge .donejloop
; calculate offset into main array
    mov rax,qword [n]            ; load n
    imul rax,r8                  ; n*i
    add rax,r9                   ; n*i+j
    movss xmm0,[rdi+4*rax]       ; load float from main array
; calculate offset into quarter array
    mov rax,r8
    sub rax,qword [ndiv2]        ; i-n/2
    mov r10,qword [ndiv2]
    imul rax,r10                 ; n/2*(i-n/2)
    add rax,r9                   ; n/2*(i-n/2)+j
    sub rax,qword [ndiv2]        ; n/2*(i-n/2)+j-n/2
    movss [rdi+4*rax],xmm0       ; store float into quarter array
; next loop j
    inc r9
    jmp .topjloop
; next loop i
.donejloop:
    inc r8
    jmp .topiloop
.doneiloop:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

; top_left - copies the top left quarter of the main matrix
; into an array large enough to hold it.
; Arguments:
; rdi - pointer to full sized matrix
; rsi - pointer to quarter size target array
; Variables:
; r8 - i
; r9 - j
; rax - offset calculations
; r10 - offset calculations

top_left:	         
    push rbp                     
    mov rbp,rsp
; in main array i ranges from 0 to n-1 and so does j
; bottom right i ranges from 0 to n/2-1 and so does j
    xor r8,r8                    ; i = 0
.topiloop:                       ; go here each loop
    cmp r8,qword [ndiv2]         ; i < n/2
    jge .doneiloop               ; exit loop
    xor r9.r9                    ; j = 0
.topjloop:
    cmp r9,qword [ndiv2]         ; j < n/2
    jge .donejloop
; calculate offset into main array
    mov rax,qword [n]            ; load n
    imul rax,r8                  ; n*i
    add rax,r9                   ; n*i+j
    movss xmm0,[rdi+4*rax]       ; load float from main array
; calculate offset into quarter array
    mov rax,r8                   ; load i
    mov r10,qword [ndiv2]
    imul rax,r10                 ; n/2*(i)
    add rax,r9                   ; n/2*(i)+j
    movss [rdi+4*rax],xmm0       ; store float into quarter array
; next loop j
    inc r9
    jmp .topjloop
; next loop i
.donejloop:
    inc r8
    jmp .topiloop
.doneiloop:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
    
; top_right - copies the top right quarter of the main matrix
; into an array large enough to hold it.
; Arguments:
; rdi - pointer to full sized matrix
; rsi - pointer to quarter size target array
; Variables:
; r8 - i
; r9 - j
; rax - offset calculations
; r10 - offset calculations

top_right:	         
    push rbp                     
    mov rbp,rsp
; in main array i ranges from 0 to n-1 and so does j
; top right i ranges from 0 to n/2-1
; j ranges from n/2 to n-1
    xor r8,r8                    ; i = 0
.topiloop:                       ; go here each loop
    cmp r8,qword [ndiv2]         ; i < n/2
    jge .doneiloop               ; exit loop
    mov r9,qword [ndiv2]         ; j = n/2
.topjloop:
    cmp r9,qword [n]             ; j < n
    jge .donejloop
; calculate offset into main array
    mov rax,qword [n]            ; load n
    imul rax,r8                  ; n*i
    add rax,r9                   ; n*i+j
    movss xmm0,[rdi+4*rax]       ; load float from main array
; calculate offset into quarter array
    mov rax,r8
    mov r10,qword [ndiv2]
    imul rax,r10                 ; n/2*(i)
    add rax,r9                   ; n/2*(i)+j
    sub rax,qword [ndiv2]        ; n/2*(i)+j-n/2
    movss [rdi+4*rax],xmm0       ; store float into quarter array
; next loop j
    inc r9
    jmp .topjloop
; next loop i
.donejloop:
    inc r8
    jmp .topiloop
.doneiloop:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
    
;    mov rdi,qword [ndiv2]
;    mov rsi,qword [qrpermptr]
;    mov rdx,qword [qrtempptr]
;    call matrix_add

; matrix_add - copies the top right quarter of the main matrix
; into an array large enough to hold it.
; Arguments:
; rdi - number of elements in quarter array = n/2
; rsi - pointer to quarter size target array
; rdx - pointer to quarter size source array
; Variables:
; r8 - i
; r9 - j
; rax - offset calculations
; r10 - offset calculations

matrix_add:	         
    push rbp                     
    mov rbp,rsp
    xor r8,r8                    ; i=0
.topiloop:                       ; loop starts here
    cmp r8,rdi                   ; i < n/2
    jge .doneiloop               ; end loop
    xor r9,r9                    ; j=0
.topjloop:
    cmp r9,rdi                   ; j < n/2
    jge .donejloop
; calculate array offset
    mov rax,r8                   ; i
    imul rax,rdi                 ; i*n/2
    add rax,r9                   ; i*n/2+j
    movss xmm0,[rsi+4*rax]       ; load target element
    movss xmm1,[rdx+4*rax]       ; load source element
    addss xmm0,xmm1              ; add
    mov [rsi+4*rax],xmm0         ; store sum in target
; next loop j
    inc r9
    jmp .topjloop
; next loop i
.donejloop:
    inc r8
    jmp .topiloop
.doneiloop:    
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
    
; matrix_alloc allocates a chunk of memory
; large enough to hold an n x n array of floats
; Arguments:
; rdi - n
; Returns:
; rax - pointer to n x n array of floats

matrix_alloc:	         
    push rbp                     
    mov rbp,rsp
    imul rdi,rdi                 ; n * n
    mov rax,4                    ; 4 bytes per float
    imul rdi,rax                 ; 4 * (n * n)
    call malloc
    leave                        ; fix stack
    ret                          ; return - rax = pointer to allocated bytes

;    mov rdi,qword [ndiv2]
;    mov rsi,qword [qrpermptr]
;    mov rdx,qword [resptr]
;    call save_bottom_left  

; save_bottom_left - copies a quarter matrix to the bottom left
; corner of the larger matrix
; Arguments:
; rdi - pointer to full size target array
; rsi - pointer to quarter size source array
; Variables:
; r8 - i
; r9 - j
; rax - offset calculations
; r10 - offset calculations

save_bottom_left:	         
    push rbp                     
    mov rbp,rsp
; in main array i ranges from 0 to n-1 and so does j
; bottom left i ranges from n/2 to n-1
; j ranges from 0 to n/2-1
    mov r8,qword [ndiv2]         ; i = n/2
.topiloop:                       ; go here each loop
    cmp r8,qword [n]             ; i < n
    jge .doneiloop               ; exit loop
    xor r9,r9                    ; j=0
.topjloop:
    cmp r9,qword [ndiv2]         ; j < n/2
    jge .donejloop
; calculate offset into quarter array
    mov rax,r8
    sub rax,qword [ndiv2]        ; i-n/2
    mov r10,qword [ndiv2]
    imul rax,r10                 ; n/2*(i-n/2)
    add rax,r9                   ; n/2*(i-n/2)+j
    movss xmm0,[rdi+4*rax]       ; load from quarter array
; calculate offset into main array
    mov rax,qword [n]            ; load n
    imul rax,r8                  ; n*i
    add rax,r9                   ; n*i+j
    movss [rdi+4*rax],xmm0       ; store in big array
; next loop j
    inc r9
    jmp .topjloop
; next loop i
.donejloop:
    inc r8
    jmp .topiloop
.doneiloop:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
 
; save_bottom_right - copies the bottom right quarter of the main matrix
; into an array large enough to hold it.
; Arguments:
; rdi - pointer to full sized matrix
; rsi - pointer to quarter size target array
; Variables:
; r8 - i
; r9 - j
; rax - offset calculations
; r10 - offset calculations

save_bottom_right:	         
    push rbp                     
    mov rbp,rsp
; in main array i ranges from 0 to n-1 and so does j
; bottom right i ranges from n/2 to n-1
; j ranges from n/2 to n-1
    mov r8,qword [ndiv2]         ; i = n/2
.topiloop:                       ; go here each loop
    cmp r8,qword [n]             ; i < n
    jge .doneiloop               ; exit loop
    mov r9,qword [ndiv2]         ; j = n/2
.topjloop:
    cmp r9,qword [n]             ; j < n
    jge .donejloop
; calculate offset into quarter array
    mov rax,r8
    sub rax,qword [ndiv2]        ; i-n/2
    mov r10,qword [ndiv2]
    imul rax,r10                 ; n/2*(i-n/2)
    add rax,r9                   ; n/2*(i-n/2)+j
    sub rax,qword [ndiv2]        ; n/2*(i-n/2)+j-n/2
    movss xmm0,[rdi+4*rax]       
; calculate offset into main array
    mov rax,qword [n]            ; load n
    imul rax,r8                  ; n*i
    add rax,r9                   ; n*i+j
    movss [rdi+4*rax],xmm0
; next loop j
    inc r9
    jmp .topjloop
; next loop i
.donejloop:
    inc r8
    jmp .topiloop
.doneiloop:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

; save_top_left - copies the top left quarter of the main matrix
; into an array large enough to hold it.
; Arguments:
; rdi - pointer to full sized matrix
; rsi - pointer to quarter size target array
; Variables:
; r8 - i
; r9 - j
; rax - offset calculations
; r10 - offset calculations

save_top_left:	         
    push rbp                     
    mov rbp,rsp
; in main array i ranges from 0 to n-1 and so does j
; bottom right i ranges from 0 to n/2-1 and so does j
    xor r8,r8                    ; i = 0
.topiloop:                       ; go here each loop
    cmp r8,qword [ndiv2]         ; i < n/2
    jge .doneiloop               ; exit loop
    xor r9.r9                    ; j = 0
.topjloop:
    cmp r9,qword [ndiv2]         ; j < n/2
    jge .donejloop
; calculate offset into quarter array
    mov rax,r8                   ; load i
    mov r10,qword [ndiv2]
    imul rax,r10                 ; n/2*(i)
    add rax,r9                   ; n/2*(i)+j
    movss xmm0,[rdi+4*rax]
; calculate offset into main array
    mov rax,qword [n]            ; load n
    imul rax,r8                  ; n*i
    add rax,r9                   ; n*i+j
    movss [rdi+4*rax],xmm0
; next loop j
    inc r9
    jmp .topjloop
; next loop i
.donejloop:
    inc r8
    jmp .topiloop
.doneiloop:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
    
; save_top_right - copies the top right quarter of the main matrix
; into an array large enough to hold it.
; Arguments:
; rdi - pointer to full sized matrix
; rsi - pointer to quarter size target array
; Variables:
; r8 - i
; r9 - j
; rax - offset calculations
; r10 - offset calculations

save_top_right:	         
    push rbp                     
    mov rbp,rsp
; in main array i ranges from 0 to n-1 and so does j
; top right i ranges from 0 to n/2-1
; j ranges from n/2 to n-1
    xor r8,r8                    ; i = 0
.topiloop:                       ; go here each loop
    cmp r8,qword [ndiv2]         ; i < n/2
    jge .doneiloop               ; exit loop
    mov r9,qword [ndiv2]         ; j = n/2
.topjloop:
    cmp r9,qword [n]             ; j < n
    jge .donejloop
; calculate offset into quarter array
    mov rax,r8
    mov r10,qword [ndiv2]
    imul rax,r10                 ; n/2*(i)
    add rax,r9                   ; n/2*(i)+j
    sub rax,qword [ndiv2]        ; n/2*(i)+j-n/2
    movss xmm0,[rdi+4*rax]
; calculate offset into main array
    mov rax,qword [n]            ; load n
    imul rax,r8                  ; n*i
    add rax,r9                   ; n*i+j
    movss [rdi+4*rax],xmm0 
; next loop j
    inc r9
    jmp .topjloop
; next loop i
.donejloop:
    inc r8
    jmp .topiloop
.doneiloop:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
    