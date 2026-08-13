SECTION .multiboot

MAGIC equ 0x1BADB002
FLAGS equ 0

dd MAGIC ; Our magic number being "emitted" as in assigned 4 bytes in actual memory
dd FLAGS ; assigning our flags (we actually have not assigned any) 4 bytes of memory
dd -(MAGIC + FLAGS) ; checksum, we are computing it here as is
