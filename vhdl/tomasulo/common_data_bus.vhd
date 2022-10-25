library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

-- Broad Casted Data bus: data + source("come from")
-- One speak every on listen
entity common_data_bus is 
port(
  valid_in    : in std_logic;
  data_in     : in std_logic_vector(XLEN-1 downto 0);
  source_in   : in std_logic_vector(XLEN-1 downto 0);
  data_out    : out std_logic_vector(XLEN-1 downto 0);
  source_out  : out std_logic_vector(XLEN-1 downto 0);
  valid_out   : out std_logic

);
end entity;

architecture rtl of common_data_bus is

begin 
  main : process(valid_in,data_in,source_in)
  begin 
    if (valid_in = '1') then 
      data_out <= data_in;
      source_out <= source_in;
      valid_out <= '1';
    else 
      data_out <= (others=>'0');
      source_out <= (others=>'0');
      valid_out <= '0';
    end if;
  end process;

end architecture;