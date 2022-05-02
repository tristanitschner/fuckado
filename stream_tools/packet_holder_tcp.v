// SPDX-License-Identifier: GPL-3.0-or-later
// (c) Tristan Itschner 2022

`define FORMAL

module packet_holder_tcp#(
  parameter max_packet_length = 2048, // enough to fit one tcp packet
  parameter stream_w = 32
)
(
  input clk,
  input rst,

  input [stream_w - 1:0] i_stream,
  output i_ready,
  input i_valid,
  input i_last,

  output [stream_w - 1:0] o_stream,
  input o_ready,
  output o_valid,
  output o_last, 
  input drop,

  output reg error_packet_too_long,
  input wire clear_errors,

  output reg [stream_w - 1:0] packet_length, // minus one

  // note that all of these are in network byte order -> reversed
  // ip frame
  output reg [3:0]  ip_version,
  output reg [3:0]  ip_hlen,
  output reg [7:0]  ip_service_type,
  output reg [15:0] ip_total_length,
  output reg [15:0] ip_identification,
  output reg [3:0]  ip_flags,
  output reg [11:0] ip_fragment_offset,
  output reg [7:0]  ip_time_to_life,
  output reg [7:0]  ip_protocol,
  output reg [15:0] ip_header_checksum,
  output reg [31:0] ip_source_ip_addr,
  output reg [31:0] ip_destination_ip_addr,
  // tcp frame
  output reg [15:0] tcp_source_port,
  output reg [15:0] tcp_destination_port,
  output reg [31:0] tcp_sequence_number,
  output reg [31:0] tcp_ack_number,
  output reg [3:0]  tcp_header_length,
  output reg [5:0]  tcp_code_bits,
  output reg [15:0] tcp_window_size,
  output reg [15:0] tcp_checksum,
  output reg [15:0] tcp_urgent_pointer
);

reg [stream_w - 1 : 0] storage [max_packet_length - 1 : 0];
localparam filling  = 0;
localparam clearing = 1;
reg state;
reg [$clog2(max_packet_length) - 1:0] fillcount; 
wire i_hs,o_hs;
reg [$clog2(max_packet_length) - 1:0] len;
reg error;
reg error_packet_too_long_p;

always @(posedge clk) error_packet_too_long_p <= error_packet_too_long;

// self-recovery in case of error -> drop the packet
// also separate drop functionality, in case the packet shall not be accepted
always @(posedge clk) begin
  if ((!error_packet_too_long_p && error_packet_too_long )||
    (o_hs && drop))
    error <= 1;
  else
    error <= 0;
end

assign i_hs = i_ready && i_valid;
assign o_hs = o_ready && o_valid;

// fillcount
always @(posedge clk) begin
  if (i_hs && o_hs)
    assert(0); // unreachable
  else if (i_hs) 
    fillcount <= fillcount + 1;
  else if (o_hs) 
    fillcount <= fillcount - 1;
  if (rst || error)
    fillcount <= 0;
end 

// write
always @(posedge clk) begin
  if (i_hs)
    storage[fillcount] <= i_stream;
end

// main
always @(posedge clk) begin
  case (state)
    filling: if (i_hs && i_last) begin
      len <= fillcount + 1;
      state <= clearing;
      packet_length <= fillcount + 1;

      // note that bit order insed 32 bit is reversed
      ip_version             <= storage[0][31:28];
      ip_hlen                <= storage[0][27:24];
      ip_service_type        <= storage[0][23:16];
      ip_total_length        <= storage[0][15:0];
      ip_identification      <= storage[1][31:16];
      ip_flags               <= storage[1][15:12];
      ip_fragment_offset     <= storage[1][11:0];
      ip_time_to_life        <= storage[2][31:24];
      ip_protocol            <= storage[2][23:16];
      ip_header_checksum     <= storage[2][15:0];
      ip_source_ip_addr      <= storage[3];
      ip_destination_ip_addr <= storage[4];
      // not dealing with options field

      tcp_source_port      <= storage[5][31:16];
      tcp_destination_port <= storage[5][15:0];
      tcp_sequence_number  <= storage[6];
      tcp_ack_number       <= storage[7];
      tcp_header_length    <= storage[8][31:28];
      tcp_code_bits        <= storage[8][21:16];
      tcp_window_size      <= storage[8][15:0];
      tcp_checksum         <= storage[9][31:16];
      tcp_urgent_pointer   <= storage[9][15:0];

    end
    clearing: if (o_hs && o_last) state <= filling;
      default:
      assert(0); // unreachable
  endcase
  if (rst || error) state <= filling;
end

assign i_ready = (state == filling) ? 1 : 0;
assign o_valid = (state == clearing) ? 1 : 0;
assign o_last = (state == clearing && fillcount == 1) ? 1 : 0;

assign o_stream = storage[len - fillcount];

// error logic
always @(posedge clk) begin
  if (i_hs && i_last && fillcount == max_packet_length - 1)
    error_packet_too_long <= 1;
  else if (clear_errors) 
    error_packet_too_long <= 0;
  if (rst)
    error_packet_too_long <= 0;
end

`ifdef FORMAL
  reg [63:0] counter_packets_in = 0;
  reg [63:0] counter_packets_out = 0;

  initial assume(rst);
  initial assume(state == filling);
  always assume (fillcount <= max_packet_length); // for induction

  reg [63:0] tickcount = 0;
  always @(posedge clk) tickcount <= tickcount + 1;
  wire done;
  assign done = tickcount > 30;
  always @(posedge clk) if (tickcount > 3) assume(rst == 0);
  always @(posedge clk) cover (done);

  always @(posedge clk) begin
    // no packets longer than max_packet_length
    if (fillcount == max_packet_length - 1 && i_hs) assume (i_last);

    if (error) counter_packets_in <= counter_packets_in - fillcount;
    else if (i_hs) counter_packets_in <= counter_packets_in + 1;
    if (o_hs) counter_packets_out <= counter_packets_out + 1;
    if (rst) begin
      counter_packets_in <= 0;
      counter_packets_out <= 0;
    end
    if (!rst) begin
      // what goes in, must be the same, as what goes out
      assert(counter_packets_in == counter_packets_out + fillcount);
      // we are either writing, or reading, but never both at the same time
      if (i_hs) assert (!o_hs);
      if (o_hs) assert (!i_hs);
      // check if error clearing works
      if ($past(clear_errors)) assert (error_packet_too_long == 0);
    end
  end
`endif

endmodule
