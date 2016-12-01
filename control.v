module control (clk, reset,Op, Zero, IorD, MemRead, MemWrite, MemtoReg, IRWrite,
PCSource, ALUSrcB, ALUSrcA, RegWrite, RegDst, PCSel, ALUOp);

	input clk;
	input reset;
	input [5:0] Op;
	input Zero;

	output reg IorD;
	output reg MemWrite;
	output reg MemRead;
	output reg MemtoReg;
	output reg IRWrite;
	output reg PCSource;
	output reg RegDst;
	output reg RegWrite;
	output reg ALUSrcA;
	output reg [1:0] ALUSrcB;
	output PCSel;
	output reg [1:0] ALUOp;

	reg PCWrite;
	reg PCWriteCond;

	assign
		PCSel = (PCWrite | (PCWriteCond & Zero));

	//states
	parameter FETCH = 4'b0000;
	parameter DECODE = 4'b0001;
	parameter MEMADRCOMP = 4'b0010;
	parameter MEMACCESSL = 4'b0011;//L1
	parameter MEMREADEND = 4'b0100;//L2
	parameter MEMACCESSS = 4'b0101;//S
	parameter EXECUTION = 4'b0110;
	parameter RTYPEEND = 4'b0111;
	parameter BEQ = 4'b1000;

	reg [3:0] state;
	reg [3:0] nextstate;

  always@(posedge clk)
    if (reset)
		state <= FETCH;
    else
		state <= nextstate;


	always@(state or Op) begin
      	case (state)
        FETCH:  nextstate = DECODE;
        DECODE:  case(Op)
					//OpCode
                   6'b100011:	nextstate = MEMADRCOMP;//lw
                   6'b101011:	nextstate = MEMADRCOMP;//sw
                   6'b000000:	nextstate = EXECUTION;//r
                   6'b000100:	nextstate = BEQ;//beq
                   default: nextstate = FETCH;
                 endcase
        MEMADRCOMP:  case(Op)
                   6'b100011:      nextstate = MEMACCESSL;//lw
                   6'b101011:      nextstate = MEMACCESSS;//sw
                   default: nextstate = FETCH;
                 endcase
        MEMACCESSL:    nextstate = MEMREADEND;
        MEMREADEND:    nextstate = FETCH;
        MEMACCESSS:    nextstate = FETCH;
        EXECUTION: nextstate = RTYPEEND;
        RTYPEEND: nextstate = FETCH;
        BEQ:   nextstate = FETCH;
        default: nextstate = FETCH;
      endcase
    end


	always@(state) begin

	IorD=1'b0; MemRead=1'b0; MemWrite=1'b0; MemtoReg=1'b0; IRWrite=1'b0; PCSource=1'b0;
	ALUSrcB=2'b00; ALUSrcA=1'b0; RegWrite=1'b0; RegDst=1'b0; PCWrite=1'b0; PCWriteCond=1'b0; ALUOp=2'b00;

    	case (state)
        FETCH:
          begin
            MemRead = 1'b1;
            IRWrite = 1'b1;
            ALUSrcB = 2'b01;
            PCWrite = 1'b1;
          end
        DECODE:
	    ALUSrcB = 2'b11;
        MEMADRCOMP:
          begin
            ALUSrcA = 1'b1;
            ALUSrcB = 2'b10;
          end
        MEMACCESSL:
          begin
            MemRead = 1'b1;
            IorD    = 1'b1;
          end
        MEMREADEND:
          begin
            RegWrite = 1'b1;
	    MemtoReg = 1'b1;
            RegDst = 1'b0;
          end
        MEMACCESSS:
          begin
            MemWrite = 1'b1;
            IorD     = 1'b1;
          end
        EXECUTION:
          begin
            ALUSrcA = 1'b1;
            ALUOp   = 2'b10;
          end
        RTYPEEND:
          begin
            RegDst   = 1'b1;
            RegWrite = 1'b1;
          end
        BEQ:
          begin
            ALUSrcA = 1'b1;
            ALUOp   = 2'b01;
            PCWriteCond = 1'b1;
	    PCSource = 2'b01;
          end
      endcase
    end
endmodule
