default rel

section .data
	str: times 20 db 0
	newline db 10

section .text
global _start

_start:
	xor	r8, r8		;init a = 0 for first calculation
	mov	rax, 1		;init b = 1 for first calculation
	mov	rdi, str	;buffer adress to rdi
	call calc_fibo



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;CALCULATE THE FIBONACCI SEQUENCE;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;set	 r9=rax, calculate rax+r8, set r8=r9 and then call the IntToString-function, then Print-function and then loop
;;;;;;;;;In:	r8=1st operand
;;;;;;;;;		rax=2nd operand
;;;;;;;;;Out:	rax=fibonacci numbers
calc_fibo:
	mov	r9, rax		;c = b
	add	rax, r8		;b = b + a, sum to rax
	mov	r8, r9		;a = c, move previous num to r8
	mov	r10, rax	;save the result in r10

	mov	rdi, str
	call int_to_str

;	mov	rax, r10
	call write
	mov	rax, r10
	cmp	rax, 10		;set upper level	
	jge exit
	jmp calc_fibo



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;CONVERT AN INTEGER INTO A STRING;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;In:	rax=int to convert
;;;;;;;;;		rdi=adress of buffer
;;;;;;;;;Out:	rsi=start adress of string
;;;;;;;;;		rdx=length of string
int_to_str:
	push	rbx
	mov	rbx, rdi		;adress of buffer to rbx
	add	rbx, 19			;point to end of buffer (+19Bytes)
	mov byte [rbx], 0	;Null-terminate the buffer, puts a 0 in the last byte of buffer
	dec	rbx				;move to index 18

	;if num is 0:
	cmp	rax, 0			;is num = 0?
	je	.zero_case		;then jump to func
	jmp	.extract_digits


.zero_case:
	mov byte [rbx], 0x30
	dec	rbx				;adjust buffer pointer


.extract_digits:
	xor	rdx, rdx		;clear rdx(for division)
	mov	rcx, 10			;divisor = 10
	div	rcx				;rax = quotient, rdx = remainder (0-9)
	add	dl, 0x30		;convert remainder to ASCII (0x30 = '0')
	mov	[rbx], dl		;store ASCII digit in buffer
	dec	rbx				;move left in buffer for next digit
	cmp	rax, 0			;stop when quotient (rax) is 0
	jne .extract_digits	;repeat if more digits
	jmp .calc_length


.calc_length:
	inc	rbx				;move past the last written digit (start of str)
	mov	rsi, rbx		;rsi = start address of the string
	mov 	rdx, rdi
	add	rdx, 19
	sub	rdx, rbx		;length = end of buffer - start of string
	pop	rbx
	ret					;return to _start



	;writes a string to stdout
write:
	mov	rax, 1			;sys_write
	mov	rdi, 1			;stdout
						;rsi is already buffer adress			
;	mov	rsi, str		;buffer adress
;rdx is already buffer size			
;	mov	rdx, 20			;buffer size
	syscall
	mov	rsi, newline
	mov	rdx, 1
	syscall
	ret

	;exit program:
exit:
	mov	rdi, 0			;exit code
	mov	rax, 60			;syscall exit number
	syscall
