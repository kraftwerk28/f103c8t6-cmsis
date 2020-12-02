#include <stdint.h>
#include "stm32f10x_gpio.h"
#include "stm32f10x_rcc.h"
#include "system_stm32f10x.h"

void assert_failed(uint8_t* file, uint32_t line) {
  while (1) {
  }
}

void delay(uint16_t ms) {
  uint32_t i = SystemCoreClock / 1000 * ms;
  while (i--) {
  }
}

void init_gpio() {
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOB, ENABLE);
  RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);

  GPIO_InitTypeDef init_struct = {.GPIO_Mode = GPIO_Mode_Out_PP,
                                  .GPIO_Pin = GPIO_Pin_All,
                                  .GPIO_Speed = GPIO_Speed_50MHz};

  GPIO_Init(GPIOB, &init_struct);
  init_struct.GPIO_Pin = GPIO_Pin_All;
  GPIO_Init(GPIOA, &init_struct);
}

int main() {
  __enable_irq();
  SystemInit();
  init_gpio();
  while (1) {
    GPIO_WriteBit(GPIOA, GPIO_Pin_0, Bit_RESET);
    delay(500);
    GPIO_WriteBit(GPIOA, GPIO_Pin_0, Bit_SET);
    delay(500);
  }
}
