SYSEXIT = 1
EXIT_SUCCESS = 0

.data
liczba1: .long 0x00000001, 0x00000000
len1 = (. - liczba1)/4 # dlugosc 1 liczby w bajtach
liczba2: .long 0x00000000, 0x00000002
len2 = (. - liczba2)/4 # dlugosc 2 liczby w bajtach

wynik: .space $len1*4+$len2*4
lenwynik: . - wynik

.text

.global _start
_start:

movl $len1,%ebx # ebx - indeks bajtow liczby 1
movl $lenwynik, %edi # edi - indeks bajtow wyniku

clc

# tworzymy iloczyny czesciowe: cala liczba2 * kolejne fragmenty liczby 1
petla1:
  decl %ebx
  movl liczba1(,%ebx,4), %eax
  movl $len2,%ecx # ecx - indeks bajtow liczby 2
  petla2:
    decl %ecx
    movl liczba2(,%ecx,4), %edx
    mull %edx
    adcl %eax, wynik(,%edi,4)
    decl %edi
    adcl %edx, wynik(,%edi,4)
    cmp $0, %ecx
    ja petla2
  cmp $0, %ebx
  ja petla1




movl $SYSEXIT, %eax
movl $EXIT_SUCCESS, %ebx
int $0x80
