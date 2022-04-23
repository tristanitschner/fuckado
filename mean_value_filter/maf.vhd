--    Copyright (C) 2022	Tristan Itschner
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <https://www.gnu.org/licenses/>.

-- Moving Average Filter
--
-- It basically only counts one in the input stream.
-- The output is not buffered, i.e. there are combinatorial paths.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

--library work;
--use work.all;

entity maf is
  generic (
			input_length  : integer := 1;
			filter_length : integer := 256
		  );
  port (
		 clk : in std_logic;
		 rst : in std_logic;
		 i_x : in std_logic_vector ( input_length - 1 downto 0);
		 o_y : out std_logic_vector ( 
		   integer(ceil(log2(real(filter_length * 2**input_length)))) - 1 
		   downto 0
		 ) := (others => '0')
	   );
end maf;

architecture a_maf of maf is
  signal x : std_logic_vector ( input_length * filter_length - 1 downto 0) := (others => '0');
  signal sum : std_logic_vector ( 
  integer(ceil(log2(real(filter_length * 2**input_length)))) - 1 
  downto 0
) := (others => '0');
begin

  -- we just shift x through
  shift_register: process(all)
  begin
    if rst then
      for i in x'range loop
        x(i) <= '1' when i mod 2 = 1 else '0';
      end loop;
    elsif rising_edge(clk) then
      x <= i_x & 
      x(filter_length*input_length - 1 downto input_length);
    end if;
  end process;

  -- main processing routine
  main: process(all)
  begin
    if rst then
  --    for i in o_y'range loop
  --      o_y(i) <= '1' when i mod 2 = 1 else '0';
  --    end loop;
  -- todo: handle i_x vectors when their maximum value is known, such as when cascading mean value filters
      o_y <= std_logic_vector(to_unsigned(filter_length/2, o_y'length));
    elsif rising_edge(clk) then
      o_y <= std_logic_vector(unsigned(o_y) + unsigned(i_x) - unsigned(x(input_length - 1 downto 0)));
    end if;
  end process;

  -- FORMAL --
  -- synthesis translate off
  process(all)
    variable s : unsigned(o_y'length - 1 downto 0) := (others => '0');
  begin
    if rst then
      sum <= std_logic_vector(to_unsigned(0, sum'length));
    elsif rising_edge(clk) then
      for i in 0 to filter_length - 1 loop
        s := s + unsigned(x(input_length*(i + 1) - 1 downto input_length*i));
      end loop;
      sum <= std_logic_vector(s);
    end if;
  end process;
  -- synthesis translate on

end a_maf;
