; Manipulate sets with commands
; 1000000 entries per set
; equals 15625 64 bit entries
; 10 sets makes 156250 total quads
; add,union,print, and quit commands
           segment .bss
allsets    resq 156250                           ; array of quads
           segment .data
scanformat db "%5s",0                            ; max 5 byte command
command    dq 0
addcmd     db "add",0,0,0,0,0
unioncmd   db "union",0,0,0
printcmd   db "print",0,0,0
quitcmd    db "quit",0,0,0,0
prompt     db "Enter command (add,union,print,quit): ",0  
setprompt  db "Enter set number (0-9): ",0  
elmprompt  db "Enter element number (0-999999): ",0  
setnumber  dq 0
elmnumber  dq 0
longscan   db "%ld",0                            ; read long integer
qwbits     dq 64
qwsperset  dq 15625
elmformat  db "%ld",0x0a,0
setoffset  dq 0
qwoffset   dq 0
cursetqw   dq 0
bitoffset  dq 0

           segment .text
           global main
           global getcommand
           global addcommand
           global printcommand
           extern scanf
           extern printf
main:
           push rbp
           mov rbp,rsp
.getnextcommand:
           call getcommand
           cmp rax,0                             ; check for add command
           jne .tryunion
           call addcommand
           jmp .getnextcommand
.tryunion:
           cmp rax,1                             ; check for union command
           jne .tryprint
           ; call union command here
           jmp .getnextcommand
.tryprint:
           cmp rax,2                             ; check for print command
           jne .done
           call printcommand
           jmp .getnextcommand
.done:
           xor eax,eax                           ; return code 0
           leave                                 ; fix stack
           ret                                   ; return
getcommand:
; Get add,union,print, and quit commands
; return 0,1,2,3 respecgtively
           push rbp
           mov rbp,rsp
.retry:
; Print command prompt
           lea rdi,[prompt]                      ; load printf format for command prompt arg 1
           xor eax,eax                           ; no floating point args
           call printf                           ; print prompt no newline
; Read command using scanf
           mov qword [command],0                 ; clear command from earlier prompts
           lea rdi,[scanformat]                  ; setting up read of one line fmt arg 1
           lea rsi,[command]                     ; pointer to command being read in arg 2
           xor eax,eax                           ; no floating point args
           call scanf                            ; read a line
; Process command
           mov rbx,qword [command]               ; load read in command in rax as 8 byte value
           mov rax,0                             ; return 0 for add
           cmp rbx,qword [addcmd]                ; compare read in command to "add"
           je .done
           mov rax,1                             ; return 1 for union
           cmp rbx,qword [unioncmd]              ; compare read in command to "union"
           je .done
           mov rax,2                             ; return 2 for print
           cmp rbx,qword [printcmd]              ; compare read in command to "print"
           je .done
           mov rax,3                             ; return 3 for quit
           cmp rbx,qword [quitcmd]               ; compare read in command to "quit"
           je .done
           jmp .retry
.done:            
           leave
           ret
addcommand:
; Prompt for a set number (0-9) and an element number (0-999999). 
; Set the bit for that set and and element
           push rbp
           mov rbp,rsp
; Prompt for set number
           lea rdi,[setprompt]                   ; load printf format
           xor eax,eax                           ; no floating point args
           call printf                           ; print prompt no newline
; Read set number using scanf
           lea rdi,[longscan]                    ; scanf format
           lea rsi,[setnumber]                   ; pointer to set number variable
           call scanf                            ; read a line
; Prompt for element number
           lea rdi,[elmprompt]                   ; load printf format
           xor eax,eax                           ; no floating point args
           call printf                           ; print prompt no newline
; Read set number using scanf
           lea rdi,[longscan]                    ; scanf format
           lea rsi,[elmnumber]                   ; pointer to element number variable
           xor eax,eax                           ; no floating point args
           call scanf                            ; read a line
; The ten sets are stored in allsets which is 156250 8 byte quadwords,
; 15625 per set. Need to calculate the offset into this set - i.e. which
; quadword we want and then the offset bit number which is 0-63.
           mov rbx,[setnumber]                   ; load the set number
           imul rbx,15625                        ; multiply by 15625 to get the offset in the array of qws
           mov rax,[elmnumber]                   ; load the element number
           xor rdx,rdx                           ; clear for remainder
           idiv qword [qwbits]                   ; divide by 64 - result in rax, remainder in rdx = bit offset
           add rbx,rax                           ; get full offset into the quad array
           bts [allsets+rbx*8],rdx               ; set the bit at the quad word indexed by rbx and the bit number in rdx. 8 bytes per qw
           leave
           ret
printcommand:
; THIS IS NOT YET WORKING!
; Prompt for a set number (0-9) and print the elements of that set.
           push rbp
           mov rbp,rsp
; Prompt for set number
           lea rdi,[setprompt]                   ; load printf format
           xor eax,eax                           ; no floating point args
           call printf                           ; print prompt no newline
; Read set number using scanf
           lea rdi,[longscan]                    ; scanf format
           lea rsi,[setnumber]                   ; pointer to set number variable
           call scanf                            ; read a line
; The ten sets are stored in allsets which is 156250 8 byte quadwords,
; 15625 per set. Need to calculate the offset into the prompted set and then
; look for 1 bits in each of the 15625 qwords. 
           mov rax,[setnumber]                   ; load the set number
           imul rax,15625                        ; multiply by 15625 to get the offset in the array of qws in rax
           mov [setoffset],rax                   ; save in setoffset
           mov qword[qwoffset],0                 ; qwoffset is the index into the 15625 words of the set. start at 0 less than qwsperset
.nextqword:
           mov rcx,[setoffset]                   ; load set offset
           add rcx,[qwoffset]                    ; add qword offset
           mov rax,[allsets+rcx*8]               ; load the qword for this part of the set into rax. 8 bytes per qword
           mov [cursetqw],rax                    ; load the qword for this part of the set into cursetqw
           mov qword [bitoffset],0               ; initialize bit offset to 0, max < qwbits
.nextbit:
           mov rax,[cursetqw]                    ; restore the qword for this part of the set into rax
           mov rbx,[bitoffset]                   ; restore the bit offset to rbx
           bt rax,rbx                            ; test for the bit
           jnc .noprint                          ; no carry = bit is zero, not element of set
; code to print element number within the set is here
           lea rdi,[elmformat]                   ; format to print an element number on a line
           mov rsi,[qwoffset]                    ; load qw offset
           imul rsi,[qwbits]                     ; multiply to get bit offset of bit 0 of the qword
           add rsi,[bitoffset]                   ; add bit offset to get element number in rax
           xor eax,eax                           ; no floating point args
           call printf                           ; print a line
.noprint:   
           add qword [bitoffset],1               ; next bit
           mov rax,[bitoffset]                   ; load bit offset
           cmp rax,[qwbits]                      ; check bit number in range 0-63
           jl .nextbit                           ; process next bit
           add qword [qwoffset],1                ; next qword of set
           mov rax,[qwoffset]                    ; load quad word offset in rax
           cmp rax,[qwsperset]                   ; check qword in range 0-15624
           jl .nextqword                         ; process next qword
; done if we reach here           
           leave
           ret