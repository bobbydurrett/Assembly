; Program uses a binary tree. Reads in a bunch of strings and then
; when it reaches EOF prints them out in alphabetical order.

global main,read_nonl,tree_insert,tree_print
extern stdin,fgets,strlen,printf,strcmp,malloc,strdup

segment .bss

buffer resb 2048                 ; 2K input buffer

segment .data

struc tree_node

c_value resq 1                   ; pointer to string value stored at this node
c_left resq 1                    ; nodes with value less than this node
c_right resq 1                   ; nodes with value greater than this node
alignb 8                         ; should not be needed - 64 bit alignment                        

endstruc

tree_root dq 0                   ; pointer to the root of the tree - 0 for empty tree

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
    je .printtree                ; Print sorted lines on EOF
    
    call tree_insert             ; insert buffer string into tree

    jmp .readline

.printtree:
  
    mov rdi,qword [tree_root]
    call tree_print

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
    
; Insert a string into a binary tree.
; Uses buffer and tree_root variables.
; variables:
; rbx - new node
; r12 - current tree node
    
tree_insert:	                     
    push rbp                    
    mov rbp,rsp 
    push rbx
    push r12

; create new tree node

    mov rdi,tree_node_size       ; node struct size
    call malloc
    mov rbx,rax                  ; save pointer to new node

; add pointer to value string

    lea rdi,[buffer]             ; duplicate string
    call strdup
    mov qword [rbx+c_value],rax  ; save duped string pointer in new node
    
; clear left and right pointers

    xor rax,rax                  ; rax = 0
    mov qword [rbx+c_left],rax   ; left = 0
    mov qword [rbx+c_left],rax   ; right = 0

 ; check for empty tree
 
    mov rax,qword [tree_root]
    cmp rax,0
    jne .notempty
 
 ; make new node the root node
 
    mov qword [tree_root],rbx    ; pointer to new node is root
    jmp .doneinsert
    
; tree not empty

.notempty:
    mov r12,qword [tree_root]    ; start at root
    
; compare new string to current node

.nextnode:
    lea rdi,[buffer]             ; new string ptr
    mov rsi,[r12+c_value]        ; current node string ptr
    call strcmp
    cmp eax,0
    jg .rightnode                ; right node if greater, left otherwise
    
; follow left node

    mov rax,qword [r12+c_left]   ; load left pointer
    cmp rax,0                    ; check for 0 pointer
    jne .goleft                  ; follow left pointer

; add new node here

    mov qword [r12+c_left],rbx   ; load pointer to new node
    jmp .doneinsert              ; done
    
; advance pointer and start again

.goleft:    
    mov r12,[r12+c_left]
    jmp .nextnode
    
; follow right node

.rightnode:
    mov rax,qword [r12+c_right]  ; load right pointer
    cmp rax,0                    ; check for 0 pointer
    jne .goright                 ; follow right pointer

; add new node here

    mov qword [r12+c_right],rbx  ; load pointer to new node
    jmp .doneinsert              ; done
    
; advance pointer and start again

.goright:    
    mov r12,[r12+c_right]
    jmp .nextnode
    
.doneinsert:    
    xor rax,rax                  ; return code 0
    pop r12
    pop rbx
    leave                        ; fix stack
    ret                          ; return
    
; Print the strings in the binary tree in order.
; Recursively print left subtree, current node, right subtree.
; Argument:
; rdi - pointer to tree
; Variables:
; rbx - saved pointer to tree

segment .data

printfmt db `%s\n`,0

segment .text
    
tree_print:	                     
    push rbp                    
    mov rbp,rsp 
    push rbx
    push rbx
    
; Check for empty tree

    cmp rdi,0
    je .doneprint                ; empty tree do nothing

; save tree pointer

    mov rbx,rdi
    
; Print left subtree

   mov rdi,qword [rbx+c_left]
   call tree_print
   
; Print current node

   lea rdi,[printfmt]
   mov rsi,[rbx+c_value]
   call printf
   
; Print right subtree

   mov rdi,qword [rbx+c_right]
   call tree_print

.doneprint:
    pop rbx
    pop rbx
    leave                        ; fix stack
    ret                          ; return