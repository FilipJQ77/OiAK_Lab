SYSEXIT = 1
EXIT_SUCCESS = 0

.data
liczba1: .long 0x10304008, 0x701100FF, 0x45100020, 0x08570030
len1 = (. - liczba1)/4 # dlugosc 1 liczby w bajtach, zakladamy ze liczba 1 ma wieksza/taka sama dlugosc
liczba2: .long 0xF040500C, 0x00220026, 0x321000CB, 0x04520031
len2 = (. - liczba2)/4 # dlugosc 2 liczby w bajtach

.text

.global _start
_start:
# edx trzyma indeks ostatnich bajtow liczby 1, edi indeks ostatnich bajtow liczby 2
movl $len1-1, %edx
movl $len2-1, %edi
# ecx trzyma dlugosc 2 liczby, bedzie licznikiem petli
movl $len2, %ecx

clc

# petla dodajaca do siebie 2 liczby, dopoki mniejsza liczba sie nie skonczyla
petla1:
  movl liczba1(,%edx,4), %eax
  movl liczba2(,%edi,4), %ebx
  adcl %ebx, %eax
  pushl %eax
  dec %edx
  dec %edi
  loop petla1

# sprawdzamy ile jeszcze zostalo 32-bitowych fragmentow wiekszej liczby
movl $len1, %ecx
movl $len2, %ebx
subl %ebx, %ecx

# jesli ecx==0, to znaczy ze liczby byly takiej samej dlugosci, czyli dodawanie zostalo zakonczone
jecxz popetli2

# jesli ecx!=0, to liczby sa roznej dlugosci, dodawaj do wiekszej liczby 0+CF
petla2:
  movl liczba1(,%edx, 4),%eax
  adcl $0, %eax
  pushl %eax
  decl %edx
  loop petla2

popetli2:
# ilosc 32-bitowych fragmentow w wyniku, taka sama jak dlugosc dluzszej liczby
movl $len1, %ecx

# jesli po dodaniu do siebie liczb zostalo nam jakies przeniesienie, trzeba je rowniez uwzglednic w wyniku
jae brakprzeniesienia
# jesli po ostatniej operacji zostalo przeniesienie, to dodajemy je na stos jako najwyzsza cyfra wyniku
pushl $1
# do ilosci 32-bitowych fragmentow wyniku nalezy dodac 1, bo najwyzszym bitem zostalo przeniesienie
addl $1, %ecx

brakprzeniesienia:

# po tych operacjach, uzyskany wynik bedzie na stosie - na szczycie stosu najwyzsze bity

# do sprawdzenia poprawnosci wyniku debuggerem (wartosci wyniku w eax pojawiaja sie od najbardziej znaczacych bitow do najmniej znaczacych):
petla3:
  pop %eax
  debug:
  loop petla3


movl $SYSEXIT, %eax
movl $EXIT_SUCCESS, %ebx
int $0x80
