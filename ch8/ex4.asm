; Check if a string is a palindrome - same backwards and forward
; refer is one.
       segment .bss
rs     resb 100             ; reversed string 100 bytes
       segment .data
s      db "refer"           ; string to check if it's a palindrome
;s      db "Bobby"           ; string to check if it's a palindrome
len    dd 5                 ; length of string   
pal    dq 0                 ; 1 if palindrome
       segment .text
       global start
start:
; load the string in reverse order
; 100 down to 1
       mov eax,[len]        ; eax is string length
       mov ebx,0            ; ebx is s index
copyloop:
       mov ecx,eax          ; ecx will have the rs index
       dec ecx              ; set ecx to max index - 4 in this case
       sub ecx,ebx          ; sub s index to get rs index - 4 first pass
       mov dl,[s+ebx]       ; copy byte
       mov [rs+ecx],dl      ; copy byte
       inc ebx              ; advance s index
       cmp ebx,eax          ; compare against string length
       jl copyloop          ; move another byte
; compare s and rs
       lea rsi,[s]          ; load s address as sourc
       lea rdi,[rs]         ; load rs address as dest
       xor rcx,rcx          ; clear rcx
       mov ecx,eax          ; load bottom 32 bits with s len
       repe cmpsb           ; compare two strings
       cmp rcx,0            ; check if made it through both strings
       jnz notpal           ; is not palindrome 
       xor rax,rax
       inc rax
       mov [pal],rax
notpal:
; exit with return code 0
       mov eax,60
       mov edi,0
       syscall
       end
