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

global main,open_file,max_records,alloc_array,load_array,sort_array,compare,print_array
extern fopen,fseek,ftell,malloc,fread,fclose,qsort,printf

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
    
    mov rdi,r13                  ; pointer to array arg1
    mov rsi,r14                  ; actual number of records loaded
    call sort_array

    mov rdi,r13                  ; pointer to array arg1
    mov rsi,r14                  ; actual number of records loaded
    call print_array

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
; r14 - pointer to current record

load_array:	                         
    push rbp                     
    mov rbp,rsp 
    push rbx
    push r12
    push r13
    push r14
    
    xor rbx,rbx                  ; zero records read so far
    mov r12,rdi                  ; save arguments
    mov r13,rsi
    
; seek to beginning of file - rdi already has file pointer

    xor rsi,rsi                  ; offset=0
    xor rdx,rdx                  ; whence is 0, relative to beginning of file
    call fseek
    
; read a record
.nextrecord:
    mov rax,rbx
    imul rax,customer_size       ; rax is offset into customer array
    mov rdi,r13                  ; pointer to beginning of array
    add rdi,rax                  ; add offset to customer array start for record location
    mov r14,rdi                  ; save pointer to current record
    mov rsi,customer_size        ; size of structure
    mov rdx,1                    ; one element
    mov rcx,r12                  ; file pointer
    call fread
    cmp rax,1                    ; check if record was read
    jne .donereading             ; no more records
    xor rax,rax
    mov eax,dword [r14+c_id]     ; load id
    cmp rax,0
    je .nextrecord               ; skip record since id == 0
    inc rbx                      ; record is ok so increment record found count
    jmp .nextrecord              ; get another record
.donereading:
    mov rdi,r12
    call fclose                  ; close file
    mov rax,rbx                  ; return records actually read into array
    pop r14
    pop r13
    pop r12
    pop rbx
    leave                        ; fix stack
    ret                          ; return

; compare - compares two customer records
; Arguments
; rdi - pointer to record 1
; rsi - pointer to record 2
; Return
; rax - negative, 0, positive number for comparison

compare:
    push rbp
    mov rbp,rsp 
    xor rax,rax                  ; clear rax
    mov eax,[rdi+c_balance]      ; load first id
    sub eax,[rsi+c_balance]      ; subtract second id
    leave
    ret

; sort_array - sorts array of customer records
; Arguments
; rdi - pointer to array
; rsi - number of records loaded in array
      
sort_array:
    push rbp
    mov rbp,rsp 
; qsort(array,n,4,compare)
; rdi already has array pointer
; rsi already has number of elements
    mov rdx,customer_size        ; number of bytes per record
    lea rcx,[compare]            ; address of compare function
    call qsort  
    leave
    ret
    
; print_array - prints array of customer records
; Arguments
; rdi - pointer to array
; rsi - number of records loaded in array
; Variables
; rbx - current position in array
; r12 - records left to print

segment .data

idfmt db `Id = %ld\n`,0
namefmt db `Name = %s\n`,0
addressfmt db `Address = %s\n`,0
balancefmt db `Balance = %ld\n`,0
rankfmt db `Rank = %ld\n`,0

segment .text
      
print_array:
    push rbp
    mov rbp,rsp 
    push rbx
    push r12
; initialize variables
    mov rbx,rdi                  ; start at beginning of array
    mov r12,rsi                  ; all records left to process
.nextrecord:
    lea rdi,[idfmt]    
    xor rsi,rsi
    mov esi,[rbx+c_id]
    xor rax,rax                  ; no floating point args
    call printf                  ; print line
    lea rdi,[namefmt]    
    lea rsi,[rbx+c_name]
    xor rax,rax                  ; no floating point args
    call printf                  ; print line
    lea rdi,[addressfmt]    
    lea rsi,[rbx+c_address]
    xor rax,rax                  ; no floating point args
    call printf                  ; print line
    lea rdi,[balancefmt]    
    xor rsi,rsi
    mov esi,[rbx+c_balance]
    xor rax,rax                  ; no floating point args
    call printf                  ; print line
    lea rdi,[rankfmt]    
    xor rax,rax
    mov al,[rbx+c_rank]
    mov rsi,rax
    xor rax,rax                  ; no floating point args
    call printf                  ; print line
    dec r12                      ; one fewer record
    add rbx,customer_size        ; point to next array element
    cmp r12,0
    jg .nextrecord               ; fall through if out of records
    pop r12
    pop rbx
    leave
    ret