## What even is Booting?

Booting is the most primary procedure, executing by a system when power first hits. This is the first task a kernel (heart of the OS, the communicator between hardware and software ) essentially performs to "wake up" a system, which is not done by a singular program, moreover, it is a relay race between 2 programs, before the baton is finally passed onto the kernel (the one I am aiming to build) . 

When power first hits the computer, our CPU is partially useless; in the sense it still has all its computing logics intact but the internal info of the system, such as free memory, or inputs, is what it lacks, as the CPU executes what is in the RAM, and RAM being a volatile memory, is empty/ garbage at power on. The CPU essentially loads info from the disks onto the RAM, but the disks themselves need another program to actually load, much like the chicken and the egg analogy. But what we understand is that all these processes and programs run on software, so, to break the system out of the loop of waiting and initiating its first action to starting up, the CPU is hardcoded to jump to execute a permanent memory location (existing in it initially), which it starts executing, this segment of code is firmware, namely, BIOS or UEFI. The firmware wakes up our hardware, gets the mills and cogs of our system running, accounts for the RAM and ventures in search of something "bootable", which is, our disc from before, the firmware looks for a signature marking among the discs, a permanent bookmark of sorts, finds "the one" and a segment of the code from the disc is loaded in the RAM and executes it; The firmware's share of race is over and the baton is passed to the bootloader, our star in this part. 

To understand its significance, let us initially understand the weird behavior of the CPU at power ON. Initially, the CPU, during power on is essentially like a mound of dough, this is the real mode (addresses only 1MB of memory), in the sense, like a late 70's system, the CPU has no authorization levels to the programs, no kernel and user level distinction, anything can touch anything, also, since it addresses only 1MB of memory at a time, segmented addressing was very very common, leading to the usage of pointers (segment + offset, compared to the current unary pointers used) just to keep track of data, something that doesn't exist for us anymore, because of the size of addressability of protected mode. This is only there to ensure backwards compatibility. The CPU's, nay, the architecture of the entire system, initially was written a long time ago, we, have since then just added on a new layer of tech these coming years, but the soul of the system is vintage, the initial state needs to match that as well, but, before the system actually does anything meaningful, it has to enter a protected mode (user and kernel modes; addresses 4 GB of memory), this work for us, in this kernel development specifically, will be handled by GRUB, which is the real MVP, without which, this project would have had the initial extra week with a time taking detour into assembly (as we would have had to manually address the real mode to be converted into protected mode) + loads the kernel. After the initial step, GRUB will handle the memory and software to us, the kernel, to abide by our bidding, which will be discussed in the coming steps.

## What is our MVP doing?

GRUB, firstly, stands for GRand Unified Bootloader, it is not a singular program, the way it starts out is far from unified. Let us refer to the previous section, the firmware looking for the starting disc, it finds the code on the desired disc, but interestingly, that code is only 512 bytes (in sectors), out of which 2 bytes are the marker, so our total size allotted is smaller than that of a text file, while our GRUB is a vast program that has a menu, reads filesystems, understands the OS, how is that adjusting in that cramped up location? Answer: it doesn't, the work of the code residing in the 510 bytes is to look for a much larger space for the GRUB to be loaded on, that is where our player actually logs into the game. The tasks that GRUB performs for us is mode conversion (from real to protected) via descriptor tables plus flipping a bit in the control registers and finally making a specific jump in the CPU to change modes. Reading the file system is the next important step, the kernel essentially is a file on the disk, GRUB must be familiar enough with the filesystem, plus, recognize the kernel enough to actually load it, else, the kernel would have to be loaded manually, every time at boot. After reading our kernel file, GRUB also parses it, i.e. our kernel contains info as to which pieces have to be loaded where and finally, creates a map of the RAM for our kernel (for example, regions of usable memory) (part 6 discussion).

The trade off of using GRUB is that my kernel cannot boot up on bare hardware alone, GRUB will always be an intermediate as I will not be writing a bootloader of my own (for now), as writing my own bootloader will involve having to deal with 16 bit assembly, which is truly out of my expertise currently.

Another important concept we will be delving into is, how will GRUB know that the file we are trying to launch at power on is a kernel? the answer is simple, the signature we discussed earlier, it has a detailed process/specification called the Multiboot Contract/ Multiboot Specification. So, our actual first step into making this kernel is not writing the bootloader but, honoring the Contract.

