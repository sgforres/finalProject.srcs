`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Pitt
// Engineer: Steven Forrest
//////////////////////////////////////////////////////////////////////////////////

/**
This is the test file. It tests the following:
-
**/
module finalProject_tb;
    //******************************//
    //26 Encryption Keys used the design
    //The debugging data were generated based on these keys
    //******************************//
    
    // Test Encrypt
    reg [63:0] din;
    reg [127:0] dinKey;
    wire [63:0] dout;
    wire [63:0] dout2;
    reg clr;
    reg clk;
    reg di_vld;
    
    encrypt test(clr,clk,din,dinKey,di_vld,dout);
    decrypt test2(clr,clk,din,dinKey,di_vld,dout2);
    
    initial begin
      clr = 1'b 0;
      clk = 1'b 0;
      din = 64'heedba5216d8f4b15;
      dinKey = 127'h 1;
      di_vld = 1'b 0;
      #100 begin
          clr = 1;
          di_vld = 1;
      end
    end
    
    always #20 clk = ~clk;      
endmodule
