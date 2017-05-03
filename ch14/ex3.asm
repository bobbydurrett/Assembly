; ch14 ex3 - sort customer records and print
; command line argument:
; file name

; Non-float arguments in these registers:
; rdi, rsi, rdx, rcx, r8 and r9
; rax contains the number of floating point arguments
; xmm0 to xmm7 contain the float arguments
; These registers must be preserved across function calls:
; rbx, rsp, rbp, r12-r15
; rax and rdx are the integer return registers
; xmm0 and xmm1 are the float return registers
; http://www.nasm.us/links/unix64abi

global main,open_file,max_records,alloc_array,load_array
extern fopen,fseek,ftell,malloc,fread,fclose

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

segment .text

; Main register use:
; rbx file pointer
; r12 maximum number of possible records including id==0
; r13 pointer to customer array
; r14 actual number of records in array id<>0

main:	                         
    push rbp                     
    mov rbp,rsp                  
    push rbx
    push r12
    push r13
    push r14

; Argc and argv are in rdi and rsi
; Argc is number of arguments including name of program
; Argv is array of 8 byte pointers to strings

    call open_file               ; rdi and rsi are arguments
    cmp rax,0
    je .errorexit                ; exit program if file not opened
    mov rbx,rax                  ; returns file pointer
    
    mov rdi,rbx                  ; file pointer argument 
    call max_records
    mov r12,rax                  ; max records in r12
    
    mov rdi,r12                  ; argument is max records
    call alloc_array
    mov r13,rax                  ; save pointer to customer array
    
    mov rdi,rbx                  ; arg1 file pointer
    mov rsi,r13                  ; arg2 pointer to array
    call load_array
    mov r14,rax                  ; save actual number of records loaded into array

.errorexit:
    pop r14
    pop r13
    pop r12
    pop rbx
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

; open_file - gets file name from the command line
; opens the file for reading and returns pointer to
; file object
; Arguments
; rdi - argc - should be 2
; rsi - arv2 - second pointer is to file name
; Return
; rax - file pointer

segment .data

mode db "r",0

segment .text

open_file:	                         
    push rbp                     
    mov rbp,rsp    
    
    cmp rdi,2
    je .twoargs                  ; 2 arguments found
    xor rax,rax
    jmp .exitproc                ; exit return code 0
    
.twoargs:
    mov rdi,[rsi+8]              ; file name argument to fopen
    lea rsi,[mode]               ; mode - read only
    call fopen

.exitproc:
    leave                        ; fix stack
    ret                          ; return
    
; max_records - finds length of file to calculate maximum number
; of records that the file could hold.
; Arguments
; rdi - file pointer
; Return
; rax - max number of records
; Variable registers
; rbx - file pointer
; r12 - byte length of file

max_records:	                         
    push rbp                     
    mov rbp,rsp    
    push rbx
    push r12
    
    mov rbx,rdi                  ; save file pointer
    
; seek to end of file - rdi already has file pointer
    xor rsi,rsi                  ; offset=0
    mov rdx,2                    ; whence is 2, relative to end of file
    call fseek
    
; get byte position
    mov rdi,rbx                  ; file pointer
    call ftell 
    mov r12,rax                  ; save length of file
    
; calculate number of records - byte length of file still in rax
    xor rdx,rdx                  ; clear upper 64 bits
    mov rcx,customer_size
    idiv rcx    
    
    pop r12
    pop rbx
    leave                        ; fix stack
    ret                          ; return
    
; alloc_array - allocate enough memory to hold all of the records
; in the file
; Arguments
; rdi - max number of records
; Return
; rax - pointer to customer array

alloc_array:	                         
    push rbp                     
    mov rbp,rsp    

    imul rdi,customer_size       ; multiply num records by bytes per record
    call malloc                  ; allocate memory

    leave                        ; fix stack
    ret                          ; return
    
load_array

; load_array - reads all of the records with non-zero ids into
; the array
; Arguments
; rdi - file pointer
; rsi - pointer to customer array
; Return
; rax - actual number of records loaded into the array
; Variables registers
; rbx - records loaded in array so far
; r12 - file pointer saved
; r13 - pointer to array saved

load_array:	                         
    push rbp                     
    mov rbp,rsp 
    push rbx
    
    xor rbx,rbx                  ; zero records read so far
    mov r12,rdi                  ; save arguments
    mov r13,rsi

; read a record
.nextrecord:
    mov rax,rbx
    imul rax,customer_size       ; rax is offset into customer array
    mov rdi,r13
    add rdi,rax                  ; add offset to customer array start for record location
    mov rsi,customer_size        ; size of structure
    mov rdx,1                    ; one element
    mov rcx,r14                  ; file pointer
    call fread
    cmp rax,1                    ; check if record was read
    je .noerror                  ; skip error
    
    pop rbx
    leave                        ; fix stack
    ret                          ; return
