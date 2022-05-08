library ti;
context ti.should_be_part_of_the_language_itself;

entity skidbuffer is 
  generic (
            width : natural;
            async_reset : boolean := false
          );
  port (
         clk : in std_logic;
         rst : in std_logic;
         input   : in  std_logic_vector(width-1 downto 0);
         i_valid : in  std_logic;
         i_ready : out std_logic;
         output  : out std_logic_vector(width-1 downto 0);
         o_valid : out std_logic;
         o_ready : in  std_logic
       );
end;

architecture a_skidbuffer of skidbuffer is 
  signal ifire,ofire : std_logic;
  signal full : boolean;
  signal buf : std_logic_vector(width-1 downto 0);
begin
  ifire <= i_valid and i_ready;
  ofire <= o_valid and o_ready;

  output <= buf when full else input;
  o_valid <= '1' when full else i_valid;

  process (all) is
  begin
    if rising_edge(clk) then
      if ifire and not ofire then
        full <= true;
        buf <= input;
        i_ready <= '0';
      elsif ofire = '1' and full then
        full <= false;
        i_ready <= '1';
      end if;
      if not async_reset and rst = '1' then
        i_ready <= '1';
        full <= false;
      end if;
    end if;
    if async_reset and rst = '1' then
      i_ready <= '1';
      full <= false;
    end if;
  end process;
end;
