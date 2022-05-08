-- here I would like to show how it is possible to address a memory larger
-- than 2^31 - 1 elements, which is the maximum integer limit in vhdl
-- some commercial simulators, such us Siemen's Modelsim are even as stupid as
-- to crash, when using integer larger than then standard allows

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity no_more_greater_than_pow_2_31_fuckery is 
  generic(
    width : integer := 8
         );
end;
architecture a_no_more_greater_than_pow_2_31_fuckery of no_more_greater_than_pow_2_31_fuckery is 
  subtype byte is std_logic_vector(width - 1 downto 0);
  type ram is array(integer range <>) of byte;
  type bank is array(integer range<>) of ram;

  signal mem : bank
  (2**16-1 downto 0)
  (2**16-1 downto 0);
  signal index : unsigned(32-1 downto 0) := (others => '0');

  function read(memx : bank; indexx : unsigned) return byte is
  begin
    return memx
    (to_integer(indexx(31 downto 16)))
    (to_integer(indexx(15 downto 0)));
  end function;

  procedure write(signal memx : inout bank; indexx : unsigned; value : byte) is
  begin
    memx
    (to_integer(indexx(31 downto 16)))
    (to_integer(indexx(15 downto 0))) 
    <= value;
  end procedure;

  signal clk,rst : std_logic := '1';
  constant clk_period : time := 10 ns;
begin

  clk <= not clk after clk_period/2;
  rst <= '1', '0' after clk_period*5;

  process (all) is
  begin
    if rising_edge(clk) then
      index <= index + "1";
      write(mem, index, std_logic_vector(index(byte'range)));
      if index > "0" then
        report "Wrote to memory the value " & to_hstring(read(mem, index - "1"));
      end if;
    end if;
  end process;

end;
