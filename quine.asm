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
t:db ';; QUINE / hannuçä; Greets to all sizecoders!çä; prints its source:çäorg 256çämov ah,6çäs:mov si,tçäl:lodsbçämov dl,alçäand dl,127çäcmp al,160çäint 33çäjne lçämov dl,39çäint 33çär:dec byte[l+4]çämov byte[r],195çäjmp sçät:db†'