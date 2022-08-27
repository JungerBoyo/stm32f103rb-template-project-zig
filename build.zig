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

  const project_name: []const u8 = "stm32f103rb-template-project-zig";

  const exe = microzig.addEmbeddedExecutable(
    b,
    project_name ++ ".elf", 
    "src/main.zig",
    .{.chip = stm32f103xb,},
    .{},       
  );
  const mode = b.standardReleaseOptions();
  exe.inner.setBuildMode(mode);
  exe.inner.install();

  const exe_bin = b.addInstallRaw(exe.inner, project_name ++ ".bin", .{});
  b.getInstallStep().dependOn(&exe_bin.step);

  const flash_cmd = b.addSystemCommand(&[_][]const u8{
    "st-flash", 
    "write", 
    b.getInstallPath(exe_bin.dest_dir, exe_bin.dest_filename),
    "0x08000000"
  });
  flash_cmd.step.dependOn(b.getInstallStep());
 
  const flash_step = b.step("flash", "flash binary into MCU");
  flash_step.dependOn(&flash_cmd.step);
}
