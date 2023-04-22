format binary as "com"
org 100h
        push es
	mov ax, 0B800h
	mov es, ax
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
	cmp ah, 50h ; Down
	jne main_loop_check_up
	mov bx, [snake_direction]
	add bx, 160
	jz main_loop_l1
	mov bx, 160
	mov [snake_direction], bx
	jmp main_loop_l1
main_loop_check_up:
	cmp ah, 48h ; Up
	jne main_loop_check_left
	mov bx, [snake_direction]
	add bx, 0FF60h
	jz main_loop_l1
	mov bx, 0FF60h
	mov [snake_direction], bx
	jmp main_loop_l1
main_loop_check_left:
	cmp ah, 4Bh
	jne main_loop_check_right
	mov bx, [snake_direction]
	add bx, 0FFFEh
	jz main_loop_l1
	mov bx, 0FFFEh
	mov [snake_direction], bx
	jmp main_loop_l1
main_loop_check_right:
	cmp ah, 4Dh
	jne main_loop_l1
	mov bx, [snake_direction]
	add bx, 2
	jz main_loop_l1
	mov bx, 2
	mov [snake_direction], bx
	jmp main_loop_l1

main_loop_l1:
	mov ax, 5
	call sleep
	mov ax, [snake_head]
	mov bx, [snake_direction]
	add ax, bx
	mov [snake_head], ax
	mov bx, [snake_head]
	mov ax, 00F58h
	mov [es:bx], ax
	
	mov bx, [snake_tail]
	mov cx, [snake_direction]
	add cx, bx
	mov [snake_tail], cx
	mov bx, [snake_tail]
	mov ax, 00F20h
	mov [es:bx], ax
	jmp main_loop
main_loop_done:
	pop es 
	ret

snake_head: dw 13*160+20
snake_tail: dw 13*160+14
snake_direction: dw 2

prepare_screen:
	mov bx, 160
	mov ax, 00FC9h	
	mov [es:bx], ax

	mov cx, 78
	mov ax, 00FCDh
	mov bx, 162
@@:	mov [es:bx], ax
	add bx, 2
	dec cx
	jnz @b

	mov ax, 00FBBh	
	mov [es:bx], ax

	mov cx, 22
	mov bx, 320
	mov ax, 00FBAh   
l2:	mov [es:bx], ax
	mov dx, 78
	mov ax, 00F20h
@@:	add bx, 2
	mov [es:bx], ax
	dec dx
	jnz @b
	add bx, 2
	mov ax, 00FBAh
	mov [es:bx], ax
	add bx, 2
	dec cx
	jnz l2
	mov ax, 00FC8h
	mov [es:bx], ax
	mov ax, 00FCDh
	mov cx, 78
	mov bx, 3842
@@:	mov [es:bx], ax
	add bx, 2
	dec cx
	jnz @b
	mov ax, 00FBCh
	mov [es:bx], ax
	ret
	
	; BX - head
	; CX - tail
draw_a_snake:
	mov bx, [snake_head]
	mov dx, bx
	mov cx, [snake_tail]
	sub dx, cx
	mov ax, 00F58h
draw_a_snake_l1:	
	mov [es:bx], ax
	sub bx, 2
	sub dx, 2
	jnz draw_a_snake_l1
	ret	
	               
	; AX - time to wait in ticks
sleep:
	mov cx, ax
	call get_tick_count
	mov di, dx
	mov si, ax
.l1:	call get_tick_count
	cmp ax, si
	jge sleep.l2
	mov bx, 0FFFFh
	sub bx, si
	add bx, ax
	mov ax, bx
	jmp @f
.l2:	sub ax, si
@@:	cmp ax, cx
	jl sleep.l1
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

	
	
	







