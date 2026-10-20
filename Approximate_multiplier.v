module multiplier_1(y,a,b);
input [7:0] a, b;
output reg [15:0] y;

wire [7:0] pp [7:0]; 


genvar i, j;
generate
  for (i = 0; i < 8; i = i + 1) begin : PARTIAL_PRODUCTS
    for (j = 0; j < 8; j = j + 2) begin : AND_LUT6_2
      LUT6_2 #(
        .INIT(64'hF000F00088888888) // Dual AND: O6 = I0&I1, O5 = I2&I3
      ) pp_and (
        .O6(pp[i][j+1]),    // O6 → a[j] & b[i]
        .O5(pp[i][j]),  // O5 → a[j+1] & b[i]
        .I0(b[i]), .I1(a[j]),
        .I2(b[i]), .I3(a[j+1]),
        .I4(1'b1), .I5(1'b1)
      );
    end
  end
endgenerate

wire s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10;
wire ss1,ss2,ss3,ss4,ss5,ss6,cc1,cc2,cc3,cc4,cc5,cc6;

acfgi1 acf1(s1,c1,pp[1][3],pp[2][2],pp[3][1],1'b0);
acfgi1 acf2(s2,c2,pp[1][4],pp[2][3],pp[3][2],pp[4][1]);
acfgi1 acf3(s3,c3,pp[1][5],pp[2][4],pp[3][3],pp[4][2]);
acfgi1 acf4(s4,c4,pp[2][5],pp[3][4],pp[4][3],pp[5][2]);

ac6g1 acg1(s5,c5,pp[1][7],pp[2][6],pp[3][5],pp[4][4]);
ac6g1 acg2(s6,c6,pp[5][3],pp[6][2],pp[7][1],1'b0);
ac6g1 acg3(s7,c7,pp[2][7],pp[3][6],pp[4][5],pp[5][4]);
ac6g1 acg4(s8,c8,pp[3][7],pp[4][6],pp[5][5],pp[6][4]);

fa faa(s9,c9,pp[5][6],pp[6][5],pp[7][4]);
fa fab(s10,c10,pp[5][7],pp[6][6],pp[7][5]);

ac6g1 acg5(ss1,cc1,s5,s6,c4,1'b0);
ac6g1 acg6(ss2,cc2,s7,c5,c6,pp[6][3]);


fa fad(ss3,cc3,s9,c8,pp[4][7]);
fa fae(ss4,cc4,pp[6][7],pp[7][6],c10);

ac6g1 acg7(sss1,ccc1,ss2,pp[7][2],cc1,1'b0);
ac6g1 acg8(sss2,ccc2,s8,c7,pp[7][3],cc2);
fa faf(sss3,ccc3,s10,c9,cc3);

wire xor1,xor2,xor3,xor4,xor5,xor6,xor7;
LUT6_2 #(
  .INIT(64'h0FF00FF066666666)
) xor_2 (
  .O6(xor2), .O5(xor1),
  .I0(s2), .I1(c1), .I2(s3), .I3(c2),
  .I4(1'b1), .I5(1'b1)
);
LUT6_2 #(
  .INIT(64'h0FF00FF066666666)
) xor_2_1 (
  .O6(xor4), .O5(xor3),
  .I0(s4), .I1(c3), .I2(ss2), .I3(cc1),
  .I4(1'b1), .I5(1'b1)
);
LUT6_2 #(
  .INIT(64'h0FF00FF066666666)
) xor_2_2 (
  .O6(xor6), .O5(xor5),
  .I0(ss3), .I1(cc2), .I2(ss4), .I3(cc3),
  .I4(1'b1), .I5(1'b1)
);
LUT2 #(
  .INIT(4'h6) // A ^ B
) xor_lut2_bit6 (
  .I0(pp[7][7]),
  .I1(cc4),
  .O (xor7)
);
// Replacing HA+FA ripple carry with CARRY4
wire [3:0] s0_sum, s1_sum, s2_sum;
wire [3:0] s0_carry, s1_carry, s2_carry;

CARRY4 rca0 (
  .CI(1'b0),
  .CYINIT(1'b0),
  .DI({s4,s3,s2,s1}),
  .S({xor3,xor2,xor1,s1}),
  .CO(s0_carry),
  .O(s0_sum)
);

CARRY4 rca1 (
  .CI(s0_carry[3]),
  .CYINIT(1'b0),
  .DI({ss3,sss2,sss1,ss1}),
  .S({xor5,xor4,sss1,ss1}),
  .CO(s1_carry),
  .O(s1_sum)
);

CARRY4 rca2 (
  .CI(s1_carry[3]),
  .CYINIT(1'b0),
  .DI({1'b0,pp[7][7],ss4,sss3}),
  .S({1'b0,xor7,xor6,sss3}),
  .CO(s2_carry),
  .O(s2_sum)
);

always @(*) begin
    y[3:0]  = 4'b0000;
    y[4]    = s0_sum[0];
    y[5]    = s0_sum[1];
    y[6]    = s0_sum[2];
    y[7]    = s0_sum[3];
    y[8]    = s1_sum[0];
    y[9]    = s1_sum[1];
    y[10]   = s1_sum[2];
    y[11]   = s1_sum[3];
    y[12]   = s2_sum[0];
    y[13]   = s2_sum[1];
    y[14]   = s2_sum[2];
    y[15]   = s2_carry[2]; // final carry
end

endmodule

module acfgi1(sum, carry, x1, x2, x3, x4);
input x1, x2, x3, x4;
output sum, carry;
/*  assign sum = 1;
  assign carry = x1;  */
 LUT6_2 #(
  .INIT(64'h88888888EEEEEEEE) // O6=(I0|I1|I2|I3), O5=(I0&(I2|I3))|(I1&I2)
) ac6g1_lut1 (
  .O6(carry), .O5(sum),
  .I0(x3), .I1(x4), .I2(1'b1), .I3(1'b1),
  .I4(1'b1), .I5(1'b1)
);  
endmodule

module ac6g1(sum, carry, x1, x2, x3, x4);
input x1, x2, x3, x4;
output sum, carry;
 LUT6_2 #(
  .INIT(64'hFAC8FAC8FFFEFFFE)
) ac6g1_lut1 (
  .O6(carry), .O5(sum),
  .I0(x1), .I1(x2), .I2(x3), .I3(x4),
  .I4(1'b1), .I5(1'b1)
);
endmodule

module fa(Sum, Carry, a, b, c);
input a, b, c;
output Sum, Carry;
LUT6_2 #(
  .INIT(64'hE8E8E8E896969696) // O6=A^B^C, O5=(A&B)|(B&C)|(C&A)
) fa_lut1 (
  .O6(Carry), .O5(Sum),
  .I0(a), .I1(b), .I2(c), .I3(1'b1),
  .I4(1'b1), .I5(1'b1)
);

endmodule
