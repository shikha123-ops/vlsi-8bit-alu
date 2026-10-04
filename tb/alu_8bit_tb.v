`timescale 1ns/1ps

module alu_8bit_tb;

reg [7:0] A;
reg [7:0] B;
reg [2:0] opcode;

wire [7:0] result;
wire zero;
wire carry;
wire overflow;

integer pass_count;
integer fail_count;

alu_8bit uut (
    .A(A),
    .B(B),
    .opcode(opcode),
    .result(result),
    .zero(zero),
    .carry(carry),
    .overflow(overflow)
);

// ========================================
// TASK: CHECK ALU OUTPUT
// ========================================

task check_result;

    input [7:0] expected_result;
    input       expected_zero;
    input       expected_carry;
    input       expected_overflow;

    begin

        #1;

        if ((result === expected_result) &&
            (zero === expected_zero) &&
            (carry === expected_carry) &&
            (overflow === expected_overflow)) begin

            $display("PASS | A=%d B=%d Opcode=%b | Result=%d Zero=%b Carry=%b Overflow=%b",
                     A, B, opcode, result, zero, carry, overflow);

            pass_count = pass_count + 1;

        end
        else begin

            $display("FAIL | A=%d B=%d Opcode=%b | Expected: Result=%d Zero=%b Carry=%b Overflow=%b | Got: Result=%d Zero=%b Carry=%b Overflow=%b",
                     A, B, opcode,
                     expected_result,
                     expected_zero,
                     expected_carry,
                     expected_overflow,
                     result,
                     zero,
                     carry,
                     overflow);

            fail_count = fail_count + 1;

        end

    end

endtask


// ========================================
// TESTS
// ========================================

initial begin

    pass_count = 0;
    fail_count = 0;

    $dumpfile("sim/alu_waveform.vcd");
    $dumpvars(0, alu_8bit_tb);

    // ------------------------------------
    // ADDITION
    // ------------------------------------

    A = 8'd10;
    B = 8'd5;
    opcode = 3'b000;
    check_result(8'd15, 1'b0, 1'b0, 1'b0);

    // ------------------------------------
    // SUBTRACTION
    // ------------------------------------

    A = 8'd10;
    B = 8'd5;
    opcode = 3'b001;
    check_result(8'd5, 1'b0, 1'b0, 1'b0);

    // ------------------------------------
    // AND
    // ------------------------------------

    A = 8'b10101010;
    B = 8'b11001100;
    opcode = 3'b010;
    check_result(8'b10001000, 1'b0, 1'b0, 1'b0);

    // ------------------------------------
    // OR
    // ------------------------------------

    opcode = 3'b011;
    check_result(8'b11101110, 1'b0, 1'b0, 1'b0);

    // ------------------------------------
    // XOR
    // ------------------------------------

    opcode = 3'b100;
    check_result(8'b01100110, 1'b0, 1'b0, 1'b0);

    // ------------------------------------
    // NOT
    // ------------------------------------

    opcode = 3'b101;
    check_result(8'b01010101, 1'b0, 1'b0, 1'b0);

    // ------------------------------------
    // INCREMENT
    // ------------------------------------

    A = 8'd20;
    B = 8'd0;
    opcode = 3'b110;
    check_result(8'd21, 1'b0, 1'b0, 1'b0);

    // ------------------------------------
    // DECREMENT
    // ------------------------------------

    A = 8'd20;
    opcode = 3'b111;
    check_result(8'd19, 1'b0, 1'b0, 1'b0);


    // ====================================
    // CORNER CASES
    // ====================================

    // 10 - 10 = 0
    A = 8'd10;
    B = 8'd10;
    opcode = 3'b001;
    check_result(8'd0, 1'b1, 1'b0, 1'b0);

    // 255 + 1 = 0 with carry
    A = 8'd255;
    B = 8'd1;
    opcode = 3'b000;
    check_result(8'd0, 1'b1, 1'b1, 1'b0);

    // 0 - 1 = 255 with borrow
    A = 8'd0;
    B = 8'd1;
    opcode = 3'b001;
    check_result(8'd255, 1'b0, 1'b1, 1'b0);

    // 255 AND 255 = 255
    A = 8'hFF;
    B = 8'hFF;
    opcode = 3'b010;
    check_result(8'hFF, 1'b0, 1'b0, 1'b0);


    // ====================================
    // SIGNED OVERFLOW TESTS
    // ====================================

    // 127 + 1 = -128
    A = 8'd127;
    B = 8'd1;
    opcode = 3'b000;
    check_result(8'd128, 1'b0, 1'b0, 1'b1);

    // -128 - 1 = 127
    A = 8'd128;
    B = 8'd1;
    opcode = 3'b001;
    check_result(8'd127, 1'b0, 1'b0, 1'b1);


    // ====================================
    // FINAL REPORT
    // ====================================

    #1;

    $display("");
    $display("========================================");
    $display("          ALU VERIFICATION REPORT");
    $display("========================================");
    $display("TOTAL PASSED : %d", pass_count);
    $display("TOTAL FAILED : %d", fail_count);
    $display("========================================");

    if (fail_count == 0)
        $display("RESULT: ALL TESTS PASSED!");
    else
        $display("RESULT: SOME TESTS FAILED!");

    $display("========================================");

    $finish;

end

endmodule
