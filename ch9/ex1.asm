; Electricity billing program
       segment .bss
custnm resb 65              ; String with replacement
       segment .data
kwhrs  dq 0                 ; kilowatt hours
scnfmt db "%64s %ld",0          ; 64 byte custname space kwhrs 8 bytes
prnfmt db "%s $%ld.%.2ld",0x0a,0  ; custname and dollars and cents of bill
prct   dq 100
       segment .text
       global main
       global bill
       extern scanf
       extern printf
main:
       push rbp
       mov rbp,rsp
nextline:
       lea rdi,[scnfmt]         ; setting up read of one line fmt arg 1
       lea rsi,[custnm]         ; pointer to cust name buffer arg 2
       lea rdx,[kwhrs]          ; kw hours arg 3 
       xor eax,eax              ; no floating point args
       call scanf               ; read a line
       cmp eax,0                ; check for EOF
       jle done                 ; go to end
       mov rdi,[kwhrs]          ; load kwhrs for billcalc
       xor rax,rax              ; clear rax
       call billcalc            ; returns bill amount in pennies in eax
       lea rdi,[prnfmt]         ; setting up read of one line fmt arg 1
       lea rsi,[custnm]         ; pointer to cust name buffer arg 2
       xor rdx,rdx              ; clear for division
       idiv qword[prct]         ; divide by 100
       mov rcx,rdx              ; remainder into rcx arg 4
       mov rdx,rax              ; dollars dividend rdx arg 3
       xor eax,eax              ; no floating point args
       call printf              ; read a line
       jmp nextline             ; get the next line
done:
       xor eax,eax              ; return code 0
       leave                    ; fix stack
       ret                      ; return
billcalc:
; calculate bill amount in pennies
; rdi has kilowatt hours
; first 1000 kwhrs is 2000 pennies
; 1 penny per hwhr after
       push rbp
       mov rbp,rsp 
       mov rax,2000             ; default is 2000 pennies
       cmp rdi,1000
       jle baserate
       sub rdi,1000             ; subtract 1000 from rdi is this ok?
       add rax,rdi              ; add the extra pennies
baserate:
       leave
       ret
