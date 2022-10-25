library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;


entity store_buffer is 

generic (
  width : integer := 3;
);
port();
end entity;

architecture rtl of store_buffer is 

type store_buffer_type is record
  busy   :  std_logic;
  address: std_logic_vector(XLEN-1 downto 0);
  fu     :  std_logic_vector(XLEN-1 downto 0);
end record;

signal stb : store_buffer_type;
end architecture;