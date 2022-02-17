;; HITHAEGLIR 32B / hannu
;;
;; Strongly inspired by matisse (orbitaldecay 2010).

 mov al,0x13
 int 0x10
 lds dx,[bx]
 push ds
 pop es
L:
 mov dx,[bx]
 or [bx+318],dx
 or [bx+322],dx
 dec bx
 loop L
 lodsw
 aaa
 stosw
 mov cl,247
 in al,0x60
 dec ax
 jnz L
 ret
