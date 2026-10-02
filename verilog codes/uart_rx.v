// uart_rx.v
module uart_rx (
    input        clk,
    input        rst,
    input        rx,
    output reg [7:0] rx_data,
    output reg       rx_done
);
    // FSM States
    parameter IDLE  = 2'b00;
    parameter START = 2'b01;
    parameter DATA  = 2'b10;
    parameter STOP  = 2'b11;

    // Bit-timing constants: same 50 MHz / 9600 baud assumption as
    // baud_rate_gen.v. FULL_BIT = one full bit period in clock cycles.
    // HALF_BIT = half of that, used to sample at the center of a bit.
    localparam FULL_BIT = 5208;
    localparam HALF_BIT = 2604;

    reg [1:0]  state;
    reg [2:0]  bit_index;
    reg [12:0] rx_counter;   // RX's own independent bit-timing counter

    // 2-flop synchronizer for the asynchronous rx input (Step 1).
    reg rx_meta, rx_sync;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_meta <= 1'b1;
            rx_sync <= 1'b1;
        end else begin
            rx_meta <= rx;
            rx_sync <= rx_meta;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state      <= IDLE;
            rx_data    <= 8'b0;
            rx_done    <= 0;
            bit_index  <= 0;
            rx_counter <= 0;
        end else begin
            case (state)
                IDLE: begin
                    rx_done    <= 0;
                    rx_counter <= 0;
                    if (rx_sync == 0)             // start-bit edge detected
                        state <= START;
                end

                START: begin
                    if (rx_counter == HALF_BIT - 1) begin
                        if (rx_sync == 0) begin   // still low at mid-bit -> real start bit
                            state      <= DATA;
                            bit_index  <= 0;
                            rx_counter <= 0;
                        end else begin            // was just a glitch, not a real start bit
                            state      <= IDLE;
                            rx_counter <= 0;
                        end
                    end else begin
                        rx_counter <= rx_counter + 1;
                    end
                end

                DATA: begin
                    if (rx_counter == FULL_BIT - 1) begin
                        rx_data[bit_index] <= rx_sync;
                        rx_counter         <= 0;
                        if (bit_index == 7)
                            state <= STOP;
                        else
                            bit_index <= bit_index + 1;
                    end else begin
                        rx_counter <= rx_counter + 1;
                    end
                end

                STOP: begin
                    if (rx_counter == FULL_BIT - 1) begin
                        if (rx_sync == 1)         // valid stop bit
                            rx_done <= 1;
                        state      <= IDLE;
                        rx_counter <= 0;
                    end else begin
                        rx_counter <= rx_counter + 1;
                    end
                end
            endcase
        end
    end
endmodule