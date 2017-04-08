; Chapter 13 Exercise 2
; 10 sets
; Each set will have 10,000 elements potentially.
; Set can hold an integer element from 0 to 9999.
; Command loop will prompt for four commands:
; add setnum elementnum
; union set1num set2num 
; insersec set1num set2num 
; print setnum  
; setnum is an integer 0 to 9
; elementnum is an integer 0 to 9999
; quit will exit the program

global main,createset,commandloop,addtoset,unionsets,insersectsets,printset
extern printf,scanf,malloc

segment .bss

set_ptr_array resq 10            ; array of 10 pointers to sets

segment .data

    struc setstruc               ; Structure for a set
setsize resq 1                   ; size of the set - in bits
setarrayptr resq 1               ; pointer to an array with enough space to hold size bits
    endstruc

segment .text

main:	                         
    push rbp                     
    mov rbp,rsp      
   
; create 10 sets
    xor rbx,rbx                  ; rbx is loop counter for 10 sets
.nextset 
    mov rdi,10000                ; get set of size 10,000
    call createset               ; create set
    mov [set_ptr_array+rbx*8],rax ; save pointer to allocated structure
    inc rbx                      ; inc counter
    cmp rbx,10                   ; fall through if 10 or more
    jl .nextset

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
; add setnum elementnum
; union set1num set2num 
; insersec set1num set2num 
; print setnum  
; quit
; It takes a pointer to a set structure as an argument in rdi

segment .data

cmdfmt db "%8s",0                ; max 8 byte command
numfmt db "%ld",0                ; long number
command dq 0                  ; 8 byte buffer to read command into 
addcmd db "add",0,0,0,0,0    ; strings to compare scanf buffer to
unioncmd db "union",0,0,0      ; have to be 8 bytes each
intercmd db "intersec"
printcmd db "print",0,0,0
quitcmd db "quit",0,0,0,0
cmdpmt db "Enter command (add,union,intersec,print,quit): ",0 
setpmt db "Enter set (0-9): ",0 
elmpmt db "Enter element number (0-9999): ",0 
elementnum dq 0
set1num dq 0
set2num dq 0

segment .text

commandloop:	                         
    push rbp                     
    mov rbp,rsp    
    
.retry:
; Print command prompt
    lea rdi,[cmdpmt]             ; load printf format for command prompt arg 1
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt no newline
; Read command using scanf
    mov qword [command],0        ; clear command from earlier prompts
    lea rdi,[cmdfmt]             
    lea rsi,[command]            ; pointer to command being read in arg 2
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
; Process command - add,union,intersec,print,quit
; Functions addtoset,unionsets,insersectsets,printset
    mov r8,qword [command]       ; load read in command in rax as 8 byte value
    cmp r8,qword [addcmd]        ; compare read in command to "add"
    jne .tryunion                ; try next command
; read set and element and call function
    lea rdi,[numfmt]             
    lea rsi,[set1num]            
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
    lea rdi,[numfmt]             
    lea rsi,[elementnum]         
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
    mov rdi,[set1num]
    mov rsi,[elementnum]
    call addtoset
    jmp .retry
.tryunion:
    cmp r8,qword [unioncmd]      
    jne .tryintersec             ; try next command
; read two set nums and call function
    lea rdi,[numfmt]             
    lea rsi,[set1num]            
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
    lea rdi,[numfmt]             
    lea rsi,[set2num]         
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
    mov rdi,[set1num]
    mov rsi,[set2num]
    call unionsets
    jmp .retry
.tryintersec:
    cmp r8,qword [intercmd]     
    jne .tryprint                ; try next command
; read two set nums and call function
    lea rdi,[numfmt]             
    lea rsi,[set1num]            
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
    lea rdi,[numfmt]             
    lea rsi,[set2num]         
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
    mov rdi,[set1num]
    mov rsi,[set2num]
    call intersectsets
    jmp .retry
.tryprint:
    cmp r8,qword [printcmd]      
    jne .tryquit
; read one set num and call function
    lea rdi,[numfmt]             
    lea rsi,[set1num]            
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
    mov rdi,[set1num]
    call printset
    jmp .retry
.tryquit:
    cmp r8,qword [quitcmd]      
    jne .retry
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
