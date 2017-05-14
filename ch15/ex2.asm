; Program uses a queue.
; Reads from console:
; dequeue - removes the first item from the queue and prints it
; print - prints the entire queue in order
; any other string - adds the string to the front of the queue 

global main,read_nonl,enqueue_command,dequeue_command,print_command
extern stdin,fgets,strlen,strcmp,malloc,strdup,printf,free

segment .bss

buffer resb 2048                 ; 2K input buffer

segment .data

; doubly linked list to implement a queue
; c_next is a pointer to the next member of the list
; c_prev is a pointer to the next member of the list
; c_value is a pointer to a string, the value of the member of 
; the list.
; the empty list has a single node with c_value == 0 and
; c_next and c_prev pointing to the node

struc queue_node

c_next resq 1                    ; next node in doubly linked list
c_prev resq 1                    ; previous node
c_value resq 1                   ; 64 bit pointer to a string
alignb 8                         ; should not be needed - 64 bit alignment                        

endstruc

queue istruc queue_node          ; The queue itself. The dummy node.
      iend                       ; no need to malloc it.

dequeue_str db "dequeue",0
print_str db "print",0

segment .text

; main - entry point of program

main:	                     
    push rbp                    
    mov rbp,rsp 

; Setup empty queue

    xor rax,rax                  ; make rax == 0
    mov qword [queue+c_value],rax ; value of dummy node is 0
    lea rax,[queue]              ; now rax points to dummy node
    mov qword [queue+c_next],rax ; next points to dummy node
    mov qword [queue+c_prev],rax ; prev points to dummy node
    
; Read a line from the console

.readline:
    lea rdi,[buffer]             ; file name buffer pointer
    mov rsi,2048                 ; 2K buffer
    xor rax,rax                  ; no floating point args
    call read_nonl               ; read a line
    cmp rax,0
    je .exitprogram              ; exit on EOF or error
    
; Check for dequeue command

    lea rdi,[buffer]
    lea rsi,[dequeue_str]
    call strcmp
    cmp rax,0
    jne .checkprint              ; check for print command if dequeue not found
    call dequeue_command
    jmp .readline
    
; Check for print command

.checkprint:
    lea rdi,[buffer]
    lea rsi,[print_str]
    call strcmp
    cmp rax,0
    jne .doenqueue                  ; do enqueue command if not dequeue or print
    call print_command
    jmp .readline   

; Enqueue string

.doenqueue:
    call enqueue_command
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
    
; enqueue_command takes the string from the command line
; and adds it to the front of the queue. Does not take any arguments
; or return any results. Uses buffer and queue
; global variables.
; Register variables:
; rbx - pointer to new node

segment .data

enqueuefmt db `Enqueued: %s\n`,0

segment .txt

enqueue_command:	                 
    push rbp                     
    mov rbp,rsp
    push rbx
    push rbx
    
; create a new node for the stack

    mov rdi,queue_node_size      ; node struct size
    call malloc
    mov rbx,rax                  ; save pointer to new node
    
; add string value    
    
    lea rdi,[buffer]             ; duplicate string 
    call strdup
    mov qword [rbx+c_value],rax  ; save duped string pointer in new node
    
; add node to front of queue

    mov rax,qword [queue+c_next] ; load next of dummy node
    mov qword [rbx+c_next],rax   ; next of new node = next of dummy node
    lea rax,[queue]              ; load pointer to dummy node
    mov qword [rbx+c_prev],rax   ; prev of new node = dummy node
    mov qword [queue+c_next],rbx ; next of dummy node = new node
    mov rax,qword [rbx+c_next]   ; load next of new node
    mov qword [rax+c_prev],rbx   ; load prev of next of new node with new node
        
; print what we did

    lea rdi,[enqueuefmt]
    lea rsi,[buffer]
    call printf
    
    pop rbx
    pop rbx
    leave                        ; fix stack
    ret                          ; return
    
; dequeue_command removes the node from the end of the queue.
; Does not take any arguments or return any results. 
; Uses buffer and queue global variables.
; Register variables:
; rbx - pointer to last node

segment .data

emptymessagefmt db `Queue is empty. Nothing dequeued.\n`,0
dequeuefmt db `Dequeued: %s\n`,0

segment .txt

dequeue_command:	                 
    push rbp                     
    mov rbp,rsp
    push rbx
    push rbx

; Check for empty queue
    
    mov rbx,qword [queue+c_prev] ; rbx now has last node in queue
    lea rax,[queue]              ; rax has address of dummy node
    cmp rbx,rax
    jne .queuenotempty           ; more nodes than just the dummy node
    
; Print empty message

    lea rdi,[emptymessagefmt]
    call printf
    jmp .donedequeue
    
; Unlink node from end of queue
; Prev of dummy node point to prev of unlinked node
; next of prev of unlinked node point to dummy node

.queuenotempty:
    lea rax,[queue]              ; rax has pointer to dummy node
    mov rcx,[rbx+c_prev]         ; rcx has prev of unlinked node
    mov qword [rax+c_prev],rcx   ; prev of dummy now is prev of unlinked
    mov qword [rcx+c_next],rax   ; set next of prev to dummy node
    
; Print value of unlinked node

    lea rdi,[dequeuefmt]
    mov rsi,[rbx+c_value]
    call printf

; Free string of top node

    mov rdi,[rbx+c_value]
    call free

; Free node

    mov rdi,rbx
    call free

.donedequeue:
    pop rbx
    pop rbx
    leave                        ; fix stack
    ret                          ; return

; print_command prints the contents of the queue.
; Does not take any arguments or return any results. 
; Uses buffer and queue global variables.
; Prints in order that objects will be dequeued.
; Register variables:
; rbx - pointer to current node
; r12 - pointer to dummy node

segment .data

printfmt db `%s\n`,0

segment .txt

print_command:	                 
    push rbp                     
    mov rbp,rsp
    push rbx
    push r12

; Get first node of queue as rbx
; Get pointer to dummy node as r12
    
    mov rbx,qword [queue+c_prev]
    lea r12,[queue]
    
; Exit when end of list reached    

.nextnode:
    cmp rbx,r12                  
    je .printdone
    
; Print current node

    lea rdi,[printfmt]
    mov rsi,[rbx+c_value]
    call printf

; Advance to next node

    mov rbx,[rbx+c_prev]
    jmp .nextnode

.printdone:
    pop r12
    pop rbx
    leave                        ; fix stack
    ret                          ; return
    
    
    
    
