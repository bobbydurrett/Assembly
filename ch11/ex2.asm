; ch 11 ex 2 - area of a polygon

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
global get_num_vertexes                      
global allocate_arrays  
global get_vertexes
global do_sum
extern scanf
extern malloc
extern printf

segment .data

n dq 0                           ; number of vertexes or n in the sum
x dq 0                           ; pointer to x array
y dq 0                           ; pointer to y array
area dq 0.0                      ; result = area
pafmt db "area = %lf",0xa,0

segment .text

main:	                         
    push rbp                     
    mov rbp,rsp                  
    call get_num_vertexes        ; number of points
    call allocate_arrays         ; allocate memory for the two arrays
    call get_vertexes            ; read points x,y
    call do_sum                  ; calculate area
    lea rdi,[pafmt]
    mov rax,1
    call printf
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
; get_num_vertexes - read using scanf
; load number of vertexes into variable n
segment .data
numvertfmt db "%ld",0            ; read long number
segment .text
get_num_vertexes:	                         
    push rbp                     
    mov rbp,rsp      
    lea rdi,[numvertfmt]         ; read a number
    lea rsi,[n]                  ; ptr to num vertexes
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line, x in xmm0
    leave                        ; fix stack
    ret                          ; return
; allocate_arrays - use malloc to allocate the x and y arrays
; size is (n+2) * 8 bytes
segment .text
allocate_arrays:	                         
    push rbp                     
    mov rbp,rsp    
    mov rdi,[n]                  ; load num vertexes
    inc rdi		         ; add 2
    inc rdi
    imul rdi,8                   ; convert to bytes (8 bytes for double)
    push rdi			 ; save rdi
    push rdi
    call malloc                  ; allocate memory
    mov [x],rax                  ; store pointer to x array
    pop rdi			 ; restore rdi
    pop rdi
    call malloc                  ; allocate memory
    mov [y],rax                  ; store pointer to y array
    leave                        ; fix stack
    ret                          ; return
; get_vertexes - read using scanf
; x and y coordinates of n points
; n+1th point is same as point 1 (index 0)
; n+2 point is 0,0
; rbx is current index into array (times 8 bytes)
; r12 is pointer to x
; r13 is pointer to y
segment .data
vertfmt db "%lf %lf",0           ; read two doubles
zerod dq 0.0                     ; zero double
segment .text
get_vertexes:	                         
    push rbp                     
    mov rbp,rsp      
    xor rbx,rbx                  ; point 0
    mov r12,[x]                  ; load x array pointer
    mov r13,[y]                  ; load y array pointer
.nextpoint:
    cmp rbx,[n]                  ; check if we are past last point
    jge .donereading
    lea rdi,[vertfmt]            ; read x and y coordinates of point
    lea rsi,[r12+rbx*8]          ; x array entry
    lea rdx,[r13+rbx*8]          ; y array entry
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
    inc rbx                      ; next array element
    jmp .nextpoint               ; top of loop
.donereading:
    mov rbx,[n]                  ; n+1th element
    movsd xmm0,[r12]             ; x[n]=x[0]
    movsd [r12+rbx*8],xmm0       ; 
    movsd xmm0,[r13]             ; y[n]=y[0]
    movsd [r13+rbx*8],xmm0       ; 
    inc rbx                      ; n+2th element
    movsd xmm0,[zerod]
    movsd [r12+rbx*8],xmm0       ; x[n+1]=0
    movsd [r13+rbx*8],xmm0       ; y[n+1]=0
    leave                        ; fix stack
    ret                          ; return
; do_sum
; calculate area of the polygon using
; xxxpd instructions to work on 2 doubles at a time.
; register   value
; rbx        index into x and y arrays
; r12        x array pointer
; r13        y array pointer
; r14        n-1 - number of vertexes minus 1
; xmm0        
; xmm1
; xmm2       two doubles containing running sums
; xmm3       way to avoid alignment issues

segment .data
twozeros dq 0.0,0.0
sum1 dq 0.0
sum2 dq 0.0
twod dq 2.0
segment .text
do_sum:	                         
    push rbp                     
    mov rbp,rsp      
    xor rbx,rbx                  ; index = 0
    mov r12,[x]                  ; load x array pointer
    mov r13,[y]                  ; load y array pointer
    mov r14,[n]                  ; load n
    dec r14                      ; n-1
    movupd xmm2,[twozeros]       ; running sums are 0.0,0.0
.looptop:
    cmp rbx,r14                  ; index > n-1
    jg .finishsum                ; done looping
    movupd xmm0,[r12+rbx*8]      ; load 2 x+index entries
    movupd xmm3,[r13+rbx*8+8]    ; mul by 2 y+index+1 entries
    mulpd xmm0,xmm3              ; mul by 2 y+index+1 entries
    movupd xmm1,[r12+rbx*8+8]    ; load 2 x+index+1 entries
    movupd xmm3,[r13+rbx]        ; mul by 2 y+index entries
    mulpd xmm1,xmm3              ; mul by 2 y+index entries
    subpd xmm0,xmm1              ; sub x0y1 entries by x1y0
    addpd xmm2,xmm0              ; add the two values to running sum
    inc rbx                      ; rbx=rbx+2
    inc rbx
    jmp .looptop
.finishsum:
    movupd [sum1],xmm2           ; save two doubles that are running sums
    movsd xmm0,[sum1]            ; load one sum
    addsd xmm0,[sum2]            ; add second sum
    divsd xmm0,[twod]            ; divide by 2.0
    movsd [area],xmm0            ; save area value
    leave                        ; fix stack
    ret                          ; return
