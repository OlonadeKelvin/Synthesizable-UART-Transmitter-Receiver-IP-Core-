`timescale 1ns / 1ps

module uart_top_tb;

    // Parameters to match our design
    localparam CLK_FREQ  = 50_000_000;
    localparam BAUD_RATE = 115200;

    // Inputs to the module
    reg        clk;
    reg        rst_n;
    reg        tx_start;
    reg  [7:0] tx_data;
    
    // Outputs from the module
    wire       tx_done;
    wire [7:0] rx_data;
    wire       rx_ready;

    // The Loopback Wire
    // This single wire connects the TX output to the RX input
    wire       serial_line;

    // Instantiate the Top-Level Module (Device Under Test)
    uart_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .clk(clk),
        .rst_n(rst_n),
        
        // Loopback Connection
        .tx_out(serial_line),
        .rx_in(serial_line), 
        
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_done(tx_done),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

    // Generate a 50 MHz Clock (20ns period -> 10ns high, 10ns low)
    always #10 clk = ~clk;

    // The Main Test Sequence
    initial begin
        // Setup GTKWave Output
        $dumpfile("uart_top_sim.vcd");
        $dumpvars(0, uart_top_tb);

        // 1. Initialize System
        clk      = 0;
        rst_n    = 0;
        tx_start = 0;
        tx_data  = 8'h00;

        // Release Reset
        #100;
        rst_n = 1;
        #100;

        // TEST CASE 1: Send 0xA5 (Binary: 10100101)

        $display("--- Test 1: Sending 0xA5 ---");
        tx_data  = 8'hA5;
        tx_start = 1;
        #20; // Hold start button for one clock cycle
        tx_start = 0;

        // Wait for the receiver to announce it has a valid byte
        wait(rx_ready == 1'b1);
        
        // Check the result
        if (rx_data == 8'hA5)
            $display("SUCCESS: Received 0x%h exactly as sent!", rx_data);
        else
            $display("ERROR: Sent 0xA5 but received 0x%h", rx_data);

        // Wait a bit before sending the next byte
        #50000; 

        // TEST CASE 2: Send 0x3C (Binary: 00111100)
        $display("--- Test 2: Sending 0x3C ---");
        tx_data  = 8'h3C;
        tx_start = 1;
        #20;
        tx_start = 0;

        // Wait for the receiver to announce it has a valid byte
        wait(rx_ready == 1'b1);
        
        // Check the result
        if (rx_data == 8'h3C)
            $display("SUCCESS: Received 0x%h exactly as sent!", rx_data);
        else
            $display("ERROR: Sent 0x3C but received 0x%h", rx_data);


        // Finish Simulation
        #10000;
        $display("--- Simulation Complete! You are ready for synthesis. ---");
        $finish;
    end

endmodule
