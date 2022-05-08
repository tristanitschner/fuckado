library ti;
context ti.should_be_part_of_the_language_itself;

entity fifo_fwft is 
  generic (
            width : natural := 8;
            depth : natural := 256;
            async_reset : boolean := false
          );
  port (
         clk       : in  std_logic;
         rst       : in  std_logic;
         input     : in  std_logic_vector(width-1 downto 0);
         output    : out std_logic_vector(width-1 downto 0);
         wr        : in  std_logic; -- replace by valid TODO
         rd        : in  std_logic; -- replace by ready
         full      : out std_logic; -- replace by not ready
         empty     : out std_logic; -- replace by not valid
         fillcount : out std_logic_vector(clog2(depth)-1 downto 0)
       );
  begin
    assert is_power_of_two(depth);
    assert is_power_of_two(width);
end;

architecture a_fifo_fwft of fifo_fwft is 
  signal rdptr,wrptr : natural;
  type mem_t is array (depth-1 downto 0) of std_logic_vector(width-1 downto 0);
  signal mem : mem_t;
  signal inverted : boolean := false;
begin

  fillcount <= std_logic_vector(to_unsigned((wrptr - rdptr) mod depth, clog2(depth)));
  output <= mem(rdptr);
  empty <= '1' when rdptr = wrptr and not inverted else '0';
  full  <= '1' when rdptr = wrptr and     inverted else '0';

  process (all) is
  begin
    if rising_edge(clk) then
      -- write logic
      if wr and not full then
        mem(wrptr) <= input;
      end if;
      -- logic for inverted
      if wr and not full and rd and not empty then
        null;
      elsif wr and not full then
        wrptr <= (wrptr + 1) mod depth;
        if (wrptr + 1) mod depth = 0 then
          inverted <= not inverted;
        end if;
      elsif rd and not empty then
        rdptr <= (rdptr + 1) mod depth;
        if (rdptr + 1) mod depth = 0 then
          inverted <= not inverted;
        end if;
      end if;
      -- reset logic
      if not async_reset and rst = '1' then
        rdptr <= 0; rdptr <= 0;
        inverted <= false;
      end if;
    end if;
    if async_reset and rst = '1' then
      rdptr <= 0; rdptr <= 0;
      inverted <= false;
    end if;
  end process;

end;
