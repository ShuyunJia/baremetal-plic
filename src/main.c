//--------------------------------------------------------------------------
// See LICENSE for license details.

//unsigned n_harts = 0;

extern int printf(const char* fmt, ...);
#include <assert.h>
#include <stdint.h>
#include <stdio.h>
#include "plic.h"
#include "encoding.h"
#define DEBUG

plic_instance_t plic0;

int main(int argc, char** argv);
int main(int argc, char** argv)
{

  printf("Hello, World from my MAIN !\n");

  //init plic
  printf("Start to init PLIC !\n");
  PLIC_init(&plic0, 0x0c000000, 2, 1);
  plic_source int_spi0 = 1;
  PLIC_enable_interrupt(&plic0, int_spi0);
  PLIC_set_priority(&plic0, int_spi0, 1);

  printf("enable MIP_MEIP in MIE !\n");
  set_csr(mie,MIP_MEIP);

  while(1);
  return 0;
}