***TO BE NOTED:** There exists 2 types of signatures, one magic number is for the firmware, to identify our disc as  "bootable" and the other is the multiboot magic number, which identifies our kernel as Multiboot Contract adjacent.*

## Multiboot Contract

This is (hopefully) the final bit of theory I encounter before building the first component. What we established in the end of last topic is that GRUB verifies a given "section" of our file to check for a signature to boot it. That is the Multiboot Contract, which is a norm for a file so that it is recognized as a kernel by GRUB, in the earlier times, the bootloader had a special code per OS, which would have been a pain, if suppose we, on a windows system also want to have a dual boot for another OS, a Linux subsidiary, this would have been accomplished via either editing the bootloader to add the code adjacent to boot that OS up, which is tough to implement, or the bootloader on every system should contain the OS code for all possible OS' which would maybe slow down our bootloader, or made it inefficient, so both are bad options (in the sense inconvenient) all around. The Contract itself has a few criteria, which are:

- It should be in the first 8 KB of your file (header) & should be 4 byte aligned (GRUB scans in 4 bytes), if not GRUB wont even consider your file.
- Now, this header must contain these 3 consecutive 32-bit values:

	- Magic: Non derivable, this is standard (for Multiboot 1 specifically), we need to look it up (probably task 1)
	- Flags: it is a bitfield of requests, each bit is asking/requesting our bootloader to do a initial setup procedure such as providing a memory map, page align loaded modules or even provide custom layout info
	- Checksum: The most interesting part of our Contract, it is a value chosen so that the sum of the three fields (added as 32 bit values), Magic + Flags + Checksum equal zero. *Why do we need this?* simply because the Magic number is essentially a 32 bit value, it could potentially occur as a portion of a random file's content (as in it isn't essentially UNIQUE unique) which would create problems. But the checksum, which is a hard requirement arithmetic relation between the three, cannot be a coincidence like Magic, and equals zero is the cheapest check there is.

*NOTE 1: The addition is a 32-bit unsigned addition, as in it wraps around on overflow*

*NOTE 2: I had the doubt that why can't the checksum equal 1 as that is the yang to the 0's yin in binary, which on searching upon I found that we would have to define 1 as the special number that our unsigned addition has to equal to while there is no special condition as such for zero, we just check checksum + magic + flags == 0*

# Now we move on to building!

This is the internal roadmap to achieve booting:
1. [x] Multiboot header — the "I'm a kernel" sticker GRUB scans for (magic, flags, checksum). Assembled into boot.o.
2. [x] Finish the assembly stub — add the entry point: set up a stack (C can't run without one), then call into C.
3. [x] Write kernel.c — the C function that draws the first character to the screen.
4. [ ] Linker script — tell the linker how to arrange the pieces in memory, and force the multiboot header into the first 8 KiB.
5. [ ] Build & link — combine the object files into one bootable binary.
6. [ ] Verify & boot — confirm GRUB accepts it (multiboot checker), then run it in QEMU.


# Understanding boot.asm

The first file of our kernel! You can look at the actual code in the src folder. Now let us understand it line by line.

#### SECTION .multiboot
 First off, this is not an executable code, it is a sticker, the barcode of our kernel which GRUB scans, as the `SECTION .multiboot` header suggests it is us just setting up the 3 portions - Magic, Flags and Checksum. The next 2 lines of the file are `MAGIC equ 0x1BADB002` and `FLAGS equ 0` first and foremost, we are following the NASM  convention of writing our sticker (need to read more about it to add to notes), this is basically the equivalent of `#define MAX 100` we are declaring `MAGIC` and `FLAGS` as 2 constants in our program. Next comes `dd MAGIC`, `dd FLAGS`, `dd -(MAGIC + FLAGS)` (`dd` stands for define doubleword), this is essentially asking the system to reserve 4 bytes with the value after our keyword, magic and flags which were just constants now have been allocated 4 bytes and checksum computation was left for our NASM (which computes it at assembly time), all we did was write the arithmetic relation (since the sum of the three has to equal to 0, we can just say that the third quantity is the negative of sum of the other 2 quantities).


#### SECTION .bss