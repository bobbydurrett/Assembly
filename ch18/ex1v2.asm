; Chapter 18 Exercise 1
; Called by ex1v2.c
; See C implementation in ex1v1.c
;
; extern void apply_convolution(unsigned char image[][IMAGE_SIZE],
; unsigned char convoluted_image[][IMAGE_SIZE],signed char convolution[][3],long image_size);
;
; 	long i,j,k,m,temp;
; 
; 	for (i=1;i<(image_size-1);i++)
; 	    for (j=1;j<(image_size-1);j++)
; 	    {
; 		temp=0;
; 	        for (k=0;k<3;k++)
; 	            for (m=0;m<3;m++)
; 	            {
; 					temp += (image[i+k-1][j+m-1])*(convolution[k][m]);
; 		    }
; 			if (temp > 255)
; 			    temp = 255;
; 			if (temp < 0)
; 				temp = 0;
; 			convoluted_image[i][j]=temp;
; 		}

global apply_convolution

; apply_convolution - see description in ex1v1.c
; Arguments:
; rdi pointer to image array
; rsi pointer to convoluted_image output array
; rdx pointer to convolution - 3x3 array
; rcx size of image x and y dimensions
; Variables:
; rbx i
; r8 j
; r9 k
; r10 m
; rax byte - AL
; r11 byte offset calculations
; r12 temp
; r13 used for calculations

segment .text

apply_convolution:	         
    push rbp                     
    mov rbp,rsp
; i for loop    
    xor rbx,rbx
    inc rbx                      ; i=1
.topiloop:
    mov rax,rcx
    dec rax
    cmp rbx,rax
    jge .endiloop                ; i >= image_size-1
; j for loop    
    xor r8,r8
    inc r8                       ; j = 1
.topjloop:
    mov rax,rcx
    dec rax
    cmp r8,rax
    jge .endjloop                ; j >= image_size-1
; temp=0;
    xor r12,r12                  ; temp = 0
; k for loop    
    xor r9,r9                    ; k = 0
.topkloop:
    mov rax,3
    cmp r9,rax
    jge .endkloop                ; k >= 3
; m for loop    
    xor r10,r10                  ; m = 0
.topmloop:
    mov rax,3
    cmp r10,rax
    jge .endmloop                ; m >= 3
; temp += (image[i+k-1][j+m-1])*(convolution[k][m]);
    mov r11,rbx                  ; r11 = i
    add r11,r9                   ; r11 = i+k
    dec r11                      ; r11 = i+k-1
    imul r11,rcx                 ; r11 = r11 * image_size
    add r11,r8                   ; r11 += j
    add r11,r10                  ; r11 += m
    dec r11                      ; -1
    xor rax,rax 
    mov AL,byte [rdi+r11]        ; load byte image array
    mov r13,rax                  ; r13 = (image[i+k-1][j+m-1])
    mov r11,r9                   ; k
    mov rax,3
    imul r11,rax                 ; k*3
    add r11,r10                  ; k*3 +m
    movsx rax,byte [rdx+r11]     ; load byte convolution
    imul r13,rax                 ; r13=(image[i+k-1][j+m-1])*(convolution[k][m])
    add r12,r13                  ; temp += ...
; bottom m loop
    inc r10
    jmp .topmloop
.endmloop:   
; bottom k loop
    inc r9
    jmp .topkloop
.endkloop:   
; if (temp > 255)
;     temp = 255;
; if (temp < 0)
;     temp = 0;
    mov rax,255
    cmp r12,rax
    jle .notover255
    mov r12,rax                  ; temp = 255
    jmp .donetemp
.notover255:
    xor rax,rax  
    cmp r12,rax
    jge .donetemp
    mov r12,rax
.donetemp:    
; convoluted_image[i][j]=temp;
    mov rax,r12                  ; rax = temp
    mov r11,rcx
    imul r11,rbx
    add r11,r8                   ; r11 is now offset in array
    mov byte [rsi+r11],AL        ; store byte - rax
; bottom j loop
    inc r8
    jmp .topjloop
.endjloop:   
; bottom i loop
    inc rbx
    jmp .topiloop
.endiloop:   
    leave                        ; fix stack
    ret                          ; return

