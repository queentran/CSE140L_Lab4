module bcd2segment_tb ();
	wire [6:0] segment;  // 7 drivers for segment
	reg [3:0] num;    // number to convert
	reg enable;

	reg clk;
	always #10 clk = ~clk;
	
	initial begin
		num = 4'b1100;
		enable = 1'b1;
		#5
		$finish;
	end

	bcd2segment bcd1(
		.segment(segment),
		.num(num),
		.enable(enable)
	);
endmodule