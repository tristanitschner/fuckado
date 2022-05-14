library ti;
context ti.should_be_part_of_the_language_itself_for_simulation;

entity bus_width_resizer_tb is 
  end;

architecture a_bus_width_resizer_tb of bus_width_resizer_tb is 
  constant input_bus_width : integer := 8;
  constant output_bus_width : integer := 32;

  signal clk : std_logic := '1';
  signal rst : std_logic;

  signal i_ready :  std_logic;
  signal i_valid :  std_logic;
  signal input   :  std_logic_vector(input_bus_width - 1 downto 0);

  signal o_ready : std_logic;
  signal o_valid : std_logic;
  signal output  :  std_logic_vector(output_bus_width - 1 downto 0);

begin
  clk <= not clk after 5 ns;
  rst <= '1', '0' after 100 ns;

  signal_generation: process is
  begin
    wait until clk;
    --i_valid <= rand;
    i_valid <= '1';
    input   <= rand(input'length);
    --o_ready <= rand;
    o_ready <= '1';
  end process;

  process is
  begin
    wait for 1000*10 ns;
    std.env.finish;
  end process;

  dut: entity ti.bus_width_resizer
  generic map (
                input_bus_width => input_bus_width,
                output_bus_width => output_bus_width
              )
  port map (
             clk     => clk,
             rst     => rst,
             i_ready => i_ready,
             i_valid => i_valid,
             input   => input,
             o_ready => o_ready,
             o_valid => o_valid,
             output  => output
           );

end;
