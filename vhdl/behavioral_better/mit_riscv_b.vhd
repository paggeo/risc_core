library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

entity riscv_b_b is 
port(
  clock: in std_logic;
  reset: in std_logic
);
end entity;


architecture rtl of riscv_b_b is 

signal instruction_memory : instruction_ram := instruction_ram_fillup; -- Fill this 

signal pc   : std_logic_vector(XLEN-1 downto 0) := (others=>'0');

signal out_instruction_memory : std_logic_vector(XLEN-1 downto 0) := (others=>'0');

signal alu_enable : std_logic_vector(5 downto 0);
signal write_enable : std_logic ;

component alu_b is 
port (
  clock : in std_logic;
  reg_or_imm : in std_logic; 
  funct3 : in funct3_vector;
  funct7 : in std_logic; 
  a : in std_logic_vector(XLEN-1 downto 0);
  b : in std_logic_vector(XLEN-1 downto 0);
  c : out std_logic_vector(XLEN-1 downto 0)
);
end component; 


component register_file_b is 
port(
  clock : in std_logic;
  reset : in std_logic;
  ra1   : in rd_vector;
  ra2   : in rd_vector;
  rd1   : out std_logic_vector(XLEN-1 downto 0);
  rd2   : out std_logic_vector(XLEN-1 downto 0);
  
  write_address : in rd_vector;
  write_enable  : in std_logic;
  write_data    : in std_logic_vector(XLEN-1 downto 0)
);
end component; 

component control_logic_b is 
port (
  instruction    : in std_logic_vector(XLEN-1 downto 0);
  c_z              : in std_logic;
  c_alu          : out std_logic_vector(4 downto 0);
  c_write_enable : out std_logic;
  c_reg_or_imm_or_sbimm   : out std_logic_vector(1 downto 0);
  c_memory_output_enable  : out std_logic;
  c_memory_write_enable   : out std_logic;
  c_memory_op_type        : out std_logic_vector(2 downto 0); 
  c_pc_select             : out std_logic_vector(1 downto 0);
  c_branch_flag           : out std_logic_vector(2 downto 0);
  c_read_memory_or_alu    : out std_logic_vector(1 downto 0)
);
end component;

component data_memory_b is 
port(
  clock     : in std_logic;
  address   : in std_logic_vector(XLEN-1 downto 0);
  memory_output_enable  : in std_logic;
  memory_write_enable   : in std_logic;
  memory_op_type        : in std_logic_vector(2 downto 0);
  write_data            : in std_logic_vector(XLEN-1 downto 0);
  read_data             : out std_logic_vector(XLEN-1 downto 0)
);
end component; 

component branch_logic_b is
port (
  clock : in std_logic;
  a     : in std_logic_vector(XLEN-1 downto 0);
  b     : in std_logic_vector(XLEN-1 downto 0);
  branch_flag : in std_logic_vector(2 downto 0);
  z     : out std_logic
);
end component;

signal rd1_t : std_logic_vector(XLEN-1 downto 0);
signal rd2_t : std_logic_vector(XLEN-1 downto 0);
signal alu_t : std_logic_vector(XLEN-1 downto 0);
signal read_data_t : std_logic_vector(XLEN-1 downto 0);

signal      opcode : opcode_vector := (others=>'0');
signal      funct3 : funct3_vector := (others=>'0');
signal      funct7 : funct7_vector := (others=>'0');
signal      rd     : rd_vector     := (others=>'0');
signal      rs1    : rs1_vector    := (others=>'0');
signal      rs2    : rs2_vector    := (others=>'0');

signal      i_imm     : i_imm_vector          := (others=>'0');
signal      se_i_imm  : std_logic_vector(XLEN-1 downto 0) := (others=>'0');

signal      sb_first_imm            : sb_first_imm_vector   := (others=>'0');
signal      sb_second_imm           : sb_second_imm_vector  := (others=>'0');
signal      uj_imm                  : uj_imm_vector         := (others=>'0'); 

