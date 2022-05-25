library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

-- Simple risc_v_core RV32I base integer instruction set
entity risc_v_core_simple is
    port (
        clock : in std_logic;
        reset : in std_logic;
        instruction : in std_logic_vector(XLEN-1 downto 0 );
        pc : out std_logic_vector(XLEN-1 downto 0)
    );
end entity;

architecture rtl of risc_v_core_simple is 

    signal      registers : reg_file:= (others=>(others=>'0'));
    constant    zero : std_logic_vector(XLEN-1 downto 0) :=(others=>'0');
    signal      opcode : opcode_vector := (others=>'0');
    signal      funct3 : funct3_vector := (others=>'0');
    signal      funct7 : funct7_vector := (others=>'0');

    begin 

    registers(0) <= zero;  -- x0 constant zero

    main : process(clock,reset)
        begin 
            if rising_edge(clock) then 
                if reset = '1' then 
                    pc <= (others=>'0');
                    registers <= (others=> (others=> '0'));
                else 
                  pc <= pc + 1;
                  -- fetch  
                  opcode <= instruction(opcode_end downto opcode_start);
                  funct3 <= instruction(funct3_end downto funct3_start);
                  funct7 <= instruction(funct7_end downto funct7_start);

                  -- Decode

                  if    (opcode = "0110111") then -- LUI
                  elsif (opcode = "0010111") then -- AUIPC
                  elsif (opcode = "1101111") then -- JAL
                  elsif (opcode = "1100111") then -- JALR
                  elsif (opcode = "1100011") then -- BEQ, BNE, BLT, BGE, BLTU, BGEU
                    if    (funct3 = "000") then -- BEQ
                    elsif (funct3 = "001") then -- BNE
                    elsif (funct3 = "100") then -- BLT
                    elsif (funct3 = "101") then -- BGE
                    elsif (funct3 = "110") then -- BLTU
                    elsif (funct3 = "111") then -- BGEU
                    end if;
                  elsif (opcode = "0000011") then -- LB, LH, LW, LBU, LHU
                    if    (funct3 = "000") then -- LB
                    elsif (funct3 = "001") then -- LH
                    elsif (funct3 = "010") then -- LW
                    elsif (funct3 = "100") then -- LBU
                    elsif (funct3 = "101") then -- LHU
                    end if;
                  elsif (opcode = "0100011") then -- SB, SH, SW
                    if    (funct3 = "000") then -- SB
                    elsif (funct3 = "001") then -- SH
                    elsif (funct3 = "010") then -- SW
                    end if;
                  elsif (opcode = "0010011") then -- ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
                    if    (funct3 = "000") then -- ADDI
                    elsif (funct3 = "010") then -- SLTI
                    elsif (funct3 = "011") then -- SLTIU
                    elsif (funct3 = "100") then -- XORI
                    elsif (funct3 = "110") then -- ORI
                    elsif (funct3 = "111") then -- ANDI
                    elsif (funct3 = "001") then -- SLLI 
                    elsif (funct3 = "101") then -- SRLI, SRAI 
                    end if;
                  elsif (opcode = "0110011") then -- ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
                    if    (funct3 = "000") then -- ADD, SUB
                    elsif (funct3 = "001") then -- SLL
                    elsif (funct3 = "010") then -- SLT
                    elsif (funct3 = "011") then -- SLTU
                    elsif (funct3 = "100") then -- XOR
                    elsif (funct3 = "101") then -- SRL, SRA
                    elsif (funct3 = "110") then -- OR
                    elsif (funct3 = "111") then -- AND
                    end if;
                  elsif (opcode = "0001111") then -- FENCE
                  elsif (opcode = "1110011") then -- ECALL
                  elsif (opcode = "0001111") then -- EBREAK
                  end if;
                end if; 
            end if;
    end process;

end architecture; 
