/* linker script for anodyx kernel (x86-64) */

ENTRY(_start)

SECTIONS {
  . = 0x100000;

  .text : {
    *(.text.entry)       /* entry stub must be first */
    *(.text)
    *(.text.*)
  }

  .rodata : {
    *(.rodata)
    *(.rodata.*)
  }

  . = ALIGN(4096);
  .data : {
    *(.data)
    *(.data.*)
  }

  . = ALIGN(4096);
  .bss : {
    bss_start = .;
    *(.bss)
    *(.bss.*)
    *(COMMON)
    . = ALIGN(8);
    bss_end = .;
  }

  kernel_end = .;
}