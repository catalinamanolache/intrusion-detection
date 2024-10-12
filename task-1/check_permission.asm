%include "../include/io.mac"

extern ant_permissions

extern printf
global check_permission

section .text

check_permission:
    push ebp
    mov ebp, esp
    pusha

    ; id si permisiunile furnicii
    mov eax, [ebp + 8]
    ; adresa unde se va scrie rezultatul
    mov ebx, [ebp + 12]

    ; se obtin primii 8 biti (id-ul furnicii)
    mov edx, eax
    ; 0xFF000000 = 11111111 00000000 00000000 00000000
    and edx, 0xFF000000
    ; aducem bitii in dreapta cu 24 pozitii pentru a-i folosi drept index
    ; in vectorul ant_permissions
    shr edx, 24
    ; obtinem lista de sali pe care furnica le poate accesa in edx
    mov edx, dword [ant_permissions + edx * 4]
    
    ; se obtin urmatorii 24 biti (ce sali doreste furnica)
    mov ecx, eax
    ; 0x00FFFFFF = 00000000 11111111 11111111 11111111
    ; obtinem salile pe care le doreste furnica in ecx
    and ecx, 0x00FFFFFF
    
    ; se verifica daca furnica are permisiunea de a accesa salile dorite
    and edx, ecx
    cmp edx, ecx
    ; daca furnica are acces la toate salile dorite, res devine 1
    je access_granted
    ; altfel, res devine 0
    mov byte [ebx], 0
    jmp end
access_granted:
    mov byte [ebx], 1
end:
    popa
    leave
    ret

