; Manipulate sets with commands
; 1000000 entries per set
; equals 15625 64 bit entries
; 10 sets makes 156250 total quads
; add,union,print, and quit commands
           segment .bss
;sets       resq 156250                           ; array of quads
           segment .data
scanformat db "%5s",0                            ; max 5 byte command
command    dq 0
addcmd     db "add",0,0,0,0,0
unioncmd   db "union",0,0,0
printcmd   db "print",0,0,0
quitcmd    db "quit",0,0,0,0
           segment .text
           global main
           global getcommand
           extern scanf
main:
           push rbp
           mov rbp,rsp
.getnextcommand:
           call getcommand
           cmp rax,0                             ; check for add command
           jne .tryunion
           ; call add command here
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
           lea rdi,[scanformat]                  ; setting up read of one line fmt arg 1
           lea rsi,[command]                     ; pointer to command being read in arg 2
           xor eax,eax                           ; no floating point args
           call scanf                            ; read a line
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
