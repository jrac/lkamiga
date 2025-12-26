.text

kaddr_ptr:
   .dc.l 0
ioreq_ptr:
   .dc.l 0

/* AllocMem stuff */
.equ    MEMF_ANY,       0x00000000
.equ    MEMF_PUBLIC,    0x00000001
.equ    MEMF_CHIP,      0x00000002
.equ    MEMF_FAST,      0x00000004

.equ    MEMF_LOCAL,     0x00000100
.equ    MEMF_24BITDMA,  0x00000200
.equ    MEMF_KICK,      0x00000400

.equ    MEMF_CLEAR,     0x00010000
.equ    MEMF_LARGEST,   0x00020000
.equ    MEMF_REVERSE,   0x00040000

/* IORequest stuff */
.equ    CMD_READ,   2
.equ    io_Unit,    24
.equ    io_Command, 28
.equ    io_Error,   31
.equ    io_Length,  36
.equ    io_Data,    40
.equ    io_Offset,  44

/* Stack stuff */
.equ    STACK_TOP,   0x00070000
.equ    STACK_SIZE,  0x00004000
.equ    STACK_BASE,  (STACK_TOP-STACK_SIZE)

lea STACK_TOP,%sp

|.equ RELOC, 0x3e800

move.w  #0x041E,0x00DFF180    /* Flash a colour on screen for debugging */

lea     loader(%pc),%a5
move.l  %a5,0x00000080        /* Trap handler */

/* Enter supervisor mode */
trap    #0 

loader:
   movea.l 0x00000004.w,%a6            /* Exec base */

   /* Stash IORequest address, passed in from Kickstart */
   lea ioreq_ptr,%a5
   move.l %a1,(%a5)

   /* Reserve memory for stack */
   move.l #STACK_SIZE,%d0
   move.l #(MEMF_CLEAR + MEMF_REVERSE),%d1 /* AllocMem attribute mask: MEMF_CLEAR | MEMF_CHIP */
   jsr -198(%a6) /* AllocMem() */
   tst.l %d0
   beq.s alloc_failure

   move.l #STACK_SIZE,%d0
   move.l #STACK_BASE,%a1
   jsr -204(%a6) | AllocAbs()
   tst.l %d0
   beq.s alloc_failure

   /* Reserve kernel relocation region */
   /*
   move.l #512000,%d0
   move.l #RELOC,%a1
   jsr -204(%a6) | AllocAbs()
   tst.l %d0
   beq.s alloc_failure
   */

   /* Allocate memory for kernel image */
   move.l #200000,%d0
   |move.l #(MEMF_CLEAR + MEMF_REVERSE),%d1 /* AllocMem attribute mask: MEMF_CLEAR | MEMF_CHIP */
   move.l #(MEMF_CLEAR),%d1 /* AllocMem attribute mask: MEMF_CLEAR | MEMF_CHIP */
   jsr -198(%a6) /* AllocMem() */
   tst.l %d0
   beq.s alloc_failure
   lea kaddr_ptr,%a0
   move.l %d0,(%a0)
   move.l %d0,%a2

   lea ioreq_ptr,%a1
   move.l (%a1),%a1

   /* Load kernel from floppy in to RAM */
   move.l  #(349*512),io_Length(%a1)   /* TODO: Write kernel size somewhere during build, read that value */
   move.l  %a2,io_Data(%a1) /* Read kernel from floppy in to memory provided by AllocMem */
   move.l  #0x400,io_Offset(%a1)        
   move.w  #CMD_READ,io_Command(%a1)
   jsr     -456(%a6) /* DoIO() */

   move.w  #9,io_Command(%a1)          /* td_motor */
   clr.l   io_Length(%a1)              /* Turn off FDD motor */
   jsr     -456(%a6)

   lea kaddr_ptr,%a0
   move.l (%a0),%a2
   jsr     -0x27c(%a6)

   /* Jump to kernel. Kickstart will perform cleanup, etc. */
   move.l #0,%d0
   move.l %a2,%a0
   jsr (%a0)

alloc_failure:
   | TODO: Throw a useful error, more graceful failure
   move.w  #0xFF00,0x00DFF180    /* Flash a colour on screen for debugging */
   moveq #0xfffffff0,%d0
   rts


