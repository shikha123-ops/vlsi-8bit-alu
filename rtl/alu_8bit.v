module alu_8bit (
    input  [7:0] A,
    input  [7:0] B,
    input  [2:0] opcode,

    output reg [7:0] result,
    output reg       zero,
    output reg       carry,
    output reg       overflow
);

reg [8:0] temp;

always @(*) begin

    // Default values
    result   = 8'b0;
    carry    = 1'b0;
    overflow = 1'b0;
    temp     = 9'b0;

    case (opcode)

        // ADDITION
        3'b000: begin
            temp   = {1'b0, A} + {1'b0, B};
            result = temp[7:0];
            carry  = temp[8];

            // Signed overflow detection
            overflow = (~(A[7] ^ B[7])) & (result[7] ^ A[7]);
        end

        // SUBTRACTION
        3'b001: begin
            result = A - B;

            // Borrow detection
            carry = (A < B);

            // Signed overflow detection
            overflow = (A[7] ^ B[7]) & (result[7] ^ A[7]);
        end

        // AND
        3'b010: begin
            result = A & B;
        end

        // OR
        3'b011: begin
            result = A | B;
        end

        // XOR
        3'b100: begin
            result = A ^ B;
        end

        // NOT
        3'b101: begin
            result = ~A;
        end

        // INCREMENT
        3'b110: begin
            temp   = {1'b0, A} + 9'd1;
            result = temp[7:0];
            carry  = temp[8];
        end

        // DECREMENT
        3'b111: begin
            result = A - 8'd1;
            carry  = (A == 8'd0);
        end

    endcase

    // ZERO FLAG
    if (result == 8'b0)
        zero = 1'b1;
    else
        zero = 1'b0;

end

endmodule
