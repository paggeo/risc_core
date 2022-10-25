library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

entity reservation_station_tb is 
end entity;


architecture testbench of reservation_station_tb is 

-----------------------------------------------------------------------
  -- Component
  -----------------------------------------------------------------------
component reservation_station is 
generic ( 
  width : integer := 3
);
port(
  clock       : in std_logic;
  valid_in    : in std_logic;
  op_in       : in opcode_vector;
  funct3_in   : in funct3_vector;
  funct7_in   : in funct7_vector;
  rs1_s         : in std_logic_vector(XLEN-1 downto 0);  
  rs2_s         : in std_logic_vector(XLEN-1 downto 0);  

  rs1_q         : in std_logic_vector(XLEN-1 downto 0);  
  rs2_q         : in std_logic_vector(XLEN-1 downto 0);  
  rs1_v         : in std_logic;
  rs2_v         : in std_logic;
  
  cdb_data_out    : in std_logic_vector(XLEN-1 downto 0);
  cdb_source_out  : in std_logic_vector(XLEN-1 downto 0);
  cdb_valid_out   : in std_logic;

  rd1         : out std_logic_vector(XLEN-1 downto 0);  
  rd2         : out std_logic_vector(XLEN-1 downto 0);  
  op_out      : out opcode_vector;
  funct3_out  : out funct3_vector;
  funct7_out  : out funct7_vector;
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
  signal clock    : std_logic;
	signal valid_in : std_logic := '0'; 
  signal op_in   : opcode_vector := (others=>'0');
  signal funct3_in   : funct3_vector := (others=>'0');
  signal funct7_in   : funct7_vector := (others=>'0');

  signal rs1_s  : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
  signal rs2_s  : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
  signal rs1_q  : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
  signal rs2_q  : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
  signal rs1_v  : std_logic :='0';
  signal rs2_v  : std_logic :='0';

  signal cdb_data_out : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
  signal cdb_source_out : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
  signal cdb_valid_out : std_logic := '0';

  -- Output signals 
  signal rd1  : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
  signal rd2  : std_logic_vector(XLEN-1 downto 0) := (others=>'0');

  signal op_out   : opcode_vector := (others=>'0');
  signal funct3_out   : funct3_vector := (others=>'0');
  signal funct7_out   : funct7_vector := (others=>'0');
	signal valid_out : std_logic := '0'; 

  signal ip_frame : integer := 0;

  begin 
  dut : reservation_station 
    port map(
      clock   => clock,
      valid_in => valid_in,
      op_in => op_in,
      funct3_in => funct3_in,
      funct7_in => funct7_in, 
      rs1_s => rs1_s,
      rs2_s => rs2_s,
      rs1_q => rs1_q,
      rs2_q => rs2_q,
      rs1_v => rs1_v,
      rs2_v => rs2_v,
      cdb_data_out => cdb_data_out,
      cdb_source_out => cdb_source_out,
      cdb_valid_out => cdb_valid_out,
      rd1 => rd1, 
      rd2 => rd2,
      op_out => op_out,
      funct3_out => funct3_out,
      funct7_out => funct7_out,
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
    valid_in <= '1';
    op_in <= std_logic_vector(to_unsigned(4,7));
    funct3_in <= std_logic_vector(to_unsigned(6,3)); 
    funct7_in <= std_logic_vector(to_unsigned(7,7)); 
    rs1_s <= std_logic_vector(to_unsigned(15,32));
    rs2_s <= std_logic_vector(to_unsigned(0,32));
    rs1_q <= std_logic_vector(to_unsigned(0,32));
    rs2_q <= std_logic_vector(to_unsigned(9,32));
    rs1_v <= '1';
    rs2_v <= '0';

    cdb_data_out <= (others=>'0');
    cdb_source_out <= (others=>'0');
    cdb_valid_out <= '0';

    ip_frame <= 1;
    wait for TIME_DELAY;
    funct7_in <= std_logic_vector(to_unsigned(8,7)); 
    rs2_q <= std_logic_vector(to_unsigned(10,32));
    wait for TIME_DELAY;
    funct7_in <= std_logic_vector(to_unsigned(9,7)); 
    rs2_q <= std_logic_vector(to_unsigned(9,32));
    wait for TIME_DELAY;
    -------------------------------------------------------------------------------------
    valid_in <= '0';
    op_in <= std_logic_vector(to_unsigned(4,7));
    funct3_in <= std_logic_vector(to_unsigned(6,3)); 
    funct7_in <= std_logic_vector(to_unsigned(7,7)); 
    rs1_s <= std_logic_vector(to_unsigned(15,32));
    rs2_s <= std_logic_vector(to_unsigned(0,32));
    rs1_q <= std_logic_vector(to_unsigned(0,32));
    rs2_q <= std_logic_vector(to_unsigned(9,32));
    rs1_v <= '1';
    rs2_v <= '0';

    cdb_data_out <= std_logic_vector(to_unsigned(9,32)); 
    cdb_source_out <= std_logic_vector(to_unsigned(9,32));
    cdb_valid_out <= '1';

    ip_frame <= 2;
    wait for TIME_DELAY;
    -------------------------------------------------------------------------------------
    valid_in <= '0';
    op_in <= (others=>'0');
    funct3_in <= (others=>'0');
    funct7_in <= (others=>'0');
    rs1_s <= (others=>'0');
    rs2_s <= (others=>'0');
    rs1_q <= (others=>'0');
    rs2_q <= (others=>'0');
    rs1_v <= '0';
    rs2_v <= '0';

    cdb_data_out <= (others=>'0');
    cdb_source_out <= (others=>'0');
    cdb_valid_out <= '0';

    ip_frame <= 0;
    wait;

  end process;
end architecture;