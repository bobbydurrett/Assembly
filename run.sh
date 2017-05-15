EX=$1
yasm -f elf64 -P ../../ebe/ebe.inc -g dwarf2 -l ${EX}.lst ${EX}.asm
ld -o ${EX}.exe ${EX}.o
./${EX}.exe

