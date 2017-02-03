; Bubble sort
       segment .bss
a      resd 100             ; 100 element array
       segment .data
n      dq 100               ; n is the number of elements in the array
       segment .text
       global start
start:
; load the array in reverse order
; 100 down to 1
       mov eax,100          ; top number
       mov ebx,0            ; first array address
loadtop:
       mov [a+4*ebx],eax    ; load array element
       dec eax              ; next lowest number
       jz loaddone          ; stop if zero - lowest is 1
       inc ebx              ; bump up array index
       jmp loadtop          ; load next element
loaddone:
       xor eax,eax          ; eax is 0 if no elements were swapped in this pass
       xor ebx,ebx          ; ebx is index into array start at 0 = i
nextelement:
       mov ecx,[a+4*ebx]    ; ecx = a[i] 
       mov edx,[a+4*ebx+4]  ; edx = a[i+1] 
       cmp ecx,edx          ; compare a[i] and a[i+1]
       jle noswap           ; if a[i]<=a[i+1] don't swap
       inc eax              ; eax has count of swaps
       mov [a+4*ebx+4],ecx  ; swap using values in registers
       mov [a+4*ebx],edx    ; a[i] and a[i+1] swapped
noswap:
       inc ebx              ; i++
       cmp ebx,99           ; index max is 98
       jl nextelement       ; move to next element
       cmp eax,0            ; see if any swaps were done
       jg  loaddone         ; make another pass through array
; exit with return code 0
       mov eax,60
       mov edi,0
       syscall
       end
