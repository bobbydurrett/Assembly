; Chapter 13 Exercise 1
; Set will have 10,000 elements potentially.
; Set can hold an integer element from 0 to 9999.
; Command loop will prompt for three commands:
; add elementnum
; remove elementnum
; test elementnum
; test will print a message saying whether the element is in the set.
; elementnum is an integer 0 to 9999
; quit will exit the program

; Non-float arguments in these registers:
; rdi, rsi, rdx, rcx, r8 and r9
; rax contains the number of floating point arguments
; xmm0 to xmm7 contain the float arguments
; These registers must be preserved across function calls:
; rbx, rsp, rbp, r12-r15
; rax and rdx are the integer return registers
; xmm0 and xmm1 are the float return resgisters
; http://www.nasm.us/links/unix64abi

global main,createset,commandloop,addtoset,removefromset,testinset
extern printf,scanf,malloc

segment .data

    struc setstruc               ; Structure for a set
setsize resq 1                   ; size of the set - in bits
setarrayptr resq 1               ; pointer to an array with enough space to hold size bits
    endstruc

setptr dq 0                      ; pointer to the struct that is the set

segment .text

main:	                         
    push rbp                     
    mov rbp,rsp      
    
    mov rdi,10000                ; get set of size 10,000
    call createset               ; create set
    mov [setptr],rax             ; save pointer to allocated structure
 
    mov rdi,rax                  ; pass set pointer into commanloop
    call commandloop             ; loop through running commands

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

; create set takes desired set size as argument in rdi
; returns pointer to set structure in rax

segment .data

temp_set_size dq 0
temp_set_ptr dq 0
bits_per_qword dq 64
bytes_per_qword dq 8

segment .text

createset:	                         
    push rbp                     
    mov rbp,rsp     
    
    mov [temp_set_size],rdi      ; save desired set size

    mov rdi,setstruc_size        ; size of structure argument for malloc
    call malloc                  ; allocate memory
    mov [temp_set_ptr],rax       ; save pointer to allocated structure
    
    mov r8,[temp_set_size]       ; save set size
    mov [rax+setsize],r8        
    
    mov rax,[temp_set_size]      ; calculate bytes needed for set size in bits
    xor rdx,rdx                  ; clear remainder
    div qword [bits_per_qword]   ; 64 bits per qword
    inc rax                      ; 1 more qword for overflow into last qword
    mul qword [bytes_per_qword]  ; multiply by 8 to get bytes for malloc
    
    mov rdi,rax                  ; move argument to malloc
    call malloc                  ; allocate memory
    mov r8,[temp_set_ptr]
    mov [r8+setarrayptr],rax     ; save pointer to set array

    mov rax,[temp_set_ptr]       ; return pointer to allocated structure
    leave                        ; fix stack
    ret                          ; return

; commandloop prompts for the commands:
; add elementnum
; remove elementnum
; test elementnum
; quit
; It takes a pointer to a set structure as an argument in rdi

segment .data

scanformat db "%6s %ld",0        ; max 6 byte command plus long element number
command    dq 0                  ; 8 byte buffer to read command into 
addcmd     db "add",0,0,0,0,0    ; strings to compare scanf buffer to
removecmd  db "remove",0,0       ; have to be 8 bytes each
testcmd    db "test",0,0,0,0
quitcmd    db "quit",0,0,0,0
prompt     db "Enter command (add,remove,test,quit) and element number (0-9999): ",0 ; commandloop prompt 
elementnum dq 0
cloop_set_ptr dq 0

segment .text

commandloop:	                         
    push rbp                     
    mov rbp,rsp    
    
    mov [cloop_set_ptr],rdi      ; save set pointer
