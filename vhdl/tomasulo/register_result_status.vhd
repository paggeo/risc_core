library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

-- If register status is 0 then we are not waiting for no register
entity register_result_status is 
port(
  s_valid_in  : in std_logic;
  s_rd_in     : in rd_vector;
  s_rs_in     : in std_logic_vector(XLEN-1 downto 0);

  l_valid_in  : in std_logic;
  l_rd_in     : in rd_vector;

  valid_out : out std_logic;
  rs_out    : out std_logic_vector(XLEN-1 downto 0)
);

end entity;

architecture rtl of register_result_status is 

type fu is array(natural range<>) of std_logic_vector(XLEN-1 downto 0);

signal rrs : fu(0 to XLEN-1) := (others=>(others=>'0'));
begin
  store : process(s_valid_in,s_rd_in,s_rs_in)
  begin 
    if s_valid_in = '1' then 
      -- Store where what the register is waiting
      rrs(to_integer(unsigned(s_rd_in))) <= s_rs_in; 
    end if;
  end process;

  load : process(l_valid_in,l_rd_in)
  begin 
    if l_valid_in = '1' then 
      -- Store where what the register is waiting
      valid_out <= '1';
      rs_out <= rrs(to_integer(unsigned(l_rd_in)));
    else 
      valid_out <= '0';
      rs_out <= (others=>'0');
    end if;
  end process;
end architecture;