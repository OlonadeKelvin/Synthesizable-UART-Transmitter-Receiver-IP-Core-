`timescale 1ns / 1ps

module UART_TX (
    input  wire       clk,       // Internal FPGA clock, though not required by UART
    input  wire       rst_n,     // Reset button (active low)
    input  wire       tx_tick,   // From baud_gen: pulses high when it's time to send a bit
    input  wire       tx_start,  // Signal to tell us to start sending, Start bit, usually, pulling the already high signal low
    input  wire [7:0] tx_data,   // The 8 bits of data to send
    output reg        tx_out,    // The actual serial wire going to the other device receiver(rx)
    output reg        tx_done    // Stop signal pull back high
);

    //State Machine states
    localparam IDLE  = 2'b00;  // Remembers when in Idle state
    localparam START = 2'b01;  // Remembers when Starting transmission
    localparam DATA  = 2'b10;  // Remembers when DATA is being sent
    localparam STOP  = 2'b11;  // Remembers when Stopping transmission

    // Internal hardware registers (memory)
    reg [1:0] state;       // Keeps track of our current state
    reg [7:0] data_reg;    // The shift register holding the data
    reg [2:0] bit_cnt;     // Counts from 0 to 7

    // Always block: Describing hardware that updates on every clock tick
    // Using "<=" (non-blocking assignment) to update registers as in sequential logic!
   
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // RESET BEHAVIOR, rst_n is always low, !rst_n mean high, so if high What should the hardware do, i.e reset has been pressed
            state   <= IDLE; // Change state to IDLE
            tx_out  <= 1'b1; // UART line is HIGH when idle
            tx_done <= 1'b0; // Set bit to low, not done
            bit_cnt <= 3'd0; // Bit count is 0, not started or at first bit
            data_reg<= 8'd0; // No data sent yet
        end 

	else begin

            // When not in reset. 
            case (state)
                IDLE: 
		    begin
                    tx_out  <= 1'b1; // Keep line HIGH, meaning no data sent
                    tx_done <= 1'b0; // Turn off done, nothing is completed
                    
                    if (tx_start == 1'b1) begin
                        // If start bit is high
                        data_reg <= tx_data;
			state <= START;
                    end
                end

                START: begin
                    // We only move to the next phase when the baud rate generator says so
                    if (tx_tick == 1'b1) begin
                        tx_out <= 1'b0;
                        state <= DATA;
                        bit_cnt <= 3'b0;
                    end
                end

                DATA: begin
                    if (tx_tick == 1'b1) 
		    begin
                        // Send the lowest bit of data_reg to the wire
                        tx_out <= data_reg[0];

                        // Shift the data_reg to the right (put a 0 at the top, keep the bottom 7)
                        data_reg <= {1'b0, data_reg[7:1]};

                        if (bit_cnt == 7) begin
                            state <= STOP;
                        end 
			else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end

                STOP: begin
                    if (tx_tick == 1'b1) begin
                        tx_out <= 1'b1;
                        tx_done <= 1'b1;
                        state <= IDLE;
                    end
                end
                
                default: state <= IDLE; // Safety catch
            endcase
        end
    end

endmodule
