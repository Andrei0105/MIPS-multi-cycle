module tb_mips;

	reg clk;
	reg reset;

	mips mips_DUT(clk,reset);

	initial
		forever #5 clk=~clk;

	initial begin
	clk=0;
	reset=1;

	#10 reset=0;

	#6000 $finish;
	end

endmodule
