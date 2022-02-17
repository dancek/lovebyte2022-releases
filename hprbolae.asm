;; HYPERBOLAE 64B / hannu
;
; This is a difficult size category. I tried to find something interesting
; with the FPU that fits, and this was the best I could do. It was really
; difficult to get working on hardware because I had no idea what I was doing.
; But after a lot of FPU register debugging it finally does work. Everywhere
; I tested. It may not be the coolest demo, its graphical ideas might be few,
; but oh boy did I put in a lot of work to get it done.
;
; Greets to all sizecoders!

push 	0xa000
pop 	es
mov 	al,0x13
int 	0x10

push si
inc cx
fninit ; for some reason my laptop needs this on freedos
fld1

bxoff equ -4 ; change if stack changes!

; helper macros to make address loading more readable
%define _k  [bx+bxoff]
%define _ax [bx+bxoff-2]
%define _cx [bx+bxoff-4]
%define _dx [bx+bxoff-6]
%define _bx [bx+bxoff-8]

pixel:
mov ax,0xCCCD   ; coordinate trick (greets to Rrrola!)
mul	di
jo same_frame
inc cx

same_frame:
movzx ax,dh
movzx dx,dl
inc ax
inc dx

pusha

fild word _k

fild word _cx
fdivp st1
fsincos
faddp st2
fmulp st1

fild 	word _dx
fdivrp st1
fild 	word _ax
fabs
fyl2x

fist word _ax

popa
stosb
jmp short pixel
