; inserts a customer record in a file
; either sticks it in the middle if the record is empty
; or at the end.

; Non-float arguments in these registers:
; rdi, rsi, rdx, rcx, r8 and r9
; rax contains the number of floating point arguments
; xmm0 to xmm7 contain the float arguments
; These registers must be preserved across function calls:
; rbx, rsp, rbp, r12-r15
; rax and rdx are the integer return registers
; xmm0 and xmm1 are the float return registers
; http://www.nasm.us/links/unix64abi

global main,get_input
extern printf,scanf

segment .bss

filename resb 80

segment .data

struc customer

c_id resd 1
c_name resb 65
c_address resb 65 
alignb 4
c_balance resd 1
c_rank resb 1 
alignb 4

endstruc

newcustomer istruc customer
            iend

segment .text

main:	                         ; main program
    push rbp                     
    mov rbp,rsp                  
    lea rdi,[newcustomer]
    lea rsi,[filename]
    call get_input

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

; get_input reads in the file name and
; each of the components of the new customer record.
; Arguments:
; rdi - pointer to customer structure
; rsi - pointer to file name buffer
; Register variables:
; rbx - saved pointer to customer structure
; r12 - saved pointer to file name buffer

segment .data

filenameprompt db "Enter file name: ",0
nameprompt db "Enter name: ",0
addressprompt db "Enter address: ",0
balanceprompt db "Enter balance: ",0
rankprompt db "Enter rank: ",0

filenamescanfmt db "%s",0
namescanfmt db "%s",0
addressscanfmt db "%s",0
balancescanfmt db "%d",0
rankscanfmt db "%ld",0

ranktemp dq 0

segment .text

get_input:	                 
    push rbp                     
    mov rbp,rsp                  
    push rbx
    push r12

    mov rbx,rdi                  ; save pointer to customer structure
    mov r12,rsi                  ; save pointer to file name buffer

; Print file name prompt
    lea rdi,[filenameprompt]     
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt
; Read filename using scanf
    lea rdi,[filenamescanfmt]   
    mov rsi,r12                  ; file name buffer pointer
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line

; Prompt for and read in name
    lea rdi,[nameprompt]     
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt
    lea rdi,[namescanfmt]   
    lea rsi,[rbx+c_name]         ; name buffer pointer
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line

; Prompt for and read in address
    lea rdi,[addressprompt]     
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt
    lea rdi,[addressscanfmt]   
    lea rsi,[rbx+c_address]      ; address buffer pointer
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line

; Prompt for and read in balance
    lea rdi,[balanceprompt]     
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt
    lea rdi,[balancescanfmt]   
    lea rsi,[rbx+c_balance]      ; balance buffer pointer
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line

; Prompt for and read in rank
    lea rdi,[rankprompt]     
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt
    lea rdi,[rankscanfmt]   
    lea rsi,[ranktemp]           ; rank is a byte so I'm reading in long
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
    mov rax,[ranktemp]           ; rank
    mov [rbx+c_rank],al          ; load only the last byte

    pop r12
    pop rbx
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
