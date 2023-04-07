SET PATH=D:\Keil_v5\ARM\ARMCC\Bin;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem;C:\WINDOWS\System32\WindowsPowerShell\v1.0\;C:\WINDOWS\System32\OpenSSH\;D:\MATLAB\R2018a\runtime\win64;D:\MATLAB\R2018a\bin;C:\Program Files\Microsoft SQL Server\130\Tools\Binn\;C:\Program Files (x86)\NVIDIA Corporation\PhysX\Common;C:\Program Files\NVIDIA Corporation\NVIDIA NvDLISR;D:\Program Files\Micron Technology\Storage Executive;D:\Python37\Scripts\;D:\Python37\;C:\Users\HUIP\AppData\Local\Microsoft\WindowsApps;D:\bandizip\;D:\iverilog\bin;D:\iverilog\gtkwave\bin;D:\intelFPGA\18.1\modelsim_ase\win32aloem;C:\Program Files (x86)\mingw-w64\i686-8.1.0-posix-dwarf-rt_v6-rev0\mingw32\bin;D:\intelFPGA_lite\20.1\modelsim_ase\win32aloem
SET CPU_TYPE=STM32F103C8
SET CPU_VENDOR=STMicroelectronics
SET UV2_TARGET=USART1-DEMO
SET CPU_CLOCK=0x00B71B00
"D:\Keil_v5\ARM\ARMCC\Bin\ArmAsm" --Via ".\startup_stm32f10x_hd._ia"
"D:\Keil_v5\ARM\ARMCC\Bin\ArmCC" --Via ".\main.__i"
"D:\Keil_v5\ARM\ARMCC\Bin\ArmCC" --Via ".\stm32f10x_it.__i"
"D:\Keil_v5\ARM\ARMCC\Bin\ArmCC" --Via ".\usart1.__i"
"D:\Keil_v5\ARM\ARMCC\Bin\ArmCC" --Via ".\stm32f10x_gpio.__i"
"D:\Keil_v5\ARM\ARMCC\Bin\ArmCC" --Via ".\stm32f10x_rcc.__i"
"D:\Keil_v5\ARM\ARMCC\Bin\ArmCC" --Via ".\stm32f10x_usart.__i"
"D:\Keil_v5\ARM\ARMCC\Bin\ArmCC" --Via ".\core_cm3.__i"
"D:\Keil_v5\ARM\ARMCC\Bin\ArmCC" --Via ".\system_stm32f10x.__i"
"D:\Keil_v5\ARM\ARMCC\Bin\ArmLink" --Via ".\STM32-DEMO.lnp"
"D:\Keil_v5\ARM\ARMCC\Bin\fromelf.exe" ".\STM32-DEMO.axf" --i32combined --output ".\STM32-DEMO.hex"
