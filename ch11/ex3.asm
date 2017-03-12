; Integral for degree 5 polynomial using
; trapezoidal rule...

; Non-float arguments in these registers:
; rdi, rsi, rdx, rcx, r8 and r9
; rax contains the number of floating point arguments
; xmm0 to xmm7 contain the float arguments
; These registers must be preserved across function calls:
; rbx, rsp, rbp, r12-r15
; rax and rdx are the integer return registers
; xmm0 and xmm1 are the float return resgisters
; http://www.nasm.us/links/unix64abi

global main 
global readinput
global calc_polynomial
extern scanf
extern printf

segment .data

; input variables

a dq 0.0                         ; start value for integral
b dq 0.0                         ; end value
intervals dq 0                   ; number of intervals to divide the range into

; coefficients of the degree 5 polynomial's terms

p0 dq 0.0
p1 dq 0.0
p2 dq 0.0
p3 dq 0.0
p4 dq 0.0
p5 dq 0.0

; variables for the calculations

curr_interval dq 0               ; current interval number
diff dq 0.0                      ; b - a
lower dq 0.0                     ; lower bounds of current interval
upper dq 0.0                     ; upper bounds
f_lower dq 0.0                   ; value of polynomial at lower boundary
f_upper dq 0.0                   ; at upper boundary
d_intervals dq 0.0               ; double float version of intervals
d_two dq 2.0                     ; constant 2.0

; output

pafmt db "area = %lf",0xa,0
area dq 0.0                      ; sum of areas so far and final result

segment .text

main:	                         ; labels start column 1
    push rbp                     ; opcodes start column 5
    mov rbp,rsp                  ; comments from 34 unless opcode and arguments are too long

    call readinput               ; get the input values
    
; main loop here with calls to calc_polynomial to get value at each boundary point 

; set initial variable values
    
    mov qword [curr_interval],1  ; interval 1 to intervals
    movsd xmm0,[b]               ; calc diff = b - a, load b
    subsd xmm0,[a]               ; subtract a
    movsd [diff],xmm0            ; save in diff
    movsd xmm0,[a]               ; load a
    movsd [lower],xmm0           ; save as lower bound
    call calc_polynomial         ; calc f(lower)=f(a)
    movsd [f_lower],xmm0         ; save f(lower)
    cvtsi2sd xmm0,qword [intervals] ; convert intervals to double float
    movsd [d_intervals],xmm0     ; save double version of intervals for calculations
    
; top of loop - one pass for every interval
; assume intervals is at least 1 so make 1 pass before checking
; curr_interval > intervals
 
.looptop:
    cvtsi2sd xmm0,qword [curr_interval] ; convert current interval to double
    divsd xmm0,[d_intervals]     ; divide current interval by total number of intervals
    mulsd xmm0,[diff]            ; multiply by b - a
    addsd xmm0,[a]               ; add a - gets new upper bound
    movsd [upper],xmm0           ; save upper bound
    call calc_polynomial         ; calc f(upper)
    movsd [f_upper],xmm0         ; save f(upper)
    addsd xmm0,[f_lower]         ; f(upper)+f(lower)
    divsd xmm0,[d_two]           ; divide by 2.0
    movsd xmm1,[upper]           ; use to calc d-c upper-lower
    subsd xmm1,[lower]           
    mulsd xmm0,xmm1              ; xmm0 has area of current interval
    movsd xmm1,[area]            ; load current area
    addsd xmm1,xmm0              ; add to running area total
    movsd [area],xmm1            ; save new total area
    movsd xmm0,[upper]           ; use to move upper to lower
    movsd [lower],xmm0           ; save
    movsd xmm0,[f_upper]         ; use to move f_upper to f_lower
    movsd [f_lower],xmm0         ; save
    mov rax,[curr_interval]      ; curr_interval++
    inc rax
    mov [curr_interval],rax
    cmp rax,[intervals]          ; see if done
    jg .doneloop
    jmp .looptop
.doneloop:
; print the area
    lea rdi,[pafmt]              ; printf format for double
    movsd xmm0,[area]
    mov rax,1
    call printf
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return

; reads a and b on first line, intervals on second line
; then p0,p1,p2 on a third line, p3,p4,p5 on a fourth line

