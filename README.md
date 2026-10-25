# ECE2 STM32_1 / FPGA 실습 준비물

기준 자료: `STM32_4week_plan.pdf` (2026-10-19 STM32_1)와 수업 저장소 문서.

## 이번 주에 할 일

1. **STM32 과제 3**: 버튼 인터럽트로 점멸 간격을 1 → 2 → 4 → 8 → 1초 순환시키고, TIM6 ISR이 LED(PA5)를 토글합니다.
2. **STM32 과제 4**: 과제 3과 별도로 버튼 인터럽트가 PB4 PWM duty를 25 → 50 → 75 → 25%로 바꿉니다. C 디버거 중단점·Watch·F10을 확인합니다.
3. **FPGA 교재 실습**: 피아노 → 신호등 → ADC 순서로 시뮬레이션과 보드 시연을 합니다.

STM32는 `NUCLEO-G474RE`와 수업 제공 저장소 `v1.1.0`을 사용합니다. STM32 예제는 `STM32/` 폴더의 코드 조각을 제공 프로젝트 `ece2_474_routine.c`에 적용합니다. 제공된 CubeMX 초기화 파일과 핀 설정은 다시 생성하거나 덮어쓰지 않습니다.

FPGA 폴더에는 문서에서 설명하는 설계 동작을 실험별 Verilog/SystemVerilog 파일로 분리했습니다. 장비 제공 ZIP과 `Xilinx S7 Pin Map.pdf`에서 확인한 보드 핀으로 각 `pins.xdc`를 작성했습니다. MCU에 XDC를 적용하지 않습니다.

## 폴더 안내

- `STM32/Task3_ISR_snippet.c`: 과제 3에 넣을 상태 변수와 함수 본문
- `STM32/Task4_PWM_snippet.c`: 과제 4용 별도 함수 본문
- `STM32/VSCode/ece2_474/`: 제공 CubeMX 파일과 ISR 과제 3이 적용된 열 수 있는 VS Code 프로젝트
- `STM32/VSCode_Task4/ece2_474/`: PWM 과제 4가 적용된 별도 VS Code 프로젝트
- `STM32/VSCode/ece2_474/Variants/Task4_PWM/ece2_474_routine.c`: 과제 4의 원본 대체 routine 파일
- `FPGA/Piano/`: `piano` 설계와 테스트벤치
- `FPGA/Traffic/`: `traffic` 설계와 테스트벤치
- `FPGA/ADC/`: `adc` 설계와 테스트벤치
- `FPGA/README.md`: Vivado 시뮬레이션 구성, 보드 시연 주의점

과제 3과 과제 4는 각각 별도 VS Code 프로젝트에 적용되어 있으며 두 프로젝트 모두 Debug ELF 빌드가 완료되었습니다. FPGA의 Piano·Traffic·ADC는 시뮬레이션과 Vivado 비트스트림 빌드가 완료되었습니다. 빠른 확인은 `FPGA/PASS.log`, 원본 근거는 각 `simulation.log`, `wave.vcd`, `FPGA/vivado_build.log`에 있습니다. VS Code에서는 `waveform.svg` 세 개와 `PASS.log`를 함께 열 수 있습니다.
