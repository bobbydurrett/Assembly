; Find and replace
       segment .bss
output resb 100             ; String with replacement
       segment .data
input  db "What an amazing book by an amazing author."  ; before replacement
inlen  dq 42                 ; length of input string   
outlen dq 100                ; length of output buffer   
srch   db "amazing"          ; search string
srclen dq 7                  ; search string length
repl   db "incredible"       ; replacement string
replen dq 10                 ; replacement string length
       segment .text
       global start
start:
; Load registers
       mov r8,[inlen]        ; r8 = input string length
       mov r10,[srclen]      ; r10 = search string length
       mov r11,[replen]      ; r11 = replacement string length
       xor r12,r12           ; r12 = input string copy offset
       xor r13,r13           ; r13 = input string search offset
       xor r14,r14           ; r14 = output string copy offset
looptop:
; Check if the current input string search offset
; leaves room at the end of the input string
; for the search string.             
       mov rax,r13           ; load current input string search offset in rax
       add rax,r10           ; add length of search string
       inc rax               ; add 1 for compare to input string length
       cmp rax,r8            ; compare to input string length
       jg copyrest           ; jump to code to copy the rest of the string and end
; Check the current input string search offset to see
; if it points to the search string
       lea rsi,[input+r13]   ; load pointer to search offset into input string
       lea rdi,[srch]        ; load pointer to search string
       mov rcx,r10           ; load search string length
       repe cmpsb            ; do compare
       cmp rcx,0             ; see if all characters compared
       jne notfound          ; jump around code for when search string found
; Search string was found. Copy from input string copy offset up to character
; before input string search offset to output string copy offset and advance
; both copy offsets the number of characters copied.
       mov rax,r13           ; load input string search offset to rax
       sub rax,r12           ; subtract copy offset to get characters to copy
       lea rsi,[input+r12]   ; load pointer to copy offset into input string
       lea rdi,[output+r14]  ; load pointer to copy offset into output string
       mov rcx,rax           ; load rcx for copy command
       rep movsb             ; copy characters
       add r12,rax           ; advance input string copy offset
       add r14,rax           ; advance output string copy offset
; Copy replace string to output at copy offset. Advance output offset by
; length of replace string. Advance input search and copy offsets by length
; of search string. 
       lea rsi,[repl]        ; load pointer to replace string
       lea rdi,[output+r14]  ; load pointer to copy offset into output string
       mov rcx,r11           ; load length of replace string for copy command
       rep movsb             ; copy characters
       add r12,r10           ; advance input string copy offset search length
       add r13,r10           ; advance input string search offset search length
       add r14,r11           ; advance output string copy offset repl length
       jmp looptop
notfound:
; Search string not found. Advancd input string search offset by 1
; then return to top of loop
       inc r13
       jmp looptop
copyrest:
; Copy from input string copy offset to end of input string
; to output string copy offset.  
       mov rcx,r8            ; load input string length
       sub rcx,r12           ; subtract input string copy offset
       dec rcx               ; subtract 1 to get number of characters to copy in rcx
       lea rsi,[input+r12]   ; load pointer to copy offset into input string
       lea rdi,[output+r14]  ; load pointer to copy offset into output string
       rep movsb             ; copy characters
; exit return code 0              
       mov eax,60
       mov edi,0
       syscall
       end
