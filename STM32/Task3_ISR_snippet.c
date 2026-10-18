/* STM32_1 과제 3: 제공 ece2_474_routine.c에 옮겨 넣을 코드 조각.
 * ece2_474.h에 htim6, LED_ece2_GPIO_Port/Pin 선언이 이미 있어야 합니다.
 * 아래 이름의 ISR wrapper는 템플릿의 기존 선언/연결을 유지하세요.
 */

#include "ece2_474.h"

/* 공유 상태: 100 ms 단위. ISR 사이에서 읽고 쓰므로 volatile입니다. */
static volatile uint32_t led_interval_ticks = 10U; /* 1 second */
static volatile uint32_t led_elapsed_ticks = 0U;

/* ece2_474_init()에 추가 */
static void task3_start(void)
{
    HAL_TIM_Base_Start_IT(&htim6);
}

/* button_isr_p7()의 함수 본문으로 사용 */
static void task3_button_press(void)
{
    static uint32_t last_ms = 0U;
    const uint32_t now_ms = HAL_GetTick();

    if ((uint32_t)(now_ms - last_ms) < 200U) {
        return;
    }
    last_ms = now_ms;

    if (led_interval_ticks == 10U) {
        led_interval_ticks = 20U;
    } else if (led_interval_ticks == 20U) {
        led_interval_ticks = 40U;
    } else if (led_interval_ticks == 40U) {
        led_interval_ticks = 80U;
    } else {
        led_interval_ticks = 10U;
    }
    led_elapsed_ticks = 0U;
}

/* tim6_isr_p4()의 함수 본문으로 사용: TIM6 주기는 제공 설정의 100 ms */
static void task3_tim6_tick(void)
{
    if (++led_elapsed_ticks >= led_interval_ticks) {
        led_elapsed_ticks = 0U;
        HAL_GPIO_TogglePin(LED_ece2_GPIO_Port, LED_ece2_Pin);
    }
}

/* 과제 3에서는 polling_routine()에서 버튼/시간/LED 제어를 하지 않습니다. */
static void task3_polling_placeholder(void)
{
}

/* 연결 안내:
 * 1) 템플릿 ece2_474_init()에서 task3_start()를 호출합니다.
 * 2) 기존 button_isr_p7()에서 task3_button_press()를 호출합니다.
 * 3) 기존 tim6_isr_p4()에서 task3_tim6_tick()을 호출합니다.
 * 4) polling_routine()은 비웁니다. 템플릿의 ISR/HAL callback 연결 코드는 보존합니다.
 */
