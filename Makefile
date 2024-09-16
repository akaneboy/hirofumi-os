MAKEFLAGS += -rR
.SUFFIXES:
.PHONY: all clean run

# Output and tool variables
OUTPUT := hirofumios
KCXX := g++
KLD := ld
QEMU := qemu-system-x86_64

# Compiler and linker flags
KCXXFLAGS := -g -O2 -pipe -Wall -Wextra -std=gnu++17 -ffreestanding -fno-stack-protector \
             -fno-stack-check -fno-lto -fno-PIC -fno-exceptions -fno-rtti -m64 -march=x86-64 \
             -mno-80387 -mno-mmx -mno-sse -mno-sse2 -mno-red-zone -mcmodel=kernel

KCPPFLAGS := -I src -MMD -MP

KNASMFLAGS := -F dwarf -g -Wall -f elf64

KLDFLAGS := -m elf_x86_64 -nostdlib -static -z max-page-size=0x1000 -T linker.ld

# Source files
CPPFILES := $(shell cd src && find -L * -type f -name '*.cpp' | LC_ALL=C sort)
ASFILES := $(shell cd src && find -L * -type f -name '*.S' | LC_ALL=C sort)
NASMFILES := $(shell cd src && find -L * -type f -name '*.asm' | LC_ALL=C sort)

# Object files
OBJ := $(addprefix obj/,$(CPPFILES:.cpp=.cpp.o) $(ASFILES:.S=.S.o) $(NASMFILES:.asm=.asm.o))
HEADER_DEPS := $(addprefix obj/,$(CPPFILES:.cpp=.cpp.d) $(ASFILES:.S=.S.d))

# Limine variables
LIMINE_VERSION := v8.x-binary
LIMINE_URL := https://github.com/limine-bootloader/limine.git

# Main targets
all: bin/$(OUTPUT) image.iso

run: image.iso
	$(QEMU) $<

clean:
	rm -rf bin obj iso_root limine image.iso

# Building the kernel
bin/$(OUTPUT): $(OBJ) | bin
	$(KLD) $(OBJ) $(KLDFLAGS) -o $@

# Creating the bootable ISO
image.iso: bin/$(OUTPUT) limine
	mkdir -p iso_root/boot/limine
	mkdir -p iso_root/EFI/BOOT
	cp -v bin/$(OUTPUT) iso_root/boot/
	cp -v limine.conf limine/limine-bios.sys limine/limine-bios-cd.bin limine/limine-uefi-cd.bin iso_root/boot/limine/
	cp -v limine/BOOTX64.EFI limine/BOOTIA32.EFI iso_root/EFI/BOOT/
	xorriso -as mkisofs -b boot/limine/limine-bios-cd.bin \
		-no-emul-boot -boot-load-size 4 -boot-info-table \
		--efi-boot boot/limine/limine-uefi-cd.bin \
		-efi-boot-part --efi-boot-image --protective-msdos-label \
		iso_root -o $@
	./limine/limine bios-install $@

# Limine bootloader
limine:
	git clone $(LIMINE_URL) --branch=$(LIMINE_VERSION) --depth=1
	$(MAKE) -C limine

# Compilation rules
obj/%.cpp.o: src/%.cpp | obj
	@mkdir -p $(@D)
	$(KCXX) $(KCXXFLAGS) $(KCPPFLAGS) -c $< -o $@

obj/%.S.o: src/%.S | obj
	@mkdir -p $(@D)
	$(KCXX) $(KCXXFLAGS) $(KCPPFLAGS) -c $< -o $@

obj/%.asm.o: src/%.asm | obj
	@mkdir -p $(@D)
	nasm $(KNASMFLAGS) $< -o $@

# Create directories
bin obj:
	mkdir -p $@

# Include dependencies
-include $(HEADER_DEPS)
