library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

entity load_buffer_tb is 
end entity;


architecture rtl of load_buffer_tb is 

  -----------------------------------------------------------------------
  -- Component
  -----------------------------------------------------------------------

component load_buffer is 
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
  position_in_ldb : out integer;
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
  signal clock : std_logic := '0'; 
  signal valid_in : std_logic := '0'; 
  signal opcode : opcode_vector := (others=>'0'); 
  signal funct3 : funct3_vector := (others=>'0'); 
  signal base_waiting_cdb : std_logic_vector(XLEN-1 downto 0) := (others=>'0'); 
  signal base_valid : std_logic := '0'; 
  signal base_value : std_logic_vector(XLEN-1 downto 0) := (others=>'0'); 
  signal se_i_imm : std_logic_vector(XLEN-1 downto 0) := (others=>'0'); 

  signal cdb_data_out : std_logic_vector(XLEN-1 downto 0) := (others=>'0'); 
  signal cdb_source_out : std_logic_vector(XLEN-1 downto 0) := (others=>'0'); 
  signal cdb_valid_out : std_logic := '0';

  -- Output signals 
  signal opcode_out : opcode_vector := (others=>'0'); 
  signal funct3_out : funct3_vector := (others=>'0'); 
  signal address_out : std_logic_vector(XLEN-1 downto 0) := (others=>'0'); 
  signal position_in_ldb : integer := 0; 
  signal valid_out : std_logic := '0'; 

  signal ip_frame : integer := 0;

  begin 
  dut : load_buffer 
    port map(
      clock => clock,
      valid_in => valid_in,
      opcode => opcode,
      funct3 => funct3,
      base_waiting_cdb => base_waiting_cdb,
      base_valid => base_valid,
      base_value => base_value,
      se_i_imm => se_i_imm,
      cdb_data_out => cdb_data_out,
      cdb_source_out => cdb_source_out,
      cdb_valid_out => cdb_valid_out,
      opcode_out => opcode_out,
      funct3_out => funct3_out,
      address_out => address_out,
      position_in_ldb => position_in_ldb,
      valid_out => valid_out
    );

  -----------------------------------------------------------------------
  -- Generate clock
  -----------------------------------------------------------------------
  generate_clock : process
  begin
    clock <= '0';
    wait for clock_period/2;
    clock <= '1';
    wait for clock_period/2;
  end process;

  simulation : process 
  begin 
   wait for TIME_DELAY;
    -------------------------------------------------------------------------------------
    valid_in <= '1';
    opcode <= std_logic_vector(to_unsigned(8,7));
    funct3 <= std_logic_vector(to_unsigned(3,3));
    
    base_waiting_cdb <= std_logic_vector(to_unsigned(15,32));  
    base_valid <= '0';
    base_value <= std_logic_vector(to_unsigned(0,32)); 
    se_i_imm <= std_logic_vector(to_unsigned(28,32));  
    cdb_data_out <= (others=>'0');
    cdb_source_out <= (others=>'0');
    cdb_valid_out <= '0';

    ip_frame <= 1;
   wait for TIME_DELAY;
    -------------------------------------------------------------------------------------
    opcode <= std_logic_vector(to_unsigned(2,7)); 
    funct3 <= std_logic_vector(to_unsigned(3,3));
    
    base_waiting_cdb <= std_logic_vector(to_unsigned(15,32));  
    se_i_imm <= std_logic_vector(to_unsigned(23,32));  
    ip_frame <= 2;
   wait for TIME_DELAY;
    -------------------------------------------------------------------------------------
    opcode <= std_logic_vector(to_unsigned(2,7)); 
    funct3 <= std_logic_vector(to_unsigned(3,3)); 
    
    base_waiting_cdb <= std_logic_vector(to_unsigned(12,32));  
    ip_frame <= 2;
   wait for TIME_DELAY;
    -------------------------------------------------------------------------------------
    valid_in <= '1';
    opcode <= std_logic_vector(to_unsigned(2,7));  
    funct3 <= std_logic_vector(to_unsigned(2,3)); 
    
    base_waiting_cdb <= std_logic_vector(to_unsigned(15,32)); 
    base_valid <= '0';
    base_value <= std_logic_vector(to_unsigned(0,32)); 
    se_i_imm <= std_logic_vector(to_unsigned(7,32)); 

    cdb_data_out <= std_logic_vector(to_unsigned(6,32));
    cdb_source_out <= std_logic_vector(to_unsigned(15,32));

    cdb_valid_out <= '1';

    ip_frame <= 3;
   wait for TIME_DELAY;
    -------------------------------------------------------------------------------------
    valid_in <= '0';
    opcode <= (others=>'0');
    funct3 <= (others=>'0');
    
    base_waiting_cdb <= (others=>'0');
    base_valid <= '0';
    base_value <= (others=>'0');
    se_i_imm <= (others=>'0');
    cdb_data_out <= (others=>'0');
    cdb_source_out <= (others=>'0');
    cdb_valid_out <= '0';

    ip_frame <= 0;
    wait;

  end process;
    
end architecture;