module fir_da (
    input clk,
    input rst,
    input [9:0] x0,
    output reg [21:0] y
);

    reg [9:0] r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16;
    reg [12:0] temp;
    reg [21:0] calc;
    reg [3:0] count;
    reg load;

    // wires to connect to the lut modules
    wire [12:0] out_b1_1, out_b2_1, out_b2_2, out_b1_2;
    
    wire [3:0] in_b1_1 = {r1[count], r2[count], r3[count], r4[count]};
    wire [3:0] in_b2_1 = {r5[count], r6[count], r7[count], r8[count]};
    wire [3:0] in_b2_2 = {r12[count], r11[count], r10[count], r9[count]};
    wire [3:0] in_b1_2 = {r16[count], r15[count], r14[count], r13[count]};

    lut_block1 b1_inst1 (.addr(in_b1_1), .val(out_b1_1));
    lut_block2 b2_inst1 (.addr(in_b2_1), .val(out_b2_1));
    lut_block2 b2_inst2 (.addr(in_b2_2), .val(out_b2_2));
    lut_block1 b1_inst2 (.addr(in_b1_2), .val(out_b1_2));

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            {r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, r16} = 0;
            temp = 0;
            calc = 0;
            count = 0; 
            load = 1;
            y = 0;
        end else begin
            if (load) begin
                r1  <= x0;
                r2  <= r1;
                r3  <= r2;
                r4  <= r3;
                r5  <= r4;
                r6  <= r5;
                r7  <= r6;
                r8  <= r7;
                r9  <= r8;
                r10 <= r9;
                r11 <= r10;
                r12 <= r11;
                r13 <= r12;
                r14 <= r13;
                r15 <= r14;
                r16 <= r15;
                load = 0; 
                count = 0;
            end else begin
                temp = out_b1_1 + out_b2_1 + out_b2_2 + out_b1_2;

                if ((count == 4'b1001) &&
                    (r1[count]  || r2[count]  || r3[count]  || r4[count]  ||
                     r5[count]  || r6[count]  || r7[count]  || r8[count]  ||
                     r12[count] || r11[count] || r10[count] || r9[count]  ||
                     r16[count] || r15[count] || r14[count] || r13[count])) 
                begin
                    calc = calc + (~(temp << count) + 1); 
                end else begin
                    calc = calc + (temp << count);
                end

                if (calc[12] == 1'b1)
                    calc[21:13] = 9'b111111111;
                else
                    calc[21:13] = 9'b000000000;

                if (count == 4'b1001) begin
                    y    = calc;
                    calc = 0;
                    temp = 0;
                    load = 1;
                end else begin
                    count = count + 1;
                end
            end
        end
    end
endmodule

module lut_block1 (
    input  [3:0] addr,
    output reg [12:0] val
);
    always @(*) begin
        case (addr)
            4'b0000 : val = 13'b0000000000000;
            4'b0001 : val = 13'b1111111110100;
            4'b0010 : val = 13'b1111111111110;
            4'b0011 : val = 13'b1111111110010;
            4'b0100 : val = 13'b0000000010110;
            4'b0101 : val = 13'b0000000001001;
            4'b0110 : val = 13'b0000000010011;
            4'b0111 : val = 13'b0000000000111;
            4'b1000 : val = 13'b0000000001000;
            4'b1001 : val = 13'b1111111111100;
            4'b1010 : val = 13'b0000000000111;
            4'b1011 : val = 13'b1111111111011;
            4'b1100 : val = 13'b0000000011100;
            4'b1101 : val = 13'b0000000010001;
            4'b1110 : val = 13'b0000000011010;
            4'b1111 : val = 13'b0000000010000;
            default : val = 13'b0000000000000;
        endcase
    end
endmodule

module lut_block2 (
    input  [3:0] addr,
    output reg [12:0] val
);
    always @(*) begin
        case (addr)
            4'b0000 : val = 13'b0000000000000;
            4'b0001 : val = 13'b0000010010100;
            4'b0010 : val = 13'b1111111110011;
            4'b0011 : val = 13'b0000010111000;
            4'b0100 : val = 13'b1111111101110;
            4'b0101 : val = 13'b0000010000010;
            4'b0110 : val = 13'b1111110000000;
            4'b0111 : val = 13'b0000001110100;
            4'b1000 : val = 13'b0000000010110;
            4'b1001 : val = 13'b0000011001001; 
            4'b1010 : val = 13'b0000000001000;
            4'b1011 : val = 13'b0000010011000;
            4'b1100 : val = 13'b0000000000100;
            4'b1101 : val = 13'b0000010010110;
            4'b1110 : val = 13'b1111111110100;
            4'b1111 : val = 13'b0000010001010;
            default : val = 13'b0000000000000;
        endcase
    end
endmodule
