// uart_tb.v
`timescale 1ns/1ps

module uart_tb;
    reg clk, rst;
    reg tx_start;
    reg [7:0] tx_data;
    wire tx, tx_busy;
    wire [7:0] rx_data;
    wire rx_done;
    wire baud_tick;

    // Instantiate modules
    baud_rate_gen baud_inst (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick)
    );

    uart_tx tx_inst (
        .clk(clk),
        .rst(rst),
        .baud_tick(baud_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    uart_rx rx_inst (
        .clk(clk),
        .rst(rst),
        .rx(tx),         // connect Tx output to Rx input
        .rx_data(rx_data),
        .rx_done(rx_done)
    );

    // Clock generation: 50MHz = 20ns period
    initial clk = 0;
    always #10 clk = ~clk;

    // Test stimulus
    initial begin
        // Initialize
        rst      = 1;
        tx_start = 0;
        tx_data  = 8'b0;
        #100;

        // Release reset
        rst = 0;
        #100;

        // Send first byte: 0xA5 (10100101)
        tx_data  = 8'hA5;
        tx_start = 1;
        #20;
        tx_start = 0;

        // Wait for transmission to complete
        wait(rx_done == 1);
        #100;
        $display("Test 1 - Sent: 0xA5 | Received: 0x%h | %s",
                  rx_data, (rx_data == 8'hA5) ? "PASS" : "FAIL");

        // Send second byte: 0x3C (00111100)
        tx_data  = 8'h3C;
        tx_start = 1;
        #20;
        tx_start = 0;

        wait(rx_done == 1);
        #100;
        $display("Test 2 - Sent: 0x3C | Received: 0x%h | %s",
                  rx_data, (rx_data == 8'h3C) ? "PASS" : "FAIL");

        // Send third byte: 0xFF (11111111)
        tx_data  = 8'hFF;
        tx_start = 1;
        #20;
        tx_start = 0;

        wait(rx_done == 1);
        #100;
        $display("Test 3 - Sent: 0xFF | Received: 0x%h | %s",
                  rx_data, (rx_data == 8'hFF) ? "PASS" : "FAIL");

        #200;
        $display("Simulation Complete!");
        $finish;
    end
endmodule

