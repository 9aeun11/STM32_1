# ECE2 STM32_1 / FPGA 실습 제출 자료

이 저장소는 STM32 과제 3·4와 FPGA Piano·Traffic·ADC 실습의 소스, 테스트벤치, 검증 자료 및 캡처를 모았습니다.

## 구성

- `STM32/Task3_ISR_snippet.c`, `Task4_PWM_snippet.c`: 각 과제에 적용할 코드
- `STM32/VSCode/`, `STM32/VSCode_Task4/`: 과제 3·4용 분리된 VS Code 프로젝트
- `FPGA/Piano/`, `FPGA/Traffic/`, `FPGA/ADC/`: SystemVerilog 소스, 테스트벤치, XDC 핀 제약, 시뮬레이션 로그와 VCD
- `Waveforms/`: 과제별 파형 기록과 미리보기 이미지
- `evidence/`: 시뮬레이션, PASS, 빌드, 파형 및 주요 코드 캡처
- `FPGA/PASS.log`, `FPGA/verification_summary.log`: 검증 요약

## 확인 결과

제출 패키지에 보존된 로그 기준으로 FPGA 세 실습의 테스트벤치 PASS와 Vivado 비트스트림 빌드 완료가 확인됩니다. STM32 과제 3·4는 각각 제공된 VS Code 프로젝트에서 ELF 링크까지 완료된 기록을 캡처에 포함했습니다. 이 기록은 시뮬레이션 및 빌드 결과이며 실제 보드 동작을 확인했다는 뜻은 아닙니다.

## 실행

FPGA의 실행 순서와 Vivado 설정은 [`FPGA/README.md`](FPGA/README.md)를 참고하세요. 시뮬레이션은 PowerShell에서 `FPGA/run_simulations.ps1`로 실행할 수 있습니다. Vivado Tcl 스크립트와 보드 핀 제약 파일은 `FPGA/` 및 각 실습 폴더에 있습니다. Vivado XSim 실행 스크립트는 `FPGA/run_xsim.tcl`입니다. 최신 실행 결과는 `FPGA/PASS.log`, `FPGA/xsim_simulation.log`, `FPGA/vivado_build.log`에서 확인할 수 있습니다.

STM32 프로젝트 여는 방법과 빌드·플래시 순서는 [`STM32/README.md`](STM32/README.md)를 참고하세요. 과제 3과 4는 별도 프로젝트이며 제공된 CubeMX 보드 설정을 유지합니다.

## 제출 파일 관련

Vivado 프로젝트 캐시, IDE 빌드 폴더, 실행 파일 등 재생성 가능한 산출물은 저장소에서 제외했습니다. 소스, 설정, 로그, VCD 및 캡처는 포함되어 있습니다.

