module dadda_nocarry_lsb (
    input clk,
    input enable,
    input [7:0] ll, lh, hl, hh,
    output [15:0] result
);
    wire [15:0] pp0 = {{8{1'b0}}, ll};
    wire [15:0] pp1 = {{4{1'b0}}, lh, 4'b0};
    wire [15:0] pp2 = {{4{1'b0}}, hl, 4'b0};
    wire [15:0] pp3 = {hh, 8'b0};

    wire [7:0] sum_wire, carry_wire;
    reg  [3:0] sum, carry;  // Only upper 4 bits registered

    genvar i;
    generate
        for (i = 4; i < 12; i = i + 1) begin : COMPRESS
            LUT6_2 #(
                .INIT(64'h69966996FEE8FEE8)
            ) LUT6_inst (
                .I0(pp0[i]),
                .I1(pp1[i]),
                .I2(pp2[i]),
                .I3(pp3[i]),
                .I4(1'b0),
                .I5(1'b0),
                .O6(sum_wire[i-4]),
                .O5(carry_wire[i-4])
            );
        end
    endgenerate

    wire gated_clk = clk & enable;

    always @(posedge gated_clk) begin
        sum   <= sum_wire[7:4];
        carry <= carry_wire[7:4];
    end

    wire [11:0] sum_r;
    wire [11:0] final_carry;

    // Lower bits from unregistered wires
    CARRY4 C0 (.CO(final_carry[3:0]), .O(sum_r[3:0]), .CI(1'b0), .CYINIT(1'b0), .DI(carry_wire[3:0]), .S(sum_wire[3:0]));
    CARRY4 C1 (.CO(final_carry[7:4]), .O(sum_r[7:4]), .CI(final_carry[3]), .CYINIT(1'b0), .DI(carry), .S(sum));
    // Upper bits from registered wires
    CARRY4 C2 (.CO(), .O(sum_r[11:8]), .CI(final_carry[7]), .CYINIT(1'b0), .DI(carry), .S({pp3[15],pp3[14],pp3[13],pp3[12]}));

    assign result[3:0] = ll[3:0];
    assign result[15:4] = sum_r;
endmodule

