; Chapter 13 Exercise 1
; Set will have 10,000 elements potentially.
; Set can hold an integer element from 0 to 9,999.
; Command loop will prompt for three commands:
; add elementnum
; remove elementnum
; test elementnum
; test will print a message saying whether the element is in the set.
; elementnum is an integer 0 to 9,999
; quit will exit the program

; Non-float arguments in these registers:
; rdi, rsi, rdx, rcx, r8 and r9
; rax contains the number of floating point arguments
; xmm0 to xmm7 contain the float arguments
; These registers must be preserved across function calls:
; rbx, rsp, rbp, r12-r15
; rax and rdx are the integer return registers
; xmm0 and xmm1 are the float return resgisters
; http://www.nasm.us/links/unix64abi

global main,createset,commandloop,addtoset,removefromset,testinset
extern printf,scanf,malloc

segment .data

    struc setstruc               ; Structure for a set
setsize resq 1                   ; size of the set - in bits
setarrayptr resq 1               ; pointer to an array with enough space to hold size bits
    endstruc

setptr dq 0                      ; pointer to the struct that is the set

segment .text

main:	                         
    push rbp                     
    mov rbp,rsp      
    
    mov rdi,10000                ; get set of size 10,000
    call createset               ; create set
    mov [setptr],rax             ; save pointer to allocated structure
    
    call commandloop             ; loop through running commands

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

; create set takes desired set size as argument in rdi
; returns pointer to set structure in rax

segment .data

temp_set_size dq 0
temp_set_ptr dq 0
bits_per_qword dq 64
bytes_per_qword dq 8

segment .text

createset:	                         
    push rbp                     
    mov rbp,rsp     
    
    mov [temp_set_size],rdi      ; save desired set size

    mov rdi,setstruc_size        ; size of structure argument for malloc
    call malloc                  ; allocate memory
    mov [temp_set_ptr],rax       ; save pointer to allocated structure
    
    mov rbx,[temp_set_size]      ; save set size
    mov [rax+setsize],rbx        
    
    mov rax,[temp_set_size]      ; calculate bytes needed for set size in bits
    xor rdx,rdx                  ; clear remainder
    div qword [bits_per_qword]   ; 64 bits per qword
    inc rax                      ; 1 more qword for overflow into last qword
    mul qword [bytes_per_qword]  ; multiply by 8 to get bytes for malloc
    
    mov rdi,rax                  ; move argument to malloc
    call malloc                  ; allocate memory
    mov rbx,[temp_set_ptr]
    mov [rbx+setarrayptr],rax    ; save pointer to set array

    mov rax,[temp_set_ptr]       ; return pointer to allocated structure
    leave                        ; fix stack
    ret                          ; return

commandloop:	                         
    push rbp                     
    mov rbp,rsp                  

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

addtoset:	                         
    push rbp                     
    mov rbp,rsp                  

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

removefromset:	                         
    push rbp                     
    mov rbp,rsp                  

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

testinset:	                         
    push rbp                     
    mov rbp,rsp                  

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
