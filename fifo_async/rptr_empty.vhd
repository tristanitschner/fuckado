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

entity rptr_empty is 
  generic (
            addr_w : integer := 4
          );
  port (
         aempty_n : in  std_logic;
         rinc     : in  std_logic;
         rclk     : in  std_logic;
         rrst_n   : in  std_logic;
         rempty   : out std_logic;
         rptr     : out std_logic_vector(addr_w - 1 downto 0)
);
end;

architecture a_rptr_empty of rptr_empty is 
  signal rbin, rgnext, rbnext : unsigned(addr_w - 1 downto 0);
  signal rempty2 : std_logic;
begin
  rbnext <= rbin + 1 when rinc and not rempty else
            rbin;
  rgnext <= (rbnext srl 1) xor rbnext;
  process(all)
  begin
    if rising_edge(rclk) or falling_edge(rrst_n) then
      rbin <= (others => '0') when not rrst_n else rbnext;
      rptr <= (others => '0') when not rrst_n else std_logic_vector(rgnext);
    end if;
    if rising_edge(rclk) or falling_edge(aempty_n) then
      rempty <= '1' when not aempty_n else
                rempty2;
      rempty2 <= '1' when not aempty_n else
                 not aempty_n;
    end if;
  end process;
end;
