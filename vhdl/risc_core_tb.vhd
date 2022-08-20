library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

library work;
use work.common.all;

entity risc_v_core_tb is 
end entity;


architecture testbench of risc_v_core_tb is 

  -----------------------------------------------------------------------
  -- Component
  -----------------------------------------------------------------------
 component risc_v_core is
	 port (
		 clock : in std_logic;
		 reset : in std_logic;
		 instruction : in std_logic_vector(XLEN-1 downto 0 );
		 pc_out : out std_logic_vector(XLEN-1 downto 0)
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

  -- General signals
  signal clock                        : std_logic := '0';  -- the master clock
  signal reset                        : std_logic := '0';  -- reset point


  -- Input signals 
	signal instruction : std_logic_vector(XLEN-1 downto 0);

  -- Output signals 
	signal pc_out : std_logic_vector(XLEN-1 downto 0);
	-- Input testbench
     type instruction_ram is array (0 to 20) of std_logic_vector(XLEN-1 downto 0);

  -----------------------------------------------------------------------
  -- Function to generate custom input_data
  function custom_ip_table return instruction_ram is
    variable result : instruction_ram;
    begin 
				result(0) := "000000001010" & "00001" & "000"& "00001"& "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x1, x1 , 10 
				result(1) := "000000001010" & "00001" & "000"& "01110"& "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x14, x1 , 10 
				result(2) := "000000001010" & "01110" & "000"& "01111"& "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x15, x14 , 10 
				result(3) := "00000000000000000000000000000000";
				result(4) := "00000000000000000000000000000000";
				result(5) := "00000000000000000000000000000000";
				result(6) := "00000000000000000000000000000000";
				result(7) := "00000000000000000000000000000000";

        return result;
  end function custom_ip_table;  

  --- Fill custom input_data
  constant IN_DATA : instruction_ram := custom_ip_table;
  -- Save frame number 
  signal ip_frame : integer := 0;
  
  begin
    dut: risc_v_core
        port map(
            clock => clock,
            reset => reset,
      		instruction => instruction,
            pc_out => pc_out
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
  
  -----------------------------------------------------------------------
  -- Generate data slave channel inputs
  -----------------------------------------------------------------------

  simulation : process
    procedure drive_sample ( data      : std_logic_vector(XLEN-1 downto 0) ) is
    begin
				instruction <= data;
    end procedure drive_sample;
    
    procedure drive_ip ( data       : instruction_ram ) is
        variable samples : integer;
        variable index   : integer;
    begin
    samples := data'length;
    index  := 0;
    while index < data'length loop
        drive_sample(data(index));
        ip_frame <= index;
        index := index + 1;
        wait for TIME_DELAY;
    end loop;

    end procedure drive_ip;

    begin 
        wait for TIME_DELAY;
        reset <= '1';
        wait for TIME_DELAY;
        reset <= '0';
        drive_ip(IN_DATA);
        wait for TIME_DELAY;
        reset <= '1';
        ip_frame <= 0;
        wait for TIME_DELAY;
        reset <= '0';
        --report "Not a real failure. Simulation finished successfully. Test completed successfully" severity failure;
        wait ;
  end process;

end architecture;
