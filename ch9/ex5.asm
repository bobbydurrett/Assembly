; Bitonic sequence checker
; Reads up to 100 numbers from stdin
; Should be increasing and then decreasing or rotatable.
; I guess find the first element that is larger than the
; previous one and previous element has to be the valley.
; Then find the first element from there that goes down. 
; Previous element is the peak. every element after peak has
; to be le prev one until we get back to the valley following
; off the end of the array to the beginning.
           segment .bss
a          resq 100                              ; array of quads
           segment .data
longscan   db "%ld",0                                    ; read long integer - qword
arraysize  dq 0                                          ; number of elements in array
maxsize    dq 100                                        ; max size of array
state      dq 0     
; state variable current state of going up or down
; 1 start state or equal
; 2 ascending
; 3 descending
; After passing through the array and wrapping around to the first element again
; can only be two switches in direction
dirchanges dq 0
currindex  dq 0
bitfmt     db "Is bitonic",0x0a,0 
notbitfmt  db "Is not bitonic",0x0a,0 
descended  dq 0                          ; set to 1 if ever in descending state
           segment .text
           global main
           global loadarray
           global isbitonic
           extern scanf
           extern printf
main:
           push rbp
           mov rbp,rsp
           call loadarray
           call isbitonic
           xor eax,eax                           ; return code 0
           leave                                 ; fix stack
           ret                                   ; return
loadarray:
           push rbp
           mov rbp,rsp
.nextnumber:
           lea rdi,[longscan]                    ; read a number
           mov rax,[arraysize]                   ; old arraysize is index into new element of array
           lea rsi,[a+rax*8]                     ; read directly into array element
           xor eax,eax                           ; no floating point args
           call scanf                            ; read a line
           cmp eax,0                             ; check for EOF
           jle .done                             ; exit if no more input
           add qword [arraysize],1               ; one more value read in
           jmp .nextnumber
.done:
           leave
           ret
isbitonic:
           push rbp
           mov rbp,rsp
.looptop:
           mov rax,[currindex]                   ; load current index into array
           cmp rax,[arraysize]                   ; compare to size of array
           jge .passcomplete                     ; pass through array is complete
           cmp rax,0
           je .nextelement                       ; can't compare to previous element if on first.
           mov rbx,[a+rax*8]                     ; get current element in rbx
           mov rcx,[a+rax*8-8]                   ; get prev element in rbx
           cmp rcx,rbx                           ; compare
           je .equal
           cmp rcx,rbx                           ; compare
           jl .less
; prev element greater if we got here so descending
           cmp qword [state],2
           jne .notascending
           add qword [dirchanges],1                    ; already ascending so now have changed direction
.notascending:
           mov qword [state],3                         ; state in now descending
           mov qword [descended],1
           jmp .nextelement                      ; go to next element
.equal:
           jmp .nextelement                      ; go to next element, same state
.less:
; prev element less if we got here so ascending
           cmp qword [state],3
           jne .notdescending
           add qword [dirchanges],1                    ; already descending so now have changed direction
.notdescending:
           mov qword [state],2                         ; state in now ascending
.nextelement:
           add qword [currindex],1                     ; advance currindex
           jmp .looptop
.passcomplete:
; at this point we have made one full pass through the array and counted the number of direction changes.
; need to compare the value of the last element of the array to the value of the first element.
; if the first element is equal then we are done - there are no more direction changes.
; if the first element is less than the last then the direction is descending. check the state and
; bump up the direction changes if currently ascending. Opposite if the first element is greater than the last.
; After all of this is done one or two state changes is bitonic otherwise not.
           mov rax,[arraysize]                   ; load array size
           dec rax                               ; subtract 1
           mov rbx,[a+rax*8]                     ; get last element in rbx
           mov rcx,[a]                           ; get first element in rcx
           cmp rcx,rbx                           ; compare
           je .nodirchange
           cmp rcx,rbx                           ; compare
           jl .descending
; ascending if got here
           cmp qword [state],3
           jne .nodirchange
           add qword [dirchanges],1                    ; changed direction
           jmp .nodirchange
.descending:
; descending if got here
           cmp qword [state],2
           jne .nodirchange
           add qword [dirchanges],1                    ; changed direction
           jmp .nodirchange
.nodirchange:
           cmp qword [dirchanges],1
           jne .check2changes
           cmp qword [descended],1
           je .bitonic
.check2changes:
           cmp qword [dirchanges],2
           je .bitonic
; not bitonic if got here
           lea rdi,[notbitfmt]                   ; setting up read of one line fmt arg 1
           xor eax,eax                           ; no floating point args
           call printf                           ; print a line
           jmp .done
.bitonic:
           lea rdi,[bitfmt]                      ; setting up read of one line fmt arg 1
           xor eax,eax                           ; no floating point args
           call printf                           ; print a line
; bitonic if got here
.done:
           leave
           ret