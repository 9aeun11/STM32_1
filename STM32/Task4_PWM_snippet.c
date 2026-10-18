/* STM32_1 과제 4: 과제 3과 별도로 제공 ece2_474_routine.c에 적용합니다.
 * PB4의 TIM3 CH1 PWM 비교값 250/500/750은 25/50/75%입니다.
 */

#include "ece2_474.h"

/* 디버거 Variables/Watch에서 pwm_percent와 pwm_step을 관찰합니다. */
volatile uint8_t pwm_percent = 25U;
static volatile uint8_t pwm_step = 0U;

/* ece2_474_init()에 추가 */
static void task4_start_pwm(void)
{
    HAL_TIM_PWM_Start(&htim3, TIM_CHANNEL_1);
    __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, 250U);
}

/* button_isr_p7()의 함수 본문으로 사용. 과제 3 버튼 코드를 대체합니다. */
static void task4_button_press(void)
{
    static uint32_t last_ms = 0U;
    const uint32_t now_ms = HAL_GetTick();
    static const uint16_t compare_values[3] = {250U, 500U, 750U};
    static const uint8_t percentages[3] = {25U, 50U, 75U};

    if ((uint32_t)(now_ms - last_ms) < 200U) {
        return;
    }
    last_ms = now_ms;

    pwm_step = (uint8_t)((pwm_step + 1U) % 3U);
    pwm_percent = percentages[pwm_step];
    __HAL_TIM_SET_COMPARE(&htim3, TIM_CHANNEL_1, compare_values[pwm_step]);
}

/* 과제 4는 TIM6을 사용하지 않습니다. polling_routine()은 비웁니다. */
static void task4_polling_placeholder(void)
{
}

/* 연결 안내:
 * 1) ece2_474_init()에서 task4_start_pwm()를 호출합니다.
 * 2) 기존 button_isr_p7()에서 task4_button_press()를 호출합니다.
 * 3) 중단점은 pwm_step 또는 compare_values 설정 행에 둡니다.
 * 4) 템플릿의 ISR/HAL callback 연결 코드는 보존하고 과제 3 동작은 비활성화합니다.
 */
