%include "../include/io.mac"

struc request
	admin resb 1
	prio resb 1
	passkey resw 1
	username resb 51
endstruc

section .text
    global check_passkeys
    extern printf

check_passkeys:
    enter 0, 0
    pusha

    mov ebx, [ebp + 8]      ; requests
    mov ecx, [ebp + 12]     ; length
    mov eax, [ebp + 16]     ; connected
    ; vom considera contorul i pentru bucla, i = 0, length
    ; initializam contorul i cu 0
    xor esi, esi
for_i:
    ; verificam daca bucla a ajuns la final, adica i < length
    cmp esi, ecx
    jge end_for_i

    ; salvez ecx pe stiva pentru a folosi registrul cx
    push ecx
    ; setez ecx cu 0 pentru a folosi cx
    xor ecx, ecx

    ; calulez adresa passkey-ului curent
    mov edx, esi
    imul edx, request_size
    add edx, passkey
    mov cx, word [ebx + edx] ; cx = ebx + esi * request_size + passkey

    ; pastram valoarea veche a passkey-ului, inainte de prelucrari
    movzx ecx, cx
    push ecx

    ; verificam daca passkey-ul are primul si ultimul bit 1
    ; 0x8001 = 1000 0000 0000 0001
    and cx, 0x8001
    ; verificam daca cx contine acesti biti
    cmp cx, 0x8001
    ; daca nu indeplineste aceasta conditie, nu e hacker
    jne not_a_hacker_1

    ; verificam daca bitii de 1 din intervalul [2, 8] sunt in numar impar
    ; in passkey
    ; restauram vechea valoare a passkey-ului
    pop ecx
     ; o salvam pentru viitoarele verificari
    push ecx
    
    ; aducem bitii pe ultimele 8 pozitii, pentru a-i masca cu 0x7F
    shr cx, 8
    ; 0x7F = 0111 1111
    and cx, 0x7F

    ; numar numarul de biti de 1 "distrugand" numarul edx
    movzx edx, cx
    ; contorul de biti de 1
    xor edi, edi
nr_ones_1:
    ; salvez numarul inainte de a-l modifica
    push edx
    ; verific daca ultimul bit este 1
    and edx, 1
    cmp edx, 1
    ; daca este 1, sarim la label-ul corespunzator
    jnz is_one_1
next_bit_1:
    ; obtinem urmatorul bit, shiftand penultimul bit pe ultima pozitie
    ; restauram valoarea passkey-ului
    pop edx
    shr edx, 1
    ; verificam daca noul numar este 0, adica am ramas fara biti
    cmp edx, 0
    ; daca nu, se verifica bitul curent
    jnz nr_ones_1
    ; altfel, se iese din bucla
    jz first_set_of_seven_bits
is_one_1:
    ; crestem numarul de biti de 1
    inc edi
    ; sarim la urmatorul bit
    jmp next_bit_1
first_set_of_seven_bits:
    ; verificam daca numarul de biti de 1 e impar
    and edi, 1
    cmp edi, 1
    ; daca nu e impar, nu e hacker
    jz not_a_hacker_1

    ; restauram valoarea veche, inainte de prelucrarile anterioare
    pop ecx

    ; verificam daca bitii de 1 din intervalul [9, 15] sunt in numar par
    ; in passkey

    ; obtinem bitii de pe ultimele 7 pozitii, prin mascarea cu 0xFE
    ; 0xFE = 1111 1110 
    and cx, 0xFE

    ; numar numarul de biti de 1 "distrugand" numarul edx
    movzx edx, cx
    ; contorul de biti de 1
    xor edi, edi
nr_ones_2:
    ; salvez numarul inainte de a-l modifica
    push edx
    ; verific daca ultimul bit este 1
    and edx, 1
    cmp edx, 1
    ; daca este 1, sarim la label-ul corespunzator
    jnz is_one_2
next_bit_2:
    ; obtinem urmatorul bit, shiftand penultimul bit pe ultima pozitie
    ; restauram valoarea passkey-ului
    pop edx
    shr edx, 1
    ; verificam daca noul numar este 0, adica am ramas fara biti
    cmp edx, 0
    ; daca nu, se verifica bitul curent
    jnz nr_ones_2
    ; altfel, se iese din bucla
    jz second_set_of_seven_bits
is_one_2:
    ; crestem numarul de biti de 1
    inc edi
    ; sarim la urmatorul bit
    jmp next_bit_2
second_set_of_seven_bits:
    ; verificam daca numarul de biti de 1 e par
    and edi, 1
    cmp edi, 1
    ; daca nu e par, nu e hacker
    jnz not_a_hacker_2

    ; daca s-a ajuns aici, e hacker
    jmp hacker
end_for_i:
    ; daca se termina bucla dupa i, s-a parcurs tot vectorul
    jmp end
not_a_hacker_1:
    ; se fac pop-urile ramase pe stiva si se seteaza connected[i] cu 0
    pop ecx
    pop ecx
    mov byte [eax + esi], 0
    ; se trece la urmatorul request
    inc esi
    jmp for_i
not_a_hacker_2:
    ; se fac pop-urile ramase pe stiva si se seteaza connected[i] cu 0
    pop ecx
    mov byte [eax + esi], 0
    ; se trece la urmatorul request
    inc esi
    jmp for_i
hacker:
    ; se fac pop-urile ramase pe stiva si se seteaza connected[i] cu 1
    pop ecx
    mov byte [eax + esi], 1
    ; se trece la urmatorul request
    inc esi
    jmp for_i
end:
    popa
    leave
    ret
    