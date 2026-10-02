// uart_tx.v
module uart_tx (
    input        clk,
    input        rst,
    input        baud_tick,
    input        tx_start,
    input  [7:0] tx_data,
    output reg   tx,
    output reg   tx_busy
);
    // FSM States
    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter DATA  = 2'b10;
    parameter STOP  = 2'b11;

    reg [1:0] state;
    reg [2:0] bit_index;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state     <= IDLE;
            tx        <= 1;   // idle line is HIGH
            tx_busy   <= 0;
            bit_index <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx      <= 1;
                    tx_busy <= 0;
                    if (tx_start) begin
                        state   <= START;
                        tx_busy <= 1;
                    end
                end

                START: begin
                    if (baud_tick) begin
                        tx    <= 0;  // start bit is LOW
                        state <= DATA;
                        bit_index <= 0;
                    end
                end

                DATA: begin
                    if (baud_tick) begin
                        tx <= tx_data[bit_index];
                        if (bit_index == 7)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;
                    end
                end

                STOP: begin
                    if (baud_tick) begin
                        tx    <= 1;  // stop bit is HIGH
                        state <= IDLE;
                    end
                end
            endcase
        end
    end
endmodule
