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

global main,createset,commandloop,addtoset,unionsets,intersectsets,printset
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
.nextset:
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
; Functions addtoset,unionsets,intersectsets,printset
    mov r8,qword [command]       ; load read in command in rax as 8 byte value
    cmp r8,qword [addcmd]        ; compare read in command to "add"
    jne .tryunion                ; try next command
; read set and element and call function
    lea rdi,[setpmt]             ; load printf format for command prompt arg 1
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt no newline
    lea rdi,[numfmt]             
    lea rsi,[set1num]            
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
    lea rdi,[elmpmt]             ; load printf format for command prompt arg 1
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt no newline
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
    lea rdi,[setpmt]             ; load printf format for command prompt arg 1
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt no newline
    lea rdi,[numfmt]             
    lea rsi,[set1num]            
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
    lea rdi,[setpmt]             ; load printf format for command prompt arg 1
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt no newline
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
    lea rdi,[setpmt]             ; load printf format for command prompt arg 1
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt no newline
    lea rdi,[numfmt]             
    lea rsi,[set1num]            
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
    lea rdi,[setpmt]             ; load printf format for command prompt arg 1
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt no newline
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
    lea rdi,[setpmt]             ; load printf format for command prompt arg 1
    xor rax,rax                  ; no floating point args
    call printf                  ; print prompt no newline
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
    
; addtoset - add one element to one set
; arguments
; rdi - set number
; rsi - element number

addtoset:	                         
    push rbp                     
    mov rbp,rsp
; Load pointer to set structure into rcx
    mov rcx,[set_ptr_array+rdi*8]
; actually set the bit
    mov rax,rsi                  ; load the element number
    xor rdx,rdx                  ; clear for remainder
    mov r8,64                    ; load constant 64 for division
    idiv r8                      ; divide by 64 - result in rax, remainder in rdx = bit offset
    bts [rcx+setarrayptr+rax*8],rdx ; set the bit at the quad word
.done:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

; unionsets - union two sets and replace first with result
; arguments
; rdi - set 1 number
; rsi - set 2 number
; assuming that all sets are same max size

segment .data

set1ptr dq 0
set2ptr dq 0
qwordsperset dq 0
qwoffset dq 0
curset1qw dq 0
curset2qw dq 0

segment .text

unionsets:	                         
    push rbp                     
    mov rbp,rsp
; get pointers to the two sets
    mov r9,[set_ptr_array+rdi*8]
    mov [set1ptr],r9
    mov r9,[set_ptr_array+rsi*8]
    mov [set2ptr],r9
; calculate bytes per set - assume both sets have the same size
    mov r8,[set1ptr]             ; get size from first set
    mov rax,[r8+setsize]         ; set size offset
    xor rdx,rdx                  ; clear remainder
    mov r9,64                    ; 64 bits per qword
    div r9                       ; setsize/64 in rax now 
    inc rax                      ; 1 more qword for overflow into last qword
    mov [qwordsperset],rax       ; save number of qwords in the set
; loop through all of the qwords of the two sets
    mov qword[qwoffset],0        ; qwoffset is the index into the set. start at 0 less than qwsperset
.nextqword:
; get current quad words for both sets
    mov rcx,[qwoffset]           ; qword offset
    mov r8,[set1ptr]             ; pointer to set 1 array 
    mov rax,[r8+rcx*8]           ; load the qword for this part of the set into rax. 8 bytes per qword
    mov [curset1qw],rax          ; save this qword for set 1
    mov r8,[set2ptr]             ; pointer to set 1 array 
    mov rax,[r8+rcx*8]           ; load the qword for this part of the set into rax. 8 bytes per qword
    mov [curset2qw],rax          ; save this qword for set 2
; or for union
    mov rax,[curset1qw]          ; load set 1 current qw
    or  rax,[curset2qw]          ; or is union
; save updated set 1 qword
    mov rcx,[qwoffset]           ; qword offset
    mov r8,[set1ptr]             ; pointer to set 1 array 
    mov [r8+rcx*8],rax           ; save the qword back to the array
; advance to new qw if not done
    add qword [qwoffset],1       ; next qword of set
    mov rax,[qwoffset]           ; load quad word offset in rax
    cmp rax,[qwordsperset]       ; check qword in range
    jl .nextqword                ; process next qword

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

; intersectsets - intersect two sets and replace first with result
; arguments
; rdi - set 1 number
; rsi - set 2 number
; assuming that all sets are same max size

