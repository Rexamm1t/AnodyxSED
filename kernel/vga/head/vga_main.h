#include <stdint.h>
#include <stddef.h>

#define vga_width 80
#define vga_height 25
#define vga_end 2000
#define vga_addr ((volatile uint16_t *)0xb8000)

extern size_t row;
extern size_t column;

void print_anodyx_logo (char* x);
void clear_buff (void);
void kprint (char log_type, const char* msg);
