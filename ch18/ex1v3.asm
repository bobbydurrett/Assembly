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

image_size_minus_2 dq 0          ; image_size - 2
num_chunks_per_row dq 0          ; number of 14 byte chunks in one line with one byte each edge
row dq 0                         ; row in image array starting at 0
chunk dq 0                       ; 14 byte chunk in a row - 0 to (num_chunks_per_row-1)
chunk_offset dq 0                ; byte offset into image array for current chunk

first_offset dq 0                ; byte offset into first 16 byte section of image array
second_offset dq 0               ; byte offset into second 16 byte section of image array
third_offset dq 0                ; byte offset into third 16 byte section of image array

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

first_target resw 8               ; first 8 words of the 16 target words - sums for convoluted image
second_target resw 8              ; second 8 words

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
    
; Setup loops for 14 byte chunks

; num_chunks_per_row =(image_size-2)/14
    
    mov rax,[image_size]        ; image_size
    dec rax
    dec rax                     ; image_size-2
    mov [image_size_minus_2],rax
    mov r8,14                   ; load 14
    xor rdx,rdx                 ; clear upper 64 bits
    idiv r8                     ; (image_size-2)/14
    mov [num_chunks_per_row],rax ; save num_chunks_per_row
    
; for row = 1 to (image_size - 2)
    
    xor rax,rax
    inc rax
    mov [row],rax               ; row = 1
    
; for chunk = 0 to (num_chunks_per_row-1)

.nextrow:
    xor rax,rax
    mov [chunk],rax

; chunk_offset = (row*image_size)+1+(chunk*14)   

.nextchunk:
    mov rax,[row]
    mov r8,[image_size]
    imul rax,r8                  ; row*image_size
    inc rax                      ; (row*image_size)+1
    mov r8,[chunk]
    mov r9,14         
    imul r8,r9                   ; chunk*14
    add rax,r8                   ; (row*image_size)+1+(chunk*14)
    mov [chunk_offset],rax

; work on the chunk here

; calculate byte offsets for the image array for the three 16 byte sections that
; surround the chunk
; first_offset = chunk_offset - image_size - 1
; second_offset = chunk_offset - 1
; third_offset = chunk_offset + image_size - 1

    mov rax,[chunk_offset]
    dec rax                      ; chunk_offset - 1
    mov [second_offset],rax
    mov r8,rax
    mov r9,[image_size]
    sub r8,r9                    ; chunk_offset - image_size - 1
    mov [first_offset],r8
    add rax,r9                   ; chunk_offset + image_size - 1
    mov [third_offset],rax
    
; process first 16 bytes before the chunk - 16 words in two variables

; load the 16 words

    mov rax,[first_offset]
    mov rbx,[image_ptr]
    movdqu xmm0,[rax+rbx]        ; load 16 bytes at image_offset
    movdqa xmm1,xmm0             ; save a copy of the 16 bytes
    pxor xmm2,xmm2               ; xmm2 all zeros
    punpcklbw xmm0,xmm2          ; xmm0 now has 16 bit words of the lower 8 bytes
    punpckhbw xmm1,xmm2          ; xmm1 now has 16 bit words of the upper 8 bytes
    movdqu [first_8_words],xmm0  ; save 8 words
    movdqu [second_8_words],xmm1 ; save 8 more words

; process convolution 0,0
    
    movdqu xmm2,[conv_0_0]       ; load conv_0_0 8 words
    pmullw xmm0,xmm2             ; multiply by conv_0_0
    pmullw xmm1,xmm2             ; ditto
    movdqu [first_target],xmm0   ; save multiplied values in target arrays
    movdqu [second_target],xmm1

; conv 1,0

    lea rax,[first_8_words]
    inc rax
    inc rax                      ; point to second word
    movdqu xmm0,[rax]            ; load current 8 words shifted left one word
    movdqu xmm1,[second_8_words] ; load second set of 8 words
    pslldq xmm1,2                ; shift left 2 bytes
    movdqu xmm2,[conv_1_0]       ; load conv_1_0 8 words
    pmullw xmm0,xmm2             ; multiply by conv_1_0
    pmullw xmm1,xmm2             ; ditto
    movdqu xmm2,[first_target]
    paddw xmm2,xmm0
    movdqu [first_target],xmm2   ; add to target
    movdqu xmm2,[second_target]
    paddw xmm2,xmm1
    movdqu [second_target],xmm2   ; add to target
    
