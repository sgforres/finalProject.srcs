`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Pitt
// Engineer: Steven Forrest
//////////////////////////////////////////////////////////////////////////////////
/**
This file contains the following high level modules:
- Encrypt
- Decrypt
- Key Generation
- Input
- Output
*/
module encrypt(

    );
endmodule

module decrypt(

    );
endmodule

module keyGen(

    );
endmodule

module inputModule(

    );
endmodule

module outputModule(

    );
endmodule

module finalProject(
    clr,
    clk,
    din,
    di_vld,
    dout
    );
    
        //******************************//
    //IO signal defination
    //******************************//
    
    input clr;
    input clk;
    input [63:0] din;
    input di_vld;
    output [63:0] dout;

    //******************************//
    //26 Encryption Keys used the design
    //The debugging data were generated based on these keys
    //******************************//
    
    parameter [31:0] skey[0:25]=
          {32'h9BBBD8C8, 32'h1A37F7FB, 32'h46F8E8C5,
          32'h460C6085, 32'h70F83B8A, 32'h284B8303, 32'h513E1454, 32'hF621ED22,
          32'h3125065D, 32'h11A83A5D, 32'hD427686B, 32'h713AD82D, 32'h4B792F99,
          32'h2799A4DD, 32'hA7901C49, 32'hDEDE871A, 32'h36C03196, 32'hA7EFC249,
          32'h61A78BB8, 32'h3B0A1D2B, 32'h4DBFCA76, 32'hAE162167, 32'h30D76B0A,
          32'h43192304, 32'hF6CC1431, 32'h65046380};
    
    
    
    //******************************//
    //Please define your own intermediate signals here
    //Below are some intermediate signals for your reference
    //These signals corresponde to the datapath modeling 
    //given in the design specification.
    //Feel free to modify for your own design and debugging
    //******************************//
    
    wire clr;
    wire clk;
    wire [63:0] din;
    wire di_vld;
    reg [63:0] dout;
    
    reg [3:0] i_cnt;
    reg [31:0] ab_xor;
    reg [31:0] a_rot;
    reg [31:0] a;
    
    reg [31:0] ba_xor;
    reg [31:0] b_rot;
    reg [31:0] b;
    
    // Four Control States
    reg [2:0] CLEAR = 3'b000;
    reg [2:0] ST_IDLE = 3'b001;
    reg [2:0] ST_PRE_ROUND = 3'b010;    
    reg [2:0] ST_ROUND_OP = 3'b011;
    reg [2:0] ST_READY = 3'b100;
    
    // The current state of the application
    reg [2:0] CURRENT_STATE = 3'b000; 
    reg updateState = 1'b0;
    
    // Temp variables for the left rotation
    reg [31:0] tempShiftedVal;
    reg [31:0] tempShiftedVal2; 
    reg [4:0] doubleI; 
    //*****************************//
    //*****************************//
    //Start writing your own design code here
    //*****************************//
    //*****************************//
    
    // FSM
    always @(posedge clk) begin
        if (clr == 1'b0) begin
            // Move and stay at ST_IDLE
            CURRENT_STATE = 3'b001; 
            
            // Clear all variables
            i_cnt = 4'b0000;
        end
        // Data flow 4 control states
        if (CURRENT_STATE == ST_IDLE) begin
            if (clr == 1'b1 && di_vld == 1'b1) begin
                // Move to ST_PRE_ROUND
                updateState = 1'b1;
            end
        end 
        if (CURRENT_STATE == ST_PRE_ROUND) begin
            // Data Path modeling
            // This is the preround
            // Slide 8 in Practicum Description
            a = din[63:32] + skey[0];
            b = din[31:0] + skey[1];
           
            // Set the value to 1 before moving on
            i_cnt = i_cnt + 1;
            // At the end of one clock cycle we move on
            updateState = 1'b1;
        end 
        if (CURRENT_STATE == ST_ROUND_OP) begin
            // Loop here for a while
            
            //Shared vars
            doubleI = i_cnt << 1;
            
            // Data Path modeling
            // This is the Round
            // Slide 8 in Practicum Description
            // Part A
            // a = ((a xor b) <<< b[4:0]) + skey[2×i];
            ab_xor = a ^ b;
            
            // Left Rotation Operation
            tempShiftedVal = ab_xor << b[4:0];
            // Now shift in the other direction so we can combine the output
            tempShiftedVal2 = ab_xor >> (32 - (b[4:0]));
            a_rot = tempShiftedVal | tempShiftedVal2;

            
            a = a_rot + skey[doubleI];
            
            // Slide 9 in Practicum Description
            // Part B 
            //b = ((b xor a) <<< a[4:0]) + skey[2×i + 1];
            ba_xor = b ^ a;

            // Left Rotation Operation
            tempShiftedVal = ba_xor << a[4:0];
            // Now shift in the other direction so we can combine the output
            tempShiftedVal2 = ba_xor >> (32 - (a[4:0]));
            b_rot = tempShiftedVal | tempShiftedVal2;

            b = b_rot + skey[doubleI + 1]; 
            
            // Part C
            dout[63:0] = {a[31:0],b[31:0]}; 
            
            // Perform the round operations
            i_cnt = i_cnt + 1;
            // After we have finished the 12 rounds we move onto ST_READY
            if (i_cnt == 4'b1101) begin
                updateState = 1'b1;
            end
        end 
        if (CURRENT_STATE == ST_READY) begin
            // Do nothing
        end
        // Finally progress if needed
        if (updateState == 1'b1) begin
            CURRENT_STATE = CURRENT_STATE + 1;
            updateState = 1'b0;
        end
    end
endmodule
