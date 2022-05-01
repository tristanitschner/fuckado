// SPDX-License-Identifier: GPL-3.0-or-later
// (c) Tristan Itschner 2022
// why? because formal verification was failing due to an obscure error...
// thus the port

`define FORMAL

module packet_holder  #(
  parameter max_packet_length = 256,
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

  output reg [48 - 1:0] destination_addr,
  output reg [stream_w - 1:0] packet_length
);

reg [stream_w - 1 : 0] storage [max_packet_length - 1 : 0];
localparam empty    = 2'h0;
localparam filling  = 2'h1;
localparam filled   = 2'h2;
localparam clearing = 2'h3;
reg [1:0] state;
reg [$clog2(max_packet_length) - 1:0] fillcount;
wire i_hs,o_hs;
reg [$clog2(max_packet_length) - 1:0] len;

assign i_hs = i_ready && i_valid;
assign o_hs = o_ready && o_valid;

// fillcount
always @(posedge clk) begin
  if (i_hs && o_hs)
    ;
  else if (i_hs) 
    fillcount <= fillcount + 1;
  else if (i_hs) 
    fillcount <= fillcount - 1;
  if (rst)
    fillcount <= 0;
end 

// write
always @(posedge clk) begin
  if (i_hs)
    storage[fillcount] <= i_stream;
end

// main
always @(posedge clk) begin
  len <= 0;
  case (state)
    empty: if (i_hs) state <= filling;
    filling: if (i_hs && i_last) state <= filled;
  filled: if (o_hs) begin
    state <= clearing;
    packet_length <= ($bits(packet_length))'(fillcount + 1);
    destination_addr <= {storage[0], storage[1][15:0]};
  end
    clearing: if (o_hs && o_last) state <= empty;
      default:
      assert(0); // unreachable
  endcase
  if (rst) state <= empty;
end

assign i_ready = (state == empty || state == filling) ? 1 : 0;
assign o_valid = (state == filled || state == clearing) ? 1 : 0;
assign o_last = (state == clearing || fillcount == 0) ? 1 : 0;

assign o_stream = storage[len - fillcount - 1];

`ifdef FORMAL
  reg [63:0] counter_packets_in = 0;
  reg [63:0] counter_packets_out = 0;
  always @(posedge clk) begin
    counter_packets_in <= counter_packets_in + 1;
    counter_packets_out <= counter_packets_out + 1;
    if (rst) begin
      counter_packets_in <= 0;
      counter_packets_out <= 0;
    end
    assert(counter_packets_out == counter_packets_in + fillcount);
  end
`endif

endmodule
