library ti;
context ti.should_be_part_of_the_language_itself;

use std.env.all;

entity priority_encoder_2_tb is 
end;

architecture a_priority_encoder_2_tb of priority_encoder_2_tb is 
  constant n_inputs : integer := 8;
  constant clk_period : time := 10 ns;

  signal clk : std_logic := '1';
  signal rst : std_logic;
  signal inputs : std_logic_vector(n_inputs-1 downto 0);
  signal output : std_logic_vector(clog2(n_inputs)-1 downto 0);
  signal valid  : std_logic;

  procedure wait_cycles(cyc : natural) is
  begin
    for i in 1 to cyc loop
      wait until clk;
    end loop;
  end procedure;
begin

  clk <= not clk after clk_period/2;
  rst <= '1', '0' after 5*clk_period;

  process is
  begin
    wait_cycles(10);
    wait_cycles(100);
    -- TODO
    std.env.finish;
    wait;
  end process;

  inputs <= rand(inputs'length) when rising_edge(clk);

  dut : entity ti.priority_encoder
  generic map (
                sched_scheme => round_robin,
                n_inputs     => n_inputs,
                debug        => true
              )
  port map (
             clk => clk,
             rst => rst,
             inputs => inputs,
             output => output,
             valid  => valid
           );
end;
