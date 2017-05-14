; Program uses a hash table
; Reads from console:
; string and integer - stores the integer in the hash table
; using the string as the key
; string only - looks up integer value in hash table
; string can not have spaces - using sscanf so it has to be 
; string of non-space characters a space and a number on input
; and just a string of non-space characters on lookup.

global main,read_nonl
extern stdin,fgets,strlen,strcmp,sscanf

segment .bss

buffer resb 2048                 ; 2K input buffer
keystr resb 2048                    ; 2K key buffer

segment .data

scanfmt db "%s %ld",0

value dq 0                       ; hash table value

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