.retry:
; Print command prompt
    lea rdi,[prompt]             ; load printf format for command prompt arg 1
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt no newline
; Read command using scanf
    mov qword [command],0        ; clear command from earlier prompts
    lea rdi,[scanformat]         ; setting up read of one line fmt arg 1
    lea rsi,[command]            ; pointer to command being read in arg 2
    lea rdx,[elementnum]         ; pointer to element number being read in arg 3
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
; Process command - addtoset,removefromset,testinset
    mov r8,qword [command]       ; load read in command in rax as 8 byte value
    cmp r8,qword [addcmd]        ; compare read in command to "add"
    jne .tryremove               ; try next command
    mov rdi,[cloop_set_ptr]      ; set pointer is first argument
    mov rsi,[elementnum]         ; set element number is second argument
    call addtoset                ; add element to the set
    jmp .retry
.tryremove:
    cmp r8,qword [removecmd]     ; compare read in command to "remove"
    jne .trytest                 ; try next command
    mov rdi,[cloop_set_ptr]      ; set pointer is first argument
    mov rsi,[elementnum]         ; set element number is second argument
    call removefromset           ; remove element from the set
    jmp .retry
.trytest:
    cmp r8,qword [testcmd]       ; compare read in command to "test"
    jne .tryquit                 ; try next command
    mov rdi,[cloop_set_ptr]      ; set pointer is first argument
    mov rsi,[elementnum]         ; set element number is second argument
    call testinset               ; test if element is in the set
    jmp .retry
.tryquit:
    cmp r8,qword [quitcmd]       ; compare read in command to "quit"
    je .done
    jmp .retry
.done:            
    leave                        ; fix stack
    ret                          ; return
    
; addtoset adds an element to a set
; arguments:
; rdi - pointer to set structure
; rsi - the element number (0-9999) 

segment .text

addtoset:	                         
    push rbp                     
    mov rbp,rsp
; check element in range
    cmp rsi,0                    ; check element < 0
    jl .done
    cmp rsi,[rdi+setsize]
    jge .done                    ; >= set size is out of range
; actually set the bit
    mov rax,rsi                  ; load the element number
    xor rdx,rdx                  ; clear for remainder
    mov r8,64                    ; load constant 64 for division
    idiv r8                      ; divide by 64 - result in rax, remainder in rdx = bit offset
    bts [rdi+setarrayptr+rax*8],rdx ; set the bit at the quad word
.done:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

; removefromset removes an element from a set
; arguments:
; rdi - pointer to set structure
; rsi - the element number (0-9999) 

removefromset:	                         
    push rbp                     
    mov rbp,rsp                  
; check element in range
    cmp rsi,0                    ; check element < 0
    jl .done
    cmp rsi,[rdi+setsize]
    jge .done                    ; >= set size is out of range
; actually clear the bit
    mov rax,rsi                  ; load the element number
    xor rdx,rdx                  ; clear for remainder
    mov r8,64                    ; load constant 64 for division
    idiv r8                      ; divide by 64 - result in rax, remainder in rdx = bit offset
    btr [rdi+setarrayptr+rax*8],rdx ; clear(reset) the bit at the quad word
.done:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

; testinset checks if an element is in a set
; arguments:
; rdi - pointer to set structure
; rsi - the element number (0-9999) 

segment .data

insetfmt db `Element %ld is in the set\n`,0 ; bit found 
notinsetfmt db `Element %ld is not in the set\n`,0 ; bit found 

segment .text

testinset:	                         
    push rbp                     
    mov rbp,rsp                  
; check element in range
    cmp rsi,0                    ; check element < 0
    jl .done
    cmp rsi,[rdi+setsize]
    jge .done                    ; >= set size is out of range
; actually check the bit
    mov rax,rsi                  ; load the element number
    xor rdx,rdx                  ; clear for remainder
    mov r8,64                    ; load constant 64 for division
    idiv r8                      ; divide by 64 - result in rax, remainder in rdx = bit offset
    bt [rdi+setarrayptr+rax*8],rdx ; check the bit at the quad word
    jc .bitset
; element not in set
    lea rdi,[notinsetfmt]        ; load printf format for command prompt arg 1
; element number is still in rsi
    xor rax,rax                  ; no floating point args
    call printf                  ; print line
    jmp .done
.bitset:
; element is in set
    lea rdi,[insetfmt]        ; load printf format for command prompt arg 1
; element number is still in rsi
    xor rax,rax                  ; no floating point args
    call printf                  ; print line
.done:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
