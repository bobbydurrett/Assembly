# Compile C and assemble asm routine(s) then debug.
# Argument is first part of C and asm file names such as ex1.
EX=$1
nasm -f elf64 ${EX}.asm -o ${EX}a.o -l ${EX}.lst -g -F dwarf
gcc -o ${EX}.exe ${EX}a.o  ${EX}.c
gdb ${EX}.exe
