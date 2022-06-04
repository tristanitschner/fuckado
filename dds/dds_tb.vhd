library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use std.env.all;

entity dds_tb is 
end;

architecture a_dds_tb of dds_tb is 
  constant acc_width         : natural := 10;
  constant sig_width         : natural := 8;
  constant log_clock_divider : natural := 7;

  signal clk           : std_logic := '0';
  signal rst           : std_logic;
  signal sel_phasestep : std_logic_vector(acc_width - 1 downto 0);
  signal y             : std_logic;

begin
  
  clk <= not clk after 10 ns;

  process is
    procedure wait_cycles(x : natural) is
    begin
      for i in 0 to x - 1 loop
        wait until rising_edge(clk);
        wait until clk = '1';
      end loop;
    end procedure;
  begin
    rst <= '1';
    wait_cycles(1);
    rst <= '0';
    for i in 10 to 100 loop
      sel_phasestep <= std_logic_vector(to_unsigned(i, sel_phasestep'length));
      wait_cycles(2**log_clock_divider*1024/(i + 1));
    end loop;

    std.env.finish;
  end process;

  dut : entity work.dds
  generic map (
                acc_width         => acc_width,
                sig_width         => sig_width,
                log_clock_divider => log_clock_divider
              )
  port map (
             clk           => clk,
             rst           => rst,
             sel_phasestep => sel_phasestep,
             y             => y
           );

end;

