/*
 * Copyright (c) 2025-2026 Josh Cummings
 *
 * Use of this source code is governed by a MIT-style
 * license that can be found in the LICENSE file or at
 * https://opensource.org/licenses/MIT
 */

#include <stdbool.h>
#include <stdint.h>
#include <sys/types.h>

// CIA-A registers
#define CIA_A_BASE 0xBFE000
#define CIA_A_PRA 0x001
#define CIA_A_PRB 0x101
#define CIA_A_DDRA 0x201
#define CIA_A_DDRB 0x301
#define CIA_A_TALO 0x401
#define CIA_A_TAHI 0x501
#define CIA_A_TBLO 0x601
#define CIA_A_TBHI 0x701
#define CIA_A_TODLO 0x801
#define CIA_A_TODMID 0x901
#define CIA_A_TODHI 0xA01
#define CIA_A_SDR 0xC01
#define CIA_A_ICR 0xD01
#define CIA_A_CRA 0xE01
#define CIA_A_CRB 0xF01

// CIA-A control flags
#define CIA_A_CRA_START (1 << 0)
#define CIA_A_CRA_LOAD (1 << 4)
#define CIA_A_CRA_SERIAL (1 << 6)

// CIA-B registers
#define CIA_B_BASE 0xBFD000
#define CIA_B_PRA 0x000
#define CIA_B_PRB 0x100
#define CIA_B_DDRA 0x200
#define CIA_B_DDRB 0x300
#define CIA_B_TALO 0x400
#define CIA_B_TAHI 0x500
#define CIA_B_TBLO 0x600
#define CIA_B_TBHI 0x700
#define CIA_B_TODLO 0x800
#define CIA_B_TODMID 0x900
#define CIA_B_TODHI 0xA00
#define CIA_B_SDR 0xC00
#define CIA_B_ICR 0xD00
#define CIA_B_CRA 0xE00
#define CIA_B_CRB 0xF00

// CIA-B control flags
#define CIA_B_CRA_START (1 << 0)
#define CIA_B_CRA_LOAD (1 << 4)
#define CIA_B_CRA_SERIAL (1 << 6)

void cia_timer_init(void);
void platform_serial_init(void);

status_t clear_interrupt(unsigned int bit);
