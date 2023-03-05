format binary as "com"
org 100h

	mov ax, 0B800h
	mov ds, ax
	mov bx, 160
	mov ax, 00FC9h	
	mov [ds:bx], ax

	mov cx, 78
	mov ax, 00FCDh
	mov bx, 162
l1:	mov [ds:bx], ax
	add bx, 2
	dec cx
	jnz l1

	mov ax, 00FBBh	
	mov [ds:bx], ax

	mov cx, 22
	mov bx, 320
	mov ax, 00FBAh   
l2:	mov [ds:bx], ax
	mov dx, 78
	mov ax, 00F20h
l3:	add bx, 2
	mov [ds:bx], ax
	dec dx
	jnz l3
	add bx, 2
	mov ax, 00FBAh
	mov [ds:bx], ax
	add bx, 2
	dec cx
	jnz l2
	mov ax, 00FC8h
	mov [ds:bx], ax
	mov ax, 00FCDh
	mov cx, 78
	mov bx, 3842
l4:	mov [ds:bx], ax
	add bx, 2
	dec cx
	jnz l4
	mov ax, 00FBCh
	mov [ds:bx], ax
	ret