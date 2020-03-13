module decodeKeys_tb();

	reg [7:0] charData;
	reg charDataValid;
	reg clk;
	reg out;
	
	
		  wire      det_esc;
		  wire      det_num;
		  wire      det_num0to5; 
		  wire      det_cr;
		  wire      det_atSign;
		  wire      det_A;
		  wire      det_L;
		  wire      det_N;
          wire      det_S;
	
	
	always #5 clk = ~clk;
	
	initial begin
		charDataValid = 0;
		charData = 8'b00000000;
		#5
		charDataValid = 1;
		charData = 8'b1101100;
		#5
		$finish;
	end

	decodeKeys decode1(
	.det_esc(det_esc),
	.det_num(det_num),
	.det_num0to5(det_num0to5),
	.det_cr(det_cr),
	.det_atSign(det_atSign),
	.det_A(det_A),
	.det_L(det_L),
	.det_N(det_N),
    .det_S(det_S),
    .charData(charData), 
	.charDataValid(charDataValid)
	);

endmodule