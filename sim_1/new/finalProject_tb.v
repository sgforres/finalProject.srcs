`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Pitt
// Engineer: Steven Forrest
//////////////////////////////////////////////////////////////////////////////////

/**
This is the test file. It tests the following:
-Encrypt
-Decrpyt
-Final Project
**/
module finalProject_tb;
    // Test Encrypt and Decrypt
    reg [63:0] din;
    reg [63:0] din2;
    reg [127:0] dinKey;
    wire [63:0] dout;
    wire [63:0] dout2;
    reg clr;
    reg clr2;
    reg clk;
    reg di_vld;
    reg readEnable;
    reg writeEnable;
    
    wire [3:0] red;
    wire [3:0] green;
    wire [3:0] blue;
    wire Vsync;
    wire Hsync;
    wire shouldEncrypt;
    wire shouldDecrypt;
    wire selectValue;
    wire selectKey;
    wire start;
    wire reset;
    wire PS2_CLK;
    wire PS2_DATA;
    
    encrypt test(clr,clk,din,dinKey,di_vld,dout);
    decrypt test2(clr,clk,din2,dinKey,di_vld,dout2);
    finalProject fp(clk,selectValue,selectKey, start, shouldEncrypt,shouldDecrypt,PS2_CLK,PS2_DATA, reset, red, green, blue, Hsync,Vsync);
    
    initial begin
      clr = 1'b 0;
      clr2 = 1'b0;
      clk = 1'b 0;
      din = 64'h0;
      din2 = 64'heedba5216d8f4b15;
      dinKey = 128'h 1;
      di_vld = 1'b0;
      readEnable = 1'b0;
      #100 begin
          clr = 1;
          di_vld = 1;
          writeEnable = 1;
      end
    end
    
    always #20 clk = ~clk;
    always #400 readEnable = 1'b1;
endmodule
