library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package common is
    constant XLEN :integer := 32;
    constant opcode_start :integer := 0;
    constant opcode_end : integer := 6;
    constant funct3_start :integer := 12;
    constant funct3_end :integer := 14;
    constant funct7_start :integer := 25;
    constant funct7_end :integer := 31;

    constant i_imm_start : integer := 20;
    constant i_imm_end : integer := 31;

    constant sb_first_imm_start : integer := 7;
    constant sb_first_imm_end : integer := 11;
    constant sb_second_imm_start : integer := 25;
    constant sb_second_imm_end : integer := 31;

    constant uj_imm_start : integer := 12;
    constant uj_imm_end : integer := 31;
    

    constant rd_start :integer := 7;
    constant rd_end :integer := 11;
    constant rs1_start :integer := 15;
    constant rs1_end :integer := 19;
    constant rs2_start :integer := 20;
    constant rs2_end :integer := 24;

    type reg_file is array(0 to 31) of std_logic_vector(XLEN-1 downto 0);
    subtype opcode_vector is std_logic_vector(opcode_end-opcode_start downto 0);
    subtype funct3_vector is std_logic_vector(funct3_end-funct3_start downto 0);
    subtype funct7_vector is std_logic_vector(funct7_end-funct7_start downto 0);

    -- Every register has 5 bits identification 2^5 = 32 registers
    subtype rd_vector  is std_logic_vector(rd_end-rd_start downto 0); 
    subtype rs1_vector is std_logic_vector(rs1_end-rs1_start downto 0);
    subtype rs2_vector is std_logic_vector(rs2_end-rs2_start downto 0);
    -- IM vectors 
    subtype i_imm_vector is std_logic_vector(i_imm_end-i_imm_start downto 0);
    subtype sb_first_imm_vector is std_logic_vector(sb_first_imm_end-sb_first_imm_start downto 0);
    subtype sb_second_imm_vector is std_logic_vector(sb_second_imm_end-sb_second_imm_start downto 0);
    subtype uj_imm_vector is std_logic_vector(uj_imm_end-uj_imm_start downto 0);


    -- Harvard Architecture
    constant i_ram_size : integer := 15;
    constant d_ram_size : integer := 15;
    -- Instruction ram 
    type instruction_ram is array(0 to i_ram_size) of std_logic_vector(XLEN-1 downto 0);
    -- Data Ram 
    type data_ram is array(0 to d_ram_size) of std_logic_vector(XLEN-1 downto 0);
    

    function data_ram_fillup return data_ram;
    function instruction_ram_fillup return instruction_ram;
    function registers_fillup return reg_file;
    --constant dram : data_ram := data_ram_fillup;
end package;

package body common is
  function instruction_ram_fillup return instruction_ram is 
    variable ram : instruction_ram := (others=>(others=>'0'));
    variable index: std_logic_vector(XLEN-1 downto 0) := (others=>'0');
    begin 
       ram(0) := "00000000001000001000000110110011";
       ram(1) := "01000000000100010000001000110011";
       ram(2) := "00000000010100010000001010010011";
       ram(3) := "00000000010000101010001100000011";
       ram(4) := "00000000010000000010000110000011";
       ram(5) := "00000000011000000010001000100011";
       ram(6) := "11111111110111111111011111101111";
    return ram;
  end function;
  
  function registers_fillup return reg_file is 
    variable registers : reg_file := (others=>(others=>'0'));
    variable index: std_logic_vector(XLEN-1 downto 0) := (others=>'0');
    begin 
       registers(1) := "00000000000000000000000000000001";
       registers(2) := "00000000000000000000000000000010";
       registers(3) := "00000000000000000000000000000011";
    return registers;
  end function;

  function data_ram_fillup return data_ram is 
    variable index : std_logic_vector(XLEN-1 downto 0) := (others=>'0');

    variable ram : data_ram := (others=>(others=>'0'));

    begin 
      for ii in 0 to d_ram_size-1 loop
        ram(ii) := index + index;
        index := index + 1;
      end loop;
      ram(d_ram_size) := "11101110111111110111111101111111"; -- this is used for testing 

      return ram;
  end function;

end package body common;
