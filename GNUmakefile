MAKEFLAGS += -rR
.SUFFIXES:
override OUTPUT := hirofumios
override USER_VARIABLE = $(if $(filter $(origin $(1)),default undefined),$(eval override $(1) := $(2)))
$(call USER_VARIABLE,KCXX,g++)
$(call USER_VARIABLE,KLD,ld)
$(call USER_VARIABLE,KCXXFLAGS,-g -O2 -pipe)
$(call USER_VARIABLE,KCPPFLAGS,)
$(call USER_VARIABLE,KNASMFLAGS,-F dwarf -g)
$(call USER_VARIABLE,KLDFLAGS,)

override KCXXFLAGS += \
    -Wall \
    -Wextra \
    -std=gnu++17 \
    -ffreestanding \
    -fno-stack-protector \
    -fno-stack-check \
    -fno-lto \
    -fno-PIC \
    -fno-exceptions \
    -fno-rtti \
    -m64 \
    -march=x86-64 \
    -mno-80387 \
    -mno-mmx \
    -mno-sse \
    -mno-sse2 \
    -mno-red-zone \
    -mcmodel=kernel

override KCPPFLAGS := \
    -I src \
    $(KCPPFLAGS) \
    -MMD \
    -MP

override KNASMFLAGS += \
    -Wall \
    -f elf64

override KLDFLAGS += \
    -m elf_x86_64 \
    -nostdlib \
    -static \
    -z max-page-size=0x1000 \
    -T linker.ld

override CPPFILES := $(shell cd src && find -L * -type f -name '*.cpp' | LC_ALL=C sort)
override ASFILES := $(shell cd src && find -L * -type f -name '*.S' | LC_ALL=C sort)
override NASMFILES := $(shell cd src && find -L * -type f -name '*.asm' | LC_ALL=C sort)
override OBJ := $(addprefix obj/,$(CPPFILES:.cpp=.cpp.o) $(ASFILES:.S=.S.o) $(NASMFILES:.asm=.asm.o))
override HEADER_DEPS := $(addprefix obj/,$(CPPFILES:.cpp=.cpp.d) $(ASFILES:.S=.S.d))

.PHONY: all
all: bin/$(OUTPUT)

bin/$(OUTPUT): GNUmakefile linker.ld $(OBJ)
	mkdir -p "$$(dirname $@)"
	$(KLD) $(OBJ) $(KLDFLAGS) -o $@

-include $(HEADER_DEPS)

obj/%.cpp.o: src/%.cpp GNUmakefile
	mkdir -p "$$(dirname $@)"
	$(KCXX) $(KCXXFLAGS) $(KCPPFLAGS) -c $< -o $@

obj/%.S.o: src/%.S GNUmakefile
	mkdir -p "$$(dirname $@)"
	$(KCXX) $(KCXXFLAGS) $(KCPPFLAGS) -c $< -o $@

obj/%.asm.o: src/%.asm GNUmakefile
	mkdir -p "$$(dirname $@)"
	nasm $(KNASMFLAGS) $< -o $@

.PHONY: clean
clean:
	rm -rf bin obj
