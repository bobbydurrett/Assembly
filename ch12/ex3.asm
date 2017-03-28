; simple grep 
; command line arguments:
; find string 
; file name

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
extern strlen
extern printf

segment .bss

data_buffer resb 4096         
curr_line resb 4096         

segment .data

buff_size dq 4096                 ; bytes in file read buffer
max_line_size dq 4095             ; max size of one line - leave room for 0 at end
find_str_size dq 0                ; actual size of the find string
find_str_ptr dq 0                 ; pointer to the find string in argv
fd dq 0
argv dq 0
bytes_read dq 0
curr_byte dq 0
curr_line_offset dq 0
find_str_offset dq 0
string_found dq 0

line_fmt db "%s",0xa,0           ; print a line

segment .text

main:	                         
    push rbp                     
    mov rbp,rsp
    
; check for 3 arguments - program, find string, file name

    cmp rdi,3
    jne .exiterror

; load arguments from command line

    mov qword [argv],rsi         ; save argv, pointer to array of pointers

; get length of file name

    mov rbx,qword [argv]         ; load pointer to argv array
    mov rax,8                    ; get offset into argv array = 8 bytes for find string
    add rbx,rax                  ; apply byte offset into argv array
    mov rdi,qword [rbx]          ; load pointer to string on argv
    mov qword [find_str_ptr],rdi ; save find string pointer
    xor rax,rax                  ; clear rax for return
    call strlen                  ; get length of find string
    mov qword [find_str_size],rax ; save length off find string
    
; open file
    
    mov rbx,qword [argv]         ; load pointer to argv array
    mov rax,16                   ; get offset into argv array = 16 bytes for file name
    add rbx,rax                  ; apply byte offset into argv array
    mov rdi,qword [rbx]          ; load pointer to string on argv
    xor rsi,rsi                  ; 0 for read only
    call open
    cmp rax,0
    jl .exiterror
    mov qword [fd],rax           ; save file descriptor for open from file
    
; init variables
; curr_line_offset = find_str_offset = string_found = 0

    xor rax,rax                  ; set to zero
    mov qword [curr_line_offset],rax
    mov qword [find_str_offset],rax
    mov qword [string_found],rax
    
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
    xor rbx,rbx                  ; rbx is offset into buffer

.nextchar:                       ; process one character
    xor rcx,rcx                  ; clear rcx for character
    mov cl,byte [data_buffer+rbx] ; one byte
    mov qword [curr_byte],rcx    ; save byte
 
; find logic starts here after the current byte is pulled from the buffer

    cmp rcx,0xa                  ; compare byte to newline
    jne .notnewline
    mov rax,qword [string_found] ; see if string found
    cmp rax,1
    jne .notstringfound          ; newline found and string found print line
    xor rax,rax                  ; zero in rax
    mov rcx,qword [curr_line_offset] ; load current offset
    mov byte [curr_line+rcx+1],al   ; put 0 at end of curr line string.
    lea rdi,[line_fmt]           ; load pointer format string
    lea rsi,[curr_line]          ; load pointer to current line
    xor rax,rax
    call printf
.notstringfound:                 ; curr byte is newline but find string not found
    xor rax,rax                  ; set to zero
    mov qword [curr_line_offset],rax ; clear all three for new line
    mov qword [find_str_offset],rax
    mov qword [string_found],rax
    jmp .nextbyte
.notnewline:                     ; curr byte is not new line
    mov rax,qword [curr_byte]    ; curr byte in rax
    mov rcx,qword [curr_line_offset] ; load current offset
    mov byte [curr_line+rcx],al  ; put curr byte at current line offset
    mov rax,qword [string_found] ; see if string found
    cmp rax,0
    jne .stringfound             ; skip next steps if string already found
    mov rcx,qword [find_str_offset] ; load find str offset
    mov rdx,qword [find_str_ptr]    ; load find str ptr
    xor rax,rax
    mov al,byte [rdx+rcx]        ; get current find string byte in rax
    mov rcx,qword [curr_byte]    ; get current byte
    cmp rax,rcx
    jne .notfindstrchar          ; chars don't match for find string
    mov rax,qword [find_str_offset] ; increment offset since bytes match
    inc rax
    mov qword [find_str_offset],rax
    mov rcx,qword [find_str_size] 
    cmp rax,rcx                  ; compare offset to find string size
    jl .notyetfound              ; more of find string to go
    mov rax,1
    mov qword [string_found],rax ; string_found = 1 - is true
.notfindstrchar:                 ; startover at beginning of find string
    xor rax,rax
    mov qword [find_str_offset],rax ; offset = 0
.stringfound:
.notyetfound:                    ; next step after checking for find string
    mov rax,qword [curr_line_offset] ; increment offset next byte
    inc rax
    mov qword [curr_line_offset],rax
    mov rcx,qword [max_line_size]
    cmp rax,rcx                  ; see if new offset is outsize curr line buffer
    jge .closefile               ; close file and exit. line is too big
 
; find logic ends here where we move to next byte possibly pulling in new buffer

.nextbyte: 
    inc rbx                      ; next byte
    mov rax,qword [bytes_read]   ; load for compare to byte number
    cmp rbx,rax
    jl .nextchar                 ; next byte until offset greater or equal num bytes read
    
    jmp .nextbuffer              ; done with this buffer.
    
; close the files

.closefile:    
    mov rdi,qword [fd]           ; fd 
    call close

.exiterror:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
