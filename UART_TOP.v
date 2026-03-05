`timescale 1ns / 1ps

module uart_top #(
    parameter CLK_FREQ  = 50_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire       clk,
    input  wire       rst_n,
    
    // External Physical Pins
    input  wire       rx_in,
    output wire       tx_out,
    
    // User Logic Interface (Connects to the rest of the FPGA)
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    output wire       tx_done,
    output wire [7:0] rx_data,
    output wire       rx_ready
);

    // --- Internal Wires ---
    // These act like physical jumper wires connecting our internal modules
    wire tx_tick;
    wire rx_tick;

    // --- 1. Instantiate the Baud Rate Generator ---
    baud_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) baud_rate_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_tick(tx_tick),
        .rx_tick(rx_tick)
    );

    // --- 2. Instantiate the Transmitter ---
    UART_TX tx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .tx_tick(tx_tick),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx_out(tx_out),
        .tx_done(tx_done)
    );

    // --- 3. Instantiate the Receiver ---
    UART_RX rx_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rx_tick(rx_tick),
        .rx_in(rx_in),
        .rx_data(rx_data),
        .rx_ready(rx_ready)
    );

endmodule
