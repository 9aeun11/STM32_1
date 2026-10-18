# FPGA 실습: Vivado 준비

순서는 Piano → Traffic → ADC입니다. 세 폴더는 Vivado에서 각각 별도 프로젝트로 열거나, 한 프로젝트에 설계 파일 하나와 해당 `tb_*.sv` 하나만 추가해 시뮬레이션합니다. 테스트벤치 최상위 이름은 서로 다릅니다.

## Vivado 시뮬레이션

Vivado Tcl Console에서 `create_vivado_project.tcl`을 실행하면 설계·테스트벤치·XDC를 별도 프로젝트로 묶습니다. `LAB`을 `Piano`, `Traffic`, `ADC` 중 하나로 지정하세요. part 기본값은 기존 Combo II-DLD 수업 프로젝트에서 확인한 `xc7s75fgga484-1`입니다. 보드 설정이 다르면 정확한 FPGA part로 `FPGA_PART`를 덮어쓰세요. 스크립트 실행 전에 경로를 해당 파일 위치로 지정합니다.

예: Tcl Console에서 `set ::env(LAB) Piano`, `cd {C:/.../STM32_1/FPGA}`, `source create_vivado_project.tcl` 순서로 입력합니다. 프로젝트는 `vivado_projects/Piano`에 만들어집니다. 다른 실습은 `LAB` 값을 바꾸고 다시 실행합니다.

스크립트를 쓰지 않을 경우 각 실습 폴더에서 다음 파일을 추가합니다.

| 실습 | Design Sources | Simulation Sources top |
|---|---|---|
| Piano | `piano.sv` | `tb_piano` |
| Traffic | `traffic.sv` | `tb_traffic` |
| ADC | `adc.sv`, `adc_board.sv` (보드 top) | `tb_adc` |

`Run Simulation → Run Behavioral Simulation`을 실행하고 Tcl Console의 `PASS ...` 메시지와 파형을 확인합니다. 본 보드용 전체 클록은 50 MHz입니다. 테스트벤치는 시뮬레이션을 빠르게 하려고 클록 수 매개변수를 줄입니다.

## 보드 시연

실제 보드에 올릴 때 설계 최상위는 `piano`, `traffic`, `adc_board`입니다. ADC의 `sample`과 `data_valid`는 시뮬레이션 내부에서 확인하고 보드 top에는 외부 ADC 선과 LED만 노출합니다. 설계 입력은 `clk_50mhz`, HIGH 활성 동기 리셋 `rst_p`를 기준으로 합니다. `pins.xdc`는 기존 제공 `piano.zip`, `traffic.zip`, `adc.zip`의 원본 XDC와 `Xilinx S7 Pin Map.pdf`를 대조해 작성했습니다. 장비의 실제 모듈 연결과 입력·LED 극성은 보드에서 확인하세요.

- Piano: `key[7:0]`은 안정된 HIGH 활성 단일 키 입력입니다. 다중 키는 무음입니다. `piezo`를 피에조 출력에 연결합니다.
- Traffic: 출력 벡터의 각 비트는 방향별 LED의 논리 상태입니다. 실제 LED의 극성이 active-low이면 XDC/상위 wrapper에서 반전해야 합니다. `flicker`는 HIGH 유지 중 점멸 모드입니다.
- ADC: 본 문서의 예제는 외부 직렬 ADC 연결입니다. STM32 ADC를 쓰지 않습니다. 실제 장치 모델, 전원/레벨, 핀 배치는 교재와 ADC 데이터시트로 확인하세요.

## 실행 결과 (2026-10-17)

- `run_simulations.ps1`로 Icarus Verilog 세 테스트벤치를 실행했습니다. 각 폴더의 `simulation.log`에 `PASS`가 기록되었고 `wave.vcd`가 생성되었습니다.
- `render_waveforms.py`가 VCD에서 `waveform.svg`를 생성했습니다. VS Code의 기본 이미지 미리보기에서 바로 열 수 있습니다.
- `build_all_vivado.tcl`로 세 설계를 합성·구현하여 `vivado_projects/<실습>/<실습>.runs/impl_1/`에 비트스트림을 생성했습니다. `vivado_build.log`에 세 설계의 `PASS`가 기록되었습니다.
- 전체 결과는 `PASS.log`와 `verification_summary.log`에 모았습니다.

시뮬레이션과 빌드 성공은 실제 보드 동작을 확인한 결과는 아닙니다. 보드 연결과 LED·스위치 극성은 장비에서 확인해야 합니다.
