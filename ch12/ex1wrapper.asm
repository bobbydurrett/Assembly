; copy from file to new file
; wrapper version
; command line arguments:
; from file
; to file
; buffer size

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
extern atol
extern malloc
extern open
extern close
extern read
extern write

segment .data

from_ptr dq 0
to_ptr dq 0
bufsizestrptr dq 0
buff_size dq 0
buff_ptr dq 0
from_fd dq 0
to_fd dq 0
bytes_read dq 0

segment .text

main:	                         
    push rbp                     
    mov rbp,rsp                  

; load arguments from command line

    cmp rdi,4                    ; expect 3 arguments plus program name which we ignore
    jne .exiterror
    mov qword rax, qword [rsi+8]
    mov qword [from_ptr],rax
    mov qword rax, qword [rsi+16]
    mov qword [to_ptr],rax
    mov qword rax, qword [rsi+24]
    mov qword [bufsizestrptr],rax
    
; allocate buffer for file copy

    mov rdi,rax                  ; move pointer to buf size string to rdi for conversion call
    call atol                    ; convert buf size as string to number
    mov qword [buff_size],rax    ; save converted number
    mov rdi,rax                  ; move buff size to argument for malloc
    call malloc                  ; allocate memory
    mov [buff_ptr],rax           ; save pointer to allocated buffer
    
; open files

; from file

    mov rdi,qword [from_ptr]     ; pointer to name of from file
    xor rsi,rsi                  ; 0 for read only
    call open
    cmp rax,0
    jl .exiterror
    mov qword [from_fd],rax      ; save file descriptor for open from file
    
; to file

    mov rdi,qword [to_ptr]       ; pointer to name of to file
    mov rsi,0x41                 ; create file write only
    mov rdx,644o                 ; create 644
    call open
    cmp rax,0
    jl .exiterror
    mov qword [to_fd],rax        ; save file descriptor for open to file
    
; copy data from one file to the other

; read a buffer

.nextbuffer:
    mov rdi,qword [from_fd]      ; fd of from file
    mov rsi,qword [buff_ptr]     ; pointer to buffer
    mov rdx,[buff_size]          ; size of buffer
    call read
    cmp rax,0
    jl .exiterror
    je .closefiles
    mov qword [bytes_read],rax   ; save number of bytes read for write

; write a buffer

    mov rdi,qword [to_fd]        ; fd of to file
    mov rsi,qword [buff_ptr]     ; pointer to buffer
    mov rdx,qword [bytes_read]         ; number of bytes read
    call write
    cmp rax,qword [bytes_read] 
    jl .exiterror
    jmp .nextbuffer
    
; close the files

.closefiles:    
    mov rdi,qword [from_fd]      ; fd of from file
    call close
    mov rdi,qword [to_fd]        ; fd of to file
    call close

; exit

.exiterror:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
