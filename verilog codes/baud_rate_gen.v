// baud_rate_gen.v
module baud_rate_gen (
    input  clk,        // 50MHz system clock
    input  rst,
    output reg baud_tick
);
    // 50MHz / 9600 = 5208 cycles per bit
    parameter BAUD_DIV = 5208;
    integer count;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count     <= 0;
            baud_tick <= 0;
        end else if (count == BAUD_DIV - 1) begin
            count     <= 0;
            baud_tick <= 1;
        end else begin
            count     <= count + 1;
            baud_tick <= 0;
        end
    end
endmodule
