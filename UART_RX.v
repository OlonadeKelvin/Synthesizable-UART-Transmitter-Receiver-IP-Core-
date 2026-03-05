`timescale 1ns / 1ps

module UART_RX (
    input  wire       clk,      // System clock
    input  wire       rst_n,    // Active-low reset
    input  wire       rx_tick,  // 16x oversampling tick from baud_gen
    input  wire       rx_in,    // The serial input wire from the transmitter
    output reg  [7:0] rx_data,  // The 8-bit byte received
    output reg        rx_ready  // Pulses HIGH for 1 clock cycle when data is valid
);

    // FSM States
    localparam IDLE  = 2'b00;
    localparam START = 2'b01;
    localparam DATA  = 2'b10;
    localparam STOP  = 2'b11;

    // Internal Registers
    reg [1:0] state;
    reg [3:0] tick_cnt; // Counts 0 to 15 for oversampling
    reg [2:0] bit_cnt;  // Counts 0 to 7 for the 8 data bits
    reg [7:0] data_reg; // Shift register to assemble the incoming bits

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state    <= IDLE;
            tick_cnt <= 4'd0;
            bit_cnt  <= 3'd0;
            data_reg <= 8'd0;
            rx_data  <= 8'd0;
            rx_ready <= 1'b0;
        end else begin
            // Default: keep rx_ready low unless we set it high in STOP state
            rx_ready <= 1'b0; 

            case (state)
                IDLE: begin
                    // If rx_in goes to 0, it might be a start bit
                    if (rx_in == 1'b0) begin
                       state <= START;
		       tick_cnt <= 4'b0;
                    end
                end

                START: begin
                    if (rx_tick == 1'b1) begin
                        if (tick_cnt == 7) begin
                            
                            if (rx_in == 1'b0) begin
                                // It's a valid start bit
                                state <= DATA;
                                tick_cnt <= 4'b0;
                                bit_cnt <= 3'b0;
                            end else begin
                                // It was a glitch (rx_in went back HIGH). 
                                state <= IDLE;
                            end
                        end else begin
                            // Keep counting ticks until we reach the middle (7)
                            tick_cnt <= tick_cnt + 1;
                        end
                    end
                end

                DATA: begin
		    if (rx_tick == 1'b1) begin
                    	if (tick_cnt == 15) begin
				tick_cnt <= 4'b0;
                        	data_reg <= {rx_in, data_reg[7:1]};
                    
				if (bit_cnt == 7) begin
					state <= STOP;
				end else begin
					bit_cnt <= bit_cnt + 1;
				end
		    	end else begin
				tick_cnt <= tick_cnt + 1;
		    	end
                	end
		    end

                STOP: begin
		    if (rx_tick == 1'b1) begin
                    	if (tick_cnt == 15) begin
				rx_data <= data_reg;
                    		rx_ready <= 1'b1;
                    		state <= IDLE;
		   	 end else begin
				tick_cnt <= tick_cnt + 1;
			end
		    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

endmodule
