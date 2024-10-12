section .rodata
	global sbox
	global num_rounds
	sbox db 126, 3, 45, 32, 174, 104, 173, 250, 46, 141, 209, 96, 230, 155, 197, 56, 19, 88, 50, 137, 229, 38, 16, 76, 37, 89, 55, 51, 165, 213, 66, 225, 118, 58, 142, 184, 148, 102, 217, 119, 249, 133, 105, 99, 161, 160, 190, 208, 172, 131, 219, 181, 248, 242, 93, 18, 112, 150, 186, 90, 81, 82, 215, 83, 21, 162, 144, 24, 117, 17, 14, 10, 156, 63, 238, 54, 188, 77, 169, 49, 147, 218, 177, 239, 143, 92, 101, 187, 221, 247, 140, 108, 94, 211, 252, 36, 75, 103, 5, 65, 251, 115, 246, 200, 125, 13, 48, 62, 107, 171, 205, 124, 199, 214, 224, 22, 27, 210, 179, 132, 201, 28, 236, 41, 243, 233, 60, 39, 183, 127, 203, 153, 255, 222, 85, 35, 30, 151, 130, 78, 109, 253, 64, 34, 220, 240, 159, 170, 86, 91, 212, 52, 1, 180, 11, 228, 15, 157, 226, 84, 114, 2, 231, 106, 8, 43, 23, 68, 164, 12, 232, 204, 6, 198, 33, 152, 227, 136, 29, 4, 121, 139, 59, 31, 25, 53, 73, 175, 178, 110, 193, 216, 95, 245, 61, 97, 71, 158, 9, 72, 194, 196, 189, 195, 44, 129, 154, 168, 116, 135, 7, 69, 120, 166, 20, 244, 192, 235, 223, 128, 98, 146, 47, 134, 234, 100, 237, 74, 138, 206, 149, 26, 40, 113, 111, 79, 145, 42, 191, 87, 254, 163, 167, 207, 185, 67, 57, 202, 123, 182, 176, 70, 241, 80, 122, 0
	num_rounds dd 10

section .text
	global treyfer_crypt
	global treyfer_dcrypt

; void treyfer_crypt(char text[8], char key[8]);
treyfer_crypt:
	push ebp
	mov ebp, esp
	pusha

	mov esi, [ebp + 8] ; text
	mov edi, [ebp + 12] ; cheie	
	; vom considera contorul ecx pentru bucla de runde
	; si contorul edx pentru bucla de parcurgere a unui cuvant

	; initializam contorul pentru runde cu 0
	xor ecx, ecx

crypt_round_loop:
	; initializam contorul pentru cuvant cu 0
    xor edx, edx
crypt_byte_loop:
	; incarcam byte-ul curent din text in t
	mov al, byte [esi + edx]
	; incarcam byte-ul curent din cheie in bl
	mov bl, byte [edi + edx]
	; adunam la t byte-ul curent din cheie
	add al, bl 

	; se muta al intr-un registru de 32 de biti pt a fi folosit
	; ca index in sbox
	movzx eax, al
	; se inlocuieste t cu echivalentul sau din sbox
	mov al, byte [sbox + eax]

	; incrementam contorul pentru a trece la urmatoarea litera
	inc edx

	; facem contorul mod 8 ca sa se intoarca la inceputul cheii daca ajunge
	; la ultima litera
	mov ebx, edx
	and ebx, 7

	; adunam la t urmatorul byte din text
	add al, byte [esi + ebx]
	; t se roteste la stanga cu 1 bit
    rol al, 1

	; se suprascrie byte-ul din text de la (i + 1) % 8 cu t
	mov byte [esi + ebx], al

	; setam cu 0 registrii folositi, pentru operatiile viitoare
	xor eax, eax
	xor ebx, ebx

	; verificam daca am terminat cuvantul
    cmp edx, 8
	; daca nu, continuam
    jl crypt_byte_loop
end_crypt_byte_loop:
	; am terminat cuvantul, trecem la urmatoarea runda
	; incrementam contorul pentru runde
	inc ecx
	; verificam daca am terminat runda pentru a iesi din bucla
	cmp ecx, [num_rounds]
	jl crypt_round_loop

	popa
	leave
	ret

; void treyfer_dcrypt(char text[8], char key[8]);
treyfer_dcrypt:

	push ebp
	mov ebp, esp
	pusha

	mov esi, [ebp + 8] ; text
	mov edi, [ebp + 12] ; cheie
	
	; vom considera contorul ecx pentru bucla de runde
	; si contorul edx pentru bucla de parcurgere a unui cuvant

	; initializam contorul pentru runde cu 0
	xor ecx, ecx

decrypt_round_loop:
	; initializam contorul pentru cuvant cu 7, incepem de la final
    mov edx, 7
decrypt_byte_loop:
	; incarcam byte-ul curent din text in t
	mov al, byte [esi + edx]
	; incarcam byte-ul curent din cheie in bl
	mov bl, byte [edi + edx]
	; adunam la t byte-ul curent din cheie
	add al, bl

	; se muta al intr-un registru de 32 de biti pt a fi folosit
	; ca index in sbox
	movzx eax, al
	; se aplica sbox pe byte-ul nou format => obtinem top
	mov al, byte [sbox + eax]

	; salvam contorul pentru runda
	push ecx
	; facem contorul mod 8 ca sa se intoarca la inceputul cheii
	mov ecx, edx
	; incrementam contorul pt a trece la urmatoarea litera
	inc ecx
	and ecx, 7

	; incarcam byte-ul urmator din text in bl
	mov bl, byte [esi + ecx]
	; acesta se roteste la dreapta cu 1 bit => obtinem bottom
	ror bl, 1

	; realizam scaderea bottom - top
	sub bl, al
	; se suprascrie byte-ul din text de la (i + 1) % 8 cu bottom - top
	mov byte [esi + ecx], bl

	; se seteaza cu 0 registrii folositi
	xor eax, eax
	xor ebx, ebx

	; restauram contorul pt runda
	pop ecx
	; decrementam contorul pt a trece la urmatoarea litera
	dec edx
	; verificam daca am terminat cuvantul
    cmp edx, 0
	; daca nu, continuam
    jge decrypt_byte_loop
end_decrypt_byte_loop:
	; am terminat cuvantul, trecem la urmatoarea runda
	; incrementam contorul pentru runde
	inc ecx
	; verificam daca am terminat runda pentru a iesi din bucla
	cmp ecx, [num_rounds]
	jl decrypt_round_loop

	popa
	leave
	ret

