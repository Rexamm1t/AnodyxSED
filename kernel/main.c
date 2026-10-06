/* This is the entry point to the kernel code.
* This is where the settings calls occur.
* The core loop is also here */

// #include "vga/vga_main.h"

void anodyx_kernel (void) {
  // clear_buff() <-- this from vga subsystem
  bool is_kernel_started = false;
  while (is_kernel_started) {
    // kernel init & something...
  }
  return 1;
}