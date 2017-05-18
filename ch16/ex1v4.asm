; Chapter 16 Exercise 1
; Called by ex1v3.c
;
; void calc_distance(long num_points,float x[],float y[],float z[],float distance[][NUM_POINTS]);
; switch to avx

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

x_buffer resd 8                  ; holds 8 floats for x[i] repeated values
y_buffer resd 8                  ; holds 8 floats for y[i] repeated values
z_buffer resd 8                  ; holds 8 floats for z[i] repeated values

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
    
; Calculate 8 distances here

    mov eax,dword [rsi+r9*4]     ; load x[i]
    mov dword [x_buffer],eax     ; save x[i] 8 times
    mov dword [x_buffer+4],eax   ; 
    mov dword [x_buffer+8],eax   ; 
    mov dword [x_buffer+12],eax  ; 
    mov dword [x_buffer+16],eax  ; 
    mov dword [x_buffer+20],eax  ; 
    mov dword [x_buffer+24],eax  ; 
    mov dword [x_buffer+28],eax  ; 
    vmovups ymm0,[x_buffer]      ; load 8 x[i] values
    vmovups ymm1,[rsi+r10*4]     ; load 8 x[j] values
    vsubps ymm0,ymm1             ; do 8 x[i]-x[j] ops
    vmulps ymm0,ymm0             ; square difference
    
    mov ebx,dword [rdx+r9*4]     ; load y[i]
    mov dword [y_buffer],ebx     ; save y[i] 8 times
    mov dword [y_buffer+4],ebx   ; 
    mov dword [y_buffer+8],ebx   ; 
    mov dword [y_buffer+12],ebx  ;    
    mov dword [y_buffer+16],ebx  ;    
    mov dword [y_buffer+20],ebx  ;    
    mov dword [y_buffer+24],ebx  ;    
    mov dword [y_buffer+28],ebx  ;    
    vmovups ymm2,[y_buffer]      ; load 8 y[i] values
    vmovups ymm3,[rdx+r10*4]     ; load 8 y[j] values
    vsubps ymm2,ymm3             ; do 8 y[i]-y[j] ops
    vmulps ymm2,ymm2             ; square difference
    
    mov r12d,dword [rcx+r9*4]    ; load z[i]
    mov dword [z_buffer],r12d    ; save z[i] 8 times
    mov dword [z_buffer+4],r12d  ; 
    mov dword [z_buffer+8],r12d  ; 
    mov dword [z_buffer+12],r12d ;    
    mov dword [z_buffer+16],r12d ;    
    mov dword [z_buffer+20],r12d ;    
    mov dword [z_buffer+24],r12d ;    
    mov dword [z_buffer+28],r12d ;    
    vmovups ymm4,[z_buffer]      ; load 8 z[i] values
    vmovups ymm5,[rcx+r10*4]     ; load 8 z[j] values
    vsubps ymm4,ymm5             ; do 8 z[i]-z[j] ops
    vmulps ymm4,ymm4             ; square difference
    
    vaddps ymm0,ymm2             ; add x and y squared diffs
    vaddps ymm0,ymm4             ; add z diff squared
    
    vsqrtps ymm0,ymm0            ; square root of the four sums
    
    mov r11,r9                   ; r11 is now i
    imul r11,rdi                 ; now i*num_points
    add r11,r10                  ; i*num_points+j
    vmovups [r8+r11*4],ymm0      ; Save the four distances

    add r10,8                    ; advance 8 entries
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

