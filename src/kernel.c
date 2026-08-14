#include <stdint.h>

void kernel_main(void){
    volatile uint16_t *p = (uint16_t *) 0xB8000;
    uint8_t color = (6 << 4) | (9);
    uint16_t cell = ('A') | (color << 8);
    p[0] = cell;
    while(1){

    }
}
