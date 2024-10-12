%include "../include/io.mac"

extern printf
extern position
global solve_labyrinth


section .text

; void solve_labyrinth(int *out_line, int *out_col, int m, int n, char **labyrinth);
solve_labyrinth:

    push    ebp
    mov     ebp, esp
    pusha

    mov     eax, [ebp + 8]  ; unsigned int *out_line, pointer to structure containing exit position
    mov     ebx, [ebp + 12] ; unsigned int *out_col, pointer to structure containing exit position
    mov     ecx, [ebp + 16] ; unsigned int m, number of lines in the labyrinth
    mov     edx, [ebp + 20] ; unsigned int n, number of colons in the labyrinth
    mov     esi, [ebp + 24] ; char **a, matrix represantation of the labyrinth

    ; initializam contoarele pentru linii si coloane cu 0
    xor edi, edi ; linii
    ; salvam coloana de iesire
    push ebx
    xor ebx, ebx ; coloane
    ; salvam linia de iesire
    push eax
next_step:
    ; verificam daca linia curenta este ultima linie
    dec ecx
    cmp edi, ecx
    jge reached_exit

    ; verificam daca coloana curenta este ultima coloana
    dec edx
    cmp ebx, edx
    jge reached_exit    

    ; revenim la dimensiunile originale
    inc edx
    inc ecx

    ; extragem elementul de la pozitia a[edi][ebx]
    mov eax, [esi + edi * 4] ; a[edi]
    movzx eax, byte [eax + ebx] ; a[edi][ebx]
    ; verificam daca celula curenta este libera
    cmp eax, 0x30
    ; daca nu, sarim la final
    jne end
    
    ; marcam celula curenta ca fiind vizitata
    mov eax, [esi + edi * 4]
    mov byte [eax + ebx], 0x39

    ; incercam sa ne mutam in dreapta
    inc ebx
    ; extragem elementul de la pozitia a[edi][ebx]
    mov eax, [esi + edi * 4] ; a[edi]
    movzx eax, byte [eax + ebx] ; a[edi][ebx]
    ; verificam daca celula curenta este libera
    cmp eax, 0x30
    ; daca nu, sarim la final
    je next_step

    ; incercam sa ne mutam in jos
    dec ebx
    inc edi
    ; extragem elementul de la pozitia a[edi][ebx]
    mov eax, [esi + edi * 4] ; a[edi]
    movzx eax, byte [eax + ebx] ; a[edi][ebx]
    ; verificam daca celula curenta este libera
    cmp eax, 0x30
    ; daca nu, sarim la final
    je next_step

    ; incercam sa ne mutam in stanga
    dec edi
    dec ebx
    ; extragem elementul de la pozitia a[edi][ebx]
    mov eax, [esi + edi * 4]  ; a[edi]
    movzx eax, byte [eax + ebx] ; a[edi][ebx]
    ; verificam daca celula curenta este libera
    cmp eax, 0x30
    ; daca nu, sarim la final
    je next_step

    ; incercam sa ne mutam in sus
    inc ebx
    dec edi
    ; extragem elementul de la pozitia a[edi][ebx]
    mov eax, [esi + edi * 4]  ; a[edi]
    movzx eax, byte [eax + ebx] ; a[edi][ebx]
    ; verificam daca celula curenta este libera
    cmp eax, 0x30
    ; daca nu, sarim la final
    je next_step
reached_exit:
    ; am ajuns la final si salvam pozitia
    ; restauram valorile initiale de pe stiva
    pop eax
    ; salvam linia de iesire
    mov [eax], edi
    mov edi, ebx
    pop ebx
    ; salvam coloana de iesire
    mov [ebx], edi
    jmp end_2

end:
    pop ebx
end_2:
    popa
    leave
    ret

