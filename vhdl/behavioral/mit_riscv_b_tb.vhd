library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library work;
use work.common.all;

entity riscv_tb_b is 
end entity; 

architecture testbench of riscv_tb_b is 

-----------------------------------------------------------------------
-- Component
-----------------------------------------------------------------------
component riscv_b is 
port(
  clock: in std_logic;
  reset: in std_logic
);
end component;
-----------------------------------------------------------------------
-- Timing constants
-----------------------------------------------------------------------
constant clock_period : time := 10 ns;
constant TIME_DELAY       : time := 10 ns;
-----------------------------------------------------------------------
-- DUT signals
-----------------------------------------------------------------------

-- General signals
signal clock                        : std_logic := '0';  -- the master clock
signal reset                        : std_logic := '0';  -- reset point

-- Save frame number 
signal ip_frame : integer := 0;
begin 
	dut: riscv_b
		port map (
		  clock => clock,
      reset => reset
    );
  -----------------------------------------------------------------------
  -- Generate clock
  -----------------------------------------------------------------------
  generate_clock : process
  begin
    clock <= '0';
    wait for clock_period/2;
    clock <= '1';
    wait for clock_period/2;
  end process;
  
  simulation : process
  begin 
    wait for TIME_DELAY/2;
    reset <= '1';
    wait for TIME_DELAY;
    reset <= '0';
    wait for 10*clock_period;
    reset <= '1';
    wait ;
  end process;

end architecture;
