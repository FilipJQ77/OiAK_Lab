SYSEXIT = 1
EXIT_SUCCESS = 0
SYSWRITE = 4
SYSREAD = 3
STDOUT = 1
STDIN = 0
SYSCALL = 0x80

.data
mes1: .ascii "Wybierz precyzje (f,d)\n"
mes1len = . - mes1
mes2: .ascii "Wybierz operacje (+,-,*,/)\n"
mes2len = . - mes2
input: .ascii " "
inputlen = .- input

float1: .float 7.89
float2: .float 2.1
double1: .double 3.123456789
double2: .double 21.3699

.text
.global _start
_start:
# pytanie o precyzje
mov $SYSWRITE, %eax
mov $STDOUT, %ebx
mov $mes1, %ecx
mov $mes1len, %edx
int $SYSCALL

# wczytanie znaku od uzytkownika
mov $SYSREAD, %eax
mov $STDIN, %ebx
mov $input, %ecx
mov $inputlen, %edx
int $SYSCALL

# wczytanie znaku do rejestru al (bo znak ascii ma 8 bitow)
mov $0, %esi
movb input(,%esi,1), %al
# jesli znak podany znak to f
cmpb $102, %al
je precision_float
# jesli podany znak to d
cmpb $100, %al
je precision_double
# nie wiadomo co robic, wroc na start
jmp _start

precision_float:
fld float2
fld float1
jmp operation

precision_double:
fldl double2
fldl double1

operation:
# pytanie o operacje
mov $SYSWRITE, %eax
mov $STDOUT, %ebx
mov $mes2, %ecx
mov $mes2len, %edx
int $SYSCALL

# wczytanie znaku od uzytkownika
mov $SYSREAD, %eax
mov $STDIN, %ebx
mov $input, %ecx
mov $inputlen, %edx
int $SYSCALL

# wczytanie znaku do rejestru al (bo znak ascii ma 8 bitow)
mov $0, %esi
movb input(,%esi,1), %al
# jesli znak podany znak to +
cmpb $43, %al
je _add
# jesli podany znak to -
cmpb $45, %al
je _sub
# jesli podany znak to *
cmpb $42, %al
je _mul
# jesli podany znak to /
cmpb $47, %al
je _div
# nie wiadomo co robic, wroc do wyboru operacji
jmp operation


_add:
faddp
jmp end

_sub:
fsubp
jmp end

_mul:
fmulp
jmp end

_div:
fdivp
jmp end

debug:
end:

movl $SYSEXIT, %eax
movl $EXIT_SUCCESS, %ebx
int $0x80
