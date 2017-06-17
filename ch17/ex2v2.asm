; Chapter 17 Exercise 2
; Called by ex2v2.c
; See C implementation in ex2v1.c
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

segment .data

str1 dq 0                        ; pointer to first string
str2 dq 0                        ; pointer to second string
commonsub dq 0                   ; pointer to buffer for returned commonsub string
length dq 0                      ; length of all three buffers
len_longest dq 0                 ; length of the longest commonsub substring
start_longest dq 0               ; index into str1 of the first character of the substring
first1 dq 0                      ; index of the first character in str1
first2 dq 0                      ; index of the first char in str2
cur1 dq 0                        ; index of current char str1
cur2 dq 0                        ; index of current char str2

segment .text

substring:	         
    push rbp                     
    mov rbp,rsp
; save arguments
    mov [str1],rdi
    mov [str2],rsi
    mov [commonsub],rdx
    mov [length],rcx
; clear variables
    xor rax,rax                  ; rax = 0
    mov [len_longest],rax
    mov [start_longest],rax
    mov [first1],rax
    mov [first2],rax
    mov [cur1],rax
    mov [cur2],rax
; outer loop
.toploop1:
    mov rax,[first1]
    mov rcx,[length]
    cmp rax,rcx
    jge .endloop1                ; check for first1 < length
; next loop
    xor rax,rax
    mov [first2],rax             ; first2 = 0
.toploop2:
    mov rax,[first2]
    mov rcx,[length]
    cmp rax,rcx
    jge .endloop2                ; check for first2 < length
; check for equal first bytes
    mov rax,[first1]
    mov r8,[str1] 
    add r8,rax                  
    mov rax,[first2]
    mov r9,[str2]
    add r9,rax     
    mov al,byte [r8]             ; al is str1[first1]
    mov dl,byte [r9]             ; dl is str2 [first2]
    cmp al,dl
    jne .skipif                  ; outer if failed
; check substring starting at first1,first2
    mov rax,[first1]
    inc rax
    mov [cur1],rax               ; cur1 = first1 + 1
    mov rax,[first2]
    inc rax
    mov [cur2],rax               ; cur2 = first2 + 1
.toploop3:
    mov rax,[length]
    mov rcx,[cur1]
    cmp rcx,rax
    jge .endloop3                ; check cur1 < length
    mov rcx,[cur2]
    cmp rcx,rax
    jge .endloop3                ; check cur2 < length
    mov rax,[cur1]
    mov r8,[str1] 
    add r8,rax                  
    mov rax,[cur2]
    mov r9,[str2]
    add r9,rax     
    mov al,byte [r8]             ; al is str1[cur1]
    mov dl,byte [r9]             ; dl is str2[cur2]
    cmp al,dl  
    jne .endloop3                ; str1[cur1] != str2[cur2]
    mov rax,[cur1]
    inc rax
    mov [cur1],rax               ; cur1++
    mov rax,[cur2]
    inc rax
    mov [cur2],rax               ; cur2++
    jmp .toploop3
.endloop3:
    mov rax,[cur1]
    mov rcx,[first1]
    sub rax,rcx                  ; rax is cur1 - first1
    mov rcx,[len_longest]
    cmp rax,rcx
    jle .skipif
    mov [len_longest],rax        ; len_longest = cur1 - first1
    mov rax,[first1]
    mov [start_longest],rax      ; start_longest = first1;
.skipif:
    mov rax,[first2]
    inc rax
    mov [first2],rax             ; first2++
    jmp .toploop2
.endloop2:
    mov rax,[first1]
    inc rax
    mov [first1],rax             ; first1++
    jmp .toploop1
.endloop1:
; copy longest substring to output
    mov rdi,[commonsub]
    mov rsi,[str1]
    mov rax,[start_longest]
    add rsi,rax                  ; rsi is str1+start_longest
    mov rdx,[len_longest]
    call strncpy
; return len_longest
    mov rax,[len_longest]
    leave                        ; fix stack
    ret                          ; return

