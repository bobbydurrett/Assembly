EX=$1
nasm -f elf64 ${EX}.asm -o ${EX}a.o -l ${EX}.lst -g -F dwarf
gcc -o ${EX}.exe ${EX}a.o  ${EX}.c
gdb ${EX}.exe
