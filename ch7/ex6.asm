; Multiply two floats using only integer 
; arithmetic and bit operations.
; float is 32 bits
; 8 bit exponent with 127 bias
; 23 bit fraction
; Use similar steps from exercise 5
; to extract fraction with 1 added
; sign bit, and exponent without bias
; for both numbers.
; Then multiply fractions and add 
; exponents. I guess xor sign bits?
; maybe have to subtract out 23 from
; exponents to get the two fractions to be
; integers and then divide back to get
; 1.xxxxx. Not sure.
        section .data
input1  dd 2.0
input2  dd 3.0  
frac1   dd 0
frac2   dd 0
expt1   dd 0
expt2   dd 0
signb1  dd 0
signb2  dd 0
fracout dd 0
exptout dd 0
signout dd 0
output  dd 0.0
        section .text
        global start
start:
; Similar to exercise 5 pull out the
; fraction, exponent, and sign bits
; for the two numbers
; Doing all this with 64 bit registers
; is probably wrong but it is what it
; is.
        mov eax,[input1]  ; Save input in eax
        mov ebx,eax       ; Use ebx for extract
        shl ebx,9         ; Clear out the top
        shr ebx,9         ; 9 bits
        bts ebx,23        ; Set bit 23 for 1 digit
        mov [frac1],ebx   ; save fraction with 1.
        mov ebx,eax       ; Use ebx for extract
        shr ebx,23        ; Shift past the fraction
        and ebx,0xFF      ; 8 bits 
        sub ebx,127       ; Subtract bias
        mov [expt1],ebx   ; save exponent without bias
        mov ebx,eax       ; Use rbx for extract
        shr ebx,31        ; Shift to last bit
        mov [signb1],ebx  ; Sign bit
; input2
        mov eax,[input2]  ; Save input in eax
        mov ebx,eax       ; Use ebx for extract
        shl ebx,9         ; Clear out the top
        shr ebx,9         ; 9 bits
        bts ebx,23        ; Set bit 23 for 1 digit
        mov [frac2],ebx   ; save fraction with 1.
        mov ebx,eax       ; Use ebx for extract
        shr ebx,23        ; Shift past the fraction
        and ebx,0xFF      ; 8 bits 
        sub ebx,127       ; Subtract bias
        mov [expt2],ebx   ; save exponent without bias
        mov ebx,eax       ; Use rbx for extract
        shr ebx,31        ; Shift to last bit
        mov [signb2],ebx  ; Sign bit
; multiply fractions
        xor rax,rax       ; clear 64 bit registers
        xor rbx,rbx
        mov eax,[frac1]   ; load into bottom 32 bits
        mov ebx,[frac2] 
        imul rax,rbx      ; multiply 64 bit
; check if bit 47 is a 1
; if so then it is the top bit
; otherwise it is bit 46
; bit 0 is the first bit
; Use rcx for top bit number
        mov rcx,46        ; 46 by defaut
        mov rdx,47        ; 47 if bit is set
        bt rax,47         ; check bit 47
        cmovc rcx,rdx     ; move in 47 if bit 47 set
        mov rdi,rcx       ; save rcx for exponent calculations
; Clear the top 65-(46 or 47) bits
; clears the top 1 bit.
; Then move back so the bit after the top 1
; bit (45 or 46) is in bit 22 (23rd bit)
; 41 bits over
        mov rdx,64        ; 64 for subtraction
        sub rdx,rcx       ; rdx contains offset
        mov cl,dl         ; move shift number into cl
        shl rax,cl        ; rax now shifted past the top 1 bit
        shr rax,41        ; rax shifted so fraction in 23 bits
        mov [fracout],eax ; move out 32 bits register
; now we have correct 23 bit fraction of multiplication result
; in the fracout variable.
; If we had bit 47 set then edi will have 47 otherwise
; it will have 46. Subtract 46 from edi and add
; the two exponents to get the final exponent.
        mov eax,46        ; 32 bit regs 
        sub edi,eax       ; sub 46 - edi has 1 or 0
        add edi,[expt1]   ; add first normalized exponent 
        add edi,[expt2]   ; add second normalized exponent
        add edi,127       ; add 127 bias
        mov [exptout],edi ; save exponent
; calculate sign by xoring the two signs
        mov eax,[signb1]
        mov ebx,[signb2]
        xor eax,ebx       ; new sign bit in eax
        mov [signout],eax ; save bit
; build 32 bit float from calculated pieces.
        mov eax,[signout] ; load sign bit
        shl eax,31        ; shift over to top bit
        mov ebx,[exptout] ; load exponent
        shl ebx,23        ; shift over to 2nd bit
        mov ecx,[fracout] ; load fraction
        xor ecx,ebx       ; add exponent
        xor ecx,eax       ; add sign
        mov [output],ecx  ; save float output of multiplication 
; exit with return code 0
        mov eax,60
        mov edi,0
        syscall
        end
