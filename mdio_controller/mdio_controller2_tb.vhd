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

use std.env.all;

entity mdio_controller2_tb is 
end;

architecture a_mdio_controller2_tb of mdio_controller2_tb is 
  signal i_clk    : std_logic := '1';
  signal i_rst    : std_logic := '0';
  signal read     : std_logic := '0';
  signal write    : std_logic := '0';
  signal data_i   : std_logic_vector(15 downto 0) := (others => '0');
  signal data_o   : std_logic_vector(15 downto 0);
  signal phy_addr : std_logic_vector(4  downto 0) := (others => '0');
  signal reg_addr : std_logic_vector(4  downto 0) := (others => '0');
  signal busy     : std_logic;
  signal mdc      : std_logic := '0';
  signal mdio_i   : std_logic := '0';
  signal mdio_o   : std_logic;
  signal mdio_t   : std_logic := '0';
--
begin

  i_clk <= not i_clk after 10 ns; -- 100 MHz

  mdio_i <= mdio_o; -- loopback

  process
  begin
    wait until i_clk = '1';
    i_rst <= '1';
    for i in 0 to 100 loop wait until i_clk = '1'; end loop;
    i_rst <= '0';
    for i in 0 to 10 loop wait until i_clk = '1'; end loop;
    -- read
    read <= '1';
    phy_addr <= 5x"11";
    reg_addr <= 5x"0f";
    wait until mdc = '1';
    wait until busy = '0';
    read <= '0';
    wait until i_clk = '1';
    -- write
    write <= '1';
    phy_addr <= 5x"11";
    reg_addr <= 5x"0f";
    data_i <= x"55aa";
    wait until mdc = '1';
    wait until busy = '0';
    -- read
    read <= '1';
    phy_addr <= 5x"11";
    reg_addr <= 5x"0f";
    wait until mdc = '1';
    wait until busy = '0';
    read <= '0';
    wait until i_clk = '1';
    wait for 100 us;
    std.env.finish;
  end process;


  dut : entity work.mdio_controller2
  generic map(
               clock_frequency => 100000,
               invert_reset    => false
             )
  port map(
            i_clk    => i_clk    ,
            i_rst    => i_rst    ,
            read     => read     ,
            write    => write    ,
            data_i   => data_i   ,
            data_o   => data_o   ,
            phy_addr => phy_addr ,
            reg_addr => reg_addr ,
            busy     => busy     ,
            mdc      => mdc      ,
            mdio_i   => mdio_i   ,
            mdio_o   => mdio_o   ,
            mdio_t   => mdio_t
          );
end;
