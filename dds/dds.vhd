library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity dds is 
  generic (
            acc_width         : natural := 8;
            sig_width         : natural := 8;
            log_clock_divider : natural := 8
          );
  port (
         clk           : in  std_logic;
         rst           : in  std_logic;
         sel_phasestep : in  std_logic_vector(acc_width - 1 downto 0);
         y             : out std_logic
       );
end;

architecture a_dds of dds is 
  signal ph      : std_logic_vector (acc_width  - 1 downto 0);
  signal sig     : std_logic_vector (sig_width  - 1 downto 0);
  signal clk_div : unsigned         (log_clock_divider - 1 downto 0);
  signal clk_2   : std_logic;
begin

  process (all) is 
  begin
    if rising_edge(clk) then
      clk_div <= clk_div + "1";
      if rst then
        clk_div <= (others => '0');
      end if;
    end if;
  end process;
  clk_2 <= not clk_div(clk_div'high);

  phase_acc_inst: entity work.phase_acc 
  generic map (
                width     => acc_width
              )
  port map (
             clk           => clk_2,
             rstn          => not rst,
             sel_phasestep => sel_phasestep,
             ph_o          => ph
           );

  lookup_table_inst : entity work.lookup_table
  generic map (
                input_width  => acc_width,
                output_width => sig_width
              )
  port map (
             clk   => clk_2,
             phase => ph,
             sig_o => sig
           );


  pdm_inst : entity work.pdm 
  generic map (
                width => sig_width
              )
  port map (
             clk => clk,
             rst => rst,
             x   => sig,
             y   => y
           );

end;


