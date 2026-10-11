/* This is the entry point to the kernel code.
* This is where the settings calls occur.
* The core loop is also here */

#include "vga/head/vga_main.h"
#include "head/anodyx_main.h"

bool is_kernel_running = false;

/*
void anodyx_base_init
(void)
{
  kprint ('w', "start setting up kernel submodules...");
  gdt_init ();
  kprint ('i', "gdt successfully loaded");
}
*/

void anodyx_kernel
(void)
{
  clear_buff ();
  print_anodyx_logo (kernel_version);
  is_kernel_running = true;

  // anodyx_base_init (); <- now loop

  kprint ('i', "anodyx_kernel successfully stared in 0x100000");

  while (is_kernel_running) {
    
  }
  return;
}
