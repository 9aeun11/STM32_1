/* STM32_1 과제 4: 과제 3 대신 사용합니다.
 * 프로젝트의 Core/Src/ece2_474_routine.c로 복사해 빌드하세요.
 */
#include "ece2_474.h"
#include "main.h"

volatile uint8_t pwm_percent = 25U; /* 디버거 Watch용 */
static volatile uint8_t pwm_step = 0U;

void ece2_474_init(void)
{
    HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_1);
    __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, 250U);
}

void polling_routine(void)
{
    /* 과제 4의 버튼 인터럽트가 PWM 비율을 변경합니다. */
}

static void button_isr_p7(void)
{
    static uint32_t last_ms = 0U;
    const uint32_t now_ms = HAL_GetTick();
    static const uint16_t compare_values[3] = {250U, 500U, 750U};
    static const uint8_t percentages[3] = {25U, 50U, 75U};
    if ((uint32_t)(now_ms - last_ms) < 200U) return;
    last_ms = now_ms;

    pwm_step = (uint8_t)((pwm_step + 1U) % 3U);
    pwm_percent = percentages[pwm_step];
    __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, compare_values[pwm_step]);
}

static void tim6_isr_p4(void) { }
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