; conv 2,0

    lea rax,[first_8_words]
    inc rax
    inc rax                      
    inc rax
    inc rax                      ; point to third word
    movdqu xmm0,[rax]            ; load current 8 words shifted left one word
    movdqu xmm1,[second_8_words] ; load second set of 8 words
    pslldq xmm1,4                ; shift left 4 bytes
    movdqu xmm2,[conv_2_0]       ; load conv_2_0 8 words
    pmullw xmm0,xmm2             ; multiply by conv_2_0
    pmullw xmm1,xmm2             ; ditto
    movdqu xmm2,[first_target]
    paddw xmm2,xmm0
    movdqu [first_target],xmm2   ; add to target
    movdqu xmm2,[second_target]
    paddw xmm2,xmm1
    movdqu [second_target],xmm2   ; add to target
    
; process second 16 bytes around the chunk
    
; load the 16 words

    mov rax,[second_offset]
    mov rbx,[image_ptr]
    movdqu xmm0,[rax+rbx]        ; load 16 bytes at image_offset
    movdqa xmm1,xmm0             ; save a copy of the 16 bytes
    pxor xmm2,xmm2               ; xmm2 all zeros
    punpcklbw xmm0,xmm2          ; xmm0 now has 16 bit words of the lower 8 bytes
    punpckhbw xmm1,xmm2          ; xmm1 now has 16 bit words of the upper 8 bytes
    movdqu [first_8_words],xmm0  ; save 8 words
    movdqu [second_8_words],xmm1 ; save 8 more words

; process convolution 0,1
    
    movdqu xmm2,[conv_0_1]       ; load conv_0_1 8 words
    pmullw xmm0,xmm2             ; multiply by conv_0_1
    pmullw xmm1,xmm2             ; ditto
    movdqu xmm2,[first_target]
    paddw xmm2,xmm0
    movdqu [first_target],xmm2   ; add to target
    movdqu xmm2,[second_target]
    paddw xmm2,xmm1
    movdqu [second_target],xmm2   ; add to target

; conv 1,1

    lea rax,[first_8_words]
    inc rax
    inc rax                      ; point to second word
    movdqu xmm0,[rax]            ; load current 8 words shifted left one word
    movdqu xmm1,[second_8_words] ; load second set of 8 words
    pslldq xmm1,2                ; shift left 2 bytes
    movdqu xmm2,[conv_1_1]       ; load conv_1_1 8 words
    pmullw xmm0,xmm2             ; multiply by conv_1_1
    pmullw xmm1,xmm2             ; ditto
    movdqu xmm2,[first_target]
    paddw xmm2,xmm0
    movdqu [first_target],xmm2   ; add to target
    movdqu xmm2,[second_target]
    paddw xmm2,xmm1
    movdqu [second_target],xmm2   ; add to target
    
; conv 2,1

    lea rax,[first_8_words]
    inc rax
    inc rax                      
    inc rax
    inc rax                      ; point to third word
    movdqu xmm0,[rax]            ; load current 8 words shifted left one word
    movdqu xmm1,[second_8_words] ; load second set of 8 words
    pslldq xmm1,4                ; shift left 4 bytes
    movdqu xmm2,[conv_2_1]       ; load conv_2_1 8 words
    pmullw xmm0,xmm2             ; multiply by conv_2_1
    pmullw xmm1,xmm2             ; ditto
    movdqu xmm2,[first_target]
    paddw xmm2,xmm0
    movdqu [first_target],xmm2   ; add to target
    movdqu xmm2,[second_target]
    paddw xmm2,xmm1
    movdqu [second_target],xmm2   ; add to target
    
; process third 16 bytes after the chunk
    
