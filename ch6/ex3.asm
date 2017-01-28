; Calulates the average of four
; grades giving the remainder of the
; integer division
    section .data
grade1 dq 100
grade2 dq 90
grade3 dq 80
grade4 dq 70
ave    dq 0
rem    dq 0
       section .text
       global start
start:
       mov rax,[grade1] ; Load first grade in rax
       add rax,[grade2] ; Add 2nd grade to rax 
       add rax,[grade3] ; Add 3rd grade to rax 
       add rax,[grade4] ; Add 4th grade to rax 
       mov rbx,4        ; Load 4 into rbx
       idiv rax,rbx       ; Divide total of grades by 4
       mov [ave],rax    ; Save average from rax
       mov [rem],rdx    ; Save remainder from rdx
; exit with return code 0
       mov eax,60
       mov edi,0
       syscall
       end
