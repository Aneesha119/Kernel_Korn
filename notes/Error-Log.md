This keeps tracks of the mistakes, no matter how minor, I made during each file or even some conceptual tangles I untangled.

### boot.asm:

While the "code" essentially was nothing worth making mistakes over, I encountered a NASM syntax fact, which is labels. When we use the `dd` command to emit our values, we can assign it to a label, instead of just `dd MAGIC`, we could have done `magic_var: dd MAGIC` where `magic_var` is a named address space, kind of like the alias that `# define` creates in C.
