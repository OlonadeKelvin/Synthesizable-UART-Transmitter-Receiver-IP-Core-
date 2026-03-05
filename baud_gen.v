`timescale 1ns / 1ps

module baud_gen #(
    parameter CLK_FREQ   = 50_000_000, // System clock frequency in Hz
    parameter BAUD_RATE  = 115200      // Target baud rate in bps
)(
    input  wire clk,
    input  wire rst_n,
    output wire tx_tick,   // Pulses once per baud period
    output wire rx_tick    // Pulses 16 times per baud period (for oversampling)
);

    // Calculate maximum counter values based on frequencies
    // TX counter needs to count up to (CLK_FREQ / BAUD_RATE)
    localparam TX_MAX = CLK_FREQ / BAUD_RATE;
    
    // RX counter needs to count up to (CLK_FREQ / (BAUD_RATE * 16))
    localparam RX_MAX = CLK_FREQ / (BAUD_RATE * 16);

    // Determine the number of bits required for the counters
    // $clog2 is a built-in Verilog function that returns the ceiling of log base 2
    reg [$clog2(TX_MAX)-1:0] tx_reg;
    reg [$clog2(RX_MAX)-1:0] rx_reg;

    // TX Tick Generation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tx_reg <= 0;
        end else begin
            if (tx_reg == (TX_MAX - 1))
                tx_reg <= 0;
            else
                tx_reg <= tx_reg + 1;
        end
    end

    // RX Tick Generation
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rx_reg <= 0;
        end else begin
            if (rx_reg == (RX_MAX - 1))
                rx_reg <= 0;
            else
                rx_reg <= rx_reg + 1;
        end
    end

    // Assert ticks for exactly one clock cycle when counters roll over
    assign tx_tick = (tx_reg == (TX_MAX - 1));
    assign rx_tick = (rx_reg == (RX_MAX - 1));

endmodule
