library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

entity register_result_status_tb is 
end entity;


architecture rtl of register_result_status_tb is 

  -----------------------------------------------------------------------
  -- Component
  -----------------------------------------------------------------------

component register_result_status is 
port(
  s_valid_in  : in std_logic;
  s_rd_in     : in rd_vector;
  s_rs_in     : in std_logic_vector(XLEN-1 downto 0);

  l_valid_in  : in std_logic;
  l_rd_in     : in rd_vector;

  valid_out : out std_logic;
  rs_out    : out std_logic_vector(XLEN-1 downto 0)
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
	signal s_valid_in : std_logic := '0'; 
  signal s_rd_in    : rd_vector := (others=>'0'); 
  signal s_rs_in  : std_logic_vector(XLEN-1 downto 0) := (others=>'0');

	signal l_valid_in : std_logic := '0'; 
  signal l_rd_in    : rd_vector := (others=>'0'); 

  -- Output signals 
  signal rs_out : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
  signal valid_out : std_logic := '0';

  signal ip_frame : integer := 0;

  begin 
  dut : register_result_status 
    port map(
      s_valid_in => s_valid_in,
      s_rd_in => s_rd_in,
      s_rs_in => s_rs_in,
      l_valid_in => l_valid_in,
      l_rd_in => l_rd_in,
      rs_out => rs_out,
      valid_out => valid_out
    );

  simulation : process 
  begin 
    wait for TIME_DELAY;
    s_valid_in <= '1';
    s_rd_in <= std_logic_vector(to_unsigned(5,5)); 
    s_rs_in <= std_logic_vector(to_unsigned(11,xlen)); 
    l_valid_in <= '0';
    l_rd_in <= std_logic_vector(to_unsigned(10,5)); 
    ip_frame <= 1;
    wait for TIME_DELAY;
    s_valid_in <= '1';
    s_rd_in <= std_logic_vector(to_unsigned(4,5)); 
    s_rs_in <= std_logic_vector(to_unsigned(13,xlen)); 
    l_valid_in <= '1';
    l_rd_in <= std_logic_vector(to_unsigned(5,5)); 
    ip_frame <= 2;
    wait for TIME_DELAY;
    s_valid_in <= '0';
    s_rd_in <= (others=>'0');
    s_rs_in <= (others=>'0');
    l_valid_in <= '0';
    l_rd_in <= (others=>'0');
    ip_frame <= 0;
    wait;

  end process;
    
end architecture;