`timescale 1ns/1ps

module gcd_tb;

    reg         clk = 0;
    reg         rst = 1;
    reg         start = 0;
    reg  [15:0] a = 0, b = 0;
    wire [15:0] result;
    wire        busy, done;

    integer errors = 0;
    integer i;

    gcd dut (
        .clk(clk), .rst(rst), .start(start),
        .a(a), .b(b),
        .result(result), .busy(busy), .done(done)
    );

    always #5 clk = ~clk;

    // reference model
    function [15:0] ref_gcd(input [15:0] p, input [15:0] q);
        reg [15:0] t;
        begin
            while (q != 0) begin
                t = p % q;
                p = q;
                q = t;
            end
            ref_gcd = p;
        end
    endfunction

    task run(input [15:0] ta, input [15:0] tb);
        reg [15:0] expected;
        begin
            expected = ref_gcd(ta, tb);
            @(negedge clk);
            a = ta; b = tb; start = 1;
            @(negedge clk);
            start = 0;
            wait (done);
            @(negedge clk);
            if (result !== expected) begin
                $display("FAIL: gcd(%0d, %0d) = %0d, expected %0d", ta, tb, result, expected);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        repeat (2) @(negedge clk);
        rst = 0;

        // directed cases
        run(48, 18);
        run(18, 48);
        run(0, 0);
        run(0, 25);
        run(25, 0);
        run(17, 17);
        run(13, 7);
        run(65535, 1);
        run(65535, 65535);
        run(65534, 32767);
        run(1024, 768);

        // random cases
        for (i = 0; i < 500; i = i + 1)
            run($random, $random);

        if (errors == 0) $display("PASS: all tests passed");
        else             $display("%0d test(s) failed", errors);
        $finish;
    end

endmodule