intersectsets:	                         
    push rbp                     
    mov rbp,rsp

; get pointers to the two sets
    mov r9,[set_ptr_array+rdi*8]
    mov [set1ptr],r9
    mov r9,[set_ptr_array+rsi*8]
    mov [set2ptr],r9
; calculate bytes per set - assume both sets have the same size
    mov r8,[set1ptr]             ; get size from first set
    mov rax,[r8+setsize]         ; set size offset
    xor rdx,rdx                  ; clear remainder
    mov r9,64                    ; 64 bits per qword
    div r9                       ; setsize/64 in rax now 
    inc rax                      ; 1 more qword for overflow into last qword
    mov [qwordsperset],rax       ; save number of qwords in the set
; loop through all of the qwords of the two sets
    mov qword[qwoffset],0        ; qwoffset is the index into the set. start at 0 less than qwsperset
.nextqword:
; get current quad words for both sets
    mov rcx,[qwoffset]           ; qword offset
    mov r8,[set1ptr]             ; pointer to set 1 array 
    mov rax,[r8+rcx*8]           ; load the qword for this part of the set into rax. 8 bytes per qword
    mov [curset1qw],rax          ; save this qword for set 1
    mov r8,[set2ptr]             ; pointer to set 1 array 
    mov rax,[r8+rcx*8]           ; load the qword for this part of the set into rax. 8 bytes per qword
    mov [curset2qw],rax          ; save this qword for set 2
; and for intersection
    mov rax,[curset1qw]          ; load set 1 current qw
    and rax,[curset2qw]          ; and is intersection
; save updated set 1 qword
    mov rcx,[qwoffset]           ; qword offset
    mov r8,[set1ptr]             ; pointer to set 1 array 
    mov [r8+rcx*8],rax           ; save the qword back to the array
; advance to new qw if not done
    add qword [qwoffset],1       ; next qword of set
    mov rax,[qwoffset]           ; load quad word offset in rax
    cmp rax,[qwordsperset]       ; check qword in range
    jl .nextqword                ; process next qword

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

segment .data

setptr dq 0
cursetqw dq 0  
bitoffset dq 0
elmformat db `%ld\n`,0

segment .text

printset:	                         
    push rbp                     
    mov rbp,rsp

; get set pointer
    mov r8,[set_ptr_array+rdi*8]
    mov [setptr],r8              ; save set pointer
; calculate bytes per set 
    mov rax,[r8+setsize]         ; set size offset
    xor rdx,rdx                  ; clear remainder
    mov r9,64                    ; 64 bits per qword
    div r9                       ; setsize/64 in rax now
    inc rax                      ; 1 more qword for overflow into last qword
    mov [qwordsperset],rax       ; save number of qwords in the set
    mov qword[qwoffset],0        ; qwoffset is the index into the words of the set.
.nextqword:
    mov rcx,[qwoffset]           ; qword offset
    mov r8,[setptr]              ; pointer to set
    mov r9,[r8+setarrayptr]      ; pointer to set array
    mov rax,[r9+rcx*8]           ; load the qword for this part of the set into rax. 8 bytes per qword
    mov [cursetqw],rax           ; load the qword for this part of the set into cursetqw
    mov qword [bitoffset],0      ; initialize bit offset to 0, max < 64
.nextbit:
    mov rax,[cursetqw]           ; restore the qword for this part of the set into rax
    mov r8,[bitoffset]           ; restore the bit offset to rbx
    bt rax,r8                    ; test for the bit
    jnc .noprint                 ; no carry = bit is zero, not element of set
; code to print element number within the set is here
    lea rdi,[elmformat]          ; format to print an element number on a line
    mov rsi,[qwoffset]           ; load qw offset
    mov r8,64
    imul rsi,r8                  ; multiply to get bit offset of bit 0 of the qword
    add rsi,[bitoffset]          ; add bit offset to get element number in rax
    xor eax,eax                  ; no floating point args
    call printf                  ; print a line
.noprint:   
    add qword [bitoffset],1      ; next bit
    mov rax,[bitoffset]          ; load bit offset
    mov r8,64
    cmp rax,r8                   ; check bit number in range 0-63
    jl .nextbit                  ; process next bit
    add qword [qwoffset],1       ; next qword of set
    mov rax,[qwoffset]           ; load quad word offset in rax
    cmp rax,[qwordsperset]       ; check qword in range
    jl .nextqword                ; process next qword

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
