format binary as "com"                          
include 'macro/struct.inc'
org 100h

struct snake_element
	offs dw ?
	next dw ?
ends

        push es
	mov ax, 0B800h
	mov es, ax
 	call prepare_screen
	call create_snake
	call draw_a_apple
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
	sub bx, 160
	cmp bx, 0FFFEh
	jnz @f
	call draw_the_upper_left_corner
	jmp @f 
@@:
	cmp bx, 2
	jnz @f
	call draw_the_upper_right_corner
@@:
	mov bx, 160
	mov [snake_direction], bx
	mov bx, 00FBAh
	mov [snake_elements], bx
	jmp main_loop_l1
main_loop_check_up:
	cmp ah, 48h ; Up
	jne main_loop_check_left
	mov bx, [snake_direction]
	add bx, 0FF60h
	jz main_loop_l1
	sub bx, 0FF60h
	cmp bx, 0FFFEh
	jnz @f      
	call draw_the_lower_left_corner
@@:
	cmp bx, 2
	jnz @f
	call draw_the_lower_right_corner
@@:
	mov bx, 0FF60h
	mov [snake_direction], bx
	mov bx, 00FBAh
	mov [snake_elements], bx
	jmp main_loop_l1
main_loop_check_left:
	cmp ah, 4Bh
	jne main_loop_check_right
	mov bx, [snake_direction]
	add bx, 0FFFEh
	jz main_loop_l1
	sub bx, 0FFFEh
	cmp bx, 0FF60h
	jnz @f
	call draw_the_upper_right_corner
@@:
	cmp bx, 160
	jnz @f
	call draw_the_lower_right_corner
@@:
	mov bx, 0FFFEh
	mov [snake_direction], bx
	mov bx, 00FCDh
	mov [snake_elements], bx
	jmp main_loop_l1
main_loop_check_right:
	cmp ah, 4Dh
	jne main_loop_l1
	mov bx, [snake_direction]
	add bx, 2
	jz main_loop_l1
	sub bx, 2
	cmp bx, 0FF60h
	jnz @f
	call draw_the_upper_left_corner
@@:
	cmp bx, 160
	jnz @f
	call draw_the_lower_left_corner
@@:
	mov bx, 2
	mov [snake_direction], bx
	mov bx, 00FCDh
	mov [snake_elements], bx
	jmp main_loop_l1
	ret

main_loop_l1:
	;mov bx, [snake_head]
	;mov ax, [bx]
	;mov bx, [snake_direction]
	;add ax, bx
	;mov bx, [snake_head]
	;mov [bx], ax
	;mov bx, ax
	;mov ax, 00F58h
	;mov [es:bx], ax
	;mov si, [snake_tail]
	;mov ax, [si]
	;mov bx, ax
	;mov si, [snake_direction]
	;add ax, si
	;mov si, [snake_tail]
	;mov [si], ax
	;mov ax, 00F20h
	;mov [es:bx], ax
	mov bx, [snake_head]
	mov si, [snake_direction]
	mov ax, [bx]
	add si, ax
	mov ax, [es:si]
	cmp ax, 00FBAh
	jz main_loop_done
	cmp ax, 00FCDh
	jz main_loop_done
	cmp ax, 00F58h
	jz main_loop_done
	cmp ax, 00FA2h
	jnz @f
	call ate_a_apple
	call draw_a_apple
	jmp sleep_here
@@:
	mov bx, [snake_tail]
	mov ax, [bx]
	mov di, ax
	mov ax, 00F20h
	mov [es:di], ax
@@:
	mov di, [bx + snake_element.next]
	cmp di, 0
	jz @f
	mov ax, [di + snake_element.offs]
	mov [bx], ax
	mov bx, di 
	jnz @b
@@:
	
	mov ax, [bx]
	mov si, [snake_direction]
	add ax, si
	mov [bx], ax   
	mov si, ax
	mov ax, [snake_elements]
	mov [es:si], ax
sleep_here:
	mov ax, 3
	call sleep
	jmp main_loop
	ret	
	

main_loop_done:
	mov ax, 00F4Ch
	mov bx, 500
	mov [es:bx], ax
	mov ax, 00F4Fh
	add bx, 2
	mov [es:bx], ax
	mov ax, 00F58H
	add bx, 2
	mov [es:bx], ax
	pop es	 
	ret

create_snake:

	mov bx, code_end
	mov si, 13*160+14
	mov [bx + snake_element.offs], si
	mov [snake_tail], bx
	mov ax, bx
	add ax, 4                                                
	mov [bx + snake_element.next], ax
	mov cx, 9
@@:     add si, 2
	add bx, 4
	mov [bx + snake_element.offs], si
	add ax, 4                                                                   
	mov [bx + snake_element.next], ax
	dec cx
	jnz @b
	mov [bx + snake_element.next], 0
	mov [snake_head], bx
	ret
	
	         
	

snake_head: dw 0
snake_tail: dw 0
snake_direction: dw 2
snake_elements: dw 00FCDh

prepare_screen:
	mov bx, 0
	mov ax, 00FC9h	
	mov [es:bx], ax

	mov cx, 78
	mov ax, 00FCDh
	mov bx, 2
@@:	mov [es:bx], ax
	add bx, 2
	dec cx
	jnz @b

	mov ax, 00FBBh	
	mov [es:bx], ax

	mov cx, 23
	mov bx, 160
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
	mov ax, [snake_elements]
	mov di, [snake_tail]
@@:	cmp di, 0
	jz @f
	mov bx, [di + snake_element.offs]
	mov [es:bx], ax
	mov di, [di + snake_element.next]
	jmp @b	
@@:	ret
	
	               
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

draw_a_apple:
	call get_tick_count
	mov bx, ax
	mov si, 77
@@:
	sub bx, si
	cmp bx, si
	jae @b
	inc bx
	call get_tick_count
	mov cx, ax
	mov si, 21
@@:
	sub cx, si
	cmp cx, si
	jae @b
	add cx, 2
	add bx, bx
@@:
	add bx, 160
	dec cx
	cmp cx, 0
	jnz @b
	mov ax, [es:bx]
	cmp ax, 00F20h
	jz next
@@:
	add bx, 6
	mov ax, [es:bx]
	cmp ax, 00F20h
	jnz @b
next:
	mov ax, 00FA2h
	mov [es:bx], ax 
	ret  

ate_a_apple:
	mov bx, [snake_head]
	mov di, bx
	sub di, 4
	mov cx, [bx + snake_element.offs]
	mov si, [di + snake_element.next]
	add si, 4
	mov [bx + snake_element.next], si
	mov ax, [snake_direction]
	add cx, ax
	mov [si + snake_element.offs], cx
	mov [si + snake_element.next], 0
	mov [snake_head], si
	mov bx, cx
	mov ax, [snake_elements]
	mov [es:bx], ax
	ret

draw_the_upper_left_corner:
	push bx
	mov ax, 00FC9h
	mov bx, [snake_head]
	mov bx, [bx]
	mov [es:bx], ax
	pop bx
	ret

draw_the_upper_right_corner:
	push bx
	mov ax, 00FBBh 
	mov bx, [snake_head]
	mov bx, [bx]
	mov [es:bx], ax
	pop bx
	ret

draw_the_lower_left_corner:
	push bx
	mov ax, 00FC8h
	mov bx, [snake_head]
	mov bx, [bx]
	mov [es:bx], ax
	pop bx
	ret

draw_the_lower_right_corner:
	push bx
	mov ax, 00FBCh
	mov bx, [snake_head]
	mov bx, [bx]
	mov [es:bx], ax
	pop bx
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

code_end:	db 0 

	
	
	







