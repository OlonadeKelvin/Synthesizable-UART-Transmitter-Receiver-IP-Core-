`timescale 1ns / 1ps

module UART_TX_Testbench;

// Signals needed in the module
	reg		clk;
	reg		rst_n;
	reg		tx_tick;
	reg		tx_start;
	reg [7:0]	tx_data;
	wire		tx_out;
	wire		tx_done;
// Instantiate the transmitter DUT (Device under test)

	UART_TX uut(
		.clk(clk),
		.rst_n(rst_n),
		.tx_tick(tx_tick),
		.tx_start(tx_start),
		.tx_data(tx_data),
		.tx_out(tx_out),
		.tx_done(tx_done)
	);

	// Generating the clock 

    	always #5 clk = ~clk;

    	//  Generate the Baud Tick
    	// Instead of using the full baud_gen module, we'll just fake a tick every 100 clock cycles 
    	// to make the simulation run faster and easier to read.
    	always begin
        	#990 tx_tick = 1'b1; // Wait 99 clock cycles
        	#10  tx_tick = 1'b0; // Pulse high for 1 clock cycle
    	end

    	//The Main Test Sequence
    	initial begin
        	// Setup GTKWave output files
        	$dumpfile("uart_tx_sim.vcd");
        	$dumpvars(0, UART_TX_Testbench);

        	// Initialize all inputs to 0
        	clk      = 0;
        	rst_n    = 0;
        	tx_tick  = 0;
        	tx_start = 0;
        	tx_data  = 8'h00;

        	// Step 1: Release the Reset button
        	#100;
        	rst_n = 1;
        	#100;

        	// Step 2: Send a Byte! Let's send 8'hAB (Binary: 10101011)
        	// Note: UART sends LSB first, so we should see 1, 1, 0, 1, 0, 1, 0, 1 on the wire.
        	$display("Starting transmission of 0xAB...");
        	tx_data  = 8'hAB;
        	tx_start = 1'b1;
        	#10;             // Hold start button for 1 clock cycle
        	tx_start = 1'b0; // Release start button

        	// Step 3: Wait for the module to say it's done
        	wait (tx_done == 1'b1);
        	$display("Transmission complete!");

        	// Step 4: Wait a little bit, then end the simulation
        	#500;
        	$finish;
    	end

endmodule
