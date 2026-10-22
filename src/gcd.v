// 16-bit GCD (Euclid's algorithm, subtraction form)
//
// Usage: hold a and b, pulse start for one cycle. When done goes high
// (for one cycle), result holds gcd(a, b). result also stays valid until
// the next start.
//
// Edge cases: gcd(a, 0) = a, gcd(0, b) = b, gcd(0, 0) = 0.
// Latency: data-dependent, worst case ~65,535 cycles (e.g. gcd(65535, 1)).

module gcd (
    input  wire        clk,
    input  wire        rst,      // synchronous, active-high
    input  wire        start,
    input  wire [15:0] a,
    input  wire [15:0] b,
    output reg  [15:0] result,
    output reg         busy,
    output reg         done
);

    reg [15:0] x, y;

    always @(posedge clk) begin
        if (rst) begin
            x      <= 16'd0;
            y      <= 16'd0;
            result <= 16'd0;
            busy   <= 1'b0;
            done   <= 1'b0;
        end else begin
            done <= 1'b0;

            if (!busy) begin
                if (start) begin
                    x    <= a;
                    y    <= b;
                    busy <= 1'b1;
                end
            end else begin
                if (y == 16'd0) begin
                    // finished: gcd is in x
                    result <= x;
                    busy   <= 1'b0;
                    done   <= 1'b1;
                end else if (x >= y) begin
                    x <= x - y;
                end else begin
                    // swap so that x >= y
                    x <= y;
                    y <= x;
                end
            end
        end
    end

endmodule
