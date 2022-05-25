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

    type reg_file is array(0 to 31) of std_logic_vector(XLEN-1 downto 0);
    type opcode_vector is std_logic_vector(opcode_end-opcode_start downto 0);
    type funct3_vector is std_logic_vector(opcode_end-opcode_start downto 0);
    type funct7_vector is std_logic_vector(opcode_end-opcode_start downto 0);

end package;

package body common is

end package body common;
