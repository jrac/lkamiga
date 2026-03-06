/*
 * Copyright (c) 2026 Josh Cummings
 *
 * Use of this source code is governed by a MIT-style
 * license that can be found in the LICENSE file or at
 * https://opensource.org/licenses/MIT
 */

#include "platform_p.h"
#include <dev/display.h>
#include <lib/page_alloc.h>
#include <lk/err.h>
#include <lk/main.h>
#include <platform/display.h>
#include <string.h>
#if WITH_KERNEL_VM
#include <kernel/vm.h>
#else
#include <kernel/novm.h>
#endif

static inline uint16_t COP_MOVE(uint16_t reg_off) {
    return (0x0000 + reg_off);
}
static inline uint16_t COP_WAIT(uint16_t vhp) {
    return (0x8000 | (vhp & 0x7FFE));
}
static inline uint16_t COP_END(void) {
    return 0xFFFF;
}

static volatile uint16_t *const paula_base = (void *)0xDFF000;

static struct display_framebuffer display_fb;

static uint8_t bitplane[BPL_BYTES];
static uint16_t copper[64];

void make_copper_list(uint8_t *bpl) {
    uintptr_t p = (uintptr_t)bpl;
    uint16_t pth = (p >> 16);
    uint16_t ptl = (p & 0xFFFF);

    int i = 0;

    // clang-format off
    // Set display window
    copper[i++] = COP_MOVE(DIWSTRT); copper[i++] = 0x2C81; // DIWSTRT
    copper[i++] = COP_MOVE(DIWSTOP); copper[i++] = ((((0x2C + H) & 0xFF) << 8) | 0xC1); // DIWSTOP
    copper[i++] = COP_MOVE(DDFSTRT); copper[i++] = 0x0038; // DDFSTRT
    copper[i++] = COP_MOVE(DDFSTOP); copper[i++] = 0x00D0; // DDFSTOP

    // 1 bitplane, enable color (0x0200)
    copper[i++] = COP_MOVE(BPLCON0); copper[i++] = (0x0200 | (1 << 12));
    copper[i++] = COP_MOVE(BPLCON1); copper[i++] = 0x0000;
    copper[i++] = COP_MOVE(BPLCON2); copper[i++] = 0x0000;

    // Bitplane modulo = 0 for a single linear bitplane 
    copper[i++] = COP_MOVE(BPL1MOD); copper[i++] = 0x0000;
    copper[i++] = COP_MOVE(BPL2MOD); copper[i++] = 0x0000;

    // Bitplane pointer
    copper[i++] = COP_MOVE(BPL1PTH); copper[i++] = pth;
    copper[i++] = COP_MOVE(BPL1PTL); copper[i++] = ptl;

    // Background and foreground colours
    copper[i++] = COP_MOVE(COLOR00); copper[i++] = 0x0000;
    copper[i++] = COP_MOVE(COLOR01); copper[i++] = 0x0FFF;

    copper[i++] = COP_END();
    copper[i++] = COP_END();
    // clang-format on
}

static void write_reg(unsigned int reg, uint32_t val) {
    paula_base[reg >> 1] = val;
}

status_t display_get_framebuffer(struct display_framebuffer *fb) {
    fb->image.pixels = bitplane;

    fb->image.format = IMAGE_FORMAT_MONO_1;
    fb->image.rowbytes = BYTES_PER_ROW;
    fb->image.width = W;
    fb->image.height = H;
    fb->image.stride = BYTES_PER_ROW;
    fb->format = DISPLAY_FORMAT_MONO_1;
    fb->flush = NULL;

    return NO_ERROR;
}

status_t display_get_info(struct display_info *info) {
    info->format = DISPLAY_FORMAT_MONO_1;
    info->width = W;
    info->height = H;

    return NO_ERROR;
}

void platform_init_display(void) {
    memset(bitplane, 0, BPL_BYTES);

    make_copper_list(bitplane);

    // Disable DMA
    write_reg(DMACON, 0x7FFF);

    // Set up copper list
    uintptr_t clist = (uintptr_t)copper;
    write_reg(COP1LCH, (clist >> 16));
    write_reg(COP1LCL, (clist & 0xFFFF));
    write_reg(COPJMP1, 0x0000);

    // Enable DMA
    write_reg(DMACON, (0x8000 | 0x0200 | 0x0080 | 0x0100));

    display_get_framebuffer(&display_fb);
}
