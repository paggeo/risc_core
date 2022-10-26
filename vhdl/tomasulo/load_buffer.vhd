library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;


entity load_buffer is 
generic (
  width : integer := 3
);
port(
  clock : in std_logic;
  valid_in : in std_logic;
  opcode  : in opcode_vector;
  funct3  : in funct3_vector;
  base_waiting_cdb    : in std_logic_vector(XLEN-1 downto 0);
  base_valid  : in std_logic;
  base_value  : in std_logic_vector(XLEN-1 downto 0);
  se_i_imm : in std_logic_vector(XLEN-1 downto 0); -- Sign-Extented imm
   -- Common Data Bus
  cdb_data_out    : in std_logic_vector(XLEN-1 downto 0);
  cdb_source_out  : in std_logic_vector(XLEN-1 downto 0);
  cdb_valid_out   : in std_logic;

  opcode_out  : out opcode_vector;
  funct3_out      : out funct3_vector;
  address_out     : out std_logic_vector(XLEN-1 downto 0);
  -- Try to add destination to that to get straight to the register status
  position_in_ldb : out integer;
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
  opcode     : opcode_vector;
  funct3 : funct3_vector;
  base : valid_load;
  base_waiting_cdb : std_logic_vector(XLEN-1 downto 0);
  offset: std_logic_vector(XLEN-1 downto 0);
end record;

constant vl_zero  : valid_load :=
( so => (others=>'0'), v => '0');
constant ldb_zero : load_buffer_type :=
(busy   => '0',
opcode     => (others=>'0'),
funct3 => (others=>'0'),
base => vl_zero,
base_waiting_cdb => (others=>'0'),
offset => (others=>'0')
);
type load_buffer_array is array(natural range <>) of load_buffer_type;
signal ldb : load_buffer_array(1 to width+1) := (others=>ldb_zero);
signal zeros : std_logic_vector(XLEN-1 downto 0):= (others=>'0');
begin 

main : process(clock)
begin 
  -- Store
  if rising_edge(clock) then 
    position_in_ldb <= 0;
    if valid_in = '1' then 
      L1 : for i in 0 to width loop 
        if ldb(i+1).busy = '0' then 
          ldb(i+1).busy <= '1';
          ldb(i+1).opcode <= opcode;
          ldb(i+1).funct3 <= funct3;

          if base_waiting_cdb = cdb_source_out then 
            -- This is if the broadcasting happend in a time when we load the 
            -- a new instruction
            ldb(i+1).base.so <= cdb_data_out;
            ldb(i+1).base.v <= '1';
            ldb(i+1).base_waiting_cdb <= (others=>'0');
          else 
            ldb(i+1).base.so <= base_value;
            ldb(i+1).base.v <= base_valid;
            ldb(i+1).base_waiting_cdb <= base_waiting_cdb;
          end if;
          ldb(i+1).offset <= se_i_imm;
          position_in_ldb <= i+1;
          exit L1;
        end if;
      end loop L1;
    end if;

    -- Output
    L2 : for i in 0 to width loop
      if ldb(i+1).base.v = '1' and ldb(i+1).busy = '1' and ldb(i+1).base_waiting_cdb = zeros then 
        ldb(i+1).busy <= '0';
        opcode_out  <= ldb(i+1).opcode;
        funct3_out  <= ldb(i+1).funct3; 
        address_out <= ldb(i+1).offset + ldb(i+1).base.so;
        valid_out   <= '1';
        exit L2;
      else  
        opcode_out  <= (others=>'0');
        funct3_out  <= (others=>'0');
        address_out <= (others=>'0');
        valid_out   <= '0';
      end if;
    end loop L2;

    -- Update
    if cdb_valid_out = '1' then 
      L3: for i in 0 to width loop 
        if ldb(i+1).base_waiting_cdb = cdb_source_out and ldb(i+1).busy = '1' then 
          ldb(i+1).base.v <= '1';
          ldb(i+1).base.so <= cdb_data_out;
          ldb(i+1).base_waiting_cdb <= (others=>'0');
        end if;
      end loop L3;
    end if;
  end if;
end process;
end architecture;