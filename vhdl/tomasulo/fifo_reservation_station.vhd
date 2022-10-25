library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

-- For now this is the same size as the reservation stations
-- We need this if 2 reservation stations get out together.
entity fifo_reservation_station is 
generic (
  width : integer := 3;
);
port (
  valid_in  : in std_logic;
  op_in     : in opcode_vector;
  funct3_in : in funct3_vector;
  funct7_in : in funct7_vector;
  rs1       : in std_logic_vector(XLEN-1 downto 0);
  rs2       : in std_logic_vector(XLEN-1 downto 0);
  
  rd2       : out std_logic_vector(XLEN-1 downto 0);
  rd2       : out std_logic_vector(XLEN-1 downto 0);

  op_out      : out opcode_vector;
  funct3_out  : out funct3_vector;
  funct7_out  : out funct7_vector;
  valid_out   : out std_logic
);
end entity;

architecture rtl of fifo is 

type fifo_type is record 
  op     : opcode_vector;
  funct3 : funct3_vector;
  funct7 : funct7_vector;
  rs1     : std_logic_vector(XLEN-1 downto 0);
  rs2     : std_logic_vector(XLEN-1 downto 0);
end record;

type fifo_array  is array(natural range<>) of fifo_type;
signal fifo : fifo_array(1 to width+1);

begin 

end architecture; 