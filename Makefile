NASM   := $(shell command -v nasm 2>/dev/null)
DD     := $(shell command -v dd 2>/dev/null)
QEMU   := $(shell command -v qemu-system-x86_64 2>/dev/null)

ifeq ($(shell command -v clang 2>/dev/null),)
  CC            := gcc
  CFLAGS_TARGET := -m64
  LD            := ld
  LDFLAGS_EXTRA := -m elf_x86_64
  OBJCOPY       := objcopy
else
  CC            := clang
  CFLAGS_TARGET := --target=x86_64-elf
  LD            := $(shell command -v ld.lld 2>/dev/null || command -v ld 2>/dev/null)
  LDFLAGS_EXTRA :=
  OBJCOPY       := $(shell command -v llvm-objcopy 2>/dev/null || command -v objcopy 2>/dev/null)
endif

CFLAGS := \
  $(CFLAGS_TARGET) \
  -ffreestanding \
  -fno-stack-protector \
  -fno-pic \
  -mno-red-zone \
  -O2 \
  -Wall -Wextra

LDFLAGS := $(LDFLAGS_EXTRA) -T kernel/linker.ld

stage1_lba   := 0
stage1_size  := 1
stage2_lba   := 1
stage2_size  := 16
stage3_lba   := 17
stage3_size  := 48
kernel_lba   := 65
kernel_size  := 128

total_sectors := $(shell expr $(stage1_size) + $(stage2_size) + $(stage3_size) + $(kernel_size))

boot_dir   := boot
kernel_dir := kernel

boot_bins := \
  $(boot_dir)/stage1.bin \
  $(boot_dir)/stage2.bin \
  $(boot_dir)/stage3.bin

kernel_objs := \
  $(kernel_dir)/entry.o \
  $(kernel_dir)/main.o \
  $(kernel_dir)/vga_main.o

kernel_elf := $(kernel_dir)/kernel.elf
kernel_bin := $(kernel_dir)/kernel.bin

img := anodyx_sed-x86_64.img

.PHONY: all
all: $(img)

$(boot_dir)/stage1.bin: $(boot_dir)/1stage_16b.asm $(boot_dir)/gdt.asm
	$(NASM) -f bin -I $(boot_dir)/ $< -o $@

$(boot_dir)/stage2.bin: $(boot_dir)/2stage_32b.asm $(boot_dir)/gdt.asm
	$(NASM) -f bin -I $(boot_dir)/ $< -o $@

$(boot_dir)/stage3.bin: $(boot_dir)/3stage_64b.asm \
                        $(boot_dir)/gdt.asm \
                        $(boot_dir)/page_tables.asm \
                        $(boot_dir)/ata_pio_lba48.asm
	$(NASM) -f bin -I $(boot_dir)/ $< -o $@

$(kernel_dir)/entry.o: $(kernel_dir)/entry.asm
	$(NASM) -f elf64 $< -o $@

$(kernel_dir)/main.o: $(kernel_dir)/main.c \
                      $(kernel_dir)/head/anodyx_main.h \
                      $(kernel_dir)/vga/head/vga_main.h
	$(CC) $(CFLAGS) -c $< -o $@

$(kernel_dir)/vga_main.o: $(kernel_dir)/vga/vga_main.c \
                          $(kernel_dir)/vga/head/vga_main.h
	$(CC) $(CFLAGS) -c $< -o $@

$(kernel_elf): $(kernel_objs) $(kernel_dir)/linker.ld
	$(LD) $(LDFLAGS) -o $@ $(kernel_objs)

$(kernel_bin): $(kernel_elf)
	$(OBJCOPY) -O binary $< $@
	@echo "  kernel.bin size: $$(stat -c%s $@) bytes"

$(img): $(boot_bins) $(kernel_bin)
	@echo "  building $(img) ($(total_sectors) sectors)"
	$(DD) if=/dev/zero of=$@ bs=512 count=$(total_sectors) status=none
	$(DD) if=$(boot_dir)/stage1.bin of=$@ bs=512 seek=$(stage1_lba) conv=notrunc status=none
	$(DD) if=$(boot_dir)/stage2.bin of=$@ bs=512 seek=$(stage2_lba) conv=notrunc status=none
	$(DD) if=$(boot_dir)/stage3.bin of=$@ bs=512 seek=$(stage3_lba) conv=notrunc status=none
	$(DD) if=$(kernel_bin) of=$@ bs=512 seek=$(kernel_lba) conv=notrunc status=none
	@echo "  $(img) built: $$(stat -c%s $@) bytes"

.PHONY: run
run: $(img)
	$(QEMU) -hda $(img) -display curses

.PHONY: clean
clean:
	rm -f $(img)
	rm -f $(boot_bins)
	rm -f $(kernel_objs) $(kernel_elf) $(kernel_bin)

.PHONY: info
info:
	@echo "cc      = $(CC)"
	@echo "ld      = $(LD)"
	@echo "objcopy = $(OBJCOPY)"
	@echo "nasm    = $(NASM)"
	@echo "qemu    = $(QEMU)"
