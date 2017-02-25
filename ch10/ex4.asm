; Hash function tester.
; Based on hashtest.c

; Non-float arguments in these registers:
; rdi, rsi, rdx, rcx, r8 and r9
; rax contains the number of floating point arguments
; These registers must be preserved across function calls:
; rbx, rsp, rbp, r12-r15
; rax and rdx are the integer return registers

global hash
global get_collisions
global print_counts
global main
extern scanf
extern printf

segment .bss

collisions resd 99991
counts resd 1000
s resb 80

segment .data

multipliers:
    dd 123456789
    dd 234567891
    dd 345678912
    dd 456789123
    dd 567891234
    dd 678912345
    dd 789123456
    dd 891234567
    
scanffmt db "%79s",0
printffmt db "There were %d entries with %d collisions.",0xa,0

segment .text

; int hash ( unsigned char *s )
; rdi is s
; rcx is h
; rsi is i
; r8 is s[i]
; r9 division constants 8 and 99991
; returns hash code in rax

hash:	                     
    push rbp                     
    mov rbp,rsp
    xor rcx,rcx                  ;  h = 0
    xor rsi,rsi                  ;  i = 0
.startwhile:
    movzx r8,byte [rdi+rsi]      ;  s[i]
    cmp r8,0                     ;  end loop if s[i] == 0
    je .endwhile
    xor rdx,rdx                  ; clear rdx for mod
    mov rax,rsi                  ; load i for mod
    mov r9,8
    div r9                       ; i%8 is in rdx now
    movsxd rax,dword [multipliers+rdx*4]  ; multipliers[i%8] in rax
    xor rdx,rdx                  ; clear rdx for mul
    mul r8                       ; s[i] * multipliers[i%8] now in rax
    add rcx,rax                  ; h = h + s[i] * multipliers[i%8];
    inc rsi                      ; i++
    jmp .startwhile              ; next s[i]
.endwhile:
    xor rdx,rdx                  ; clear rdx for mod
    mov rax,rcx                  ; h in rax
    mov r9,99991
    div r9                       ; mod 99991
    mov rax,rdx                  ; h % 99991 in rax for return
    leave                        ; fix stack
    ret                          ; return
; void get_collisions
; rdi is i and argument to hash
; rax is h return of hash
; s is label in data segment
get_collisions:	                     
    push rbp                     
    mov rbp,rsp     
; initialize collisions to all -1
    xor rdi,rdi                  ; i = 0
.inittop:
    cmp rdi,99991                ; i < 99991    
    jge .initdone
    mov dword [collisions+rdi*4],-1    ; collisions[i] = -1
    inc rdi                      ; i++
    jmp .inittop
.initdone:
.whiletop:
    lea rdi,[scanffmt]           ; read a 79 byte string
    lea rsi,[s]                  ; s is 80 byte buffer
    xor eax,eax                  ; no floating point args
    call scanf                   ; read a line
    cmp eax,1                    ; check for EOF
    jne .whiledone               ; exit if no more input
    lea rdi,[s]                  ; s argument to hash
    call hash              
    inc dword [collisions+rax*4] ; collisions[h]++
    jmp .whiletop
.whiledone:
    leave                        ; fix stack
    ret                          ; return
; void print_counts
; rbx is i - preserved for printf call
; rdi is k
print_counts:	                     
    push rbp                     
    mov rbp,rsp
    push rbx
    push rbx
    xor rbx,rbx                  ; i=0
.topfor1:
    cmp rbx,99991                ; i < 99991
    jge .endfor1
    movsxd rdi,dword [collisions+rbx*4] ; k = collisions[i]
    cmp rdi,999                  ; if (k > 999) k = 999
    jle .lesstest
    mov rdi,999
.lesstest:
    cmp rdi,0                  ; if (k < 0) k = 0
    jge .cmpdone
    mov rdi,0
.cmpdone:
    inc dword [counts+rdi*4]   ; counts[k]++;
    inc rbx                    ; i++
    jmp .topfor1               ; loop again
.endfor1:

    xor rbx,rbx                  ; i=0
.topfor2:
    cmp rbx,1000                 ; i < 1000
    jge .endfor2
    cmp dword [counts+rbx*4],0   ; counts[i] > 0
    jle .noprint
; printf("There were %d entries with %d collisions.\n",counts[i],i); 
    lea rdi,[printffmt]        ; printf format arg 1
    movsxd rsi,dword [counts+rbx*4] ; counts[i] 
    mov rdx,rbx                ; i
    xor eax,eax                ; no floating point args
    call printf                ; print line
.noprint:
    inc rbx                    ; i++
    jmp .topfor2               ; loop again
.endfor2:
    pop rbx
    pop rbx
    leave                        ; fix stack
    ret                          ; return
main:	                     
    push rbp                     
    mov rbp,rsp     
; call the main functions    
    call get_collisions          
    call print_counts
; normal exit
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
