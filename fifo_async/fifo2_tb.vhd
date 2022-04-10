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

entity fifo2_tb is 
end;
architecture a_fifo2_tb of fifo2_tb is 
  signal clk : std_logic := '1';
  signal cnt_rst : boolean := false; -- randomly resyncronize the clocks, to see effects
  signal cnt_rst1 : boolean := false; -- randomly resyncronize the clocks, to see effects
  signal cnt_rst2 : boolean := false; -- randomly resyncronize the clocks, to see effects
  -- entity signals
  signal rdata  : std_logic_vector(7 downto 0);
  signal rempty : std_logic := '0';
  signal wfull  : std_logic := '0';
  signal wdata  : std_logic_vector(7 downto 0);
  signal winc   : std_logic := '0';
  signal wclk   : std_logic := '1';
  signal wrst_n : std_logic;
  signal rinc   : std_logic := '0';
  signal rclk   : std_logic := '1';
  signal rrst_n : std_logic;
begin

  init: process
  begin
    rrst_n <= '1'; wrst_n <= '1';
    wait until wclk = '1';
    wait until rclk = '1';
    rrst_n <= '0'; wrst_n <= '0';
    wait for 300 ns;
    rrst_n <= '1'; wrst_n <= '1';
    wait for 10000 ns;
  end process;

  read: process
  begin
    wait for 430 ns;
    wait until rclk = '1'; rinc <= '1';
    wait until rclk = '1'; rinc <= '0';
    wait until rclk = '1'; rinc <= '1';
    wait until rclk = '1'; rinc <= '0';
    wait until rclk = '1'; rinc <= '1';
    wait until rclk = '1'; rinc <= '0';
    cnt_rst1 <= true; wait for 20 ps; cnt_rst1 <= false;
    wait until rclk = '1'; rinc <= '1';
    wait until rclk = '1'; rinc <= '0';
    wait for 10000 ns;
  end process;

  writes: process
  begin
    wait for 400 ns;
    wait until wclk = '1'; winc <= '1'; wdata <= x"de"; 
    wait until wclk = '1'; winc <= '0';
    wait until wclk = '1'; winc <= '1'; wdata <= x"ad"; 
    wait until wclk = '1'; winc <= '0';
    cnt_rst2 <= true; wait for 20 ps; cnt_rst2 <= false;
    wait until wclk = '1'; winc <= '1'; wdata <= x"be"; 
    wait until wclk = '1'; winc <= '0';
    wait until wclk = '1'; winc <= '1'; wdata <= x"ef"; 
    wait until wclk = '1'; winc <= '0';
    wait for 100 ns;
    wait for 2000 ns;
    std.env.finish;
  end process;

  clk <= not clk after 10 ps;
  cnt_rst <= cnt_rst1 or cnt_rst2;

  process(all)
    variable wcounter : integer := 0;
  begin
    if rising_edge(clk) then
      if wcounter = 881 - 1 or cnt_rst then
        wclk <= not wclk;
        wcounter := 0;
      else
        wcounter := wcounter + 1;
      end if;
    end if;
  end process;

  process(all)
    variable rcounter : integer := 0;
  begin
    if rising_edge(clk) then
      if rcounter = 883 - 1 or cnt_rst then
        rclk <= not rclk;
        rcounter := 0;
      else
        rcounter := rcounter + 1;
      end if;
    end if;
  end process;



fifo2_inst : entity work.fifo2
  port map (
         rdata  => rdata,
         rempty => rempty,
         wfull  => wfull,
         wdata  => wdata,
         winc   => winc,
         wclk   => wclk,
         wrst_n => wrst_n,
         rinc   => rinc,
         rclk   => rclk,
         rrst_n => rrst_n
       );
end;
