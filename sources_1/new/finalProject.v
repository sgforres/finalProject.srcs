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
    input clr,
    input clk,
    input [63:0] dinValue,
    input [127:0] dinKey,
    input di_vld,
    output reg [63:0] dout
    );
    //******************************//
    // Please define your own intermediate signals here
    // Below are some intermediate signals for your reference
    // These signals corresponde to the datapath modeling 
    // given in the design specification.
    // Feel free to modify for your own design and debugging
    //******************************//
    
    reg [3:0] i_cnt;
    reg [31:0] ab_xor;
    reg [31:0] a_rot;
    reg [31:0] a;
    
    reg [31:0] ba_xor;
    reg [31:0] b_rot;
    reg [31:0] b;
    
    // The current state of the application
    reg [2:0] CURRENT_STATE = 3'b000; 
    
    // Temp variables for the left rotation
    reg [31:0] tempShiftedVal;
    reg [31:0] tempShiftedVal2; 
    reg [4:0] doubleI; 
    
    //*****************************//
    //*****************************//
    // Start writing your own design code here
    //*****************************//
    //*****************************//
    wire [831:0] keyOut;
    reg [31:0] skey[0:25];
    keyGen key(dinKey, keyOut);
    // FSM
    always @(posedge clk) begin
        if (clr == 1'b0) begin
            // Move and stay at ST_IDLE
            CURRENT_STATE = 3'b001; 
            
            // Clear all variables
            i_cnt = 4'b0000;
            
            for (integer i=0; i<=25; i = i + 1) begin
                skey[i][31:0] = keyOut[32*i+31 -: 32];
            end
            
        end
        // Data flow 4 control states
        //ST_IDLE
        else if (CURRENT_STATE == 3'b001) begin
            if (clr == 1'b1 && di_vld == 1'b1) begin
                // Move to ST_PRE_ROUND
                CURRENT_STATE = 3'b010;
            end
        end
        //ST_PRE_ROUND
        else if (CURRENT_STATE == 3'b010) begin
            // Data Path modeling
            // This is the preround
            // Slide 8 in Practicum Description
            a = dinValue[63:32] + skey[0][31:0];
            b = dinValue[31:0] + skey[1][31:0];
           
            // Set the value to 1 before moving on
            i_cnt = 4'b0001;
            // At the end of one clock cycle we move on
            CURRENT_STATE = 3'b011;
        end
        //ST_ROUND_OP
        else if (CURRENT_STATE == 3'b011) begin
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

            a = a_rot + skey[doubleI][31:0];
            
            // Slide 9 in Practicum Description
            // Part B 
            //b = ((b xor a) <<< a[4:0]) + skey[2×i + 1];
            ba_xor = b ^ a;

            // Left Rotation Operation
            tempShiftedVal = ba_xor << a[4:0];
            // Now shift in the other direction so we can combine the output
            tempShiftedVal2 = ba_xor >> (32 - (a[4:0]));
            b_rot = tempShiftedVal | tempShiftedVal2;

            b = b_rot + skey[doubleI + 1][31:0]; 
            
            // Part C
            dout[63:0] = {a[31:0],b[31:0]}; 
            
            // Perform the round operations
            i_cnt = i_cnt + 1;
            // After we have finished the 12 rounds we move onto ST_READY
            if (i_cnt == 4'b1101) begin
                CURRENT_STATE = 3'b100;
            end
        end 
        //ST_READY
        else if (CURRENT_STATE == 3'b100) begin
            // Do nothing
        end
    end
endmodule

module decrypt(
    input clr,
    input clk,
    input [63:0] dinValue,
    input [127:0] dinKey,
    input di_vld,
    output reg [63:0] dout
    );

    //******************************//
    // Please define your own intermediate signals here
    // Below are some intermediate signals for your reference
    // These signals corresponde to the datapath modeling 
    // given in the design specification.
    // Feel free to modify for your own design and debugging
    //******************************//
    
    reg [3:0] i_cnt;
    reg [31:0] ab_xor;
    reg [31:0] a_rot;
    reg [31:0] a;
    
    reg [31:0] ba_xor;
    reg [31:0] b_rot;
    reg [31:0] b;
    
    // The current state of the application
    reg [2:0] CURRENT_STATE = 3'b000; 
    reg updateState = 1'b0;
    
    // Temp variables for the left rotation
    reg [31:0] tempShiftedVal;
    reg [31:0] tempShiftedVal2; 
    reg [4:0] doubleI; 
    
    //*****************************//
    //*****************************//
    // Start writing your own design code here
    //*****************************//
    //*****************************//
    wire [831:0] keyOut;
    reg [31:0] skey[0:25];
    keyGen key(dinKey, keyOut);
    
    // FSM
    always @(posedge clk) begin
        if (clr == 1'b0) begin
            // Move and stay at ST_IDLE
            CURRENT_STATE = 3'b001; 
            
            // Clear all variables
            i_cnt = 4'b1100;
            
            for (integer i=0; i<=25; i = i + 1) begin
                skey[i][31:0] = keyOut[32*i+31 -: 32];
            end
        end
        // Data flow 4 control states
        //ST_IDLE
        else if (CURRENT_STATE == 3'b001) begin
            if (clr == 1'b1 && di_vld == 1'b1) begin
                // Move to ST_PRE_ROUND
                CURRENT_STATE = 3'b010;
            end
        end
        //ST_PRE_ROUND
        else if (CURRENT_STATE == 3'b010) begin
            // Data Path modeling
            // This is the preround
            // Slide 7
            a = dinValue[63:32];
            b = dinValue[31:0];
           
            // Set the value to 12 before moving on
            i_cnt = 4'b1100;
            // At the end of one clock cycle we move on
            CURRENT_STATE = 3'b011;
        end
        //ST_ROUND_OP
        else if (CURRENT_STATE == 3'b011) begin
            // Loop here for a while
            
            //Shared vars
            doubleI = i_cnt << 1;
            
            // Data Path modeling
            // This is the Round
            // Slide 7
            // B = ((B - S[2×i +1]) >>> A[4:0]) xor A;
            b_rot = b - skey[doubleI + 1][31:0];
            
            // Right Rotation
            tempShiftedVal = b_rot >> a[4:0];
            // Now shift in the other direction so we can combine the output
            tempShiftedVal2 = b_rot << (32 - (a[4:0]));
            b_rot = tempShiftedVal | tempShiftedVal2;
            
            // XOR A
            b = b_rot ^ a;
            
            // A = ((A - S[2×i]) >>> B[4:0]) xor B;
            a_rot = a - skey[doubleI][31:0];
         
            // Right Rotation
            tempShiftedVal = a_rot >> b[4:0];
            // Now shift in the other direction so we can combine the output
            tempShiftedVal2 = a_rot << (32 - (b[4:0]));
            a_rot = tempShiftedVal | tempShiftedVal2;
            
            //XOR B
            a = a_rot ^ b;
         
            // Part C
            dout[63:0] = {a[31:0],b[31:0]};
            
            // Perform the round operations
            i_cnt = i_cnt - 1;
            // After we have finished the 12 rounds we move onto ST_READY
            if (i_cnt == 4'b0000) begin
                CURRENT_STATE = 3'b100;
            end
        end 
        //ST_READY
        else if (CURRENT_STATE == 3'b100) begin
            b = b - skey[1][31:0];
            a = a - skey[0][31:0];
            dout[63:0] = {a[31:0],b[31:0]};
            // Do nothing
        end
    end
endmodule

module keyGen(
    input [127:0] din,
    output [831:0] dout // 26 elements, 32 bits each
    );
    
  assign dout = 832'h65046380F6CC14314319230430D76B0AAE1621674DBFCA763B0A1D2B61A78BB8A7EFC24936C03196DEDE871AA7901C492799A4DD4B792F99713AD82DD427686B11A83A5D3125065DF621ED22513E1454284B830370F83B8A460C608546F8E8C51A37F7FB9BBBD8C8;
  
endmodule

module inputModule(

    );
endmodule

module outputModule(

    );
endmodule

module finalProject(

    );

endmodule
