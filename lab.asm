CSEG segment 
assume cs: CSEG
assume ds: CSEG
assume ss: CSEG

org 100h


start:


	call print_ECS_Space
	
	call press_button
	
	cmp al, 20h	
	je begin
	
	cmp al, 1Bh 
  jne start
  int 20h
	
begin:

	mov dx, offset msg_write_name
	call print
	
	mov ah, 0Ah 
	mov dx, offset filename
	int 21h
	
	call read_filename

	jc error1
	
	mov handle, ax
	
	mov bx, handle
	mov ah, 3Fh
	mov cx, 2048
	mov dx, offset buffer
	int 21h
	jc error2
	
	jmp a
	
error1:

	push ax
	push dx
	
	mov dx, offset msg_error_file
	call print 
	
	push ax
	push dx
	
	jmp begin
	
error2:

	push ax
	push dx
	
	mov dx, offset msg_error_buffer
	call print 
	
	pop dx
	pop ax
	jmp begin	
	
a: 
	
	cmp ax,0
	jne bps
	int 20h
	bps:
	mov cx, ax
	
	mov si, offset buffer
	inc cx
	
	push cx
	push si
	
cycle1:
	dec cx
	lodsb
	call find_max_len
	cmp cx,0
	jne cycle1
;	dec max_len
;continue:
	pop cx 
	pop si
cycle2:
	dec cx
	lodsb
	call print_len
		
		push bx
		push cx
		
		mov bx, reg_of_spase
		cmp bx,1
		jne off2
	;	mov reg_of_spase, 0
		mov cx, max_len
		
		sub cx, len ;---------------
		
		mov bx, si
		mov wordstarts, bx
		sub bx, len
		mov wordend, bx
	;	add cx, 2
	
	cycle_in_cycle:
		cmp cx,0	
		je bypass
		mov ah, 02h
		mov dx, '1'
		int 21h
		dec cx
		jmp cycle_in_cycle
		;push si
		
		
		bypass:
		mov cx, len 
		mov si, wordstarts
		c:
		lodsb
		mov ah, 02h
		mov dl, al
		mov dh, 0
		;int 21h
		dec cx
		cmp cx,0
		jne c
		
		
		
		pop si
		
		mov ah, 02h
		mov dx, 0Ah
		int 21h
		
		mov ah, 02h
		mov dx, 0Dh
		int 21h
		
	
		mov len, 0
	;	mov bx, 0
		mov reg_of_spase, 0
	off2:
		pop cx
		pop bx
		
	cmp cx,0	
	jne cycle2
	

	jmp off


off:
	int 20h

;----------Пoдпрограммы----------

read_filename proc

	xor bh, bh
	mov bl, filename[1]
	mov filename[bx+2], 0
	mov ax, 3D00h
	mov dx, offset filename+2
	int 21h
	
	ret
read_filename endp

print_ECS_Space proc
	
	mov dx, offset msg_press_ESC
	call print 
	mov dx, offset msg_press_Space
	call print 
	
	ret
print_ECS_Space endp

print proc
	mov ah,09h
	int 21h
	ret
print endp

find_max_len proc
		push cx
	
		cmp al, 20h
		je zero_len
		cmp al, 10h
		je zero_len
		cmp al, 13h
		je zero_len
		
		inc len
		jmp offproc 
	
	
	zero_len: 
		push bx 
		mov bx, max_len
		cmp bx, len  
		jl exh
		mov len, 0
		pop bx
		jmp offproc
	
	exh: 
		mov bx, len
		mov max_len,bx
		mov len,0
		pop bx   

	offproc:
		pop cx
		ret
find_max_len endp

print_len proc
	
		push cx
		
		cmp al, 20h
		je zero_len1
		cmp al, 10h
		je zero_len1
		cmp al, 13h
		je zero_len1
		mov cx, len
		inc cx
		mov len, cx
		
		
		jmp offproc1
	
	zero_len1:
		inc reg_of_spase
	offproc1:
		mov cx, len
		pop cx
		ret
print_len endp

press_button proc
	mov ah, 10h
	int 16h
	ret
press_button endp	

;----------Данные----------
	filename db 40 dup (' ')
	buffer dw 2048 dup(' ')
	buf dw 80(' ')
	handle dw 0
	reg dw 0
	max_len dw 0
	len dw 0
	wordstarts dw 0
	wordend dw 0
	reg_of_spase dw 0
	
;----------Сообщения---------	
	msg_error_file db ' Error: file is not found!', 0Ah, 0Dh, '$'
	msg_error_buffer db ' Error: can not read file', 0Ah, 0Dh, '$'
	msg_press_ESC db 'Press ESC for exit', 0Ah, 0Dh, '$'
	msg_press_Space db 'Press Space for continue', 0Ah, 0Dh, '$'
	msg_write_name db 'Write a filename', 0Ah, 0Dh, '$'
	msg_OK db 'OK', 0Ah, 0Dh, '$'
	
CSEG ends
end start
	reg_of_spase dw 0
	
;----------Сообщения---------	
	msg_error_file db ' Error: file is not found!', 0Ah, 0Dh, '$'
	msg_error_buffer db ' Error: can not read file', 0Ah, 0Dh, '$'
	msg_press_ESC db 'Press ESC for exit', 0Ah, 0Dh, '$'
	msg_press_Space db 'Press Space for continue', 0Ah, 0Dh, '$'
	msg_write_name db 'Write a filename', 0Ah, 0Dh, '$'
	msg_OK db 'OK', 0Ah, 0Dh, '$'
	
CSEG ends
end start
