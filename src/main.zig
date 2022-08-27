const microzig = @import("microzig");
const registers = microzig.chip.registers;

pub fn delay(ticks: i32) void {
  var i = @divExact(ticks, 5);
  while(i > 0) : (i -= 1) {
    asm volatile("nop");
  }
}

pub fn main() !void {
  // turn on HSI clk src
  registers.RCC.CR.modify(.{ .HSION = 1 });
  while(registers.RCC.CR.read().HSIRDY == 0) {}
  const clkFreq: i32 = 8000000; // default HSI freq
  // choose HSI as system clk
  registers.RCC.CFGR.modify(.{ .SW = 0b00 });
  
  // enable clock for GPIOA
  registers.RCC.APB2ENR.modify(.{ .IOPAEN = 1 });

  registers.GPIOA.CRL.modify(.{
    .CNF5  = 0b00, // set pa5 as push-pull output
    .MODE5 = 0b11, // set pa5 max output f to 50Mhz
  });

  const second = clkFreq;
  while(true) {
    delay(second);
    registers.GPIOA.BSRR.modify(.{ .BS5 = 1 }); // set diode ON
    delay(second);
    registers.GPIOA.BSRR.modify(.{ .BR5 = 1 }); // set diode OFF
  }
}

