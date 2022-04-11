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

entity mdio_controller2 is 
  generic (
            clock_frequency : integer := 100000; -- kHz
            invert_reset    : boolean := false
          );
  port (
         i_clk : in std_logic;
         i_rst : in std_logic;
         -- slave
         read     : in  std_logic;
         write    : in  std_logic;
         data_i   : in  std_logic_vector(15 downto 0);
         data_o   : out std_logic_vector(15 downto 0);
         phy_addr : in  std_logic_vector(4  downto 0);
         reg_addr : in  std_logic_vector(4  downto 0);

         -- master
         mdc    : out std_logic;
         mdio_i : in  std_logic;
         mdio_o : out std_logic;
         mdio_t : out std_logic
       );
end;

architecture a_mdio_controller2 of mdio_controller2 is 
  constant counter_ceiling : integer := integer(floor(real(clock_frequency)/real(2*2500)));
  signal rst        : std_logic;
  signal phy_addr_r : std_logic_vector(4 downto 0);
  signal reg_addr_r : std_logic_vector(4 downto 0);
  signal w_data     : std_logic_vector(15 downto 0);
  signal r_data     : std_logic_vector(15 downto 0);
  signal global_cnt : integer := 0;
  signal read_flag  : boolean;
begin
  rst_gen: if invert_reset generate
    rst <= not i_rst;
  else generate
    rst <= i_rst;
  end generate;

  mdc_proc : process(all)
    variable counter : integer := 0;
  begin
    if rst then
      counter := 0;
    elsif rising_edge(i_clk) then
      if counter = 0 then
        counter := counter_ceiling;
        mdc <= not mdc;
      else 
        counter := counter - 1;
      end if;
    end if;
  end process;

  r_data <= mdio_i & r_data(15 downto 1) when rising_edge(mdc);

  mdio_o <= '1' when global_cnt < 32 else
            '0' when global_cnt = 32 else
            '1' when global_cnt = 33 else
            '1' when global_cnt = 34 and read_flag else
            '0' when global_cnt = 34 and not read_flag else
            '0' when global_cnt = 35 and read_flag else
            '1' when global_cnt = 35 and not read_flag else
            phy_addr_r(36 - global_cnt + 5) when global_cnt < 41 else
            reg_addr_r(41 - global_cnt + 5) when global_cnt < 46 else
            w_data(64 - global_cnt + 16) when global_cnt < 64 else
            '0';

  mdio_t <= '0' when global_cnt < 47 else
            '1' when read_flag else
            '0';

  process(all)
  begin
    if rising_edge(mdc) then
      if read_flag and global_cnt = 63 then
        data_o <= r_data;
      end if;
    end if;
  end process;

  process(all)
    type state_t is (idle, running);
    variable state : state_t := idle;
  begin
    if falling_edge(mdc) then
      case state is 
        when idle => 
          global_cnt <= 0;
          -- fixme: how do we informe the master, that we have accepted the read / write? 
          if read or write then
            read_flag <= true when read else false;
            phy_addr_r <= phy_addr;
            reg_addr_r <= reg_addr;
            w_data <= data_i;
            state := running;
          end if;
        when running =>
          if global_cnt < 64 then
            global_cnt <= global_cnt + 1;
          else
            global_cnt <= 0;
            state := idle;
          end if;
      end case;

    end if;
  end process;

end;
