;; ALMONDS IN A SNOWSTORM 128B / hannu
;
; One of my first prods. You just have to write that Mandelbrot, don't you?
; I wrote an initial FPU implementation. It looked too big for 64B and had
; plenty of space left for 128B so I started looking at what I could do.
; Julia sets are an obvious choice so I wrote that, and then some effect
; switching hacks, animation, zooming and whatnot.
;
; For a long time I struggled with an ugly palette. Eventually found a way to
; map the VGA palette nicely without losing too many bytes.
;
; Near release I realized FPU stack shouldn't overflow. It wasn't an issue on
; FreeDOS/QEMU so I never suspected it would be a problem. Luckily the intro
; was 126 bytes at that point and a simple FNINIT fixed the issue.
;
; Again, the Sizecoding wiki was very helpful while learning. Thanks to
; everyone who contributed there or shared information elsewhere!
;
; Greets to all sizecoders!

scale equ 50       ; just fits the fractals in 200px
iterations equ 15  ; works nicely with grayscale part of VGA palette

; MANDELBROT / JULIA
; pseudocode:
;  c = (x,y)
;  z = (0,0)
;  while(iterations):
;    temp = z*z
;    z = temp + c
;
; naming:
;   (X,Y) = c
;   (U,V) = z

xchg cx,ax ; init time cx=0

push 	0xa000-10
pop 	es
mov 	al,0x13
int 	0x10

;; Prepare stack for FPU code (after pusha)
push 4
push scale

bxoff equ -6 ; change if stack changes!

; STACK in relation to value of bx+bxoff (after pusha)
; +2  0x0004
; 0   scale
; -2  AX
; -4  CX
; -6  DX
; -8  BX
; -10 SP (before pusha)
; -12 BP
; -14 SI
; -16 DI
;
; helper macros to make address loading more readable
%define _4  [bx+bxoff+2]
%define _s  [bx+bxoff]
%define _ax [bx+bxoff-2]
%define _cx [bx+bxoff-4]
%define _dx [bx+bxoff-6]
%define _bx [bx+bxoff-8]

pixel:
imul di,byte 117 ; pseudorandom order to mask slow rendering (greets to HellMood!)
mov ax,0xCCCD   ; coordinate trick (greets to Rrrola!)
mul	di
jo same_frame

in al,0x60
dec al
jz exit
inc cl

same_frame:
movzx ax,dh
movsx dx,dl
sub 	ax,100		; align vertically

pusha 					; push all registers on stack

test cl,0x30     ; switch between mandelbrot and julia

; FPU stack contents in comments

fninit
fild  word _s   ; s

_julia1:
fild word _cx
fdiv st1
; NOTE: this is abused for mandelbrot scrolling, so don't jump over this section
fsincos            ; j(Y X) s
fxch st2
;jnz _common2

_mandel1:          ; s j(Y X)
fiadd  word _cx

_common2:
fild 	word _ax
fdiv st1
fild 	word _dx
fdivrp  st2   ; j(V U) Y X

fsub st2      ; scrolling
jnz _common3

_mandel2:
fldz
fldz                ; V U Y X

_common3:

mov cl,iterations

_mandel_iter:
fld st1         ; U V U Y X
fincstp         ; V U Y X
fmul st1,st0    ; V UV Y X
fmul st0        ; V² UV Y X
fdecstp         ; U V² UV Y X
fmul st0        ; U² V² UV Y X

; check if U²+V²>4
fld st0
fadd st2        ; V²+U² U² V² UV Y X
ficomp word _4  ; U² V² UV Y X
fnstsw ax
sahf
jae _non_mandel

fsubrp          ; U²-V² UV Y X
fadd st3        ; U' UV Y X
fxch st1        ; UV U' Y X
fadd st0        ; 2UV U' Y X
fadd st2        ; V' U' Y X
loop _mandel_iter

_non_mandel:
xchg ax,cx
add al,16
stosb

popa					; pop all registers from stack
inc di

jmp short pixel

exit:
; restore stack before exit
pop ax
pop ax
ret
