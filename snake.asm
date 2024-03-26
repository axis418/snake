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
        call prepare_screen_1
start_here:
        mov ax, 2
        mov [snake_direction], ax
        mov ax, 00FCDh
        mov [snake_elements], ax
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
        mov bx, [snake_head]
        mov si, [snake_direction]
        mov ax, [bx]
        add si, ax
        mov ax, [es:si]
        cmp ax, 00FA2h
        jnz @f
        call ate_a_apple
        call draw_a_apple
        jmp sleep_here
@@:
        cmp ax, 00F20h
        jnz main_loop_done
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
        mov ax, 2
        call sleep
        jmp main_loop
        ret     
        

main_loop_done:
        mov di, 1830
        mov si, my_string
        mov ah, 0Eh
        call write_string
check:
        mov ah, 0Ch
        mov al, 08h
        int 21h
        cmp al, 27
        je finish
        cmp al, 32
        je start_here
        jmp check
finish:
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
        
                 

my_string: db "RESTART?", 0
my_string_1: db "Game made by axis418", 0
my_string_2: db "Use arrows to control the snake", 0
my_string_3: db "SCORE:", 0
snake_head: dw 0
snake_tail: dw 0
snake_direction: dw 2
snake_elements: dw 00FCDh
random: dw 0
random_k1: dw 20
random_k2: dw 140
random_k3: dw 3998
score: dw 9

prepare_screen:
        call get_tick_count
        mul ax
        mov [random], ax
        mov bx, 160
        mov ax, 00FDAh  
        mov [es:bx], ax
        mov cx, 78
        mov ax, 00FC4h
        mov bx, 162
@@:     mov [es:bx], ax
        add bx, 2
        dec cx
        jnz @b
        mov ax, 00FBFh  
        mov [es:bx], ax
        mov cx, 22
        mov bx, 320
        mov ax, 00FB3h   
l2:     mov [es:bx], ax
        mov dx, 78
        mov ax, 00F20h
@@:     add bx, 2
        mov [es:bx], ax
        dec dx
        jnz @b
        add bx, 2
        mov ax, 00FB3h
        mov [es:bx], ax
        add bx, 2
        dec cx
        jnz l2
        mov ax, 00FC0h
        mov [es:bx], ax
        mov ax, 00FC4h
        mov cx, 78
        mov bx, 3842
@@:     mov [es:bx], ax
        add bx, 2
        dec cx
        jnz @b
        mov ax, 00FD9h
        mov [es:bx], ax
        mov bx, 0
        mov cx, 80
        mov ax, 00F20h
@@:     mov [es:bx], ax
        add bx, 2
        dec cx
        jnz @b
        mov di, 0
        mov si, my_string_3
        mov ah, 0Ah
        call write_string
	xor ax, ax
	mov [score], ax
	call write_a_number
        ret

prepare_screen_1:
        call prepare_screen
        mov di, 3798
        mov si, my_string_1
        mov ah, 0Ah
        call write_string
        mov di, 1808
        mov si, my_string_2
        mov ah, 0Bh
        call write_string
check_1:
        mov ah, 0Ch
        mov al, 08h
        int 21h
        cmp al, 32
        je finish_1
        jmp check_1
finish_1:
        ret
        
        ; BX - head
        ; CX - tail
draw_a_snake:
        mov ax, [snake_elements]
        mov di, [snake_tail]
@@:     cmp di, 0
        jz @f
        mov bx, [di + snake_element.offs]
        mov [es:bx], ax
        mov di, [di + snake_element.next]
        jmp @b  
@@:     ret
        
                       
        ; AX - time to wait in ticks
sleep:
        mov cx, ax
        call get_tick_count
        mov di, dx
        mov si, ax
.l1:    call get_tick_count
        cmp ax, si
        jge sleep.l2
        mov bx, 0FFFFh
        sub bx, si
        add bx, ax
        mov ax, bx
        jmp @f
.l2:    sub ax, si
@@:     cmp ax, cx
        jl sleep.l1
        ret

draw_a_apple:
start:
        mov ax, [random]
        mov bx, [random_k1]     ; X(n+1) = (X(n) * k1 + k2) mod k3
        mul bx
        mov bx, [random_k2]
        add ax, bx
        mov bx, [random_k3]
        cmp ax, bx
        jl next
@@:
        sub ax, bx
        cmp ax, bx
        jae @b
next:
        
        mov [random], ax
        mov bx, ax
        mov ax, [es:bx]
        cmp ax, 00F20h
        jnz start
        cmp bx, 158
        jna start
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
        mov ax, [score]
        add ax, 500
        mov [score], ax
        call write_a_number
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

write_string:
write_string_l1:
        mov al, [si]
        cmp al, 0
        jz @f
        mov [es:di], ax
        inc si
        add di, 2
        jmp write_string_l1
@@:
        ret

write_a_number:
        mov di, 18
	mov bl, 10
	mov ax, [score]
@@:
        div bl
	add ah, 48
	mov [es:di], ah
	cmp al, 0
	jz @f
	and ax, 0ffh
	sub di, 2
	jmp @b
@@:
        ret
        

get_tick_count:
        push    ds        ; Preserve data segment
        pushf           ; Keep interrupt flag
        xor    ax,ax        ; Zero
        mov    ds,ax        ; Address BIOS data area
        cli            ; Don't want a tick to interrupt us
        mov    ax,[ds:46Ch]    ; Get loword of count
        mov    dx,[ds:46Eh]    ; Get hiword of count
        popf            ; Restore interrupt flag as provided
        pop    ds        ; Restore data segment
        ret            ; Return tick count in DX|AX

code_end:       db 0 