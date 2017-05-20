# Assemble using nasm not using C library or main entry point.
# Argument is first part of asm file name such as ex1.
EX=$1
nasm -f elf64 ${EX}.asm -o ${EX}.o -l ${EX}.lst -g -F dwarf
ld -o ${EX}.exe ${EX}.o
gdb ${EX}.exe
