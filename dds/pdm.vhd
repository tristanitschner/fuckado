library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity pdm is 
  generic (
            width : natural := 8
          );
  port (
         clk : in  std_logic;
         rst : in  std_logic;
         x   : in  std_logic_vector(width - 1 downto 0);
         y   : out std_logic
       -- other ports
       );
end;

architecture a_pdm of pdm is 
  signal counter    : signed(x'range);
begin

  y <= '1' when signed(x) > counter else '0';

  process (all) is
  begin
    if rising_edge(clk) then
      counter <= counter + "01"; -- vhdl is very stupid...
      if rst then
        counter <= (others => '0');
      end if;
    end if;
  end process;


end;
