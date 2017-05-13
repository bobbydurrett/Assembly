; Program uses a stack.
; Reads from console:
; pop - pops the top item off of the stack and prints it
; print - prints the entire stack
; any other string - pushes the string on to the stack 

global main,read_nonl
extern stdin,fgets,strlen,strcmp

segment .bss

buffer resb 2048                 ; 2K input buffer

segment .data

; singly linked list to implement a stack
; c_next is a pointer to the next member of the list
; 0 represents the end of the list
; c_value is a pointer to a string, the value of the member of 
; the list

struc stack_node

c_next resq 1
c_value resq 1
alignb 8                         ; should not be needed - 64 bit alignment                        

endstruc

stack_ptr dq 0                   ; top of the stack, beginning of the list

pop_str db "pop",0
print_str db "print",0

segment .text

; main - entry point of program

main:	                     
    push rbp                    
    mov rbp,rsp 

; Read a line from the console

.readline:
    lea rdi,[buffer]             ; file name buffer pointer
    mov rsi,2048                 ; 2K buffer
    xor rax,rax                  ; no floating point args
    call read_nonl               ; read a line
    cmp rax,0
    je .exitprogram              ; exit on EOF or error
    
; Check for pop command

    lea rdi,[buffer]
    lea rsi,[pop_str]
    call strcmp
    cmp rax,0
    jne .checkprint              ; check for print command if pop not found
; call pop_command here
    jmp .readline
    
; Check for print command

.checkprint:
    lea rdi,[buffer]
    lea rsi,[print_str]
    call strcmp
    cmp rax,0
    jne .dopush                  ; do push command if not pop or print
; call print_command here
    jmp .readline   

; Push string on stack

.dopush:
; call push_command here
    jmp .readline
    
.exitprogram:    
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

; read_nonl reads a line of input trimming of the 
; trailing newline.
; Arguments:
; rdi - pointer to character buffer
; rsi - buffer size
; Returns:
; rax - 0 if EOF or error, pointer to character buffer otherwise
; Register variables:
; rbx - saved pointer to character buffer
; r12 - saved buffer size

read_nonl:	                 
    push rbp                     
    mov rbp,rsp                  
    push rbx
    push r12
    
    mov rbx,rdi                  ; save pointer to character buffer
    mov r12,rsi                  ; save buffer size
    
    mov rdx,[stdin]
    xor rax,rax                  ; no floating point args
    call fgets                   ; read a line
    cmp rax,rbx                  ; on success returns pointer to buffer
    jne .eoforerror              ; EOF or some error
    
    xor rax,rax
    mov rdi,rbx                  ; point to character buffer
    call strlen                  ; get length of string
    dec rax                      ; strlen - 1
    mov byte [rbx+rax],0         ; put null over newline
    mov rax,rbx                  ; return pointer to buffer on success
    jmp .exitfunction

.eoforerror:                     ; return 0 on error or eof
    xor rax,rax
    jmp .exitfunction

.exitfunction:
    pop r12
    pop rbx
    leave                        ; fix stack
    ret                          ; return