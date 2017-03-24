; simple word count - bytes, words, lines
; command line arguments:
; files to wc

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
extern open
extern close
extern read

segment .bss

data_buffer resb 4096         

segment .data

buff_size dq 4096
fd dq 0
argc dq 0
argv dq 0
curr_arg dq 0                   ; number of current command line argument
bytes_read dq 0 

; count variables

byte_count dq 0
word_count dq 0
line_count dq 0
bytes_on_line dq 0              ; number of bytes found on the current line
bytes_in_word dq 0              ; number of bytes found in the current word

segment .text

main:	                         
    push rbp                     
    mov rbp,rsp                  

; load arguments from command line

    mov qword [argc],rdi         ; save argc
    mov qword [argv],rsi         ; save argv
    mov qword [curr_arg],2       ; skip first argument
    
; check if any file names remain

.looptop:
    mov rax,qword [curr_arg]
    mov rbx,qword [argc]
    cmp rax,rbx
    jg .endloop                   ; end loop if out of files
        
; open file
    
    mov rbx,qword [argv]         ; load pointer to argv array
    dec rax                      ; get offset into argv array curr_arg-1
    imul rax,8                   ; multiply by 8 to get byte offset
    add rbx,rax                  ; apply byte offset into argv array
    mov rdi,qword [rbx]          ; load pointer to string on argv
    xor rsi,rsi                  ; 0 for read only
    call open
    cmp rax,0
    jl .exiterror
    mov qword [fd],rax           ; save file descriptor for open from file
    
; initialize counts

    xor rax,rax                  ; zero rax
    mov qword [byte_count],rax
    mov qword [word_count],rax
    mov qword [line_count],rax
    mov qword [bytes_on_line],rax
    mov qword [bytes_in_word],rax
        
; read a buffer

.nextbuffer:
    mov rdi,qword [fd]           ; fd of from file
    lea rsi,[data_buffer]        ; pointer to buffer
    mov rdx,qword [buff_size]    ; size of buffer
    call read
    cmp rax,0
    jl .exiterror
    je .closefile
    mov qword [bytes_read],rax   ; save number of bytes read
    
; update counts

    xor rbx,rbx                  ; rbx is offset into buffer
.nextchar                        ; process one character
    xor rcx,rcx                  ; clear rcx for character
    mov rcx,byte [data_buffer+rbx] ; one byte
; increment byte counts
    mov rdx,qword [byte_count]
    inc rdx
    mov qword [byte_count],rdx
    mov rdx,qword [bytes_on_line]
    inc rdx
    mov qword [bytes_on_line],rdx
    mov rdx,qword [bytes_in_word]
    inc rdx
    mov qword [bytes_in_word],rdx    
    
    jmp .nextbuffer              ; keep reading
    
; close the files

.closefile:    
    mov rdi,qword [fd]           ; fd 
    call close
    
; prep for next argument
    mov rax,qword [curr_arg]
    inc rax
    mov qword [curr_arg],rax     ; curr_arg++
    jmp .looptop
.endloop:

; exit

.exiterror:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
