module datapath(clk, reset, IorD, MemRead, MemWrite, MemtoReg, IRWrite,
PCSource, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCSel, ALUCtrl, Op, Zero, Function);

	parameter PCSTART = 128; //starting address of instruction memory
	input clk;
	input reset;
	input IorD;
	input MemWrite,MemRead,MemtoReg;
	input IRWrite;
	input PCSource;
	input RegDst,RegWrite;
	input ALUSrcA;
	input [1:0] ALUSrcB;
	input PCSel;
	input [3:0] ALUCtrl;

	output [5:0] Op;
	output Zero;
	output [5:0] Function;

	reg [7:0]PC;

	reg [31:0] ALUOut;

	reg [31:0] ALUResult;
	wire [31:0] OpA;
	reg [31:0] OpB;

	reg [31:0]A;
	reg [31:0]B;

	wire [7:0] address;

    wire [31:0] MemData;

	reg[31:0]mem[255:0];

	reg [31:0]Instruction;

	reg [31:0]mdr;

	wire [31:0] da;//read data 1
	wire [31:0] db;//read data 2

	reg[31:0]registers[31:0];

	assign Function=Instruction[5:0];
	assign Op=Instruction[31:26];

	//data and instruction memory
	assign address=(IorD)?ALUOut:PC;

	initial
		$readmemh("mem.dat", mem);

	always @(posedge clk) begin
		if(MemWrite)
			mem[address]<=B;
	end

	assign
		MemData =(MemRead)? mem[address]:32'bx;

	//PC logic

	always@ (posedge clk)begin
		if(reset)
			PC<=PCSTART;
		else
		if(PCSel)begin
			case (PCSource)
				1'b0: PC<=ALUResult;
				1'b1: PC<=ALUOut;
			endcase
		end
	end

	//instruction register

	always @(posedge clk) begin
		if (IRWrite)
			Instruction <= MemData;
	end

	//memory data register
	always @(posedge clk) begin
		mdr <= MemData;
	end

	//register file
	//$r0 is always 0
	assign da = (Instruction[25:21]!=0) ? registers[Instruction[25:21]] : 0;
	assign db = (Instruction[20:16]!=0) ? registers[Instruction[20:16]] : 0;


	always @(posedge clk) begin
		if (RegWrite)begin
			if (RegDst)
				registers[Instruction[15:11]]<=(MemtoReg)?mdr:ALUOut;
			else
				registers[Instruction[20:16]]<=(MemtoReg)?mdr:ALUOut;
		end
	end

	//A and B registers

	always @(posedge clk) begin
		A<=da;
	end

	always@(posedge clk) begin
		B<=db;
	end


	//ALU

	assign OpA=(ALUSrcA)?A:PC;

	always@(ALUSrcB or B or Instruction[15:0])begin
		casex(ALUSrcB)
		2'b00:OpB=B;
		2'b01:OpB=1;
		2'b1x:OpB={{(16){Instruction[15]}},Instruction[15:0]};
		endcase
	end

	assign Zero = (ALUResult==0);//Zero == 1 when ALUResult is 0 (for branch)

	always @(ALUCtrl or OpA or OpB) begin
		case(ALUCtrl)
		4'b0000:ALUResult = OpA & OpB;
		4'b0001:ALUResult = OpA | OpB;
		4'b0010:ALUResult = OpA + OpB;
		4'b0110:ALUResult = OpA - OpB;
		4'b0111:ALUResult = OpA < OpB?1:0;
		4'b1100:ALUResult = ~(OpA | OpB);
		endcase
	end

	//ALUOut register

	always@(posedge clk) begin
		ALUOut<=ALUResult;
	end

endmodule
