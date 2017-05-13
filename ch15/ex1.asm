; Program uses a stack.
; Reads from console:
; pop - pops the top item off of the stack and prints it
; print - prints the entire stack
; any other string - pushes the string on to the stack 

global main,read_nonl,push_command,pop_command,print_command
extern stdin,fgets,strlen,strcmp,malloc,strdup,printf,free

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
    
    xor rax,rax
    mov qword [stack_ptr],rax    ; zero out stack pointer

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
    call pop_command
    jmp .readline
    
; Check for print command

.checkprint:
    lea rdi,[buffer]
    lea rsi,[print_str]
    call strcmp
    cmp rax,0
    jne .dopush                  ; do push command if not pop or print
    call print_command
    jmp .readline   

; Push string on stack

.dopush:
    call push_command
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
    
; push_command takes the string from the command line
; and pushes it on the stack. Does not take any arguments
; or return any results. Uses buffer and stack_ptr
; global variables.
; Register variables:
; rbx - pointer to new node

segment .data

pushmessagefmt db `Pushed: %s\n`,0

segment .txt

push_command:	                 
    push rbp                     
    mov rbp,rsp
    push rbx
    push rbx
    
; create a new node for the stack

    mov rdi,stack_node_size      ; node struct size
    call malloc
    mov rbx,rax                  ; save pointer to new node
    
; add string value    
    
    lea rdi,[buffer]             ; duplicate string 
    call strdup
    mov qword [rbx+c_value],rax  ; save duped string pointer in new node
    
; add node to top of stack

    mov rax,qword [stack_ptr]
    mov qword [rbx+c_next],rax   ; save current stack pointer to next of new node
    mov qword [stack_ptr],rbx    ; point top of stack to new node
    
; print what we did

    lea rdi,[pushmessagefmt]
    lea rsi,[buffer]
    call printf
    
    pop rbx
    pop rbx
    leave                        ; fix stack
    ret                          ; return
    
; pop_command pops the top string off of the stack.
; Does not take any arguments or return any results. 
; Uses buffer and stack_ptr global variables.
; Register variables:
; rbx - pointer to top node of stack

segment .data

emptymessagefmt db `Stack is empty. Nothing popped.\n`,0
popmessagefmt db `Popping: %s\n`,0

segment .txt

pop_command:	                 
    push rbp                     
    mov rbp,rsp
    push rbx
    push rbx

; Check for empty stack
    
    mov rbx,qword [stack_ptr]
    cmp rbx,0
    jne .stacknotempty
    
; Print empty message

    lea rdi,[emptymessagefmt]
    call printf
    jmp .donepop
    
; Unlink node from list

.stacknotempty:
    mov rax,[rbx+c_next]         ; next pointer from node
    mov qword [stack_ptr],rax    ; stack pointer now points to next node
    
; Print value of top node

    lea rdi,[popmessagefmt]
    mov rsi,[rbx+c_value]
    call printf

; Free string of top node

    mov rdi,[rbx+c_value]
    call free

; Free node

    mov rdi,rbx
    call free

.donepop:
    pop rbx
    pop rbx
    leave                        ; fix stack
    ret                          ; return

; print_command prints the contents of the stack.
; Does not take any arguments or return any results. 
; Uses buffer and stack_ptr global variables.
; Register variables:
; rbx - pointer to current node

segment .data

printfmt db `%s\n`,0

segment .txt

print_command:	                 
    push rbp                     
    mov rbp,rsp
    push rbx
    push rbx

; Get top of stack as current pointer
    
    mov rbx,qword [stack_ptr]
    
; Exit when end of list reached    

.nextnode:
    cmp rbx,0                  
    je .printdone
    
; Print current node

    lea rdi,[printfmt]
    mov rsi,[rbx+c_value]
    call printf

; Advance to next node

    mov rbx,[rbx+c_next]
    jmp .nextnode

.printdone:
    pop rbx
    pop rbx
    leave                        ; fix stack
    ret                          ; return
    
    
    
    
