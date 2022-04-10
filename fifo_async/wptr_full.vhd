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

entity wptr_full is 
  generic (
            addr_w : integer := 4
          );
  port (
         wfull   : out std_logic;
         wptr    : out std_logic_vector(addr_w - 1 downto 0);
         afull_n : in  std_logic;
         winc    : in  std_logic;
         wclk    : in  std_logic;
         wrst_n  : in  std_logic
       );
end;

architecture a_wptr_full of wptr_full is 
  signal wbin : unsigned(addr_w - 1 downto 0);
  signal wfull2 : std_logic;
  signal wgnext, wbnext : unsigned(addr_w - 1 downto 0);
begin
  wbnext <= wbin + 1 when winc and not wfull else
            wbin;
  wgnext <= (wbnext srl 1) xor wbnext;

  process(all)
  begin
    if rising_edge(wclk) or falling_edge(wrst_n) then
      wbin <= (others => '0') when not wrst_n else wbnext;
      wptr <= (others => '0') when not wrst_n else std_logic_vector(wgnext);
    end if;
    if rising_edge(wclk) or falling_edge(wrst_n) or falling_edge(afull_n) then
      wfull <= '0' when not wrst_n else
               '1' when not afull_n else
               wfull2;
      wfull2 <= '0' when not wrst_n else
                '1' when not afull_n else
                not afull_n;
    end if;
  end process;
end;
