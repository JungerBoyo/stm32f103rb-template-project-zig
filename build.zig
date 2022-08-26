const std = @import("std");
const microzig = @import("microzig/src/main.zig");
const MemoryRegion = @import("microzig/src/modules/MemoryRegion.zig");

pub fn build(b: *std.build.Builder) void {
  const stm32f103xb = microzig.Chip {
    .name = "STM32F103xB",
    .path = "microzig/src/modules/chips/stm32f103/stm32f103.zig",
    .cpu  = microzig.cpus.cortex_m3,
    .memory_regions = &.{
      MemoryRegion { .offset = 0x08000000, .length = 128 * 1024, .kind = .flash },
      MemoryRegion { .offset = 0x20000000, .length = 20 * 1024,  .kind = .ram   },
    },
  };

  var mem_buffer: [256]u8 = undefined;
  const allocator = std.heap.FixedBufferAllocator.init(&mem_buffer).allocator();

  const project_name: []const u8 = "stm32f103rb-template-project-zig";

  const exe_name = std.fmt.allocPrint(allocator, "{s}.elf", .{project_name}) catch "exe.elf";
  const exe = microzig.addEmbeddedExecutable(
    b,
    exe_name, 
    "src/main.zig",
    .{.chip = stm32f103xb,},
    .{},       
  );
  exe.inner.setBuildMode(.ReleaseFast);
  exe.inner.install();

  const exe_elf_path = std.fmt.allocPrint(allocator, "zig-out/bin/{s}.elf", .{project_name}) catch "zig-out/bin/exe.elf";
  const exe_bin_path = std.fmt.allocPrint(allocator, "zig-out/bin/{s}.bin", .{project_name}) catch "zig-out/bin/exe.bin";
  const convert_to_binary_cmd = b.addSystemCommand(&[_][]const u8{
    "arm-none-eabi-objcopy", 
    "-O", 
    "binary", 
    exe_elf_path,
    exe_bin_path,
  });
  convert_to_binary_cmd.step.dependOn(b.getInstallStep());

  var convert_to_binary_step = b.step("convert_to_binary", "converts compiled ELF file to binary file using objcopy");
  convert_to_binary_step.dependOn(&convert_to_binary_cmd.step);

  const flash_cmd = b.addSystemCommand(&[_][]const u8{
    "st-flash", 
    "write", 
    exe_bin_path,
    "0x08000000"
  });
  flash_cmd.step.dependOn(convert_to_binary_step);
 
  const flash_step = b.step("flash", "flash binary into MCU");
  flash_step.dependOn(&flash_cmd.step);
}
