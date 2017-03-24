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
extern printf

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

file_fmt db "file = %s",0xa,0     ; file name
bytes_fmt db "bytes = %ld",0xa,0  ; bytes count
words_fmt db "words = %ld",0xa,0  ; words count
lines_fmt db "lines = %ld",0xa,0  ; lines count

; state
; 1 = new line found
; 2 = space but not new line
; 3 = not space

curr_state dq 0
next_state dq 0

file_name_ptr dq 0


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
    mov qword [file_name_ptr],rdi ; save for printf
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
    
; init state
    mov rax,1
    mov qword [curr_state],rax   ; new line initial state
        
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
.nextchar:                       ; process one character
    xor rcx,rcx                  ; clear rcx for character
    mov cl,byte [data_buffer+rbx] ; one byte
; increment byte count
    mov rdx,qword [byte_count]
    inc rdx
    mov qword [byte_count],rdx
; look at character to determine next state
    cmp rcx,0xa                  ; check for newline = 0xa
    jne .checkspace
    mov qword [next_state],1     ; state 1 = new line found
    jmp .foundstate
.checkspace:
; http://www.cplusplus.com/reference/cctype/isspace/
    cmp rcx,0x20                 ; check for space
    je .foundspace
    cmp rcx,0x9                  ; check for tab
    je .foundspace
    cmp rcx,0xb                  ; check for vertical tab ?
    je .foundspace
    cmp rcx,0xc                  ; check for form feed
    je .foundspace
    cmp rcx,0xd                  ; check for carriage return
    je .foundspace
; not space if got here
    mov qword [next_state],3     ; state 3 = not space
    jmp .foundstate
.foundspace:   
    mov qword [next_state],2     ; state 2 = space but not new line
.foundstate:
; based on curr_state and next_state figure out wether to increment
; line_count and word_count
    mov rax,qword [curr_state]
    cmp rax,1
    je .new_line
    cmp rax,2
    je .space_not_nl
; not space if got here
    jmp .nextbyte                ; don't increment lines or words
.new_line:
    mov rdx,qword [line_count]   ; increment line count every time you
    inc rdx                      ; exit new_line state
    mov qword [line_count],rdx
.space_not_nl:                   ; if curr state is space not new line inc words if next state is not space
    mov rax,qword [next_state]   ; see if next state is not space 
    cmp rax,3
    jne .nextbyte
    mov rdx,qword [word_count]   ; increment word count transitioning from
    inc rdx                      ; new line to not space
    mov qword [word_count],rdx
.nextbyte: 
    mov rdx,qword [next_state]   ; move next_state to curr_state
    mov qword [curr_state],rdx
    inc rbx                      ; next byte
    mov rax,qword [bytes_read]   ; load for compare to byte number
    cmp rbx,rax
    jl .nextchar                 ; next byte until offset greater or equal num bytes read
    
    jmp .nextbuffer              ; done with this buffer.
    
; close the files

.closefile:    
    mov rdi,qword [fd]           ; fd 
    call close
    
; print counts
    lea rdi,[file_fmt]           ; file name format
    mov rsi,qword [file_name_ptr]   ; pointer to file name string
    mov rax,0                    ; 0 float arguments
    call printf                  ; print line
    lea rdi,[bytes_fmt]          ; bytes format
    mov rsi,qword [byte_count]   ; num bytes
    mov rax,0                    ; 0 float arguments
    call printf                  ; print line
    lea rdi,[words_fmt]          ; bytes format
    mov rsi,qword [word_count]   ; num bytes
    mov rax,0                    ; 0 float arguments
    call printf                  ; print line
    lea rdi,[lines_fmt]          ; bytes format
    mov rsi,qword [line_count]   ; num bytes
    mov rax,0                    ; 0 float arguments
    call printf                  ; print line

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
