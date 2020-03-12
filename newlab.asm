W equ 1Fh
H equ 18h
OFFS equ 04h

.model tiny
.186
.code
org 100h
main:
jmp start


cells db W + OFFS dup(0)
c_n db W + OFFS dup(0)
bsymb db 0
ticks db 0
_sleep dw 1fffh
running db 0
	; int_2Fh_vector  DD  ? ;   
	;old_09h         DD  ?
	old_09h         DD  ?
	old_1Ch         DD  ?
;	old_60h			DD  ?
	
	
	
	T dw ? ; ( )
screensaver proc 
	
	mov ax, 0f00h 
	int 10h
	push ax 
	
	mov ax, 0003h 
	int 10h
	mov running, 1
	iret
screensaver endp

screensstep proc
imul dx, 4E35h
	inc dx
	push dx
	and dh, W
	add dh, OFFS
	shr dx, 08h
	mov bx, dx
	lea di, cells
	inc byte ptr [di+ bx]
	mov dh, byte ptr [di+ bx]
	cmp dh, H
	jne next1
	mov byte ptr [di+ bx], 0
	
	next1:
	cmp dh, 0
	je draw1
	
	dec dh ;  
	mov bh, 00h
	mov ah, 02h 
	int 10h
	
	mov ah, 09h 
	mov al, bsymb 
	mov bx, 0002h ;green
	mov cx, 01h
	int 10h
	
	draw1:
	inc dh
	mov bh, 00h
	mov ah, 02h 
	int 10h
	
	mov ah, 09h  
		pop dx
		imul dx, 4E35h
		inc dx
		push dx
		mov bsymb, dh 
	mov al, bsymb
	mov bx, 000Ah ;white green
	mov cx, 01h
	int 10h
	
	;...
	pop dx
	imul dx, 4E35h
	inc dx
	push dx
	and dh, W
	add dh, OFFS
	shr dx, 08h
	mov bx, dx
	lea di, c_n
	add byte ptr [di+ bx], 01h
	mov dh, byte ptr [di+ bx]
	cmp dh, H + 01h
	jne next2
	mov byte ptr [di+ bx], 00h
	
	next2:
	dec dh
	mov bh, 00h
	mov ah, 2 
	int 10h
	
	mov ah, 09h 
	mov al, 08h 
	mov bh, 00h 
	mov bl, 00h 
	mov cx, 0001h 
	int 10h
	iret
screensstep endp

screenssexit proc

	pop dx
	pop ax 
	mov ah, 00h 
	mov bh, 00h
	int 10h   
	iret
	
screenssexit endp

new_1Ch proc
	
	call screensstep
	
new_1Ch endp	

new_09h proc far
	mov CS:ticks, 0
	cmp CS:running, 0
	je lolr
	mov CS:running, 0
	;call screenssexit
	lolr:
	jmp     dword ptr CS:[old_09h]
	iret
new_09h     endp

start:
		call screensaver

		
		
end main
