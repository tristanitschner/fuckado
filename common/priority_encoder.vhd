library ti;
context ti.should_be_part_of_the_language_itself;

-- NOTE: this is not a "common" priority encoder, but makes use of several
-- scheduling schemes. (two actually, as of right now...) Hence it may be
-- applied where transactions take only one cycle to execute. When using round
-- robin it is very similar to an arbiter, though it does not track, whether a
-- transaction has taken place.

entity priority_encoder is 
  generic (
             sched_scheme : sched_scheme_t := lowest_index_first;
             n_inputs : integer := 8;
             debug : boolean := false
          );
  port (
         clk : in std_logic;
         rst : in std_logic;
         inputs : in  std_logic_vector(n_inputs-1 downto 0);
         output : out std_logic_vector(clog2(n_inputs)-1 downto 0);
         valid  : out std_logic
       );
  begin
    assert(is_power_of_two(n_inputs));
end;

architecture a_priority_encoder of priority_encoder is 
begin

  debug_gen: if debug generate
    valid <= or(inputs) when not rst else '0';
  else generate
    valid <= or(inputs);
  end generate;

  lowest_index_first_gen: if sched_scheme = lowest_index_first generate
    process (all) is
      variable temp : inputs'subtype := (others => '0');
    begin
      for i in inputs'reverse_range loop
        output <= (others => '0');
        temp := (others => '0');
        if inputs(i) = '1' then
          temp(i) := '1';
          output <= from_onehot(temp);
          exit;
        end if;
      end loop;
    end process;
  end generate;

  round_robin_gen: if sched_scheme = round_robin generate
    round_robin_b: block is
      signal last_index : output'subtype;
    begin
      last_index <= output when rising_edge(clk) and valid = '1' else
                   (others => '0') when rising_edge(clk) and rst = '1';
      process (all) is
        variable temp : inputs'subtype := (others => '0');
      begin
        output <= (others => '0');
        temp := (others => '0');
        for i in inputs'reverse_range loop
          if inputs((to_integer(unsigned(last_index)) + i + 1) mod n_inputs) then
            temp((to_integer(unsigned(last_index)) + i + 1) mod n_inputs) := '1';
            output <= from_onehot(temp);
            report integer'image(i) & " : " & to_hstring(temp);
            exit;
          end if;
        end loop;
      end process;
    end block;
  end generate;

end;
