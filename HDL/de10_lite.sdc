# 1. Tell TimeQuest that a 50 MHz clock enters the physical MAX10_CLK1_50 pin
create_clock -name MAX10_CLK1_50 -period 20.000 [get_ports {MAX10_CLK1_50}]

# 2. Tell TimeQuest to automatically calculate ALL internal PLL output clocks (c0, c1, inverted clocks, phase shifts)
derive_pll_clocks

# 3. Add clock uncertainty parameters to model physical jitter
derive_clock_uncertainty