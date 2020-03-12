;Ввести текст из файла, имя которого задано в командной строке.
;Весь текст преобразуется следующим образом - каждое новое слово выводится
;в следующую колонку за счет добавления необходимого числа пробелов, ширина
;колонок одинаковая и определяется по самому длинному слову в тексте. Вывести
;полученный текст в другой файл и на экран. Если имя второго файла не задано в
;командной строке, то запрашивается у пользователя.

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
	push SI		
	mov SI, 128
	lodsb
	cmp AL, 0
	jnz pass
	mov AH, 09h
	mov DX, offset no_f
	int 21h
	int 20h		
	pass:
	add SI, 1
	mov f_adr, SI
	lp:
	lodsb
	cmp AL, 0Dh
	jnz lp
	dec SI
	xor AL,AL
	mov DS:[SI], byte ptr AL
	inc SI
	pop SI
	

	mov dx, offset msg_write_name
	call print
	
	mov ah, 0Ah 
	mov dx, offset filename
	int 21h
	mov dx, f_adr
	call read_filename

	jc error1
	
	mov handle, ax
	
	mov bx, handle
	mov ah, 3Fh
	mov cx, 2048
	mov dx, offset buffer
	int 21h
	jc error2
	
	push ax
	xor bh, bh
	mov bl, filename[1]
	mov filename[bx+2], 0
	mov ax, 3D00h
	mov dx, offset filename+2
	mov ah,3Ch   
	xor cx,cx               
	int 21h                 	    
	mov handle, AX	
	pop ax

	
	jmp a
	
error1:

	push ax
	push dx
	
	mov dx, offset msg_error_file
	call print 
	
	push ax
	push dx
	
	int 20h
	
error2:

	push ax
	push dx
	
	mov dx, offset msg_error_buffer
	call print 
	
	pop dx
	pop ax
	int 20h
	
a: 
	
	cmp ax,0
	jne on
	int 20h
	on:
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
	mov len, 0
;	dec max_len
	inc max_len
	pop si
continue:
	pop cx 
	mov wordstarts, si
cycle2:
	call print_len
		push bx
		push cx
		mov cx, max_len
		mov ax, toline
		add ax, cx
		sub cx, prevword
		mov bx, len
		mov prevword, bx
		mov toline, ax
		cmp ax, 80
		jl cycle_in_cycle
		mov dx, 0Ah
		call print_s
		mov dx, 0Dh
		call print_s
		mov toline, 0
	cycle_in_cycle:
		cmp cx,0	
		je bypass
		mov ax, toline
		cmp ax, 0
		je bypass
		mov dx, ' '
		call print_s
		;inc toline
		dec cx
		jmp cycle_in_cycle
		bypass:
		mov si, wordstarts
		mov cx, len
		c:
			cmp cx,0
			je nec
			lodsb
			mov dl, al
			mov dh, 0
			;inc toline
			call print_s
			dec cx
			jmp c
		nec:
		inc si
		mov wordstarts, si
		mov len, 0
		mov reg_of_spase, 0
	off2:
		pop cx
		pop bx
		
	cmp cx,0	
	jne cycle2
	

	jmp off


off:
	int 20h

;----------Процедуры----------

read_filename proc

	xor bh, bh
	mov ax, 3D00h
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
		cmp al, 13h
		je zero_len
		cmp al, 0Ah
		je zero_len
		cmp al, 0Dh
		je offproc 
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
	
		;push cx
		push bx
		mov bx, 0
		cccycle:
		dec cx
		lodsb
		cmp al, 20h
		je zero_len1
		cmp al, 13h
		je zero_len1
		cmp al, 0Ah
		je zero_len1
		cmp al, 0
		je zero_len1
		cmp al, 0Dh
		je nolen
		
		;mov cx, len
		inc bx
		;
		nolen:
		jmp cccycle
	
	zero_len1:
		mov len, bx
		pop bx
		ret
print_len endp

press_button proc
	mov ah, 10h
	int 16h
	ret
press_button endp	

		
print_s proc
	mov ah, 02h
	int 21h
	push CX
	push DX
	push AX
	push BX
	mov to_print, DL
	mov BX,handle               
	mov AH,40h ;write file             
	mov DX,offset to_print         
	mov CX,1
	int 21h
	pop BX
	pop AX
	pop	DX
	pop CX
	ret
print_s endp 

;----------Данные----------
	filename db 40 dup (' ')
	buffer dw 2048 dup(' ')
	f_adr dw 00
	f_adr1 dw 0
	handle dw 0
	toline dw 80
	prevword dw 0
	reg dw 0
	max_len dw 0
	len dw 0
	reg_of_spase dw 0
	to_print db 'A'
	wordstarts dw 0
	
	
	msg_error_file db ' Error: file is not found!', 0Ah, 0Dh, '$'
	msg_error_buffer db ' Error: can not read file', 0Ah, 0Dh, '$'
	msg_press_ESC db 'Press ESC for exit', 0Ah, 0Dh, '$'
	msg_press_Space db 'Press Space for continue', 0Ah, 0Dh, '$'
	no_f db 'Usage: lab filename [filename]',0Ah, 0Dh,'$'
	msg_write_name db 'Write a filename', 0Ah, 0Dh, '$'
	msg_OK db 'OK', 0Ah, 0Dh, '$'
	
CSEG ends
end start
