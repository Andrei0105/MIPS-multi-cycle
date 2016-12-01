module mips(clk,reset);

	input clk,reset;

	wire [5:0] Op;
	wire Zero;
	wire IorD;
	wire MemRead;
	wire MemWrite;
	wire MemToReg;
	wire IRWrite;
	wire PCSource;
	wire [1:0] ALUSrcB;
	wire ALUSrcA;
	wire RegWrite;
	wire RegDst;
	wire PCSel;
	wire [1:0] ALUOp;
	wire [3:0] ALUCtrl;
	wire [5:0] Function;

	control control_D(clk, reset,Op, Zero, IorD, MemRead, MemWrite, MemtoReg,
	IRWrite, PCSource, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCSel, ALUOp);

	alucontrol alucontrol_D(ALUOp, Function, ALUCtrl);

	datapath  datapath_D(clk, reset,IorD, MemRead, MemWrite, MemtoReg, IRWrite, PCSource,
	ALUSrcB, ALUSrcA, RegWrite, RegDst, PCSel, ALUCtrl, Op, Zero, Function);

endmodule
