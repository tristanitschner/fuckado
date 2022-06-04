library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity phase_acc is 
  generic (
            width : natural := 48
          );
  port                 (
         clk  : in std_logic;
         rstn : in std_logic; -- not used, may be used, but not necessarily so
         sel_phasestep : in  std_logic_vector(width - 1 downto 0);
         ph_o          : out std_logic_vector(width - 1 downto 0)
       );
begin
end;

architecture a_phase_acc of phase_acc is 
  signal step  : unsigned(sel_phasestep'range);
  signal phase : unsigned(ph_o'range) := (others => '0');
begin

  step  <= unsigned(sel_phasestep);
  ph_o  <= std_logic_vector(phase);
  phase <= phase + step when rising_edge(clk);

end;
