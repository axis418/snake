format binary as "com"
org 100h

 	call prepare_screen
	call draw_a_snake
main_loop:
	mov ah, 1
	int 16h
	jz main_loop_l1
	mov ah, 0
	int 16h
	cmp ah, 1
	je main_loop_done
main_loop_l1:
	mov ax, 15
	call sleep
	mov ax, [snake_head]
	mov bx, [snake_direction]
	add ax, bx
	mov [snake_head], ax
	push ds
	mov ax, 0B800h
	mov ds, ax
	mov bx, [snake_head]
	mov ax, 00F58h
	mov [ds:bx], ax
	pop ds
	jmp main_loop
main_loop_done: 
	ret

snake_head: dw 13*160+20
snake_tail: dw 13*160+14
snake_direction: dw 2

prepare_screen:
	push ds
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
	pop ds
	ret
	
	; BX - head
	; CX - tail
draw_a_snake:
	mov bx, [snake_head]
	mov dx, bx
	mov cx, [snake_tail]
	sub dx, cx
	mov ax, 0B800h
	push ds
	mov ds, ax		
	mov ax, 00F58h
draw_a_snake_l1:	
	mov [ds:bx], ax
	sub bx, 2
	sub dx, 2
	jnz draw_a_snake_l1
	pop ds
	ret	

	; AX - time to wait in ticks
sleep:
	mov cx, ax
	call get_tick_count
	mov di, dx
	mov si, ax
sleep_l2:
	call get_tick_count
	cmp ax, si
	jge sleep_l1
	mov bx, 0FFFFh
	sub bx, si
	add bx, ax
	mov ax, bx
	jmp sleep_l3

sleep_l1:
	sub ax, si
sleep_l3:
	cmp ax, cx
	jl sleep_l2
	ret
	
	

get_tick_count:
        push    ds        ; Preserve data segment
        pushf		; Keep interrupt flag
        xor    ax,ax        ; Zero
        mov    ds,ax        ; Address BIOS data area
        cli            ; Don't want a tick to interrupt us
        mov    ax,[ds:46Ch]    ; Get loword of count
        mov    dx,[ds:46Eh]    ; Get hiword of count
        popf            ; Restore interrupt flag as provided
        pop    ds        ; Restore data segment
        ret            ; Return tick count in DX|AX

	
	
	







