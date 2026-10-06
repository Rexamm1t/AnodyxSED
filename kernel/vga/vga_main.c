#include <stdint.h>
#include <stddef.h>

#define vga_width 80
#define vga_height 25
#define vga_end 2000
#define vga_addr ((volatile uint16_t *)0xb8000)

static size_t row = 0;
static size_t column = 0;

static uint8_t color = 0x1f;

static inline void outb(uint16_t port, uint8_t val) {
    __asm__ volatile ("outb %0, %1" : : "a"(val), "Nd"(port));
}

static void crtc_cursor (size_t u_row, size_t u_col) {
  uint16_t pos = (uint16_t)(u_row * vga_width + u_col);
  outb (0x3d4, 0x0f);
  outb (0x3d5, (uint8_t)(pos & 0xff));
  outb (0x3d4, 0x0e);
  outb (0x3d5, (uint8_t)((pos >> 8) & 0xff));
}

static void vga_scroll (void) {
  for (size_t srl_addr = 80; srl_addr < vga_end; srl_addr++) {
    vga_addr[srl_addr-80] = vga_addr[srl_addr];
  }
  for (size_t i = 1920; i < vga_end; i++) {
    vga_addr[i] = ((uint16_t)color << 8) | (uint8_t)' ';
  }
  row = 24;
  column = 0;
}

static void put_char (char x) {
  if (x == '\n' && column <= vga_width) {
    row++;
    column = 0;
    if (row >= vga_height) {
      vga_scroll();
    }
    crtc_cursor(row, column);
    return;
  }
  if (column >= vga_width) {
    column = 0;
    row++;
  }
  if (row >= vga_height) {
    vga_scroll();
  }
  size_t index = row * vga_width + column;
  vga_addr[index] = ((uint16_t) color << 8) | (uint8_t) x;
  column++;
  crtc_cursor(row, column);
}

static void put_str (const char* x) {
  while (*x) {
    put_char (*x);
    x++;
  }
}

static void clear_buff (void) {
  for (size_t i = 0; i < vga_end; i++) {
    vga_addr[i] = ((uint16_t)color << 8) | (uint8_t)' ';
  }
  row = 0;
  column = 0;
  crtc_cursor(row, column);
}

void kprint (char log_type, const char* msg) {
  switch (log_type) {
    case 'i':
      put_str ("k > info > ");
      break;
    case 'w':
      put_str ("k > warn > ");
      break;
    case 'e':
      put_str ("k > err! > ");
      break;
    default:
      // kernel_panic in vga - soon...
      // now - just return
      put_str ("k > def? > ");
      break;
  }
  put_str (msg);
  put_char ('\n');
}