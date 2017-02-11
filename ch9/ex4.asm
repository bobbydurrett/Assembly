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

           segment .text
           global main
           global getcommand
           global addcommand
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
           ; call print command here
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
           bts [allsets+rbx],rdx                 ; set the bit at the quad word indexed by rbx and the bit number in rdx
           leave
           ret