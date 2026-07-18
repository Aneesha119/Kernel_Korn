# Kernel_Korn
A toy x86 kernel, built from scratch to learn how computers actually work.

Written in C (plus the minimum assembly needed to get C running), booting on bare metal with no operating system underneath — no standard library, no `printf`, no `malloc`. Everything is built by hand, one part at a time.

## Roadmap

- [ ] **01 — Booting** · Machine hands control to my code; one character on screen
- [ ] **02 — Screen output** · Strings, newlines, scrolling, colors — my own `printf`
- [ ] **03 — Interrupts** · Responding to events instead of running top-to-bottom
- [ ] **04 — Keyboard** · Typing works; a human is in the loop
- [ ] **05 — Timer** · The kernel knows time is passing
- [ ] **06 — Memory allocator** · My own `malloc` and `free`
- [ ] **07 — Virtual memory** · Fake addresses mapped onto real RAM
- [ ] **08 — Multitasking** · Two things running "at once"
- [ ] **09 — Userspace** · User programs and system calls

## Notes

Each part has a write-up in [`notes/`](notes/) — what I was trying to do, the theory I had to learn first, what broke, and what I still don't understand.
