EX=$1
gcc -g -o ${EX}.exe ${EX}.c -lm
gdb ${EX}.exe
