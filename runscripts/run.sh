# Assemble using yasm not using C library or main entry point.
# Argument is first part of asm file name such as ex1.
EX=$1
yasm -f elf64 -P ../../ebe/ebe.inc -g dwarf2 -l ${EX}.lst ${EX}.asm
ld -o ${EX}.exe ${EX}.o
./${EX}.exe

