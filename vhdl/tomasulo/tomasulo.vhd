library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;


entity tomasulo is 
port();
end entity;


architecture rtl of tomasulo is 

component reservation_station is 
generic ( 
  width : integer := 3;
);
port(
  valid_in    : in std_logic;
  op_in       : in opcode_vector;
  funct3_in   : in funct3_vector;
  funct7_in   : in funct7_vector;
  rs1         : in std_logic_vector(XLEN-1 downto 0);  
  rs2         : in std_logic_vector(XLEN-1 downto 0);  

  rd1         : out std_logic_vector(XLEN-1 downto 0);  
  rd2         : out std_logic_vector(XLEN-1 downto 0);  
  op_out      : out opcode_vector;
  funct3_out  : out funct3_vector;
  funct7_out  : out funct7_vector;
  valid_out   : out std_logic
);

end component;

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
end architecture;