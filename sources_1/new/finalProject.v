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
- Output
- finalProject

The goal of the project is to complete the RC5 encryption and decryption algorith
*/

module encrypt(
    input clr,
    input clk,
    input [63:0] dinValue,
    input [127:0] dinKey,
    input di_vld,
    output [63:0] dout
    );

    reg [3:0] i_cnt;
    reg [5:0] loopCount;
    reg [31:0] a;
    reg [31:0] b;
    
    // The current state of the application
    reg [2:0] CURRENT_STATE = 3'b000; 

    // Go and generate the keys
    wire [831:0] keyOut;
    reg [31:0] skey[0:25];
    keyGen key(dinKey, keyOut);
    
    // Variables for pipeline
    wire [31:0] aOut1;
    wire [31:0] bOut1;
    wire [63:0] dOut1;
    wire [31:0] aOut2;
    wire [31:0] bOut2;
    wire [63:0] dOut2;
    wire [31:0] aOut3;
    wire [31:0] bOut3;
    wire [63:0] dOut3;
    wire [31:0] aOut4;
    wire [31:0] bOut4;
    wire [63:0] dOut4;
    wire [31:0] aOut5;
    wire [31:0] bOut5;
    wire [63:0] dOut5;
    wire [31:0] aOut6;
    wire [31:0] bOut6;
    wire [63:0] dOut6;
    wire [31:0] aOut7;
    wire [31:0] bOut7;
    wire [63:0] dOut7;
    wire [31:0] aOut8;
    wire [31:0] bOut8;
    wire [63:0] dOut8;
    wire [31:0] aOut9;
    wire [31:0] bOut9;
    wire [63:0] dOut9;
    wire [31:0] aOut10;
    wire [31:0] bOut10;
    wire [63:0] dOut10;
    wire [31:0] aOut11;
    wire [31:0] bOut11;
    wire [63:0] dOut11;
    wire [31:0] aOut12;
    wire [31:0] bOut12;
    wire [63:0] dOut12;
    
    // Pipeline
    pipelineEncrypt  p1(clk, a, b, skey[2][31:0],skey[3][31:0],dOut1,aOut1,bOut1, CURRENT_STATE);
    pipelineEncrypt  p2(clk, aOut1, bOut1, skey[4][31:0],skey[5][31:0],dOut2,aOut2,bOut2,CURRENT_STATE);
    pipelineEncrypt  p3(clk, aOut2, bOut2, skey[6][31:0],skey[7][31:0],dOut3,aOut3,bOut3,CURRENT_STATE);
    pipelineEncrypt  p4(clk, aOut3, bOut3, skey[8][31:0],skey[9][31:0],dOut4,aOut4,bOut4,CURRENT_STATE);
    pipelineEncrypt  p5(clk, aOut4, bOut4, skey[10][31:0],skey[11][31:0],dOut5,aOut5,bOut5,CURRENT_STATE);
    pipelineEncrypt  p6(clk, aOut5, bOut5, skey[12][31:0],skey[13][31:0],dOut6,aOut6,bOut6,CURRENT_STATE);
    pipelineEncrypt  p7(clk, aOut6, bOut6, skey[14][31:0],skey[15][31:0],dOut7,aOut7,bOut7,CURRENT_STATE);
    pipelineEncrypt  p8(clk, aOut7, bOut7, skey[16][31:0],skey[17][31:0],dOut8,aOut8,bOut8,CURRENT_STATE);
    pipelineEncrypt  p9(clk, aOut8, bOut8, skey[18][31:0],skey[19][31:0],dOut9,aOut9,bOut9,CURRENT_STATE);
    pipelineEncrypt  p10(clk, aOut9, bOut9, skey[20][31:0],skey[21][31:0],dOut10,aOut10,bOut10,CURRENT_STATE);
    pipelineEncrypt  p11(clk, aOut10, bOut10, skey[22][31:0],skey[23][31:0],dOut11,aOut11,bOut11,CURRENT_STATE);
    pipelineEncrypt  p12(clk, aOut11, bOut11, skey[24][31:0],skey[25][31:0],dout,aOut12,bOut12,CURRENT_STATE);
    
    // FSM
    always @(posedge clk or posedge clr) begin
        if (clr == 1'b0) begin
            // Move and stay at ST_IDLE
            CURRENT_STATE = 3'b001; 
            
            // Clear all variables
            i_cnt = 4'b0000;
            
            for (loopCount=0; loopCount<=25; loopCount = loopCount + 1) begin
                skey[loopCount][31:0] = keyOut[32*loopCount+31 -: 32];
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
            i_cnt = i_cnt + 1;
            // After we have finished the 12 rounds we move onto ST_READY
            if (i_cnt === 4'b1101) begin
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
    
    reg [3:0] i_cnt;
    reg [5:0] loopCount;
    reg [31:0] a;
    reg [31:0] b;
    
    // The current state of the application
    reg [2:0] CURRENT_STATE = 3'b000; 
    
    // Go and generate the keys
    wire [831:0] keyOut;
    reg [31:0] skey[0:25];
    keyGen key(dinKey, keyOut);
    
    // Variables for pipeline
    wire [31:0] aOut1;
    wire [31:0] bOut1;
    wire [63:0] dOut1;
    wire [31:0] aOut2;
    wire [31:0] bOut2;
    wire [63:0] dOut2;
    wire [31:0] aOut3;
    wire [31:0] bOut3;
    wire [63:0] dOut3;
    wire [31:0] aOut4;
    wire [31:0] bOut4;
    wire [63:0] dOut4;
    wire [31:0] aOut5;
    wire [31:0] bOut5;
    wire [63:0] dOut5;
    wire [31:0] aOut6;
    wire [31:0] bOut6;
    wire [63:0] dOut6;
    wire [31:0] aOut7;
    wire [31:0] bOut7;
    wire [63:0] dOut7;
    wire [31:0] aOut8;
    wire [31:0] bOut8;
    wire [63:0] dOut8;
    wire [31:0] aOut9;
    wire [31:0] bOut9;
    wire [63:0] dOut9;
    wire [31:0] aOut10;
    wire [31:0] bOut10;
    wire [63:0] dOut10;
    wire [31:0] aOut11;
    wire [31:0] bOut11;
    wire [63:0] dOut11;
    wire [31:0] aOut12;
    wire [31:0] bOut12;
    wire [63:0] dOut12;
    
    // Pipeline
    pipelineDecrypt  p1(clk, a, b, skey[25][31:0],skey[24][31:0],dOut1,aOut1,bOut1, CURRENT_STATE);
    pipelineDecrypt  p2(clk, aOut1, bOut1, skey[23][31:0],skey[22][31:0],dOut2,aOut2,bOut2,CURRENT_STATE);
    pipelineDecrypt  p3(clk, aOut2, bOut2, skey[21][31:0],skey[20][31:0],dOut3,aOut3,bOut3,CURRENT_STATE);
    pipelineDecrypt  p4(clk, aOut3, bOut3, skey[19][31:0],skey[18][31:0],dOut4,aOut4,bOut4,CURRENT_STATE);
    pipelineDecrypt  p5(clk, aOut4, bOut4, skey[17][31:0],skey[16][31:0],dOut5,aOut5,bOut5,CURRENT_STATE);
    pipelineDecrypt  p6(clk, aOut5, bOut5, skey[15][31:0],skey[14][31:0],dOut6,aOut6,bOut6,CURRENT_STATE);
    pipelineDecrypt  p7(clk, aOut6, bOut6, skey[13][31:0],skey[12][31:0],dOut7,aOut7,bOut7,CURRENT_STATE);
    pipelineDecrypt  p8(clk, aOut7, bOut7, skey[11][31:0],skey[10][31:0],dOut8,aOut8,bOut8,CURRENT_STATE);
    pipelineDecrypt  p9(clk, aOut8, bOut8, skey[9][31:0],skey[8][31:0],dOut9,aOut9,bOut9,CURRENT_STATE);
    pipelineDecrypt  p10(clk, aOut9, bOut9, skey[7][31:0],skey[6][31:0],dOut10,aOut10,bOut10,CURRENT_STATE);
    pipelineDecrypt  p11(clk, aOut10, bOut10, skey[5][31:0],skey[4][31:0],dOut11,aOut11,bOut11,CURRENT_STATE);
    pipelineDecrypt  p12(clk, aOut11, bOut11, skey[3][31:0],skey[2][31:0],dOut12,aOut12,bOut12,CURRENT_STATE);
    
    // FSM
    always @(posedge clk) begin
        if (clr == 1'b0) begin
            // Move and stay at ST_IDLE
            CURRENT_STATE = 3'b001; 
            
            // Clear all variables
            i_cnt = 4'b1100;
            
            for (loopCount=0; loopCount<=25; loopCount = loopCount + 1) begin
                skey[loopCount][31:0] = keyOut[32*loopCount+31 -: 32];
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
            // Perform the round operations
            i_cnt = i_cnt - 1;
            // After we have finished the 12 rounds we move onto ST_READY
            if (i_cnt == 4'b0000) begin
                CURRENT_STATE = 3'b100;
            end
        end 
        //ST_READY
        else if (CURRENT_STATE == 3'b100) begin
            b = bOut12 - skey[1][31:0];
            a = aOut12 - skey[0][31:0];
            dout[63:0] = {a[31:0],b[31:0]};
            CURRENT_STATE = 3'b101;
            // Do nothing
        end
    end
endmodule

module keyGen(
    input [127:0] din,
    output reg [831:0] dout // 26 elements, 32 bits each
    );
    // Old output, Uncomment if you want to check against practicum numbers
    //assign dout = 832'h65046380F6CC14314319230430D76B0AAE1621674DBFCA763B0A1D2B61A78BB8A7EFC24936C03196DEDE871AA7901C492799A4DD4B792F99713AD82DD427686B11A83A5D3125065DF621ED22513E1454284B830370F83B8A460C608546F8E8C51A37F7FB9BBBD8C8;
  
    reg [7:0] loopCount;
    reg [7:0] i = 8'b0;
    reg [7:0] j = 8'b0;
    reg [31:0] L[0:3];
    reg [31:0] S[0:25];
    reg [31:0] A = 32'b0;
    reg [31:0] B = 32'b0;
    reg [31:0] A_intermediate = 32'b0;
    reg [31:0] B_intermediate = 32'b0;
    
    // Temp variables for the left rotation
    reg [31:0] tempShiftedVal;
    reg [31:0] tempShiftedVal2; 
    
    always @(din) begin
        // Slide 5, Initialize S
        S[0][31:0] = 32'hB7E15163;
        for (loopCount=1; loopCount<=25; loopCount = loopCount + 1) begin
            S[loopCount][31:0] = S[loopCount - 1][31:0] + 32'h9E3779B9 ;
        end  
        // Slide 5, Initialize L
        for (loopCount=0; loopCount<=3; loopCount = loopCount + 1) begin
            L[loopCount][31:0] = din[32*loopCount+31 -: 32];
        end
        // Slide 5, Round Key Generation
        for (loopCount=0; loopCount<=77; loopCount = loopCount + 1) begin
            A_intermediate  = (S[i] + A + B);// <<< 3;
            // Left Rotation Operation
            tempShiftedVal = A_intermediate << 3;
            // Now shift in the other direction so we can combine the output
            tempShiftedVal2 = A_intermediate >> (32 - 3);
            A = tempShiftedVal | tempShiftedVal2;
            
            B_intermediate  = (L[j] + A + B);// <<< (A + B);
            // Left Rotation Operation
            tempShiftedVal = B_intermediate << (A + B);
            // Now shift in the other direction so we can combine the output
            tempShiftedVal2 = B_intermediate >> (32 - (A + B));
            B = tempShiftedVal | tempShiftedVal2; 
            
            A = S[i];
            B = L [j];
            i = (i + 1) % 26;
            j = (j + 1) % 4;
        end  
        // Need to build up the return array
        for (loopCount=0; loopCount<=25; loopCount = loopCount + 1) begin
            dout[32*loopCount+31 -: 32] = S[loopCount][31:0];
        end 
    end
endmodule

module pipelineEncrypt(
    input clk,
    input [31:0] a,
    input [31:0] b,
    input [31:0] skey,
    input [31:0] skey2,
    output reg [63:0] dout,
    output reg [31:0] aout, 
    output reg [31:0] bout,
    input [2:0] CURRENT_STATE
    );
    reg [31:0] ab_xor;
    reg [31:0] a_rot;
    reg [31:0] ba_xor;
    reg [31:0] b_rot;
    
    // Temp variables for the left rotation
    reg [31:0] tempShiftedVal;
    reg [31:0] tempShiftedVal2; 
    
    always @(posedge clk) begin
        if (CURRENT_STATE == 3'b011) begin
            // Data Path modeling
            // This is the Round
            // Slide 8 in Practicum Description
            // Part A
            // a = ((a xor b) <<< b[4:0]) + skey[2�i];
            ab_xor = a ^ b;
            
            // Left Rotation Operation
            tempShiftedVal = ab_xor << b[4:0];
            // Now shift in the other direction so we can combine the output
            tempShiftedVal2 = ab_xor >> (32 - (b[4:0]));
            a_rot = tempShiftedVal | tempShiftedVal2;
        
            aout = a_rot + skey;
            
            // Slide 9 in Practicum Description
            // Part B 
            //b = ((b xor a) <<< a[4:0]) + skey[2�i + 1];
            ba_xor = b ^ aout;
        
            // Left Rotation Operation
            tempShiftedVal = ba_xor << aout[4:0];
            // Now shift in the other direction so we can combine the output
            tempShiftedVal2 = ba_xor >> (32 - (aout[4:0]));
            b_rot = tempShiftedVal | tempShiftedVal2;
        
            bout = b_rot + skey2; 
            
            // Part C
            dout[63:0] = {aout[31:0],bout[31:0]}; 
        end
    end
endmodule
   
module pipelineDecrypt(
    input clk,
    input [31:0] a,
    input [31:0] b,
    input [31:0] skey,
    input [31:0] skey2,
    output reg [63:0] dout,
    output reg [31:0] aout, 
    output reg [31:0] bout,
    input [2:0] CURRENT_STATE
    );
    reg [31:0] ab_xor;
    reg [31:0] a_rot;
    reg [31:0] ba_xor;
    reg [31:0] b_rot;
    
    // Temp variables for the right rotation
    reg [31:0] tempShiftedVal;
    reg [31:0] tempShiftedVal2; 
    
    always @(posedge clk) begin
        if (CURRENT_STATE == 3'b011) begin
            // Data Path modeling
            // This is the Round
            // Slide 7
            // B = ((B - S[2�i +1]) >>> A[4:0]) xor A;
            b_rot = b - skey;
            
            // Right Rotation
            tempShiftedVal = b_rot >> a[4:0];
            // Now shift in the other direction so we can combine the output
            tempShiftedVal2 = b_rot << (32 - (a[4:0]));
            b_rot = tempShiftedVal | tempShiftedVal2;
            
            // XOR A
            bout = b_rot ^ a;
            
            // A = ((A - S[2�i]) >>> B[4:0]) xor B;
            a_rot = a - skey2;
         
            // Right Rotation
            tempShiftedVal = a_rot >> bout[4:0];
            // Now shift in the other direction so we can combine the output
            tempShiftedVal2 = a_rot << (32 - (bout[4:0]));
            a_rot = tempShiftedVal | tempShiftedVal2;
            
            //XOR B
            aout = a_rot ^ bout;
         
            // Part C
            dout[63:0] = {aout[31:0],bout[31:0]};
        
        end
    end
endmodule

/**
This is the output module to the VGA display
*/
module outputModule(
    input clk,
    output reg [3:0] VGA_R,
    output reg [3:0] VGA_G,
    output reg [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    // These are the characters that should be displayed per line
    input [63:0] lineOne,
    input [63:0] lineTwo,
    input [63:0] lineThree,
    input [63:0] lineFour,
    input [63:0] lineFive,
    input [63:0] lineSix
    );
    
    // NOTE: My display requires this to be 1280X1080@60Hz
    reg [11:0] counterHorizontal = 12'b0;
    reg [11:0] counterVertical = 12'b0;
    reg [11:0] characterIndex = 12'b0;
    integer horizontalLine = 1600;
    integer verticalLine = 1100;
    integer usableAreaH = 1280;
    integer usableAreaV = 1024;
    
    // Should the pixel be turned on
    reg isPixelOn;
    //Local variable for storing what character we are drawing
    reg [3:0] currentChar;
    
    /**
    This is how I draw to the screen
    It tells which bits to turn on
    Note: This is "backwards" since 0 is actually the last character
    */
    parameter [39:0] characterMap[0:15] = {
        {40'b0000011110100101001010010100101001011110},         // Draw a 0
        {40'b0000010000100001000010000100001000010000},         // Draw a 1
        {40'b0000011110000100001011110100001000011110},         // Draw a 2
        {40'b0000011110100001000011110100001000011110},         // Draw a 3
        {40'b0000010000100001000011110100101001010010},         // Draw a 4
        {40'b0000011110100001000011110000100001011110},         // Draw a 5
        {40'b0000011110100101001011110000100001011110},         // Draw a 6
        {40'b0000010000100001000010000100001000011110},         // Draw a 7
        {40'b0000011110100101001011110100101001011110},         // Draw a 8
        {40'b0000010000100001000011110100101001011110},         // Draw a 9
        {40'b0000010010100101001011110100101001011110},         // Draw a A
        {40'b0000011110100101001011110100101001001110},         // Draw a B
        {40'b0000011110000100001000010000100001011110},         // Draw a C
        {40'b0000001110100101001010010100101001001110},         // Draw a D
        {40'b0000011110000100001011110000100001011110},         // Draw a E
        {40'b0000000010000100001011110000100001011110}          // Draw a F
    };
    
    // https://learn.digilentinc.com/Documents/269
    assign VGA_HS = (counterHorizontal < usableAreaH) ? 0 : 1;
    assign VGA_VS = (counterVertical < usableAreaV) ? 0 : 1;
    
    always @(posedge clk) begin
        if (counterHorizontal < horizontalLine - 1) begin
                    // THIS IS WHERE WE DO ALL OF THE COLOR WORK
                    
                    // Start with the pixel turned "off"
                    isPixelOn = 1'b0;

                    if (counterHorizontal > 159 && counterHorizontal < 1120 && counterVertical > 47 && counterVertical < 1000) begin
                        // This is the basic color for the background. This is what color is shown when pixel is "off"
                        VGA_R = 4'b1111;
                        VGA_G = 4'b1111;
                        VGA_B = 4'b1111;
                        //Make sure we only draw characters for the first 64 bits
                        if (counterHorizontal - 160 < 160) begin
                        
                            // Draw the first line of characters to the screen
                            if (counterVertical - 48 < 16) begin
                                currentChar = lineOne[66-((counterHorizontal - 160)/10*4 + 3) -: 4];
                                isPixelOn = characterMap[currentChar[3:0]][(counterHorizontal%10)/2 + 5*((counterVertical%16)/2)];
                            end
                            
                            // Draw the second line of characters to the screen
                            if (counterVertical - 48 > 31 && counterVertical - 48 < 48) begin
                                currentChar = lineTwo[66-((counterHorizontal - 160)/10*4 + 3) -: 4];
                                isPixelOn = characterMap[currentChar[3:0]][(counterHorizontal%10)/2 + 5*((counterVertical%16)/2)];
                            end

                            // Draw the third line of characters to the screen                            
                            if (counterVertical - 48 > 63 && counterVertical - 48 < 80) begin
                                currentChar = lineThree[66-((counterHorizontal - 160)/10*4 + 3) -: 4];
                                isPixelOn = characterMap[currentChar[3:0]][(counterHorizontal%10)/2 + 5*((counterVertical%16)/2)];
                            end
                            
                            // Draw the fourth line of characters to the screen                              
                            if (counterVertical - 48 > 95 && counterVertical - 48 < 112) begin
                                currentChar = lineFour[66-((counterHorizontal - 160)/10*4 + 3) -: 4];
                                isPixelOn = characterMap[currentChar[3:0]][(counterHorizontal%10)/2 + 5*((counterVertical%16)/2)];
                            end
                            
                            // Draw the fifth line of characters to the screen  
                            if (counterVertical - 48 > 127 && counterVertical - 48 < 144) begin
                                currentChar = lineFive[66-((counterHorizontal - 160)/10*4 + 3) -: 4];
                                isPixelOn = characterMap[currentChar[3:0]][(counterHorizontal%10)/2 + 5*((counterVertical%16)/2)];
                            end
                            
                            // Draw the sixth line of characters to the screen  
                            if (counterVertical - 48 > 159 && counterVertical - 48 < 176) begin
                                currentChar = lineSix[66-((counterHorizontal - 160)/10*4 + 3) -: 4];
                                isPixelOn = characterMap[currentChar[3:0]][(counterHorizontal%10)/2 + 5*((counterVertical%16)/2)];
                            end
                            
                            // If the pixel is "on" change the color
                            if (isPixelOn) begin
                                VGA_R = 4'b1000;
                                VGA_G = 4'b1000;
                                VGA_B = 4'b1000;
                            end
                        end
                    end else begin
                        VGA_R = 4'b0000;
                        VGA_G = 4'b0000;
                        VGA_B = 4'b0000;
                    end
                    counterHorizontal = counterHorizontal + 1;
                end
            else begin
                // Restart for the next lap
                counterHorizontal = 0;
                if (counterVertical < verticalLine - 1) begin
                    counterVertical = counterVertical + 1;
                end
                else begin
                    counterVertical = 0;
                end
            end
        end
endmodule

module finalProject(
    input clk,                      // 40 ns clock. Easiest to use with VGA display
    input selectValue,              // Determines if we are using the mouse event for value
    input selectKey,                // Determines if we are using the mouse event for value
    input start,
    input shouldEncrypt,
    input shouldDecrypt,
    inout PS2_CLK,
    inout PS2_DATA,
    input reset,
    output [3:0] VGA_R,
    output [3:0] VGA_G,
    output [3:0] VGA_B,
    output VGA_HS,
    output VGA_VS
    );

    reg[63:0] dinValue = 64'b0;     // The users inputed value         
    reg[127:0] dinKey = 128'b0;     // The users inputed key
    wire[63:0] encryptOut;          // The value returned from the encryption
    wire[63:0] encryptOutFromFIFO;  // The value read out from the FIFO
    wire[63:0] decryptOut;          // The value after decryption
    
    reg writeEnable = 1'b0;         // If we should write to FIFO
    reg readEnable = 1'b0;          // If we should read from FIFO
    reg readyToDecrypt  = 1'b0;     // Need to ensure that we have the value from FIFO before trying to decrypt
    
    
    // INPUT MODULE ------------------------------------------------
    // Struggled to abstract this to a different module. The dinKey, dinValue where never set properly
    
    // Position of mouse
    wire[11:0] xPos;
    wire[11:0] yPos;
    
    // Grab the mouse coordinates
    // https://reference.digilentinc.com/nexys4-ddr:userdemo
    MouseCtl MC(.clk(clk), .rst(reset), .ps2_clk(PS2_CLK), .ps2_data(PS2_DATA), .xpos(xPos), .ypos(yPos));
    
    always @(posedge clk) begin
        if (reset) begin
            dinValue[63:0] = 64'b0;
            dinKey[127:0] = 128'b0;
        end else if (selectValue) begin
            dinValue[63:0] = xPos * yPos;
        end else if (selectKey) begin
            dinKey[127:0] = xPos * yPos;
        end
    end
    
    // END INPUT MODULE ------------------------------------------------
    
    
    encrypt e1(start, clk, dinValue, dinKey, shouldEncrypt, encryptOut);
    fifo_main fifo(clk, reset, encryptOut, writeEnable, readEnable, encryptOutFromFIFO);
    decrypt d1(start, clk, encryptOutFromFIFO, dinKey, readyToDecrypt, decryptOut);
    // Display everything to the screen
    // Line 1: Value the user passed in
    // Line 2: Top 64 bits of the key that the user passed in
    // Line 3: Bottom 64 bits of the key that the user passed in
    // Line 4: The output from the encryption
    // Line 5: The output that is read from FIFO
    // Line 6: The decrypted value
    outputModule om(clk, VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS, dinValue, dinKey[127:64], dinKey[63:0], encryptOut, encryptOutFromFIFO, decryptOut);
    
    integer readCounter = 0;                // Determine when it is safe to read the value from FIFO
    always @(posedge clk) begin
        if (shouldEncrypt && encryptOut) begin
            writeEnable = 1'b1;
            readEnable = 1'b0;
            readCounter = 0;
        end
        if (shouldDecrypt) begin
            readEnable = 1'b1;
            writeEnable = 1'b0;
            readCounter = readCounter + 1;
        end
        // It will be safe to use the value in encryptOutFromFIFO to decrypt
        if (readCounter === 20) begin
            readyToDecrypt = 1'b1;
        end
        if (reset) begin
            readCounter = 0; 
            readEnable = 1'b0;
            writeEnable = 1'b0;
        end
    end
endmodule
