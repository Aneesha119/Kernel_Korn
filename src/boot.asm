; MULTIBOOT CONTRACT
SECTION .multiboot

MAGIC equ 0x1BADB002
FLAGS equ 0

dd MAGIC ; Our magic number being "emitted" as in assigned 4 bytes in actual memory
dd FLAGS ; assigning our flags (we actually have not assigned any) 4 bytes of memory
dd -(MAGIC + FLAGS) ; checksum, we are computing it here as is

; STACK SETUP
SECTION .bss
align 16
stack_bottom: ; Reserving bits for our initial stack, which grows downwards, 
    resb 16384
stack_top:

SECTION .text
global _start
extern kernel_main ; calling kernel main function from our kernel.c file

_start:
    mov esp, stack_top ; esp, a known pointer (system stack) initialized to the top of our stack
    call kernel_main
    cli

.hang: ; this step just disables interrupts initally as we do not have interrupts set up
    hlt
    jmp .hang