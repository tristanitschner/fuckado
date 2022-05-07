library ti;
context ti.should_be_part_of_the_language_itself;

entity fifo_fwft_tb is 
end;

architecture a_fifo_fwft_tb of fifo_fwft_tb is 
  subtype mypayload_t is unsigned(7 downto 0);

  constant clk_period : time := 10 ns;

  signal clk    : std_logic;
  signal rst    : std_logic;
  signal input  : unsigned(7 downto 0);
  signal output : unsigned(7 downto 0);
  signal wr     : std_logic;
  signal rd     : std_logic;
  signal full   : std_logic;
  signal empty  : std_logic;

  procedure wait_cycles(x: natural) is
  begin
    for i in 1 to x loop
      wait until clk;
    end loop;
  end procedure;
begin

  clk <= not clk after clk_period/2;
  rst <= '1','0' after 5*clk_period;

  process is
    procedure write (
                      data : unsigned(7 downto 0)
                   ) is 
    begin
      input <= data;
      wr <= '1';
      wait until clk;
    end procedure;
  begin
    rd <= '0';
    wait_cycles(10);
    assert(empty = '1');
    assert(full = '0');
    for i in 0 to 10 loop
      write(to_unsigned(i, 8));
    end loop;
    assert(empty = '0');
    assert(full = '0');
    rd <= '1';
    for i in 0 to 10 loop
      assert(output = to_unsigned(i, 8));
      wait until clk;
    end loop;
    assert(empty = '1');
    for i in 0 to 255 loop
      write(to_unsigned(i mod 256, 8));
    end loop;
    assert(empty = '0');
    assert(full = '1');
  end process;

  dut: entity ti.fifo_fwft
  generic map (
            payload_t => mypayload_t
          )
 port          map (
         clk    =>  clk,
         rst    =>  rst,
         input  =>  input,
         output =>  output,
         wr     =>  wr,
         rd     =>  rd,
         full   =>  full,
         empty  =>  empty
       );

end;
