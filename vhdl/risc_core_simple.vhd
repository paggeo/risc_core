library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

package common is
    constant XLEN :integer := 32;
    type reg_file is array(0 to 31) of std_logic_vector(XLEN-1 downto 0);
end package;

package body common is

end package body common;

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

    begin 

    registers(0) <= zero;  -- x0 constant zero

    main : process(clock,reset)
        begin 
            if rising_edge(clock) then 
                if reset = '1' then 
                    pc <= (others=>'0');
                else 
                    pc <=(others=>'1');
                end if; 
            end if;
    end process;

end architecture; 
