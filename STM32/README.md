# VS Code STM32 starter

`VSCode/ece2_474/ece2_474.code-workspace` opens the prepared NUCLEO-G474RE project. It is based on the STM32_0 starter already present in the user's `LAB4_FPGA_MCU` folder, keeping the generated CubeMX files and using the STM32_1 ISR implementation for Task 3.

## Build and flash

1. In VS Code install/enable the `STM32CubeIDE for Visual Studio Code` extension and `gnu-tools-for-stm32` bundle as described by the course README.
2. Open `ece2_474.code-workspace` from this folder.
3. In the CMake view choose **Configure → Debug**, then **Build**.
4. Confirm the board JP5 jumper is at `5V_STLK`, connect the ST-LINK USB port, choose **STM32Cube: Launch ST-Link GDB Server**, and press F5. When execution stops at `main`, press F5 again.

The current `Core/Src/ece2_474_routine.c` runs Task 3. For Task 4, copy `Variants/Task4_PWM/ece2_474_routine.c` over `Core/Src/ece2_474_routine.c`, build, and flash again. The two tasks are separate; do not leave the TIM6 task 3 code active during Task 4.

The `build/` directory was intentionally omitted so VS Code can configure a fresh local build. Do not regenerate the IOC or replace the supplied board initialization. A clean build/program cycle is needed after changing the routine file.
