library ti;
context ti.should_be_part_of_the_language_itself_for_simulation;

use std.env.all;

entity skidbuffer_tb is 
end;

architecture a_skidbuffer_tb of skidbuffer_tb is 

  constant clk_period : time := 10 ns;

         signal clk : std_logic := '1';
         signal rst : std_logic;
         signal input   : std_logic_vector(7 downto 0);
         signal i_valid : std_logic;
         signal i_ready : std_logic;
         signal output  : std_logic_vector(7 downto 0);
         signal o_valid : std_logic;
         signal o_ready : std_logic;

begin

  clk <= not clk after clk_period/2;
  rst <= '1','0' after 5*clk_period;

  process is
  begin
    wait until not rst;
    for i in 0 to 100 loop
         input   <= rand(input'length);
         i_valid <= rand;
         o_ready <= rand;
         wait until clk;
    end loop;
    std.env.finish;
    wait;
  end process;

  -- not paying for fucking proper PSL support, so this is what I do:
  assertions: block is
    signal ifire,ofire : std_logic;
    signal p_rst : std_logic;
    signal p_ifire,p_ofire : std_logic;
    signal p_input : std_logic_vector(7 downto 0);
  begin
    ifire <= i_valid and i_ready;
    ofire <= o_valid and o_ready;
    p_rst <= rst when rising_edge(clk);
    p_ifire <= ifire when rising_edge(clk);
    p_ofire <= ofire when rising_edge(clk);
    p_input <= input when rising_edge(clk) and ifire = '1' ;
    process (all) is
    begin
      if rising_edge(clk) and p_rst = '0' then
        -- passthrough
        if ofire and ifire then
          assert(output = input);
        end if;
        -- can't write twice if not read
        assert(not(ifire and p_ifire and not ofire and not p_ofire));
        -- if we read but there's not new input, it must be in the buffer
        if ofire and not ifire then
          assert(output = p_input);
        end if;
      end if;
    end process;
  end block;

dut: entity ti.skidbuffer
  generic map (
            width => 8
          )
  port map (
         clk => clk,
         rst => rst,
         input   => input,
         i_valid => i_valid,
         i_ready => i_ready,
         output  => output,
         o_valid => o_valid,
         o_ready => o_ready
       );
end;
