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
    wire [63:0] dout;
    reg clr;
    reg clk;
    reg di_vld;
    
    
    encrypt test(clr,clk,din,di_vld,dout);
    
    initial begin
      clr = 1'b 0;
      clk = 1'b 0;
      din = 64'h 1;
      di_vld = 1'b 0;
      #100 begin
          clr = 1;
          di_vld = 1;
      end
    end
    
    always #20 clk = ~clk;      
endmodule
