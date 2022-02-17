;; RIGID ROENTGEN 256B / hannu
;
; This is my first prod and what got me into sizecoding. I wrote the bytebeat
; and started wondering how small it could be. Then added a simple rotozoomer
; and some palette effects.
;
; Most of the implementation is copied and adapted from the Sizecoding wiki.
; I'm humbly standing on the shoulders of giants. Thanks to everyone who has
; shared information!
;
; I had the intro at 121 bytes without ESC support and the text, but I also had
; another 128 byte intro I liked more. So I started experimenting with adding
; text, and soon found a nice way to create and map a texture to the rotozoomed
; xor pattern.
;
; The result is this 256 byte demo. It's still basically the same 121 byte hack
; with all its shortcomings because I wanted to call it my first prod even
; though I've written a bunch of other intros in the meantime. I didn't bother
; with ESC support because, well, it sounded more like work than fun. Timer
; interrupts are a bit annoying.
;
; I'm also including the original 121 byte version in the archive. The first
; implementation of this bytebeat was actually a 77 byte Linux ELF (including
; ~36 bytes of header). Maybe that will become a demo in itself one day, as the
; 32-bit version of the bytebeat sounds quite different from this 16-byte one.
; But for now it's been enough to learn DOS+BIOS+16-bit. 32-bit and Linux
; syscalls feel much more complicated.
;
; Greets to all sizecoders!
;
; PS. BQN refers to this awesome array programming language:
;     https://mlochbaum.github.io/BQN/

org 100h

; init graphics
 mov al,0x13
 int 0x10

; init texture
 mov ah,9
 mov dx,text
 int 0x21

 xor si,si
 xor di,di
 push 0xa000
 pop ds
 push bp ; 0x09** works as a segment in 0x07c00-0x7ffff conventional memory
 pop es
 mov cx,128*128-1
cp:
 lodsb
 stosb
 test cx,0x7f
 jnz cnt
 add si,192 ; read 128-column texture from 320-wide buffer
cnt:
 loop cp

 ; ds=cs is needed during timer setup, and after that reading back the
 ; texture doesn't work because the ISR modifies CX
 push cs
 pop ds

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

 push es
 pop ds
 push 0xa000-10
 pop es

; init time variable
 mov ch,0xfa
 xor dx,dx


 xor di,di
 xor si,si
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
; sar ax,3
; sar bx,3
; xor al,bh
; and al,0xf8
 shr ax,2
 shr bx,3
 mov dx,ax
 shr dl,1
 xor dl,bh
 and dl,0xf8
 shr bx,6

 and ax,0x7f
 and bx,0x7f
 imul ax,128 ; ax * 128 + bx for 128x128 texture
 add ax,bx
 mov si,ax
 lodsb
 add ax,dx
 stosb

 jmp main

timer:
 pusha

; For a reason I don't understand, DS needs to be the initial value during
; this ISR. So set it and here and in the end.
 push ds
 push cs
 pop ds
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

 pop ds
 jz advance_timestep
 popa
 iret
advance_timestep:
 popa
 inc cx
 iret

text:
 db `\
Lovebyte2022\r\n\r\n\
Greets to all\r\n\
 sizecoders!\r\n\r\n\
-hannu\r\n\
PS. `,3,`BQN$`
