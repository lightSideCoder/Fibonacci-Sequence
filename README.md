# Fibonacci-Sequence

Assembly code for printing as many Fibonacci-numbers as you like to sdtout. (Max 64 Bits)

compile with:
nasm -f elf64 -o fibonacci.o fibonacci.s && ld -o fibonacci fibonacci.o && ./fibonacci
