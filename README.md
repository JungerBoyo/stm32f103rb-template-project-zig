# stm32f103rb-template-project-zig
stm32f103rb mcu ziglang template project with microzig. To use you will need zig >=0.10.0 compiler, st-flash and st-util.

## Building 
Build steps:
* Build to elf and binary, run `zig build -fstage1 install.`
* Flash binary using st-flash tool, run `zig build -fstage1 flash`

## Debugging
Steps:
* switch build mode to `.Debug`
* `run gdb` and `st-util`
* (in gdb) `target extended:4242`
* (in gdb) `file zig-out/bin/<project_name>.elf`
