.text

lea     0(%pc),%a4
add.l   #0x200,%a4 /* skip bootblock */

jmp     (%a4)
