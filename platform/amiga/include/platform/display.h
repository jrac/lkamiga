#pragma once

enum { W = 320, H = 256, BYTES_PER_ROW = (W / 8), BPL_BYTES = (BYTES_PER_ROW * H) };

void make_copper_list(uint8_t *bpl);
void platform_init_display(void);
void init_display(void);

