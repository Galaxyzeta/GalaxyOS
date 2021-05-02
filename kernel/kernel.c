#include "cpu/isr.h"
#include "drivers/vga.h"

void main() {
    isr_install();
    /* Test the interrupts */
    cls();
    printk("asd");
    asm volatile("int $2");
    asm volatile("int $3");
}