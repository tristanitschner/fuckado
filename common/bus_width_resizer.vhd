library ti;
context ti.should_be_part_of_the_language_itself;

entity bus_width_resizer is 
  generic (
            input_bus_width : natural;
            output_bus_width : natural
          );
  port (
         clk : in std_logic;
         rst : in std_logic;

         -- input
         i_ready : out std_logic;
         i_valid : in  std_logic;
         input   : in  std_logic_vector(input_bus_width - 1 downto 0);

         -- output
         o_ready : in  std_logic;
         o_valid : out std_logic;
         output  : out  std_logic_vector(output_bus_width - 1 downto 0)
       );
begin 
  assert(
  ((output_bus_width mod input_bus_width) = 0) or
  ((input_bus_width mod output_bus_width) = 0));
end;

architecture a_bus_width_resizer of bus_width_resizer is 
  function is_upsizer(i, o : integer) return boolean is
  begin
  end function;
begin

  main_gen: if input_bus_width = output_bus_width generate

    -- we are "noting":
    i_ready <= o_ready;
    o_valid <= i_valid;
    output <= input;

  elsif input_bus_width > output_bus_width generate

    down_sizer: block is
      constant n_slices : natural := input_bus_width / output_bus_width;
      signal active : std_logic;
      signal count : integer range 0 to n_slices - 1;
      subtype slice is std_logic_vector(output_bus_width - 1 downto 0);
      type storage_t is array (natural range<>) of slice;
      signal storage : storage_t(n_slices - 1 downto 0);
    begin
      i_ready <= '0' when rst else
                 '1' when not active else
                 '0';
      o_valid <= '0' when rst else
                 '1' when count = 0 and (active or (i_valid and i_ready)) = '1' else
                 '1' when count /= 0 else
                 '0';
      output <= input(output_bus_width-1 downto 0) when (i_ready and i_valid) = '1' and count = 0 else
                storage(count) when active else
                (others => '0'); -- could be removed to save logic
      process (all) is 
      begin
        if rising_edge(clk) then
          -- deal with the state flag
          if i_ready and i_valid and not active then
            active <= '1';
          elsif (o_ready and o_valid) = '1' and count = n_slices - 1 then
            active <= '0';
          end if;
          if rst then
            active <= '0';
          end if;
          -- deal with the counter
          if o_valid and o_ready then 
            count <= count + 1;
          end if;
          if (o_valid and o_ready) = '1' and count = n_slices - 1 then
            count <= 0;
          end if;
          if rst then
            count <= 0;
          end if;
          -- register the input
          if i_ready and i_valid and not active then
            for i in 0 to n_slices - 1 loop
              storage(i) <= input((i + 1)*output_bus_width - 1 downto i*output_bus_width);
            end loop;
          end if;
        end if;
      end process;
    end block;

  else generate

    up_sizer: block is
      constant n_slices : natural := output_bus_width / input_bus_width;
      signal count : integer range 0 to n_slices;
      signal active : std_logic;
      subtype slice is std_logic_vector(input_bus_width - 1 downto 0);
      type storage_t is array (natural range<>) of slice;
      signal storage : storage_t(n_slices - 1 downto 0);
    begin
      i_ready <= '0' when rst else
                 '1' when not active else
                 '1' when active = '1' and count /= n_slices else
                 '0';
      o_valid <= '1' when active = '1' and (count = n_slices - 1 and i_valid = '1')else 
                 '0';
      process (all) is 
      begin
        if rising_edge(clk) then
          -- deal with the state flag
          if (i_ready and i_valid) and not active then
            active <= '1';
          end if;
          if o_ready and o_valid then
            active <= '0';
          end if;
          if rst then
            active <= '0';
          end if;
          -- deal with the counter
          if o_valid and o_ready then
            count <= 0;
          end if;
          if (i_valid and i_ready) = '1' and count /= n_slices - 1 then 
            count <= count + 1;
          end if;
          if rst then
            count <= 0;
          end if;
          -- register the input
          if i_valid and i_ready then 
            storage(count) <= input;
          end if;
        end if;
        if o_ready and o_valid then
          for i in 0 to n_slices - 2 loop
            output((i + 1)*input_bus_width - 1 downto i*input_bus_width) <= storage(i);
          end loop;
          if i_ready and i_valid then
            output(output_bus_width - 1 downto output_bus_width - input_bus_width) <= input;
          else
            output(output_bus_width - 1 downto output_bus_width - input_bus_width) <= storage(n_slices-1);
          end if;
        else 
          output <= (others => '0');
        end if;
      end process;
    end block;

  end generate;

end;
