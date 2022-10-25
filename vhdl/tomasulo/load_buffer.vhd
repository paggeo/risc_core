library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;


entity load_buffer is 
generic (
  width : integer := 3;
);
port(
  clock : in std_logic;
  valid_in : in std_logic;
  opcode  : in opcode_vector;
  funct3  : in funct3_vector;
  dest    : in rd_vector;
  base_waiting_cdb    : in rs1_vector;
  base_valid  : in std_logic;
  base_value  : in std_logic_vector(XLEN-1 downto 0);
  se_i_imm : in std_logic_vector(XLEN-1 downto 0); -- Sign-Extented imm
   -- Common Data Bus
  cdb_data_out    : in std_logic_vector(XLEN-1 downto 0);
  cdb_source_out  : in std_logic_vector(XLEN-1 downto 0);
  cdb_valid_out   : in std_logic;

  opcode_out  : out opcode_vector;
  funct3      : out funct3_vector;
  dest_out    : out rd_vector;
  address     : out std_logic_vector(XLEN-1 downto 0);
  fu          : out std_logic_vector(XLEN-1 downto 0); -- Position to put in the register status
  valid_out   : out std_logic
);
end entity;

architecture rtl of load_buffer is 

type valid_load  is record
  so: std_logic_vector(XLEN-1 downto 0);
  v : std_logic;
end record;
type load_buffer_type is record
  busy : std_logic;
  op     : opcode_vector;
  funct3 : funct3_vector;
  base : valid_load;
  base_waiting_cdb : std_logic_vector(XLEN-1 downto 0);
  offset: std_logic_vector(XLEN-1 downto 0);
end record;

type load_buffer_array is array(natural range <>) of load_buffer_type;
signal ldb : load_buffer_array(1 to width+1); -- TODO: Initialisation
signal zeros : std_logic_vector(XLEN-1 downto 0):= (others=>'0');
begin 

main : process(clock)
begin 
  if rising_edge(clock) then 
  -- we need the position where we have put the argument
  -- fu
  -- So maybe be implement a fifo with the numbers 
  -- For example: 
  -- [1,2,3,4] -> comes one -> [2,3,4] -> comes second -> 
  -- [3,4] -> finishes the second -> [3,4,2] -> finishes one => [3,4,2,1]

    if valid_in = '1' then 
      L1 : for i in 0 to width loop 
        if ldb(i+1).busy = '0' then 
          ldb(i+1).busy <= '1';
          ldb(i+1).opcode <= opcode;
          ldb(i+1).funct3 <= funct3;

          ldb(i+1).base.so <= base_value;
          ldb(i+1).base.v <= '1';
          ldb(i+1).base_waiting_cdb <= base_waiting_cdb;
          ldb(i+1).offset <= se_i_imm;
          fu <= std_logic_vector(unsigned(i),XLEN); -- Return the position to put it in the reservation status
          exit L2;
        end if;
      end loop L1;
    end if;

    L2 : for i in 0 to width loop
      if ldb(i+1).base.v = '1' and ldb(i+1).busy = '1' and ldb(i+1).base_waiting_cdb = zeros then 
        opcode_out <= ldb(i+1).opcode;
        funct3_out <= ldb(i+1).funct3; 
        address    <= ldb(i+1).address;
        valid_out  <= '1';
      else  
      end if;
    end loop L2;
  end if;
end process;
end architecture;