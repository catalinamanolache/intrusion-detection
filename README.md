**Nume:** Manolache Maria-Catalina
**Grupa:** 313CA

**Intrusion Detection:**
Un proiect de detectie a intruziunilor care implementeaza verificarea
permisiunilor, sortarea cererilor, detectarea hackerilor, criptare/decriptare
Treyfer si navigarea intr-un labirint.

# Task 1 - Permissions

Codul incepe prin extragerea ID-ul furnicii din primii 8 biti ai lui n din
antetul functiei care se foloseste pentru a accesa pozitia la care este stocata
lista de sali pe care furnica le poate rezerva din vectorul ant_permissions.

Se extrag urmatorii 24 de biti din n, care contin salile pe care le vrea
furnica.

Se verifica daca furnica are permisiunea de a accesa toate camerele dorite,
efectuand operatia and, bit cu bit, intre permisiunile furnicii si camerele
dorite si comparand rezultatul cu salile dorite.

Daca furnica are acces la toate salile pe care le doreste, se va scrie 1 in 
res, altfel se va scrie 0.

# Task 2 - Requests

## Subtask 1
Codul incepe prin initializarea contoarelor pentru buclele exterioare si
interioare (i si j). Apoi, intra in bucla exterioara (for_i), unde se verifica
daca bucla a ajuns la final. Daca nu, se initializeaza contorul pentru bucla 
interioara (for_j) si se intra in aceasta.

In bucla interioara, se compara fiecare pereche de request-uri adiacente. Mai
intai, se compara campul admin al acestora. Daca request-ul i are un camp
admin mai mic decat request-ul j, atunci le interschimbam, deoarece cererile cu
admin = 1 sunt prioritare fata de cele cu admin = 0.
Daca request-ul i are un camp admin mai mare decat request-ul j, atunci acestea
sunt deja sortate si se trece la alta pereche.

Daca campurile admin sunt egale, se compara campul prio al celor doua
request-uri. Daca request-ul i are un camp prio mai mare decat request-ul j,
atunci le interschimbam, deoarece cererile cu prio mai mic sunt prioritare.
Daca request-ul i are un camp prio mai mic decat request-ul j, atunci acestea
sunt deja sortate si se trece la alta pereche.

Daca campurile prio sunt egale, se compara campul username al celor doua
request-uri, litera cu litera. Daca username-ul cererii i este lexicografic
mai mare decat username-ul cererii j, atunci le interschimbam, deoarece cererile
trebuie sortate alfabetic dupa username.
Daca request-urile sunt sortate deja alfabetic, se trece la alta pereche.

In partea de swap a codului, se interschimba, pe rand, campurile admin, prio,
passkey si username. Pentru username, se schimba litera cu litera.

## Subtask 2
Codul incepe prin initializarea contorului (i) pentru bucla (for_i) cu 0. 

Pentru fiecare request, se verifica urmatoarele conditii:
1. Daca primul si ultimul bit al passkey-ului sunt 1.
2. Daca numarul de biti de 1 din intervalul [2, 8] al passkey-ului este impar.
3. Daca numarul de biti de 1 din intervalul [9, 15] al passkey-ului este par.

Daca vreuna dintre aceste 3 conditii nu este indeplinita, utilizatorul nu este
considerat hacker si se seteaza valoarea corespunzatoare lui din vectorul 
connected cu 0.

Daca toate conditiile sunt indeplinite, utilizatorul este considerat hacker si
se seteaza valoarea corespunzatoare lui din connected cu 1.

# Task 3 - Treyfer

Codul incepe prin initializarea contoarelor pentru runda si parcurgerea unui
cuvant.
## treyfer_crypt:
Se parcurge fiecare byte din text, se aduna cu byte-ul corespunzator 
din cheie si apoi se inlocuieste cu echivalentul sau din sbox.
Apoi, se aduna la acesta urmatorul byte din text si se roteste rezultatul la
stanga cu 1 bit. Intr-un final, byte-ul de pe pozitia (i + 1) % 8 se inlocuieste
cu byte-ul rezultat in urma acestor prelucrari. Acest proces are loc pentru
o pereche cheie - cuvant de 8 caractere fiecare, timp de 10 runde.

## treyfer_dcrypt:
Procesul de decriptare este inversul celui de criptare. Pentru
fiecare runda, functia parcurge fiecare byte din text in ordine inversa, il
aduna cu byte-ul corespunzator din cheie si apoi se inlocuieste cu echivalentul
sau din sbox, obtinandu-se top. Apoi, se roteste urmatorul byte din text la 
dreapta cu 1 bit, obtinandu-se bottom. Intr-un final, byte-ul de pe pozitia 
(i + 1) % 8 se inlocuieste cu diferenta bottom - top. Acest proces are loc
pentru o pereche cheie - cuvant de 8 caractere fiecare, timp de 10 runde.

# Task 4 - Labyrinth

Codul incepe prin initializarea contoarelor pentru linii (edi) si coloane (ebx)
cu 0. Apoi, se intra intr-o bucla in care incercam sa ne mutam in dreapta, in 
jos, in stanga si in sus, in aceasta ordine.

Pentru fiecare directie, verifica daca celula in care incearca sa se mute este
libera. Daca este, marcheaza celula ca vizitata (schimband valoarea din '0' in
'1') si continua in acea directie. Daca nu, incearca urmatoarea directie.

Cand ajunge la iesire, salveaza pozitia de iesire in variabilele date ca
parametrii si iese din functie.

In cazul in care nu se poate muta in nicio directie, se revine la pozitia
initiala si se incearca o alta directie.

De asemenea, se verifica daca am ajuns la ultima linie sau coloana din labirint

Acest proces se repeta pana cand se gaseste o cale de iesire.