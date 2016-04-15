`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2016 02:32:25 AM
// Design Name: 
// Module Name: fifo_tb
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

module fifo_tb;

reg[63:0] din;
wire[63:0] dout;
reg clr;
reg clk;
reg wr_en;
reg rd_en;
wire full;
wire empty;


fifo_main test(.clk(clk), .rst(clr), .din(din), .wr_en(wr_en), .rd_en(rd_en), .dout(dout), .full(full), .empty(empty));

initial begin
    clr = 1'b 0;
    clk = 1'b 0;
    din = 64'h 1;
    wr_en = 1'b 0;
    rd_en = 1'b 0;
    
    #40 begin
        clr = 1'b 1;
    end
    
    #80 begin
        wr_en = 1'b 1;
    end
    #160 begin
        wr_en = 1'b 0;
    end
    
    #200 begin
        rd_en =1'b0;
end
end
always #20 clk = ~clk;


endmodule