signal      se_sb_imm               : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
signal      se_sb_first_second_imm  : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
signal      se_uj_imm               : std_logic_vector(XLEN-1 downto 0) := (others=>'0'); 

type opcode_array is array(0 to 4) of opcode_vector;
signal opcode_t : opcode_array:=(others=>(others=>'0'));

type funct3_array is array(0 to 4) of funct3_vector;
signal funct3_t : funct3_array:=(others=>(others=>'0'));

type funct7_array is array(0 to 4) of funct7_vector;
signal funct7_t : funct7_array:=(others=>(others=>'0'));

type rd_array is array(0 to 4) of rd_vector;
signal rd_t : rd_array:=(others=>(others=>'0'));

type rs1_array is array(0 to 4) of rs1_vector;
signal rs1_t : rs1_array:=(others=>(others=>'0'));

type rs2_array is array(0 to 4) of rs2_vector;
signal rs2_t : rs2_array:=(others=>(others=>'0'));

type se_i_imm_array is array(0 to 4) of std_logic_vector(XLEN-1 downto 0);
signal se_i_imm_t : se_i_imm_array:=(others=>(others=>'0'));

type se_sb_imm_array is array(0 to 4) of std_logic_vector(XLEN-1 downto 0);
signal se_sb_imm_t : se_sb_imm_array:=(others=>(others=>'0'));

type se_sb_first_second_imm_array is array(0 to 4) of std_logic_vector(XLEN-1 downto 0);
signal se_sb_first_second_imm_t : se_sb_first_second_imm_array:=(others=>(others=>'0'));

type se_uj_imm_array is array(0 to 4) of std_logic_vector(XLEN-1 downto 0);
signal se_uj_imm_array_t : se_uj_imm_array:=(others=>(others=>'0'));

-- TODO: this needs to be pipelined
-- ALU and register is pipelined 
-- Control Logic is not 

signal c_write_enable : std_logic := '0';
signal c_z            : std_logic := '0';
signal c_alu          : std_logic_vector(4 downto 0) := (others=>'0');
signal c_reg_or_imm_or_sbimm   : std_logic_vector(1 downto 0) := (others=>'0');
signal c_memory_output_enable : std_logic := '0';
signal c_memory_write_enable  : std_logic := '0';
signal c_memory_op_type   : std_logic_vector(2 downto 0) := (others=>'0');
signal c_read_memory_or_alu   : std_logic_vector(1 downto 0) := (others=>'0');
signal c_pc_select            : std_logic_vector(1 downto 0) := (others=>'0');
signal c_branch_flag          : std_logic_vector(2 downto 0) := (others=>'0');

