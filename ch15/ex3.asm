; Program uses a hash table
; Reads from console:
; string and integer - stores the integer in the hash table
; using the string as the key
; string only - looks up integer value in hash table
; string can not have spaces - using sscanf so it has to be 
; string of non-space characters a space and a number on input
; and just a string of non-space characters on lookup.

global main,read_nonl,insert_hash,query_hash,calc_hash,search_list
extern stdin,fgets,strlen,strcmp,sscanf,printf,strcmp,malloc,strdup

segment .bss

buffer resb 2048                 ; 2K input buffer
keystr resb 2048                 ; 2K key buffer
hash_table resq 100000           ; 100000 entry hash table

segment .data

scanfmt db "%s %ld",0

value dq 0                       ; hash table value
hash_value dq 0                  ; index into hash table

argcntfmt db `Skipped line: %s\n`,0

struc list_node

c_next resq 1                    ; next node in doubly linked list
c_key resq 1                     ; pointer to string - key
c_value resq 1                   ; 64 bit integer value associated with key
alignb 8                         ; should not be needed - 64 bit alignment                        

endstruc

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
    
; parse arguments (1 or 2) from buffer

    lea rdi,[buffer]             ; pointer to buffer
    lea rsi,[scanfmt]            ; pointer to scan format
    lea rdx,[keystr]             ; key string
    lea rcx,[value]              ; 
    xor rax,rax                  ; no floating point args
    call sscanf                  ; parse string
    
; two arguments means insert into hash table

    cmp rax,2
    jne .checkoneargument        ; not two arguments. check for one next
    call insert_hash             ; insert value into hash table using keystr
    jmp .readline                ; read next line
    
; one argument means query hash table for value

.checkoneargument:
    cmp rax,1
    jne .badargumentcount        ; print error - should be 1 or 2 arguments
    call query_hash              ; look up value in hash table using keystr
    jmp .readline
    
; bad argument count

.badargumentcount:    
    lea rdi,[argcntfmt]
    lea rsi,[buffer]
    call printf
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
    
; insert_hash inserts a value into the hash table using
; the key. Uses the variables keystr and value as inputs.
; If the key already is in the table just update the value.
; variables
; rbx - pointer to new node

insert_hash:	                 
    push rbp                     
    mov rbp,rsp 
    push rbx
    push rbx
    
    call calc_hash               ; get hash value
    
    call search_list             ; find the key on the list on the current ht entry
    cmp rax,0
    je .addnode                  ; add new node to list if key not found
   
; just update value on node that was found

    mov rcx,qword [value]        ; load value into rcx
    mov qword [rax+c_value],rcx  ; save value in existing node
    jmp .doneinsert

; insert new node since key not found

.addnode:
    mov rdi,list_node_size       ; node struct size
    call malloc
    mov rbx,rax                  ; save pointer to new node

; add key string

    lea rdi,[keystr]             ; duplicate string
    call strdup
    mov qword [rbx+c_key],rax    ; save duped string pointer in new node

; add value

    mov rax,qword [value]
    mov qword [rbx+c_value],rax  ; save value in new node
    
; point next to current start of list and update hash table to point to new node

    mov rax,qword [hash_value]   ; load index into hash table
    mov rcx,qword [hash_table+rax] ; load pointer to list, possibly 0 if empty
    mov qword [rbx+c_next],rcx   ; point new node next to previous start of list
    mov qword [hash_table+rax],rbx ; point hash table entry to new node

.doneinsert:
    pop rbx
    pop rbx
    leave                        ; fix stack
    ret                          ; return

; query_hash looks up a key in the hash table and returns 
; the associated value. Uses the variable keystr input.
; Prints message if key not found.

segment .data

notfoundfmt db `Key: %s not found\n`,0
foundfmt db `Key: %s Value: %ld\n`,0

segment .text

query_hash:	                 
    push rbp                     
    mov rbp,rsp                  

    call calc_hash               ; get hash value
    
    call search_list             ; find the key on the list on the current ht entry
    cmp rax,0
    je .notfound                 ; key not found
    
; print value found

    lea rdi,[foundfmt]
    mov rsi,[rax+c_key]
    mov rdx,[rax+c_value]
    call printf
    jmp .donequery
    
; not found message

.notfound:
    lea rdi,[notfoundfmt]
    lea rsi,[keystr]
    call printf
    
.donequery:
    leave                        ; fix stack
    ret                          ; return

; calc_hash - calculates the hash value based on a string
; uses the C code in Seyfarth book page 173 but rewritten
; in assembly.

; Assumes hash table of 100000 members.
; gets string from keystr
; push hash result in hash_value
; register variables
; rdi - string pointer
; r8 - hash value

calc_hash:	                 
    push rbp                     
    mov rbp,rsp 
    
    xor r8,r8                    ; h = 0
    lea rdi,[keystr]             ; pointer to string
    
 .nextbyte:                      ; check next byte of string
    xor rax,rax                  ; clear rax
    mov al,byte [rdi]            ; get current byte
    cmp rax,0                    ; check for 0 byte
    je .donestring
    
    imul r8,191                  ; h*191
    add r8,rax                   ; add current byte
    inc rdi                      ; advance to next byte in string
    jmp .nextbyte
        
.donestring:

    xor rdx,rdx                  ; clear rdx for division
    mov rax,r8                   ; load h for division to get modulus 100000
    mov r9,100000
    idiv r9                      ; divide by 100000
    mov qword [hash_value],rdx   ; save remainder in hash_value

    leave                        ; fix stack
    ret                          ; return
    
; search_list - searches the list at the current hash table entry
; for the key. Uses these global variables:
; keystr - key as string
; hash_table - hash table - array of 64 bit pointers.
; value - value to be inserted
; hash_value - hast table index
; returns
; rax - pointer to node with key or 0 if none found
; variables
; rbx - index into hash table
; r12 - current node of list off hash table entry

search_list:	                 
    push rbp                     
    mov rbp,rsp 
    push rbx
    push r12
    
    mov rbx,qword [hash_value]   ; load index into hash table
    mov r12,qword [hash_table+rbx] ; load pointer to list, possibly 0 if empty
    
.nextitem:
    cmp r12,0
    je .donesearch               ; return 0 pointer if not found
    
; check key on current node

    lea rdi,[keystr]             ; pointer to key string
    mov rsi,qword [r12+c_key]    ; pointer to key string in current node
    call strcmp
    cmp rax,0
    je .donesearch               ; done if keys are equal
    mov r12,qword [r12+c_next]   ; next node in list
    jmp .nextitem

.donesearch:
    mov rax,r12                  ; return pointer or 0
    pop r12
    pop rbx
    leave                        ; fix stack
    ret                          ; return