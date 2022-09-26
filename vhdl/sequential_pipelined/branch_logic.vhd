library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

entity branch_logic is
port (
  clock : in std_logic;
  a     : in std_logic_vector(XLEN-1 downto 0);
  b     : in std_logic_vector(XLEN-1 downto 0);
  branch_flag : in std_logic_vector(2 downto 0);
  z     : out std_logic
);
end entity;

architecture rtl of branch_logic is 
begin
main : process(clock)
begin 
  if rising_edge(clock) then 
    case branch_flag is 
      when "000" => -- BEQ
        if a = b then 
          z <= '1';
        else 
          z <= '0';
        end if;
      when "001" => -- BNE
        if a /= b then 
          z <= '1';
        else 
          z <= '0';
        end if;
      when "100" => -- BLT
        if signed(a) < signed(b) then 
          z <= '1';
        else 
          z <= '0';
        end if;
      when "101" => -- BGE
        if signed(a) >= signed(b) then 
          z <= '1';
        else 
          z <= '0';
        end if;
      when "110" => -- BLTU
        if unsigned(a) < unsigned(b) then 
          z <= '1';
        else 
          z <= '0';
        end if;
      when "111" => -- BGEU
        if unsigned(a) >= unsigned(b) then 
          z <= '1';
        else 
          z <= '0';
        end if;
      when others => -- Wrong Op
    end case;
  end if;
end process;

end architecture;
