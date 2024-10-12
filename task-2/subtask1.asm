%include "../include/io.mac"

struc request
	admin resb 1
	prio resb 1
	passkey resw 1
	username resb 51
endstruc

section .text
	global sort_requests
	extern printf

sort_requests:
	enter 0,0
	pusha

	mov ebx, [ebp + 8]      ; requests
	mov ecx, [ebp + 12]     ; length
	; vom considera contorul i pentru bucla exterioara, i = 0, length - 1
	; j pentru bucla interioara, j = i + 1, length

	; initializam contorii pentru bucle
	xor edi, edi ; j = 0
	xor esi, esi ; i = 0
for_i:
	; verificam daca bucla dupa i a ajuns la final
	dec ecx ; scadem lungimea pentru a face comparatia
	cmp esi, ecx ; i < length - 1
	; daca i devine egal cu length - 1, atunci am incheiat
	jge end_for_i

	; revenim la lungimea initiala
	inc ecx
	; initializam contorul pentru j cu j = i + 1
	mov edi, esi
	inc edi
for_j: 
	; verificam daca bucla dupa j a ajuns la final
	cmp edi, ecx ; j < length?
	jge end_for_j
	; daca j devine egal cu length, atunci am incheiat
compare_start:
	; incepem seria de comparari
	; salvam ecx pentru a nu pierde lungimea
	push ecx
compare_admin:
	; calculam adresa elementului i
	mov edx, esi
	imul edx, request_size
	mov al, byte [ebx + edx + admin] ; req[i].admin

	; calculam adresa elementului j
	mov edx, edi
	imul edx, request_size
	mov cl, byte [ebx + edx + admin] ; req[j].admin

	; comparam campul admin al celor doua request-uri
	cmp al, cl
	; daca req[i].admin < req[j].admin, atunci le interschimbam
	; requesturile cu admin = 1 sunt prioritare celor cu admin = 0
	jl swap_start
	; altfel, sunt deja sortate dupa admin si incheiem compararea
	jg end_swap
compare_prio:
	; calculam adresa elementului i
	mov edx, esi
	imul edx, request_size
	movzx ax, byte [ebx + edx + prio] ; req[i].prio

	; calculam adresa elementului j
	mov edx, edi
	imul edx, request_size
	movzx cx, byte [ebx + edx + prio] ; req[j].prio

	; comparam campul prio al celor doua request-uri
	cmp ax, cx
	; daca req[i].prio > req[j].prio, atunci le interschimbam
	; requesturile cu prio mai mica sunt prioritare
	jg swap_start
	; altfel, sunt deja sortate dupa prio si incheiem compararea
	jl end_swap
compare_username_start:
	; incepem compararea litera cu litera a username-urilor
	; notam cu k indexul curent in username (ecx va contine k)
	xor ecx, ecx
	; edx va fi folosit pt calculul adresei elementelor
compare_username:
	; calculam adresa literei curente din req[i].username
	mov edx, esi
	imul edx, request_size
	add edx, username
	add edx, ecx ; edx = esi * request.size + username + k
	; mutam in al litera curenta din req[i].username
	mov al, byte [ebx + edx] ; req[i].username[k]

	; salvam idx i pe stiva pentru a folosi esi in calculul adresei urmatoare
	push esi
	
	; calculam adresa literei curente din req[j].username
	mov esi, edi 
	imul esi, request_size
	add esi, username
	add esi, ecx ; esi = edi * request.size + username + k

	; salvam idx j pe stiva pentru a folosi edi drept contorul k in username pt
	; ca am nevoie de cl pentru stocarea literei curente din req[j].username
	push edi
	mov edi, ecx

	; mutam in cl litera curenta din req[j].username
	; setam ecx pe 0 pentru a folosi cl
	xor ecx, ecx
	; in cl vom stoca litera curenta din req[j].username
	mov cl, byte [ebx + esi] ; req[j].username[k]

	; comparam req[i].username[k] cu req[j].username[k]
	cmp al, cl
	; daca i.username[k] > j.username[k] atunci le interschimbam
	jg aux_compare_swap
	; daca i.username[k] < j.username[k] atunci incheiem compararea
	jl aux_compare_end
	; restauram contorul k pentru literele din username
	mov ecx, edi
	; trecem la urmatorea litera
	inc ecx
	; verificam daca am ajuns la sfarsitul username-ului
	cmp ecx, 51
	; daca nu, trecem la urmatoarea litera
	jl aux_compare_next
aux_compare_next:
	pop edi ; restaurez j
	pop esi ; restaurez i
	jmp compare_username ; trecem la urmatoarea litera
