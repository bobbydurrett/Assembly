; Adler-32 checksum reading from stdin
; See adler32.c
; Registers used for varables:
; a              r12
; b              r13
; index          r14
; checksum       r15
; datbuf address rbx
; current byte datbuf[index] r11 - don't need to preserve

           segment .bss
datbuf     resb 1024                  ; one kilobyte datbuf
           segment .data
MOD_ADLER  dq 65521                   ; constant for mod operations
pformat    db "Adler-32 checksum of stdin = %ld",0x0a,0      
           segment .text
           global main
           extern stdin
           extern fgets
           extern printf
main:
           push rbp                   
           mov rbp,rsp
           push r12                   ; preserve registers
           push r13
           push r14
           push r15
           push rbx
           push rbx                   ; keep 16 byte boundary on stack
           mov r12,1                  ; a = 1
           xor r13,r13                ; b = 0
           lea rbx,[datbuf]           ; store datbuf address
getnextdatbuf:
           mov rdi,rbx                ; datbuf address first argument
           mov rsi,1024               ; datbuf size in bytes
           mov rdx, [stdin]           ; move stdin FILE pointer to rdx
           xor eax,eax                ; no floating point args
           call fgets                 ; read a datbuf
           cmp rax,rbx                ; compare return to datbuf address
           jne computechecksum        ; done with outer loop
           xor r14,r14                ; index = 0
nextbyte:
           movsx r11,byte [rbx+r14]   ; get datbuf[index]
           cmp r11,0                  ; check for 0 byte
           je getnextdatbuf           ; done with datbuf
           xor rdx,rdx                ; clear rdx for division
           mov rax,r12                ; load a into rax for addition
           add rax,r11                ; add datbuf[index]
           idiv qword [MOD_ADLER]     ; get mod 65521 in rdx
           mov r12,rdx                ; a = (a + datbuf[index]) % MOD_ADLER
           xor rdx,rdx                ; clear rdx for division
           mov rax,r12                ; load a into rax for addition
           add rax,r13                ; add b
           idiv qword [MOD_ADLER]     ; get mod 65521 in rdx
           mov r13,rdx                ; b = (b + a) % MOD_ADLER;
           inc r14                    ; index++
           jmp nextbyte               ; process next byte
computechecksum:
           mov r15,r13                ; load b
           shl r15,16                 ; b << 16
           or r15,r12                 ; checksum = (b << 16) | a
           lea rdi,[pformat]          ; printf format arg 1
           mov rsi,r15                ; checksum arg 2   
           xor eax,eax                ; no floating point args
           call printf                ; read a line
           pop rbx                    ; restore registers
           pop rbx                   
           pop r15                   
           pop r14
           pop r13
           pop r12
           xor rax,rax                ; return code 0
           leave                      ; fix stack
           ret                        ; return
