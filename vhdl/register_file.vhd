library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

entity register_file is 
port(
  clock : in std_logic;
  reset : in std_logic;
  ra1   : in rd_vector;
  ra2   : in rd_vector;
  rd1   : out std_logic_vector(XLEN-1 downto 0);
  rd2   : out std_logic_vector(XLEN-1 downto 0);
  
  write_address : in rd_vector;
  write_enable  : in std_logic;
  write_data    : in std_logic_vector(XLEN-1 downto 0)
);

end entity; 


architecture rtl of register_file is 

signal registers : reg_file := registers_fillup;

constant zero : std_logic_vector(XLEN-1 downto 0) := (others=>'0');

begin 
  registers(0) <= zero;
  
  register_file_process_load : process(reset,write_enable,write_data,write_address)
  begin 
    --if rising_edge(clock) then 
      if reset = '1' then 
        --registers <= (others=>(others=>'0'));
      else
        if write_enable = '1' and write_address /= 0 then 
          registers(to_integer(unsigned(write_address))) <= write_data; 
        else -- do nothing
        end if;
      end if;
   -- end if;
  end process;

  register_file_process_store : process(reset,write_enable,ra1,ra2)
  begin 
    --if rising_edge(clock) then 
      rd1 <= registers(to_integer(unsigned(ra1)));
      rd2 <= registers(to_integer(unsigned(ra2)));
    --end if;
  end process;


end architecture;
