/* TODO: Do we need all this? */
ENTRY(_start)

MEMORY {
  chip : ORIGIN = 0x20000, LENGTH = 0x47000
}

SECTIONS {
  . = ORIGIN(chip);
  _start = .;

  .text : {
    *(.text.boot)
    *(.text*)
  } >chip

  .rodata : {
    *(.rodata*)
  } >chip

  commands : {
    *(commands)
  } >chip

  .data : {
    *(.data*)
    /* *(apps) */
    *(lk_init)
    *(.got*)
    *(.dynamic)
  } >chip

  .ctors : {
    __ctor_list = .;
    KEEP(*(.ctors))
    KEEP(*(.init_array))
    __ctor_end = .;
    __dtor_list = .;
    KEEP(*(.dtors))
    KEEP(*(.fini_array))
    __dtor_end = .;
  } >chip

  . = ALIGN(4);
  __bss_start = .;
  .bss (NOLOAD) : {
    *(.bss*)
    *(COMMON)
  } >chip
  __bss_end = .;

  . = ALIGN(4);
  __lk_end = .;
  _end = .;

  /DISCARD/ : {
    *(.note*)
    *(.comment)
    *(.eh_frame)
  }
}

