/* STM32_1 과제 3: 제공 ece2_474 프로젝트용 완성 routine 파일.
 * 프로젝트의 Core/Src/ece2_474_routine.c로 사용합니다.
 */
#include "ece2_474.h"
#include "main.h"

static volatile uint32_t led_interval_ticks = 10U; /* 100 ms tick x 10 = 1 s */
static volatile uint32_t led_elapsed_ticks = 0U;

void ece2_474_init(void)
{
    HAL_TIM_Base_Start_IT(&htim6);
}

void polling_routine(void)
{
    /* 과제 3의 버튼·타이밍·LED 동작은 ISR에서 처리합니다. */
}

static void button_isr_p7(void)
{
    static uint32_t last_ms = 0U;
    const uint32_t now_ms = HAL_GetTick();
    if ((uint32_t)(now_ms - last_ms) < 200U) return;
    last_ms = now_ms;

    if (led_interval_ticks == 10U) led_interval_ticks = 20U;
    else if (led_interval_ticks == 20U) led_interval_ticks = 40U;
    else if (led_interval_ticks == 40U) led_interval_ticks = 80U;
    else led_interval_ticks = 10U;
    led_elapsed_ticks = 0U;
}

static void tim6_isr_p4(void)
{
    if (++led_elapsed_ticks >= led_interval_ticks) {
        led_elapsed_ticks = 0U;
        HAL_GPIO_TogglePin(LED_ece2_GPIO_Port, LED_ece2_Pin);
    }
}

static void uart2_isr_p6(void) { }
static void uart3_isr_p5(void) { }
static void gpio_in_pullup_isr_p8_ece2(void) { }
static void gpio_in_pulldown_isr_p9_ece2(void) { }

void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
    if (GPIO_Pin == BUTTON_ece2_Pin) button_isr_p7();
    else if (GPIO_Pin == GPIO_IN_PULLUP_ece2_Pin) gpio_in_pullup_isr_p8_ece2();
    else if (GPIO_Pin == GPIO_IN_PULLDOWN_ece2_Pin) gpio_in_pulldown_isr_p9_ece2();
}

void HAL_TIM_PeriodElapsedCallback(TIM_HandleTypeDef *htim)
{
    if (htim->Instance == TIM6) tim6_isr_p4();
}

void HAL_UART_RxCpltCallback(UART_HandleTypeDef *huart)
{
    if (huart->Instance == USART2) uart2_isr_p6();
    else if (huart->Instance == USART3) uart3_isr_p5();
}
