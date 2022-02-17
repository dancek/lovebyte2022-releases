;; RIGID ROENTGEN 128B / hannu
;
; My first prod, released as expanded to 256 bytes. See rr-256b.asm.

org 100h

; init graphics
 mov al,0x13
 int 0x10

; init time variable
 mov ch,0xfa

; init timer for pc speaker and animation
; Copied from http://www.sizecoding.org/wiki/Output#PC_Speaker_variant
 mov al,63
 out 0x61,al
 mov al,149
 out 0x40,al
 salc
 out 0x40,al
 mov al,0x90
 out 0x43,al
 mov ax,0x2508
 mov dx,timer
 int 0x21

 push 0xa000-10
 pop es
 xor di,di
main:
 mov ax,0xcccd
 mul di
 movzx ax,dh		; get X into AL
 movsx dx,dl		; get Y into DL
 mov bx,ax
 imul bx,cx
 add bh,dl
 imul dx,cx
 sub al,dh
 sar ax,3
 sar bx,3
 xor al,bh
 and al,0xf8
 stosb			; finally, draw to the screen
 jmp main

timer:
 pusha
.counter: ; dx=t, the 0 gets modified
 mov dx, 0
 mov cx, dx
 sar cx, 1
 or ch, dh
 sar cx, 4
 or cx, dx
 sar cx, 5
 mov ax, dx
 and al, 0x7d
 mul cx
 mov dx,0x03c9
 out dx,al
 shl ax, 1
 out 0x42,al

 inc word [timer.counter+1]
 mov al,0x20
 out 0x20,al
 test bl,0x7f ; this determines "framerate"; 8000/128 ~ 62.5fps
 jz advance_timestep
 popa
 iret
advance_timestep:
 popa
 inc cx
 iret
