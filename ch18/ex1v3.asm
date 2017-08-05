; Chapter 18 Exercise 1
; Called by ex1v3.c
; See C implementation in ex1v1.c
; This is a SSE version based on the example in the chapter.
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

segment .data

image_ptr dq 0                   ; pointer to image array
conv_image_ptr dq 0              ; pointer to convoluted image output array
convolution_ptr dq 0             ; pointer to 3x3 convolution array
image_size dq 0                  ; size in bytes of x and y dimensions.

image_offset dq 0                ; current offset into image array

segment .bss

first_8_words resw 8             ; first 8 words from offset
second_8_words resw 8            ; second 8 words from offset

conv_0_0 resw 8                  ; entry 0,0 of convolution repeated 8 times as words
conv_0_1 resw 8                   
conv_0_2 resw 8                   
conv_1_0 resw 8                   
conv_1_1 resw 8                   
conv_1_2 resw 8                   
conv_2_0 resw 8                   
conv_2_1 resw 8                   
conv_2_2 resw 8                   

segment .text

apply_convolution:	         
    push rbp                     
    mov rbp,rsp
    
; save arguments

    mov [image_ptr],rdi
    mov [conv_image_ptr],rsi
    mov [convolution_ptr],rdx
    mov [image_size],rcx
    
; load convolution array entries as 8 16 bit words

    mov r8,[convolution_ptr]    ; pointer to convolution array in register
; 0,0
    xor rax,rax                 ; clear rax
    movsx ax,byte [r8]          ; load byte 0,0	as word preserving sign
    lea r9,[conv_0_0]           ; load pointer to 0,0 array
    mov [r9],ax                 ; save word 
    mov [r9+2],ax               ; save word 
    mov [r9+4],ax               ; save word 
    mov [r9+6],ax               ; save word 
    mov [r9+8],ax               ; save word 
    mov [r9+10],ax              ; save word 
    mov [r9+12],ax              ; save word 
    mov [r9+14],ax              ; save word 
; 0,1
    xor rax,rax                 ; clear rax
    movsx ax,byte [r8+1]        ; load byte 0,1	as word preserving sign
    lea r9,[conv_0_1]           ; load pointer to 0,1 array
    mov [r9],ax                 ; save word 
    mov [r9+2],ax               ; save word 
    mov [r9+4],ax               ; save word 
    mov [r9+6],ax               ; save word 
    mov [r9+8],ax               ; save word 
    mov [r9+10],ax              ; save word 
    mov [r9+12],ax              ; save word 
    mov [r9+14],ax              ; save word 
; 0,2
    xor rax,rax                 ; clear rax
    movsx ax,byte [r8+2]        ; load byte 0,2	as word preserving sign
    lea r9,[conv_0_2]           ; load pointer to 0,2 array
    mov [r9],ax                 ; save word 
    mov [r9+2],ax               ; save word 
    mov [r9+4],ax               ; save word 
    mov [r9+6],ax               ; save word 
    mov [r9+8],ax               ; save word 
    mov [r9+10],ax              ; save word 
    mov [r9+12],ax              ; save word 
    mov [r9+14],ax              ; save word 
; 1,0
    xor rax,rax                 ; clear rax
    movsx ax,byte [r8+3]        ; load byte 1,0	as word preserving sign
    lea r9,[conv_1_0]           ; load pointer to 1,0 array
    mov [r9],ax                 ; save word 
    mov [r9+2],ax               ; save word 
    mov [r9+4],ax               ; save word 
    mov [r9+6],ax               ; save word 
    mov [r9+8],ax               ; save word 
    mov [r9+10],ax              ; save word 
    mov [r9+12],ax              ; save word 
    mov [r9+14],ax              ; save word     
; 1,1
    xor rax,rax                 ; clear rax
    movsx ax,byte [r8+4]        ; load byte 1,1	as word preserving sign
    lea r9,[conv_1_1]           ; load pointer to 1,1 array
    mov [r9],ax                 ; save word 
    mov [r9+2],ax               ; save word 
    mov [r9+4],ax               ; save word 
    mov [r9+6],ax               ; save word 
    mov [r9+8],ax               ; save word 
    mov [r9+10],ax              ; save word 
    mov [r9+12],ax              ; save word 
    mov [r9+14],ax              ; save word     
; 1,2
    xor rax,rax                 ; clear rax
    movsx ax,byte [r8+5]        ; load byte 1,2	as word preserving sign
    lea r9,[conv_1_2]           ; load pointer to 1,2 array
    mov [r9],ax                 ; save word 
    mov [r9+2],ax               ; save word 
    mov [r9+4],ax               ; save word 
    mov [r9+6],ax               ; save word 
    mov [r9+8],ax               ; save word 
    mov [r9+10],ax              ; save word 
    mov [r9+12],ax              ; save word 
    mov [r9+14],ax              ; save word     
; 2,0
    xor rax,rax                 ; clear rax
    movsx ax,byte [r8+6]        ; load byte 2,0	as word preserving sign
    lea r9,[conv_2_0]           ; load pointer to 2,0 array
    mov [r9],ax                 ; save word 
    mov [r9+2],ax               ; save word 
    mov [r9+4],ax               ; save word 
    mov [r9+6],ax               ; save word 
    mov [r9+8],ax               ; save word 
    mov [r9+10],ax              ; save word 
    mov [r9+12],ax              ; save word 
    mov [r9+14],ax              ; save word     
; 2,1
    xor rax,rax                 ; clear rax
    movsx ax,byte [r8+7]        ; load byte 2,1	as word preserving sign
    lea r9,[conv_2_1]           ; load pointer to 2,1 array
    mov [r9],ax                 ; save word 
    mov [r9+2],ax               ; save word 
    mov [r9+4],ax               ; save word 
    mov [r9+6],ax               ; save word 
    mov [r9+8],ax               ; save word 
    mov [r9+10],ax              ; save word 
    mov [r9+12],ax              ; save word 
    mov [r9+14],ax              ; save word     
; 2,2
    xor rax,rax                 ; clear rax
    movsx ax,byte [r8+8]        ; load byte 2,2	as word preserving sign
    lea r9,[conv_2_2]           ; load pointer to 2,2 array
    mov [r9],ax                 ; save word 
    mov [r9+2],ax               ; save word 
    mov [r9+4],ax               ; save word 
    mov [r9+6],ax               ; save word 
    mov [r9+8],ax               ; save word 
    mov [r9+10],ax              ; save word 
    mov [r9+12],ax              ; save word 
    mov [r9+14],ax              ; save word     
    
; set image offset
    xor rax,rax
    mov [image_offset],rax       ; image_offset = 0
; get 16 words starting at image_offset
.nextwords:
    mov rax,[image_offset]
    mov rbx,[image_ptr]
    movdqu xmm0,[rax+rbx]        ; load 16 bytes at image_offset
    movdqa xmm1,xmm0             ; save a copy of the 16 bytes
    pxor xmm2,xmm2               ; xmm2 all zeros
    punpcklbw xmm0,xmm2          ; xmm0 now has 16 bit words of the lower 8 bytes
    punpckhbw xmm1,xmm2          ; xmm1 now has 16 bit words of the upper 8 bytes
    movdqu [first_8_words],xmm0  ; save 8 words
    movdqu [second_8_words],xmm1 ; save 8 more words


    leave                        ; fix stack
    ret                          ; return

