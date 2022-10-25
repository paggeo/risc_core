library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

entity common_data_bus_tb is 
end entity;

architecture testbench of common_data_bus_tb is 

  -----------------------------------------------------------------------
  -- Component
  -----------------------------------------------------------------------
component common_data_bus is 
port(
  valid_in    : in std_logic;
  data_in     : in std_logic_vector(XLEN-1 downto 0);
  source_in   : in std_logic_vector(XLEN-1 downto 0);
  data_out    : out std_logic_vector(XLEN-1 downto 0);
  source_out  : out std_logic_vector(XLEN-1 downto 0);
  valid_out   : out std_logic

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

  -- Input signals 
	signal valid_in : std_logic := '0'; 
  signal data_in  : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
  signal source_in  : std_logic_vector(XLEN-1 downto 0) := (others=>'0');


  -- Output signals 
  signal data_out : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
  signal source_out : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
  signal valid_out : std_logic := '0';

  signal ip_frame : integer := 0;

  begin 
    dut : common_data_bus 
      port map(
        valid_in => valid_in,
        data_in => data_in, 
        source_in => source_in,
        data_out => data_out, 
        source_out => source_out,
        valid_out => valid_out
      );
  -----------------------------------------------------------------------
  -- Generate clock
  -----------------------------------------------------------------------
  --  generate_clock : process
  --  begin
  --      clock <= '0';
  --      wait for clock_period/2;
  --      clock <= '1';
  --      wait for clock_period/2;
  --  end process;
  
  -----------------------------------------------------------------------
  -- Generate data slave channel inputs
  -----------------------------------------------------------------------
  simulation : process 
  begin 
    wait for TIME_DELAY;
    valid_in <= '1';
    data_in   <= std_logic_vector(to_unsigned(10,XLEN));
    source_in <= std_logic_vector(to_unsigned(4,XLEN));
    ip_frame <= 1;
    wait for TIME_DELAY;
    valid_in <= '0';
    data_in   <= std_logic_vector(to_unsigned(11,xlen));
    source_in <= std_logic_vector(to_unsigned(5,xlen));
    ip_frame <= 2;
    wait for time_delay;
    valid_in <= '1';
    data_in   <= std_logic_vector(to_unsigned(12,xlen));
    source_in <= std_logic_vector(to_unsigned(6,xlen));
    ip_frame <= 2;
    wait for time_delay;
    valid_in <= '0';
    data_in   <= (others=>'0');
    source_in <= (others=>'0');
    ip_frame <= 2;
    wait;

  end process;
end architecture;
