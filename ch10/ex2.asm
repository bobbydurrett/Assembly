; fill an array with random 4 byte integers
; and sort and do binary search on the array
; based on values passed from the user
           segment .data
asize      dq 0                     ; array size
aptr       dq 0                     ; pointer to array
i          dq 0                     ; array index
mod1k      dq 1000                  ; mod 1000 constant
longscan   db "%ld",0                                    ; read long integer - qword
searchkey  dq 0                     ; number to search for
foundfmt   db "%ld found at array index %ld",0x0a,0      ; found
notfmt     db "%ld not found in array",0x0a,0            ; not found
two        dq 2                     ; two
           segment .text
           global main
           global fillarray
           global sortarray
           global compare
           global binarysearch
           extern atol
           extern malloc
           extern random
           extern qsort
           extern scanf
           extern printf
main:
           push rbp
           mov rbp,rsp
; Get array size from command line arguments
           cmp rdi,2                ; check for two arguments, second is size
           jl .done
           mov rdi,qword [rsi+8]          ; load pointer to string which is array size number
           call atol                      ; convert character string to integer.
           mov [asize],rax                ; save array size 
; Call malloc to allocate the array memory
           mov rdi,[asize]                ; load array size
           imul rdi,4                     ; convert to bytes
           call malloc                    ; allocate memory
           mov [aptr],rax                 ; store pointer to array
; Fill the array
           call fillarray           ; fill array with random integers
; Sort the array
           call sortarray           ; sort the array
; Read number to search for using binary search
.nextsearch:
           lea rdi,[longscan]                    ; read a number
           lea rsi,[searchkey]                   ; load number to search for
           xor eax,eax                           ; no floating point args
           call scanf                            ; read a line
           cmp eax,1                             ; check for EOF
           jne .done                             ; exit if no more input
           call binarysearch
           cmp rax,-1
           je .notfound
           lea rdi,[foundfmt]         ; setting up read of one line fmt arg 1
           mov rsi,[searchkey]        ; search key arg2   
           mov rdx,rax                ; array index
           xor eax,eax                ; no floating point args
           call printf                ; read a line
           jmp .nextsearch
.notfound:
           lea rdi,[notfmt]         ; setting up read of one line fmt arg 1
           mov rsi,[searchkey]        ; search key arg2   
           xor eax,eax                ; no floating point args
           call printf                ; read a line
           jmp .nextsearch
.done:
           xor eax,eax              ; return code 0
           leave                    ; fix stack
           ret                      ; return
fillarray:
; add asize entries into array pointed to by aptr
; call unix function random() 
           push rbp
           mov rbp,rsp 
.looptop:
           call random              ; get random int in rax
           xor rdx,rdx              ; clear rdx for division
           idiv qword [mod1k]       ; get mod 1000 of random number in rdx/edx
           mov r8,[i]               ; load array index
           mov r9,[aptr]            ; load array pointer
           mov dword [r9+4*r8],edx  ; save in array only bottom 4 bytes
           inc r8                   ; increment array index
           mov [i],r8               ; save index
           cmp r8,[asize]           ; check if max number of entries
           jl .looptop
           leave
           ret
compare:
; compare two integers
; pointers in rdi, rsi
; return value in eax
           push rbp
           mov rbp,rsp 
           mov eax,[rdi]            ; load first integer
           sub eax,[rsi]            ; subtract second integer
           leave
           ret
sortarray:
; sort array a using qsort
           push rbp
           mov rbp,rsp 
; qsort(array,n,4,compare)
           mov rdi,[aptr]           ; pointer to array arg1
           mov rsi,[asize]          ; array size arg 2
           mov rdx,4                ; number of bytes per entry - 4
           lea rcx,[compare]        ; address of my compare function
           call qsort
           leave
           ret
binarysearch:
; search for searchkey in array pointed to by aptr
; return index into array in rax
; use binary search
; based on https://github.com/bobbydurrett/miscpython/blob/master/binarysearch.py
           push rbp
           mov rbp,rsp 
           xor r8,r8                ; r8 is lo
           mov r9,[asize]           ; r9 is hi
           dec r9                   ; r9 starts as max array index
           mov r10,[aptr]           ; r10 is array pointer
           mov r12,[searchkey]      ; r12 is search key
           cmp r9,0                 ; check hi < 0
           jl .notfound
           movsx r11,dword [r10+r8*4] ; getkey(sortedlist[lo])
           cmp r11,r12              ; > targetkey
           jg .notfound
           movsx r11,dword [r10+r9*4] ; getkey(sortedlist[hi])
           cmp r11,r12              ; < targetkey
           jl .notfound
.looptop:
           mov rax,r8
           inc rax
           cmp r9,rax               ; hi > (lo+1)
           jle .endwhile
           mov rax,r8
           add rax,r9
           xor rdx,rdx
           idiv qword [two]         ; rax is mid = (lo+hi)/2
           movsx rbx,dword [r10+rax*4]      ; getkey(sortedlist[mid]) rbx
           cmp rbx,r12
           je .isfound              ; rax is index to found element
           jg .hitomid
           mov r8,rax               ; lo = mid
           jmp .looptop             ; search again
.hitomid:           
           mov r9,rax               ; hi = mid
           jmp .looptop             ; search again
.endwhile:
           mov rax,r8               ; rax is lo
           movsx rbx,dword [r10+rax*4]      ; getkey(sortedlist[lo]) rbx
           cmp rbx,r12
           je .isfound              ; rax is index to found element
           mov rax,r9               ; rax is hi
           movsx rbx,dword [r10+rax*4]      ; getkey(sortedlist[hi]) rbx
           cmp rbx,r12
           je .isfound              ; rax is index to found element
.notfound:
           mov rax,-1               ; -1 means not found
.isfound:
           leave
           ret