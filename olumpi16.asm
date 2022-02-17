;; OLUMPIC SWIM 16B / hannu

les bx,[si]
l:
inc bx
stosw
xor bl,bh
mov ah,bh
shr ax,1
and ah,0x0f
jmp l
