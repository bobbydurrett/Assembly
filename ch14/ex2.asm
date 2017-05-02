; ch14 ex2 - update balance on customer id record
; return error if not found
; command line arguments:
; file name, customer id, new balance

; Non-float arguments in these registers:
; rdi, rsi, rdx, rcx, r8 and r9
; rax contains the number of floating point arguments
; xmm0 to xmm7 contain the float arguments
; These registers must be preserved across function calls:
; rbx, rsp, rbp, r12-r15
; rax and rdx are the integer return registers
; xmm0 and xmm1 are the float return registers
; http://www.nasm.us/links/unix64abi

global main                      
extern atol,printf,fopen,fseek,fread,fwrite,fclose

segment .data

mode db "r",0                   ; read-only

struc customer

c_id resd 1
c_name resb 65
c_address resb 65 
alignb 4
c_balance resd 1
c_rank resb 1 
alignb 4

endstruc

foundrecord istruc customer
            iend

errorfmt db `Did not find customer id %ld\n`,0

segment .text

; Register use:
; rbx pointer to file name
; r12 customer id
; r13 new balance
; r14 file pointer
; r15 byte offset to seek

main:	                         ; labels start column 1
    push rbp                     ; opcodes start column 5
    mov rbp,rsp                  ; comments from 34 unless opcode and arguments are too long
    push rbx
    push r12
    push r13
    push r14
    push r15
    push r15

; Argc and argv are in rdi and rsi
; Argc is number of arguments including name of program
; Argv is array of 8 byte pointers to strings

; first save command line arguments

    mov rbx,[rsi]                ; save pointer to file name
    mov r12,[rsi+8]              ; save pointer to character version of cust id
    mov r13,[rsi+16]             ; save pointer to character version of new balance
    mov rdi,r12                  ; character argument to atol
    call atol                    ; convert to long
    mov r12,rax                  ; now r12 has numeric version of cust id
    mov rdi,r13
    call atol
    mov r13,rax                  ; now r13 has numeric version of new balance
    
; next open file

    mov rdi,rbx                  ; file name argument to fopen
    lea rsi,[mode]               ; mode
    call fopen
    mov r14,rax                  ; save file pointer    

; seek to record for customer id

    mov rdi,r14                  ;  first argument to fseek, fp
    mov rsi,r12                  ; get customer id
    dec rsi                      ; -1 for record number
    imul rsi,customer_size       ; multiply record number by size of structure to get byte offset
    mov r15,rsi                  ; save byte offset for second seek
    xor rdx,rdx                  ; whence is 0
    call fseek

; initialize customer id to 0 in structure

    xor rax,rax
    mov dword [foundrecord+c_id],eax
    
; read record

    lea rdi,[foundrecord]        ; pointer to customer structure
    mov rsi,customer_size        ; size of structure
    mov rdx,1                    ; one element
    mov rcx,r14                  ; file pointer
    call fread
    cmp rax,1                    ; check if record was read
    je .noerror                  ; skip error

; print error

    lea rdi,[errorfmt]    
    mov rsi,r12                  ; customer id
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt
    jmp .finish
 
; update balance in structure

.noerror:   
    mov dword [foundrecord+c_balance],r13d ; save balance in structure

; seek again to record

    mov rdi,r14                  ; first argument to fseek, fp
    mov rsi,r15                  ; saved byte offseet
    xor rdx,rdx                  ; whence is 0
    call fseek
    
; write updated record

    lea rdi,[foundrecord]        ; pointer to customer structure
    mov rsi,customer_size        ; size of structure
    mov rdx,1                    ; one element
    mov rcx,r14                  ; file pointer
    call fwrite
    
; close file

.finish:
    mov rdi,r14
    call fclose
      
    pop r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