; load the 16 words

    mov rax,[third_offset]
    mov rbx,[image_ptr]
    movdqu xmm0,[rax+rbx]        ; load 16 bytes at image_offset
    movdqa xmm1,xmm0             ; save a copy of the 16 bytes
    pxor xmm2,xmm2               ; xmm2 all zeros
    punpcklbw xmm0,xmm2          ; xmm0 now has 16 bit words of the lower 8 bytes
    punpckhbw xmm1,xmm2          ; xmm1 now has 16 bit words of the upper 8 bytes
    movdqu [first_8_words],xmm0  ; save 8 words
    movdqu [second_8_words],xmm1 ; save 8 more words

; process convolution 0,2
    
    movdqu xmm2,[conv_0_2]       ; load conv_0_2 8 words
    pmullw xmm0,xmm2             ; multiply by conv_0_2
    pmullw xmm1,xmm2             ; ditto
    movdqu xmm2,[first_target]
    paddw xmm2,xmm0
    movdqu [first_target],xmm2   ; add to target
    movdqu xmm2,[second_target]
    paddw xmm2,xmm1
    movdqu [second_target],xmm2   ; add to target

; conv 1,2

    lea rax,[first_8_words]
    inc rax
    inc rax                      ; point to second word
    movdqu xmm0,[rax]            ; load current 8 words shifted left one word
    movdqu xmm1,[second_8_words] ; load second set of 8 words
    pslldq xmm1,2                ; shift left 2 bytes
    movdqu xmm2,[conv_1_2]       ; load conv_1_2 8 words
    pmullw xmm0,xmm2             ; multiply by conv_1_2
    pmullw xmm1,xmm2             ; ditto
    movdqu xmm2,[first_target]
    paddw xmm2,xmm0
    movdqu [first_target],xmm2   ; add to target
    movdqu xmm2,[second_target]
    paddw xmm2,xmm1
    movdqu [second_target],xmm2   ; add to target
    
; conv 2,2

    lea rax,[first_8_words]
    inc rax
    inc rax                      
    inc rax
    inc rax                      ; point to third word
    movdqu xmm0,[rax]            ; load current 8 words shifted left one word
    movdqu xmm1,[second_8_words] ; load second set of 8 words
    pslldq xmm1,4                ; shift left 4 bytes
    movdqu xmm2,[conv_2_2]       ; load conv_2_2 8 words
    pmullw xmm0,xmm2             ; multiply by conv_2_2
    pmullw xmm1,xmm2             ; ditto
    movdqu xmm2,[first_target]
    paddw xmm2,xmm0
    movdqu [first_target],xmm2   ; add to target
    movdqu xmm2,[second_target]
    paddw xmm2,xmm1
    movdqu [second_target],xmm2   ; add to target
    
; convert 16 target words to 14 bytes and store in convoluted_image array
    
; advance to next chunk
    mov rax,[chunk]
    inc rax                      ; chunk++
    mov [chunk],rax
    mov r8,[num_chunks_per_row]
    dec r8                       ; num_chunks_per_row - 1
    cmp rax,r8                   ; chunk <= (chunk_offset - 1)
    jle .nextchunk               ; next chunk in current row
; advance to next row
    mov rax,[row]
    inc rax
    mov [row],rax
    mov r8,[image_size_minus_2]
    cmp rax,r8
    jle .nextrow
    
; last row is done if we get here

    leave                        ; fix stack
    ret                          ; return


; saving this for later
;    mov rax,[image_offset]
;    mov rbx,[image_ptr]
;    movdqu xmm0,[rax+rbx]        ; load 16 bytes at image_offset
;    movdqa xmm1,xmm0             ; save a copy of the 16 bytes
;    pxor xmm2,xmm2               ; xmm2 all zeros
;    punpcklbw xmm0,xmm2          ; xmm0 now has 16 bit words of the lower 8 bytes
;    punpckhbw xmm1,xmm2          ; xmm1 now has 16 bit words of the upper 8 bytes
;    movdqu [first_8_words],xmm0  ; save 8 words
;    movdqu [second_8_words],xmm1 ; save 8 more words

