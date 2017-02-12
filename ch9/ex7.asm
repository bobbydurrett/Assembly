; check for balanced parentheses
; 
           segment .bss
parray     resb 80                              ; zero terminated array of parentheses
           segment .data
inputfmt   db "%79s",0                          ; up to 79 parentheses
leftparen  db "("
rightparen db ")"
           segment .text
           global main
           global isbalanced
           extern scanf
           extern printf
main:
           push rbp
           mov rbp,rsp
           lea rdi,[inputfmt]                    ; format for string read
           lea rsi,[parray]                      ; pointer to string buffer
           xor eax,eax                           ; no floating point args
           call scanf                            ; read a line
           mov rdi,0                             ; beginning of entire string
           mov rsi,79                            ; end of string - points to a zero
           call isbalanced
           xor eax,eax                           ; return code 0
           leave                                 ; fix stack
           ret                                   ; return
; Returns 1 in eax if string is balanced parentheses
; Two parameters
; rdi - array index of start of string
; rsi - array index of end of string
; if rdi points to zero is empty string return 1
; assumes array is all parentheses followed by a zero
; for each ( add 1. for each ) subtract 1. when balance reaches zero you have the match point.
; if you reach a 0 without a match point or if the balance goes below zero return a failure.
; recursively call isbalanced on the string in between the first ( and the match point if there
; are 1 or more parentheses between.
; also recursively call isbalanced for the remainder of the string after the match point.
; should always at least be a trailing zero that will eventually be an empty string.
startindex equ 0
endindex   equ 8
matchindex equ 16
balance    equ 24
isbalanced:
           push rbp
           mov rbp,rsp
           sub rsp,32                           ; room for four qw variables on stack
           mov [rsp+startindex],rdi             ; save startindex
           mov [rsp+matchindex],rdi             ; start matchindex at startindex
           mov [rsp+endindex],rsi               ; save endindex
           mov qword [rsp+balance],0            ; initialize balance = 0
; check for empty string
           mov al,byte [parray+rdi]             ; load first byte
           cmp al,0                             ; check if zero
           jne .notempty                        ; continue on
           mov eax,1                            ; success
           jmp .done
.notempty:
; check each byte incrementing and decrementing balance
           mov rbx,[rsp+matchindex]             ; get current matchindex
           mov al,byte [parray+rbx]             ; load byte at current matchindex
           cmp al,byte [leftparen]              ; check for (
           jne .checkright
           add qword [rsp+balance],1            ; add 1 for (
           jmp .nextbyte
.checkright:
           cmp al,byte [rightparen]              ; check for )
           jne .iszero
           sub qword [rsp+balance],1             ; sub 1 for )
           jmp .nextbyte
.iszero:
           mov rbx,qword [rsp+balance]           ; load balance
           cmp rbx,0                             ; see if balance==0
           jne .fail
           mov eax,1                             ; success
           jmp .done
.fail      xor eax,eax                           ; failure
           jmp .done
.nextbyte:
           mov rbx,qword [rsp+balance]           ; load balance
           cmp rbx,0                             ; see if balance < 0
           jl .fail                              ; fail if < 0
           cmp rbx,0
           je .recurse                           ; need to do recursive calls
           add [rsp+matchindex],1                ; advance to next byte for matchindex
           jmp .notempty                         ; check next byte
.recurse:
; at this point matchindex points to the byte that has the final )
; if matchindex - startindex > 1 then call recursively with
; startindex = startindex +1 and endindex = matchindex -1
           mov rbx,qword [rsp+matchindex]              ; get matchindex
           sub rbx,qword [rsp+startindex]              ; subtract startindex
           cmp rbx,1
           jle .skiprecurse
           mov rdi,qword [rsp+startindex]              ; load startindex for recursive call
           inc rdi                                     ; new start is startindex + 1
           mov rsi,qword [rsp+matchindex]              ; load matchindex for recursive call
           dec rsi                                     ; new end is matchindex - 1
           call isbalanced
           cmp eax,1                                   ; is substring balanced?
           jne .fail                                   ; fail if not
; If we got here then the substring was a success. Now do recursive call on the rest of the string.
; Start is matchindex + 1
; end is same as current end
.skiprecurse:
           mov rdi,qword [rsp+matchindex]              ; load matchindex for recursive call
           inc rdi                                     ; new start is matchindex + 1
           mov rsi,qword [rsp+endindex]                ; load endindex for recursive call
           dec rsi                                     ; new end is matchindex - 1
           call isbalanced
           cmp eax,1                                   ; is substring balanced?
           jne .fail                                   ; fail if not
; eax is 1 if we get here so let fall through for success
.done:
           leave
           ret
