; Chapter 17 Exercise 2
; Called by ex2v3.c
; See C implementation in ex2v1.c
; This mostly register version of ex2v2.asm
;
; extern long substring(unsigned char *str1,unsigned char *str2,unsigned char *commonsub,long length);
;

global substring
extern strncpy

; substring finds the longest commonsub substring between two strings.
; Arguments:
; rdi pointer to str1
; rsi pointer to str2
; rdx pointer to buffer for returned substring - commonsub
; rcx length of str1,str2,commonsub
; Variables:
; rbx length
; r10 str1
; r11 str2
; r12 first1
; r13 first2
; r14 cur1
; r15 cur2

segment .data

commonsub dq 0                   ; pointer to buffer for returned commonsub string
len_longest dq 0                 ; length of the longest commonsub substring
start_longest dq 0               ; index into str1 of the first character of the substring

segment .text

substring:	         
    push rbp                     
    mov rbp,rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    push r15
; save arguments
    mov r10,rdi
    mov r11,rsi
    mov [commonsub],rdx
    mov rbx,rcx
; clear variables
    xor rax,rax                  ; rax = 0
    mov [len_longest],rax
    mov [start_longest],rax
    xor r12,r12
    xor r13,r13
    xor r14,r14
    xor r15,r15
; outer loop
.toploop1:
    mov rax,r12
    cmp r12,rbx
    jge .endloop1                ; check for first1 < length
; next loop
    xor r13,r13             ; first2 = 0
.toploop2:
    cmp r13,rbx
    jge .endloop2                ; check for first2 < length
; check for equal first bytes
    mov r8,r10 
    add r8,r12                  
    mov r9,r11
    add r9,r13     
    mov al,byte [r8]             ; al is str1[first1]
    mov dl,byte [r9]             ; dl is str2[first1]
    cmp al,dl
    jne .skipif                  ; outer if failed
; check substring starting at first1,first2
    mov r14,r12
    inc r14                   ; cur1 = first1 + 1
    mov r15,r13
    inc r15                   ; cur2 = first2 + 1
.toploop3:
    cmp r14,rbx
    jge .endloop3                ; check cur1 < length
    mov rcx,r15
    cmp r15,rbx
    jge .endloop3                ; check cur2 < length
    mov r8,r10 
    add r8,r14                  
    mov r9,r11
    add r9,r15     
    mov al,byte [r8]             ; al is str1r14
    mov dl,byte [r9]             ; dl is str2r15
    cmp al,dl  
    jne .endloop3                ; str1[cur1] != str2[cur2]
    inc r14                      ; cur1++
    inc r15                      ; cur2++
    jmp .toploop3
.endloop3:
    mov rax,r14
    sub rax,r12                  ; rax is cur1 - first1
    mov rcx,[len_longest]
    cmp rax,rcx
    jle .skipif
    mov [len_longest],rax        ; len_longest = cur1 - first1
    mov [start_longest],r12      ; start_longest = first1;
.skipif:
    inc r13                      ; first2++
    jmp .toploop2
.endloop2:
    inc r12                      ; first1++
    jmp .toploop1
.endloop1:
; copy longest substring to output
    mov rdi,[commonsub]
    mov rsi,r10
    mov rax,[start_longest]
    add rsi,rax                  ; rsi is str1+start_longest
    mov rdx,[len_longest]
    call strncpy
; return len_longest
    mov rax,[len_longest]
    pop r15
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave                        ; fix stack
    ret                          ; return

