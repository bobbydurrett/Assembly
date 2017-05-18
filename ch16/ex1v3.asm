; Chapter 16 Exercise 1
; Called by ex1v3.c
;
; void calc_distance(long num_points,float x[],float y[],float z[],float distance[][NUM_POINTS]);
;

global calc_distance

; calc_distance calculates the distance between a bunch of 3D points.
; Arguments:
; rdi - number of points in the arrays
; rsi - pointer to x array of floats
; rdx - pointer to y array
; rcx - pointer to z array
; r8 - pointer to two dimensional distance array - the output
; Variables:
; r9 - i - first loop index
; r10 - j - second loop index
; r11 - distance byte offset
; eax - loading x buffer
; ebx - loading y buffer
; r12d - loading z buffer

segment .bss

; use three buffers to try to improve pipelining

x_buffer resd 4              ; holds four floats for x[i] repeated values
y_buffer resd 4              ; holds four floats for y[i] repeated values
z_buffer resd 4              ; holds four floats for z[i] repeated values

segment .text

calc_distance:	         
    push rbp                     
    mov rbp,rsp
    push rbx
    push r12
    
; for simplicity we will assume that the number of ponts is divisible by 4.
; that way we can just do four floating point operations at a time.

    xor r9,r9                    ; i=0
.nextouter:                      ; top of outer loop
    cmp r9,rdi                   ; i < num_points?
    jge .doneouter               ; Exit outer loop
    xor r10,r10                  ; j=0
.nextinner:                      ; top of inner loop
    cmp r10,rdi                  ; j < num_points?
    jge .doneinner               ; exit inner loop
    
; Calculate 4 distances here

    mov eax,dword [rsi+r9*4]     ; load x[i]
    mov dword [x_buffer],eax     ; save x[i] 4 times
    mov dword [x_buffer+4],eax   ; save x[i] 4 times
    mov dword [x_buffer+8],eax   ; save x[i] 4 times
    mov dword [x_buffer+12],eax  ; save x[i] 4 times
    movups xmm0,[x_buffer]       ; load 4 x[i] values
    movups xmm1,[rsi+r10*4]      ; load 4 x[j] values
    subps xmm0,xmm1              ; do 4 x[i]-x[j] ops
    mulps xmm0,xmm0              ; square difference
    
    mov ebx,dword [rdx+r9*4]     ; load y[i]
    mov dword [y_buffer],ebx     ; save y[i] 4 times
    mov dword [y_buffer+4],ebx   ; save y[i] 4 times
    mov dword [y_buffer+8],ebx   ; save y[i] 4 times
    mov dword [y_buffer+12],ebx  ; save y[i] 4 times   
    movups xmm2,[y_buffer]       ; load 4 y[i] values
    movups xmm3,[rdx+r10*4]      ; load 4 y[j] values
    subps xmm2,xmm3              ; do 4 y[i]-y[j] ops
    mulps xmm2,xmm2              ; square difference
    
    mov r12d,dword [rcx+r9*4]    ; load z[i]
    mov dword [z_buffer],r12d    ; save z[i] 4 times
    mov dword [z_buffer+4],r12d  ; save z[i] 4 times
    mov dword [z_buffer+8],r12d  ; save z[i] 4 times
    mov dword [z_buffer+12],r12d ; save z[i] 4 times   
    movups xmm4,[z_buffer]       ; load 4 z[i] values
    movups xmm5,[rcx+r10*4]      ; load 4 z[j] values
    subps xmm4,xmm5              ; do 4 z[i]-z[j] ops
    mulps xmm4,xmm4              ; square difference
    
    addps xmm0,xmm2              ; add x and y squared diffs
    addps xmm0,xmm4              ; add z diff squared
    
    sqrtps xmm0,xmm0             ; square root of the four sums
    
    mov r11,r9                   ; r11 is now i
    imul r11,rdi                 ; now i*num_points
    add r11,r10                  ; i*num_points+j
    movups [r8+r11*4],xmm0       ; Save the four distances

    add r10,4                    ; advance 4 entries
    jmp .nextinner
.doneinner:
    add r9,1                     ; advance 1 entries
    jmp .nextouter
.doneouter:
    xor rax,rax                  ; return code 0
    pop r12
    pop rbx
    leave                        ; fix stack
    ret                          ; return

