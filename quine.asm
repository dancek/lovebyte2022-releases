;; QUINE / hannu
; Greets to all sizecoders!
; prints its source:
org 256
mov ah,6
s:mov si,t
l:lodsb
mov dl,al
and dl,127
cmp al,160
int 33
jne l
mov dl,39
int 33
r:dec byte[l+4]
mov byte[r],195
jmp s
t:db ';; QUINE / hannu��; Greets to all sizecoders!��; prints its source:��org 256��mov ah,6��s:mov si,t��l:lodsb��mov dl,al��and dl,127��cmp al,160��int 33��jne l��mov dl,39��int 33��r:dec byte[l+4]��mov byte[r],195��jmp s��t:db�'