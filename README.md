# Fibonacci-Sequence

Assembly code for printing the first 6 Fibonacci-digits to sdtout

compile with:
nasm -f elf64 -o fibonacci.o fibonacci.s && ld -o fibonacci fibonacci.o && ./fibonacci
