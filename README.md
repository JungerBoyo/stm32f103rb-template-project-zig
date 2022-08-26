# stm32f103rb-template-project-zig
stm32f103rb mcu ziglang template project with microzig

## Building 
Build steps:
* Build to elf, run `zig build -fstage1 install.`
* Convert elf to binary, run `zig build -fstage1 convert_to_binary`
* Flash binary using st-flash tool, run `zig build -fstage1 flash`

## Debugging
Steps:
* switch build mode to `.Debug`
* `run gdb` and `st-util`
* (in gdb) `target extended:4242`
* (in gdb) `file zig-out/bin/<project_name>.elf
`