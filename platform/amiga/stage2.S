.text

/* IORequest stuff */
.equ    CMD_READ,   2
.equ    io_Unit,    24
.equ    io_Command, 28
.equ    io_Error,   31
.equ    io_Length,  36
.equ    io_Data,    40
.equ    io_Offset,  44

move.l  #0x070000,%sp         /* stack in Chip RAM */
move.w  #0x041E,0x00DFF180    /* Flash a colour on screen for debugging */

lea     loader(%pc),%a5
move.l  %a5,0x00000080        /* Trap handler */

/* Enter supervisor mode */
trap    #0 

loader:
   /* Load kernel from floppy in to RAM */
   movea.l 0x00000004.w,%a6            /* Exec base */
   move.l  #(297*512),io_Length(%a1)   /* TODO: Write kernel size somewhere during build, read that value */
   move.l  #0x20000,io_Data(%a1)
   move.l  #0x400,io_Offset(%a1)        
   move.w  #CMD_READ,io_Command(%a1)
   jsr     -456(%a6)

   move.w  #9,io_Command(%a1)          /* td_motor */
   clr.l   io_Length(%a1)              /* Turn off FDD motor */
   jsr     -456(%a6)

   jmp     0x20000
