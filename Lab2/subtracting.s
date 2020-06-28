SYSEXIT = 1
EXIT_SUCCESS = 0

.data
liczba1: .long 0x00000000, 0x80FFAB69, 0xFFFFFFFF
len1 = (. - liczba1)/4 # dlugosc 1 liczby w bajtach
liczba2: .long 0x000000FF, 0xFFFFFFFF, 0xABCDEF12
len2 = (. - liczba2)/4 # dlugosc 2 liczby w bajtach

.text

.global _start
_start:
# odejmowanie liczb o tej samej dlugosci
# ecx trzyma dlugosc liczby, bedzie licznikiem petli
movl $len2, %ecx # albo len1 albo len2, bez roznicy skoro dlugosc taka sama
movl $len2-1, %edx # indeks bajtow

clc

# petla wykonujaca liczba1-liczba2
petla1:
  movl liczba1(,%edx,4), %eax
  movl liczba2(,%edx,4), %ebx
  sbbl %ebx, %eax
  pushl %eax
  decl %edx
  loop petla1


movl $len1, %ecx
# jesli po odjeciu od siebie liczb zostalo nam jakies przeniesienie, trzeba je rowniez uwzglednic w wyniku
jae brakprzeniesienia
# jesli po ostatniej operacji zostalo przeniesienie, to dodajemy je na stos jako najwyzsze bity wyniku
pushl $0xFFFFFFFF
# do ilosci 32-bitowych fragmentow wyniku nalezy dodac 1, bo najwyzszym bitem zostalo przeniesienie
addl $1, %ecx

brakprzeniesienia:

# po tych operacjach, uzyskany wynik bedzie na stosie - na szczycie stosu najwyzsze bity

# do sprawdzenia poprawnosci wyniku debuggerem(najwyzsze bity wyniku na poczatku, potem coraz nizsze):
petla2:
  pop %eax
  debug:
  loop petla2


movl $SYSEXIT, %eax
movl $EXIT_SUCCESS, %ebx
int $0x80
