--    Copyright (C) 2022	Tristan Itschner
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <https://www.gnu.org/licenses/>.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library xpm;
use xpm.vcomponents.all;

entity fifomem is 
  generic (
            use_xpm_primitive : boolean := false;
            data_w            : integer := 8;
            addr_w            : integer := 4;
            depth             : integer := to_integer(to_unsigned(1, 64) sll addr_w) -- "vhdl is strongly typed..."
          );
  port (
         rdata  : out std_logic_vector(data_w - 1 downto 0);
         wdata  : in  std_logic_vector(data_w - 1 downto 0);
         waddr  : in  std_logic_vector(addr_w - 1 downto 0);
         raddr  : in  std_logic_vector(addr_w - 1 downto 0);
         wclk   : in  std_logic;
         wclken : in  std_logic
);
end;

architecture a_fifomem of fifomem is 
begin

  memgen: if use_xpm_primitive generate
    xpm_memory_sdpram_inst : xpm_memory_sdpram
    generic map (
                  ADDR_WIDTH_A            => addr_w,          -- DECIMAL
                  ADDR_WIDTH_B            => addr_w,          -- DECIMAL
                  AUTO_SLEEP_TIME         => 0,               -- DECIMAL
                  BYTE_WRITE_WIDTH_A      => data_w,          -- DECIMAL
                  CLOCKING_MODE           => "common_clock",  -- String
                  ECC_MODE                => "no_ecc",        -- String
                  MEMORY_INIT_FILE        => "none",          -- String
                  MEMORY_INIT_PARAM       => "0",             -- String
                  MEMORY_OPTIMIZATION     => "true",          -- String
                  MEMORY_PRIMITIVE        => "block",         -- String
                  MEMORY_SIZE             => addr_w*data_w,   -- DECIMAL
                  MESSAGE_CONTROL         => 0,               -- DECIMAL
                  READ_DATA_WIDTH_B       => data_w,          -- DECIMAL
                  READ_LATENCY_B          => 1,               -- DECIMAL
                  READ_RESET_VALUE_B      => "0",             -- String
                  USE_EMBEDDED_CONSTRAINT => 0,               -- DECIMAL
                  USE_MEM_INIT            => 1,               -- DECIMAL
                  WAKEUP_TIME             => "disable_sleep", -- String
                  WRITE_DATA_WIDTH_A      => 32,              -- DECIMAL
                  WRITE_MODE_B            => "no_change"      -- String
                )
    port map (
               dbiterrb       => open, -- 1-bit output: Status signal to indicate double bit error occurrence
                                       -- on the data output of port B.
               doutb          => rdata, -- READ_DATA_WIDTH_B-bit output: Data output for port B read operations.
               sbiterrb       => open, -- 1-bit output: Status signal to indicate single bit error occurrence
                                       -- on the data output of port B.
               addra          => waddr, -- ADDR_WIDTH_A-bit input: Address for port A write operations.
               addrb          => raddr, -- ADDR_WIDTH_B-bit input: Address for port B read operations.
               clka           => wclk, -- 1-bit input: Clock signal for port A. Also clocks port B when
                                       -- parameter CLOCKING_MODE is "common_clock".
               clkb           => wclk, -- 1-bit input: Clock signal for port B when parameter CLOCKING_MODE is
                                       -- "independent_clock". Unused when parameter CLOCKING_MODE is
                                       -- "common_clock".
               dina           => wdata, -- WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
               ena            => wclken, -- 1-bit input: Memory enable signal for port A. Must be high on clock
                                         -- cycles when write operations are initiated. Pipelined internally.
               enb            => '1', -- 1-bit input: Memory enable signal for port B. Must be high on clock
                                      -- cycles when read operations are initiated. Pipelined internally.
               injectdbiterra => '0', -- 1-bit input: Controls double bit error injection on input data when
                                      -- ECC enabled (Error injection capability is not available in
                                      -- "decode_only" mode).
               injectsbiterra => '0', -- 1-bit input: Controls single bit error injection on input data when
                                      -- ECC enabled (Error injection capability is not available in
                                      -- "decode_only" mode).
               regceb         => '1', -- 1-bit input: Clock Enable for the last register stage on the output
                                      -- data path.
               rstb           => '0', -- 1-bit input: Reset signal for the final port B output register
                                      -- stage. Synchronously resets output port doutb to the value specified
                                      -- by parameter READ_RESET_VALUE_B.
               sleep          => '0', -- 1-bit input: sleep signal to enable the dynamic power saving feature.
               wea            => "1" -- WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input
                                     -- data port dina. 1 bit wide when word-wide writes are used. In
                                     -- byte-wide write configurations, each bit controls the writing one
                                     -- byte of dina to address addra. For example, to synchronously write
                                     -- only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be
                                     -- 4'b0010.
             );
  else generate
    memblock: block
      type mem_t is array(depth - 1 downto 0) of std_logic_vector(data_w - 1 downto 0);
      signal mem : mem_t := (others => (others => '0'));
    begin
      rdata <= mem(to_integer(unsigned(raddr)));
      process (all)
      begin
        if rising_edge(wclk) then
          mem(to_integer(unsigned(waddr))) <= wdata when wclken;
        end if;
      end process;
    end block;
  end generate;
end;
