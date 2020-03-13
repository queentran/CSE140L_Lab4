module Num2BCD(
       output[7:0] bcd,
       input [3:0] num
	   );
	   
    // convert binary to bcd
    assign bcd = (~|(num ^ 4'b0000)) ? "0" : //0
                 (~|(num ^ 4'b0001)) ? "1" : //1
                 (~|(num ^ 4'b0010)) ? "2" : //2
                 (~|(num ^ 4'b0011)) ? "3" : //3
                 (~|(num ^ 4'b0100)) ? "4" : //4
                 (~|(num ^ 4'b0101)) ? "5" : //5
                 (~|(num ^ 4'b0110)) ? "6" : //6
                 (~|(num ^ 4'b0111)) ? "7" : //7
                 (~|(num ^ 4'b1000)) ? "8" : //8
                 (~|(num ^ 4'b1001)) ? "9" : //9
                 (~|(num ^ 4'b1010)) ? "A" : //A
                 (~|(num ^ 4'b1011)) ? "B" : //B
                 (~|(num ^ 4'b1100)) ? "C" : //C
                 (~|(num ^ 4'b1101)) ? "D" : //D
                 (~|(num ^ 4'b1110)) ? "E" : //E
                 (~|(num ^ 4'b1111)) ? "F" : ""; //F
              
endmodule // end module Num2BCD