signal second_operand     : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
signal return_operand     : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
signal select_pc_operand  : std_logic_vector(XLEN-1 downto 0) := (others=>'0');
signal ones : std_logic_vector(XLEN-1 downto 0) := (others=>'1');
begin 
  --pc_select_process : process (c_pc_select)
  --begin 
    --case c_pc_select is 
      --when "00" => select_pc_operand <= pc +1;
      --when "01" => select_pc_operand <= pc + se_sb_first_second_imm;
      --when others => second_operand <= (others=>'0');
    --end case;
  --end process;

  pc_process: process(clock, reset,select_pc_operand,c_pc_select)
  begin 
    if rising_edge(clock) then 
      if reset = '1' then 
        pc <= (others=>'1');
      else 
        --pc <= select_pc_operand ; -- Need to change it to pc <= pc+4;
        case c_pc_select is 
          when "00" => pc <= pc +1;
          when "01" => pc <= pc + se_sb_first_second_imm;
          when "10" => pc <= pc + se_uj_imm;
          when others => pc <= (others=>'1');
        end case;
      end if;
    end if;
  end process;

  -- Fetch
  use_pc : process(pc)
  begin
    --if rising_edge(clock) then 
       if pc /= ones then 
        out_instruction_memory <= instruction_memory(to_integer(unsigned(pc)));
      end if;
    --end if;
  end process;
  
  -- Decode and Bring Registers
  opcode <= out_instruction_memory(opcode_end downto opcode_start);
  funct3 <= out_instruction_memory(funct3_end downto funct3_start);
  funct7 <= out_instruction_memory(funct7_end downto funct7_start);

  rd     <= out_instruction_memory(rd_end downto rd_start);
  rs1    <= out_instruction_memory(rs1_end downto rs1_start);
  rs2    <= out_instruction_memory(rs2_end downto rs2_start);
  i_imm  <= out_instruction_memory(i_imm_end downto i_imm_start); -- Load uses this one

  sb_first_imm  <= out_instruction_memory(sb_first_imm_end downto sb_first_imm_start); --- Store uses this one
  sb_second_imm <= out_instruction_memory(sb_second_imm_end downto sb_second_imm_start);
  uj_imm        <= out_instruction_memory(uj_imm_end downto uj_imm_start);

  se_i_imm <= std_logic_vector(resize(signed(i_imm),XLEN));
  se_sb_imm <= std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm & sb_first_imm)),XLEN));
  se_sb_first_second_imm <= std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm(sb_second_imm'length-1) & sb_first_imm(0) & sb_second_imm(sb_second_imm'length-2 downto 0) & sb_first_imm(sb_first_imm'length-1 downto 1) & '0')),XLEN));
  se_uj_imm <=  std_logic_vector(resize(signed(std_logic_vector'(uj_imm(19) & uj_imm(7 downto 0) & uj_imm(8) & uj_imm(18 downto 9) & '0')),XLEN));
  
  control_logic_module : control_logic_b
    port map(
      instruction     => out_instruction_memory,
      c_z             => c_z,
      c_alu           => c_alu,
      c_write_enable  => c_write_enable,
      c_reg_or_imm_or_sbimm    => c_reg_or_imm_or_sbimm,
      c_memory_output_enable => c_memory_output_enable,
      c_memory_write_enable => c_memory_write_enable,
      c_memory_op_type      => c_memory_op_type,
      c_pc_select           => c_pc_select,
      c_branch_flag         => c_branch_flag,
      c_read_memory_or_alu  => c_read_memory_or_alu
    );
   
  register_file_module : register_file_b
    port map(
      clock => clock, 
      reset => reset, 
      ra1   => rs1, 
      ra2   => rs2,
      rd1   => rd1_t,
      rd2   => rd2_t,
      write_address   => rd,
      write_enable    => c_write_enable,
      write_data      => return_operand
    );
 
    brach_logic_module : branch_logic_b
      port map(
        clock => clock, 
        a => rd1_t,
        b => rd2_t, 
        branch_flag => c_branch_flag,
        z => c_z 
      );

    second_operand_module : process (c_reg_or_imm_or_sbimm,rd2_t,se_sb_imm,se_i_imm)
    begin 
      case c_reg_or_imm_or_sbimm is 
        when "00" => second_operand <= rd2_t;
        when "01" => second_operand <= se_sb_imm;
        when "11" => second_operand <= se_i_imm; 
        when others => second_operand <= (others=>'0');
      end case;
    end process;
 
  alu_module : alu_b
    port map(
      clock =>clock, 
      reg_or_imm => c_alu(0), 
      funct3 => c_alu(3 downto 1), 
      funct7 => c_alu(4), 
      a => rd1_t, 
      b => second_operand, 
      c => alu_t 
    );

  data_memory_module : data_memory_b
    port map(
      clock => clock,
      address => alu_t,
      memory_output_enable => c_memory_output_enable,
      memory_write_enable => c_memory_write_enable,
      memory_op_type => c_memory_op_type,
      write_data          => rd2_t,
      read_data           => read_data_t
    );

    memory_or_alu_module : process(c_read_memory_or_alu,alu_t,read_data_t)
    begin 
      case c_read_memory_or_alu is 
        when "01" => return_operand <= alu_t;
        when "10" => return_operand <= read_data_t;
        when "00" => return_operand <= pc + 1;
        when others=> return_operand <= (others=>'0');
      end case;
    end process;

end architecture;
