`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2016 02:29:59 AM
// Design Name: 
// Module Name: fifo_main
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module fifo_main(
    input clk,
    input clr,
    input [63:0] din,
    input wr_en,
    input rd_en,
    output [63:0] dout,
    output full,
    output empty
    );
    fifo_ip r1(.clk(clk), .rst(clr), .din(din), .wr_en(wr_en), .rd_en(rd_en), .dout(dout), .full(full), .empty(empty));    
endmodule
