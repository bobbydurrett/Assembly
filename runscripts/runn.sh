# Assemble using nasm using C library and main entry point then run debugger.
# Argument is first part of asm file name such as ex1.
EX=$1
nasm -f elf64 ${EX}.asm -o ${EX}.o -l ${EX}.lst -g -F dwarf
gcc -o ${EX}.exe ${EX}.o
gdb ${EX}.exe
