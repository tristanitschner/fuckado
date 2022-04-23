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

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use ieee.math_real.all;

library work;
use work.all;

use std.env.all;

entity maf_tb is 
end entity;

architecture a_maf_tb of maf_tb is 
  constant input_length : integer := 1;
  constant filter_length : integer := 255;
  constant period : real := 100.0*MATH_PI_OVER_2;  -- this is relative to the number of ticks
  signal m_ticks : integer := 0;
  signal clk : std_logic := '1';
  signal rst : std_logic := '1';
  signal i_x : std_logic_vector ( input_length - 1 downto 0) := "1";
  signal o_y : std_logic_vector ( 
    integer(ceil(log2(real(filter_length * 2**input_length)))) - 1 
    downto 0
  ) := (others => '0');

    
begin
  clk <= not clk after 5 ps;
  m_ticks <= m_ticks + 1 when rising_edge(clk);

  process (all) is
    variable seed1,seed2 : integer := 42;
    variable rand : real;
  begin
    if rising_edge(clk) then 
      uniform(seed1,seed2,rand);
      i_x <= "1" when rand < (sin(real(m_ticks)/period) + 1.0)/2.0 else "0"; -- surprisingly, this works
    end if;
  end process;


  process is
    procedure wait_cycles(cycles : integer) is
    begin
      for i in 1 to cycles loop
        wait until clk;
      end loop;
    end procedure;
  begin
    rst <= '1';
    wait_cycles(10);
    rst <= '0';
    wait_cycles(8000);
    std.env.finish;
  end process;

maf_inst : entity work.maf 
  generic map (
			input_length  => input_length,
			filter_length => filter_length
		  )
  port map (
		 clk => clk,
		 rst => rst,
		 i_x => i_x,
		 o_y => o_y
	   );
end architecture;