segment .data

line1fmt db "%lf %lf",0            
line2fmt db "%ld",0            
line3and4fmt db "%lf %lf %lf",0            

segment .text

readinput:	                 
    push rbp                     
    mov rbp,rsp                  
; line 1 
    lea rdi,[line1fmt]           ; two double floats
    lea rsi,[a]                  ; ptr to a
    lea rdx,[b]                  ; ptr to b
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
; line 2 
    lea rdi,[line2fmt]           ; one qword int
    lea rsi,[intervals]          ; ptr to intervals
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
; line 3 
    lea rdi,[line3and4fmt]       ; 3 double floats
    lea rsi,[p0]                 ; ptr to p0
    lea rdx,[p1]                 ; ptr to p1
    lea rcx,[p2]                 ; ptr to p2
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
; line 4 
    lea rdi,[line3and4fmt]       ; 3 double floats
    lea rsi,[p3]                 ; ptr to p3
    lea rdx,[p4]                 ; ptr to p4
    lea rcx,[p5]                 ; ptr to p5
    xor rax,rax                  ; no floating point args
    call scanf                   ; read a line
; return    
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
; takes x as an argument in xmm0
; returns f(x) in xmm0

segment .data

x dq 0.0 
xpower dq 0.0                    ; power of x = x^0 = 1
sum dq 0.0                       ; sum of polynomial terms
d_one dq 1.0

segment .text

calc_polynomial:	                 
    push rbp                     
    mov rbp,rsp                  
    
    movsd [x],xmm0               ; save input x
; p0
    movsd xmm0,[d_one]
    movsd [xpower],xmm0          ; start xpower at 1.0 for x^0
    movsd xmm0,[p0]
    movsd [sum],xmm0             ; sum starts with p0
; p1
    movsd xmm0,[xpower]          ; load previous x power
    movsd xmm1,[x]               ; load x
    mulsd xmm0,xmm1              ; get new x power
    movsd [xpower],xmm0          ; save new x power
    movsd xmm1,[p1]              ; load p1
    mulsd xmm0,xmm1              ; calculate term
    movsd xmm1,[sum]             ; load current sum
    addsd xmm1,xmm0              ; add new term
    movsd [sum],xmm1             ; save sum
; p2
    movsd xmm0,[xpower]          ; load previous x power
    movsd xmm1,[x]               ; load x
    mulsd xmm0,xmm1              ; get new x power
    movsd [xpower],xmm0          ; save new x power
    movsd xmm1,[p2]              ; load p2
    mulsd xmm0,xmm1              ; calculate term
    movsd xmm1,[sum]             ; load current sum
    addsd xmm1,xmm0              ; add new term
    movsd [sum],xmm1             ; save sum
; p3
    movsd xmm0,[xpower]          ; load previous x power
    movsd xmm1,[x]               ; load x
    mulsd xmm0,xmm1              ; get new x power
    movsd [xpower],xmm0          ; save new x power
    movsd xmm1,[p3]              ; load p3
    mulsd xmm0,xmm1              ; calculate term
    movsd xmm1,[sum]             ; load current sum
    addsd xmm1,xmm0              ; add new term
    movsd [sum],xmm1             ; save sum
; p4
    movsd xmm0,[xpower]          ; load previous x power
    movsd xmm1,[x]               ; load x
    mulsd xmm0,xmm1              ; get new x power
    movsd [xpower],xmm0          ; save new x power
    movsd xmm1,[p4]              ; load p4
    mulsd xmm0,xmm1              ; calculate term
    movsd xmm1,[sum]             ; load current sum
    addsd xmm1,xmm0              ; add new term
    movsd [sum],xmm1             ; save sum
; p5
    movsd xmm0,[xpower]          ; load previous x power
    movsd xmm1,[x]               ; load x
    mulsd xmm0,xmm1              ; get new x power
    movsd [xpower],xmm0          ; save new x power
    movsd xmm1,[p5]              ; load p5
    mulsd xmm0,xmm1              ; calculate term
    movsd xmm1,[sum]             ; load current sum
    addsd xmm1,xmm0              ; add new term
    movsd xmm0,xmm1              ; move sum to xmm0 for return value
; return
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