end_compare:
	; daca s-a ajuns aici, inseamna ca cele doua request-uri nu trebuie
	; schimbate, deci trecem la urmatoarea iteratie dupa j
	pop edi ; restaurez j
	pop esi ; restaurez i
	jmp end_swap
aux_compare_swap:
	; label folosit pentru trecerea la interschimbarea request-urilor 
	pop edi ; restaurez j
	pop esi ; restaurez i
	jmp swap_start
aux_compare_end:
	; label folosit pentru a incheia compararea si a trece la urm iteratie
	pop edi ; restaurez j
	pop esi ; restaurez i
	jmp end_swap
swap_start:
	; incepem interschimbarea request-urilor
swap_admin:
	; interschimbam req[i].admin cu req[j].admin
	mov edx, esi
	imul edx, request_size
	mov al, byte [ebx + edx + admin] ; req[i].admin

	mov edx, edi
	imul edx, request_size
	mov cl, byte [ebx + edx + admin] ; req[j].admin

	; interschimbarea campurilor:
	mov edx, esi
	imul edx, request_size
	; req[i].admin = req[j].admin
	mov byte [ebx + edx + admin], cl 

	mov edx, edi
	imul edx, request_size
	; req[j].admin = req[i].admin
	mov byte [ebx + edx + admin], al 

swap_prio:
	; interschimbam req[i].prio cu req[j].prio
	mov edx, esi
	imul edx, request_size
	mov al, byte [ebx + edx + prio] ; req[i].prio

	mov edx, edi
	imul edx, request_size
	mov cl, byte [ebx + edx + prio] ; req[j].prio

	; interschimbarea campurilor:
	mov edx, esi
	imul edx, request_size
	; req[i].prio = req[j].prio
	mov byte [ebx + edx + prio], cl

	mov edx, edi
	imul edx, request_size
	; req[j].prio = req[i].prio
	mov byte [ebx + edx + prio], al

swap_passkey:
	; interschimbam req[i].passkey cu req[j].passkey
	mov edx, esi
	imul edx, request_size
	mov ax, word [ebx + edx + passkey] ; req[i].passkey

	mov edx, edi
	imul edx, request_size
	mov cx, word [ebx + edx + passkey] ; req[j].passkey

	; interschimbarea campurilor:
	mov edx, esi
	imul edx, request_size
	; req[i].passkey = req[j].passkey
	mov word [ebx + edx + passkey], cx

	mov edx, edi
	imul edx, request_size
	; req[j].passkey = req[i].passkey
	mov word [ebx + edx + passkey], ax
swap_username_start:
	; incepem interschimbarea username-urilor, litera cu litera
	; notam cu k indexul curent in username (ecx va contine k)
	xor ecx, ecx
swap_username:
	; interschimbam req[i].username[k] cu req[j].username[k]
	; calculam adresa literei curente din req[i].username
	mov edx, esi
	imul edx, request_size
	add edx, username
	add edx, ecx ; edx = esi * request.size + username + k
	mov al, byte [ebx + edx] ; al = req[i].username[k]
	; salvez req[i].username[k] pe stiva
	movzx eax, al
	push eax

	; calculam adresa literei curente din req[j].username
	mov edx, edi
	imul edx, request_size
	add edx, username
	add edx, ecx ; edx = edi * request.size + username + k
	mov al, byte [ebx + edx] ; al = req[j].username[k]
	movzx eax, al

	; req[i].username[k] = req[j].username[k]
	mov edx, esi
	imul edx, request_size 
	add edx, username
	add edx, ecx ; edx = esi * request.size + username + k
	; suprascriem req[i].username[k] cu req[j].username[k]
	mov byte [ebx + edx], al

	; restaurez req[i].username[k] pentru a-l pune in req[j].username[k]
	pop eax

	; req[j].username[k] = req[i].username[k]
	mov edx, edi
	imul edx, request_size
	add edx, username
	add edx, ecx ; edx = edi * request.size + username + k
	; suprascriem req[j].username[k] cu req[i].username[k]
	mov byte [ebx + edx], al
	; trecem la urmatoarea litera
	inc ecx
	; verificam daca am ajuns la sfarsitul username-ului
	cmp ecx, 51
	; daca nu, trecem la urmatoarea litera
	jl swap_username
end_swap:
	; incheiem compararea si interschimbarea
	; se executa o noua iteratie dupa j
	; restaurez ecx
	pop ecx
	; incrementam contorul j
	inc edi
	jmp for_j
end_for_j:
	; se executa o noua iteratie dupa i
	inc esi
	jmp for_i
end_for_i:
	popa
	leave
	ret
	