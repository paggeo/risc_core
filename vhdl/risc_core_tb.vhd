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
  type instruction_ram is array (0 to 25) of std_logic_vector(XLEN-1 downto 0);

  -----------------------------------------------------------------------
  -- Function to generate custom input_data
  function test_register_imm return instruction_ram is
    variable result : instruction_ram;
    begin 
        -- Is it compiler responsible for nops or the core must implement the stalling in the pipeline ?
				result(0) := "000000001010" & "00001" & "000" & "00001" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x1, x1 , 10 
				result(1) := "000000001010" & "00001" & "000" & "01110" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x14, x1 , 10 
				result(2) := "000000001010" & "01110" & "000" & "01111" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x15, x14 , 10 

				result(3) := "000000000111" & "00001" & "111" & "10000" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- andi x16, x1 , 0b0111 
				result(4) := "000000000111" & "00001" & "110" & "10001" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- ori  x17, x1 , 0b0111 
				result(5) := "000000000111" & "00001" & "100" & "10010" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- xori x18, x1 , 0b0111 

				result(6) := "000000001001" & "00001" & "010" & "10011" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7) -- slti x19, x1 , 9 
				result(7) := "000000001011" & "00001" & "010" & "10100" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- slti x20, x1 , 11 

				result(8) := "111111110111" & "00001" & "010" & "10011" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7) -- slti x19, x1 , -9 
				result(9) := "111111110101" & "00001" & "010" & "10100" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- slti x20, x1 , -11 
				result(10) := "111111110111" & "00001" & "011" & "10011" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7) --sltui x19, x1 ,-9|4087 
				result(11) := "111111110101" & "00001" & "011" & "10100" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)--sltui x20, x1 ,-11|4085 

				result(12) := "000000001010" & "00010" & "000" & "00010" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x2, x2 , 10 
				result(13) := "000000000010" & "00010" & "001" & "00011" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- slli x3, x2 , 2 
				result(14) := "000000000010" & "00010" & "101" & "00100" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- srli x4, x2 , 2 
				result(15) := "000000000010" & "00110" & "101" & "00101" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- srli x5, x6 , 2 
				result(16) := "010000000010" & "00110" & "101" & "00111" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- srai x7, x6 , 2 

        -- for srai to test change in the reset the x6 to be (others=>'1');
        return result;
  end function test_register_imm;  

  function test_register_register return instruction_ram is
    variable result : instruction_ram;
    begin 
        -- Is it compiler responsible for nops or the core must implement the stalling in the pipeline ?
				result(0) := "000000001010" & "00000" & "000" & "00001" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x1, x0 , 10 | x0 = zero 
				result(1) := "000000000101" & "00000" & "000" & "00010" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x2, x0 , 5 | x0 = zero
				result(2) := "0000000" & "00010" & "00001" & "000" & "00011" & "0110011"; -- funct7(7) & rs2 (5)& & rs1(5) & funct3(3) & rd(5) & opcode(7)-- add x3, x1 , x2 
				result(3) := "0100000" & "00010" & "00001" & "000" & "00100" & "0110011"; -- funct7(7) & rs2 (5)& & rs1(5) & funct3(3) & rd(5) & opcode(7)-- sub x4, x1 , x2 
				result(4) := "0000000" & "00010" & "00001" & "010" & "00101" & "0110011"; -- funct7(7) & rs2 (5)& & rs1(5) & funct3(3) & rd(5) & opcode(7)-- slt x5, x1 , x2 
				result(5) := "0000000" & "00001" & "00010" & "010" & "10110" & "0110011"; -- funct7(7) & rs2 (5)& & rs1(5) & funct3(3) & rd(5) & opcode(7)-- slt x22, x2 , x1 
  

				result(6) := "000000000010" & "00000" & "000" & "00010" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x2, x0 , 2 | x0 = zero

				result(7) := "0000000" & "00010" & "00001" & "001" & "00111" & "0110011"; -- funct7(7) & rs2 (5)& & rs1(5) & funct3(3) & rd(5) & opcode(7)-- sll x7, x1 , x2 
				result(8) := "0000000" & "00010" & "00001" & "101" & "01000" & "0110011"; -- funct7(7) & rs2 (5)& & rs1(5) & funct3(3) & rd(5) & opcode(7)-- srl x8, x1 , x2 
				result(9) := "0100000" & "00010" & "00110" & "101" & "01001" & "0110011"; -- funct7(7) & rs2 (5)& & rs1(5) & funct3(3) & rd(5) & opcode(7)-- sra x9, x6 , x2 
        -- for srai to test change in the reset the x6 to be (others=>'1');

				result(10) := "000000000111" & "00000" & "000" & "00010" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x2, x0 , 7 | x0 = zero
				result(11) := "0000000" & "00010" & "00001" & "111" & "01010" & "0110011"; -- funct7(7) & rs2 (5)& & rs1(5) & funct3(3) & rd(5) & opcode(7)-- add x10, x1 , x2 
				result(12) := "0000000" & "00010" & "00001" & "110" & "01011" & "0110011"; -- funct7(7) & rs2 (5)& & rs1(5) & funct3(3) & rd(5) & opcode(7)-- or x11, x1 , x2 
				result(13) := "0000000" & "00010" & "00001" & "100" & "01100" & "0110011"; -- funct7(7) & rs2 (5)& & rs1(5) & funct3(3) & rd(5) & opcode(7)-- xor x12, x1 , x2 

				result(14) := "111111110111" & "00000" & "000" & "00010" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x2, x0 , -9|4087 | x0 = zero
				result(15) := "0000000" & "00010" & "00001" & "011" & "01101" & "0110011"; -- funct7(7) & rs2 (5)& & rs1(5) & funct3(3) & rd(5) & opcode(7)-- sltu x13, x1 , x2 --1
				result(16) := "0000000" & "00001" & "00010" & "011" & "01101" & "0110011"; -- funct7(7) & rs2 (5)& & rs1(5) & funct3(3) & rd(5) & opcode(7)-- sltu x13, x2 , x1 --0
				result(17) := "0000000" & "00010" & "00001" & "010" & "01101" & "0110011"; -- funct7(7) & rs2 (5)& & rs1(5) & funct3(3) & rd(5) & opcode(7)-- slt x13, x1 , x2 --0 
				result(18) := "0000000" & "00001" & "00010" & "010" & "01101" & "0110011"; -- funct7(7) & rs2 (5)& & rs1(5) & funct3(3) & rd(5) & opcode(7)-- slt x13, x2 , x1 --1
        return result;
  end function test_register_register;  

  function test_load_register return instruction_ram is
    variable result : instruction_ram;
    begin 
        -- Is it compiler responsible for nops or the core must implement the stalling in the pipeline ?
				result(0) := "000000001010" & "00000" & "000" & "00001" & "0000011"; -- imm(12)|(memory offset) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- lb x1, 10(x0) -- ram starts form 0x0 instead of 0x80000
				result(1) := "000000001011" & "00000" & "000" & "00010" & "0000011"; -- imm(12)|(memory offset) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- lb x2, 11(x0) -- ram starts form 0x0 instead of 0x80000
				result(2) := "000000000011" & "00001" & "000" & "00011" & "0000011"; -- imm(12)|(memory offset) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- lb x3, 3(x1) -- ram starts form 0x0 instead of 0x80000
				result(2) := "000000110010" & "00000" & "000" & "00100" & "0000011"; -- imm(12)|(memory offset) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- lb x4, 50(x0) -- ram starts form 0x0 instead of 0x80000
				result(3) := "000000110010" & "00000" & "100" & "00101" & "0000011"; -- imm(12)|(memory offset) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- lbu x5, 50(x0) -- ram starts form 0x0 instead of 0x80000
				result(4) := "000000110010" & "00000" & "001" & "00110" & "0000011"; -- imm(12)|(memory offset) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- lh x6, 50(x0) -- ram starts form 0x0 instead of 0x80000
				result(5) := "000000110010" & "00000" & "101" & "00111" & "0000011"; -- imm(12)|(memory offset) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- lhu x7, 50(x0) -- ram starts form 0x0 instead of 0x80000
				result(6) := "000000110010" & "00000" & "010" & "01000" & "0000011"; -- imm(12)|(memory offset) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- lw x7, 50(x0) -- ram starts form 0x0 instead of 0x80000
        return result;
  end function test_load_register;  

  function test_store_register return instruction_ram is
    variable result : instruction_ram;
    begin 
        -- Is it compiler responsible for nops or the core must implement the stalling in the pipeline ?
				result(0) := "000000000011" & "00000" & "000" & "00001" & "0000011"; -- imm(12)|(memory offset) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- lb x1, 3(x0) -- ram starts form 0x0 instead of 0x80000
				result(1) := "000000001010" & "00001" & "000" & "00001" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x1, x1 , 10 
				result(2) := "0000000" & "00001" & "00000" & "000" & "01010" & "0100011"; -- imm(7) & rs2(5) & rs1(5) & funct3(3) & imm(5) & opcode(7)-- sb x1|rs2, 10(x0|rs1) -- ram starts form 0x0 instead of 0x80000
				result(3) := "0000001" & "00001" & "00000" & "000" & "01010" & "0100011"; -- imm(7) & rs2(5) & rs1(5) & funct3(3) & imm(5) & opcode(7)-- sb x1|rs2, 42(x0|rs1) -- ram starts form 0x0 instead of 0x80000

				result(4) := "000000001010" & "00001" & "000" & "00001" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x1, x1 , 10 
				result(5) := "0000000" & "00001" & "00000" & "000" & "01010" & "0100011"; -- imm(7) & rs2(5) & rs1(5) & funct3(3) & imm(5) & opcode(7)-- sb x1|rs2, 10(x0|rs1) -- ram starts form 0x0 instead of 0x80000
				result(6) := "0000001" & "00001" & "00000" & "000" & "01010" & "0100011"; -- imm(7) & rs2(5) & rs1(5) & funct3(3) & imm(5) & opcode(7)-- sb x1|rs2, 42(x0|rs1) -- ram starts form 0x0 instead of 0x80000

				result(7) := "0000000" & "00001" & "00000" & "001" & "01010" & "0100011"; -- imm(7) & rs2(5) & rs1(5) & funct3(3) & imm(5) & opcode(7)-- sh x1|rs2, 10(x0|rs1) -- ram starts form 0x0 instead of 0x80000
				result(8) := "0000001" & "00001" & "00000" & "001" & "01010" & "0100011"; -- imm(7) & rs2(5) & rs1(5) & funct3(3) & imm(5) & opcode(7)-- sh x1|rs2, 42(x0|rs1) -- ram starts form 0x0 instead of 0x80000

				result(9) := "0000000" & "00001" & "00000" & "010" & "01010" & "0100011"; -- imm(7) & rs2(5) & rs1(5) & funct3(3) & imm(5) & opcode(7)-- sw x1|rs2, 10(x0|rs1) -- ram starts form 0x0 instead of 0x80000
				result(10) := "0000001" & "00001" & "00000" & "010" & "01010" & "0100011"; -- imm(7) & rs2(5) & rs1(5) & funct3(3) & imm(5) & opcode(7)-- sw x1|rs2, 42(x0|rs1) -- ram starts form 0x0 instead of 0x80000
        
        return result;
  end function test_store_register;  

  function test_branch_register return instruction_ram is
    variable result : instruction_ram;
    begin 
        -- Is it compiler responsible for nops or the core must implement the stalling in the pipeline ?
				result(0) := "000000000011" & "00000" & "000" & "00001" & "0000011"; -- imm(12)|(memory offset) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- lb x1, 3(x0) -- ram starts form 0x0 instead of 0x80000
				result(1) := "000000001010" & "00001" & "000" & "00001" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x1, x1 , 10 
				result(2) := "000000001101" & "00010" & "000" & "00010" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x2, x2 , 13 

				result(3) := "0000001" & "00010" & "00001" & "000" & "10000" & "1100011"; -- imm(12|10:5) & rs2(5) & rs1(5) & funct3(3) & imm(4:1|11) & opcode(7)-- beq x1,x2, 0x30 (all jumps are relative pc+0x30)
				result(4) := "000000000001" & "00010" & "000" & "00010" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x2, x2 , 1 

				result(5) := "0000001" & "00010" & "00001" & "001" & "10100" & "1100011"; -- imm(12|10:5) & rs2(5) & rs1(5) & funct3(3) & imm(4:1|11) & opcode(7)-- bne x1,x2, 0x34 (all jumps are relative pc+0x34)
				result(6) := "1111111" & "00010" & "00001" & "001" & "11101" & "1100011"; -- imm(12|10:5) & rs2(5) & rs1(5) & funct3(3) & imm(4:1|11) & opcode(7)-- bne x1,x2, -4 (all jumps are relative pc+(-4)
        
        return result;
  end function test_branch_register;  

  function test_jump return instruction_ram is
    variable result : instruction_ram;
    begin 
        -- Is it compiler responsible for nops or the core must implement the stalling in the pipeline ?
				result(0) := "000000000011" & "00000" & "000" & "00001" & "0000011"; -- imm(12)|(memory offset) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- lb x1, 3(x0) -- ram starts form 0x0 instead of 0x80000
				result(1) := "000000001010" & "00001" & "000" & "00001" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x1, x1 , 10 

				--result(2) := "000000001010" & "00001" & "000" & "00010" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- j, r2, 0x30
				--result(3) := "000000001010" & "00001" & "000" & "00010" & "0010011"; -- imm(20) & rd(5) & opcode(7)-- jal, r2, -4
				--result(3) := "000000001010" & "00001" & "000" & "00001" & "0010011"; -- imm(12) & rs1(5) & funct3(3) & rd(5) & opcode(7)-- addi x1, x1 , 10 
        
        return result;
  end function test_jump;  

  function test_add return instruction_ram is 
    variable result: instruction_ram;
    begin 
      result(0) := "00000000000100000010000010000011";
      result(1) := "00000000101000000010000100000011";
      result(2) := "00000000001000001000000110110011";
      result(3) := "01000000001000001000001000110011";
      result(4) := "11111111111000101000001010010011";
      result(5) := "00000000000000011010000110100011";
      return result;
    end function test_add;
  --- Fill custom input_data
  --constant IN_DATA : instruction_ram := test_register_imm;
  --constant IN_DATA : instruction_ram := test_register_register;
  --constant IN_DATA : instruction_ram := test_load_register;
  --constant IN_DATA : instruction_ram := test_store_register;
  --constant IN_DATA : instruction_ram := test_branch_register;
  --constant IN_DATA : instruction_ram := test_jump;
  constant IN_DATA : instruction_ram := test_add;

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
        wait for 3*TIME_DELAY;
        reset <= '1';
        ip_frame <= 0;
        wait for TIME_DELAY;
        reset <= '0';
        --report "Not a real failure. Simulation finished successfully. Test completed successfully" severity failure;
        wait ;
  end process;

end architecture;
