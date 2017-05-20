# Compile and debug a C program only.
# Argument is first part of C file name such as ex1.
EX=$1
gcc -g -o ${EX}.exe ${EX}.c -lm
gdb ${EX}.exe
