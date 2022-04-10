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

entity mc51_addr_dec is 
  generic ( -- addr0 is always 0, i.e. the first slave is mapped to 0x00000000
            addr1 : integer := 16#00000000#;
            addr2 : integer := 16#10000000#;
            addr3 : integer := 16#20000000#
          );
  port (
         -- purely combinatorial, so no clk or rst
         -- mb master interface
         s_mb_addr   : in   std_logic_vector(3 downto 0);
         s_mb_wrdata : in   std_logic_vector(7 downto 0);
         s_mb_rddata : out  std_logic_vector(7 downto 0);
         s_mb_we     : in   std_logic;

         -- slave interfaces
         m_mb0_addr   : out std_logic_vector(3 downto 0);
         m_mb0_wrdata : out std_logic_vector(7 downto 0);
         m_mb0_rddata : in  std_logic_vector(7 downto 0);
         m_mb0_we     : out std_logic;

         m_mb1_addr   : out std_logic_vector(3 downto 0);
         m_mb1_wrdata : out std_logic_vector(7 downto 0);
         m_mb1_rddata : in  std_logic_vector(7 downto 0);
         m_mb1_we     : out std_logic;

         m_mb2_addr   : out std_logic_vector(3 downto 0);
         m_mb2_wrdata : out std_logic_vector(7 downto 0);
         m_mb2_rddata : in  std_logic_vector(7 downto 0);
         m_mb2_we     : out std_logic;

         m_mb3_addr   : out std_logic_vector(3 downto 0);
         m_mb3_wrdata : out std_logic_vector(7 downto 0);
         m_mb3_rddata : in  std_logic_vector(7 downto 0);
         m_mb3_we     : out std_logic
       );
end;
architecture a_mc51_addr_dec of mc51_addr_dec is 
begin

  process (all)
    variable addr : integer := to_integer(unsigned(s_mb_addr));
  begin
    if addr < addr1 then
      m_mb0_addr   <= std_logic_vector(to_unsigned(addr - 0, s_mb_addr'length));
      m_mb0_wrdata <= s_mb_wrdata;
      s_mb_rddata <= m_mb0_rddata;
      m_mb0_we     <= s_mb_we;
    elsif addr < addr2 then
      m_mb1_addr   <= std_logic_vector(to_unsigned(addr - addr1, s_mb_addr'length));
      m_mb1_wrdata <= s_mb_wrdata;
      s_mb_rddata <= m_mb1_rddata;
      m_mb1_we     <= s_mb_we;
    elsif addr < addr3 then
      m_mb2_addr   <= std_logic_vector(to_unsigned(addr - addr2, s_mb_addr'length));
      m_mb2_wrdata <= s_mb_wrdata;
      s_mb_rddata <= m_mb2_rddata;
      m_mb2_we     <= s_mb_we;
    else
      m_mb3_addr   <= std_logic_vector(to_unsigned(addr - addr3, s_mb_addr'length));
      m_mb3_wrdata <= s_mb_wrdata;
      s_mb_rddata <= m_mb3_rddata;
      m_mb3_we     <= s_mb_we;
    end if;
  end process;

end;
