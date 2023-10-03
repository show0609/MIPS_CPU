`timescale 1ns/1ps
module testbench2
(
	input CLK,
	input BTNC,
    input [15:0] SW,
  
    output CA,
    output CB,
    output CC,
    output CD,
    output CE,
    output CF,
    output CG,
    output DP,
    output [7:0] AN
);
reg [31:0] cycles, i;

// Instruction DM initialilation
initial
begin
	/*=================================================     write down your program     =================================================*/
    // $1: 1
    // $2: input number
    // $3: test number
    // $4: step
    // $5: i
    // $6: for set on less than
    // $7: for mod
    // $8: memory address to store

    // mem[0]: input number
    // mem[1]: prime A (small)
    // mem[2]: prime B (big)

    for (i=0; i<128; i=i+1)  cpu.IF.instruction[ i] = 32'b000000_00000_00000_00000_00000_100000; //NOP(add $0, $0, $0)
    
    // A
    cpu.IF.instruction[ 0] = 32'b100011_00000_00010_00000_00000_000000;    // lw $2,0($0)
    cpu.IF.instruction[ 4] = 32'b100011_00000_00011_00000_00000_000000;    // lw $3,0($0)
    cpu.IF.instruction[ 8] = 32'b000000_00000_00001_00100_00000_100010;    // sub $4,$zero,$1
    cpu.IF.instruction[12] = 32'b000000_00000_00001_01000_00000_100000; // add $8,$zero,$1
    cpu.IF.instruction[16] = 32'b000010_00000_00000_00000_00000_100000; // jump to find () ?

    // B
    cpu.IF.instruction[20] = 32'b100011_00000_00011_00000_00000_000000;    // lw $3,0($0)
    cpu.IF.instruction[24] = 32'b000000_00000_00001_00100_00000_100000;    // add $4,$zero,$1
    cpu.IF.instruction[28] = 32'b000000_00001_00001_01000_00000_100000; // add $8,$1,$1

    // find
    cpu.IF.instruction[32] = 32'b000000_00011_00100_00011_00000_100000; // add $3,$3,$4
    cpu.IF.instruction[36] = 32'b000000_00001_00001_00101_00000_100000; // add $5,$1,$1

    // next_i
    cpu.IF.instruction[40] = 32'b000000_00101_00011_00110_00000_101010; // slt $6,$5,$3
    cpu.IF.instruction[44] = 32'b000100_00110_00000_00000_00000_011111; // beq $6,$zero,print ?
    cpu.IF.instruction[48] = 32'b000000_00011_00000_00111_00000_100000; // add $7,$3,$zero

    // mod
    cpu.IF.instruction[52] = 32'b000000_00111_00101_00111_00000_100010; // sub $7,$7,$5
    cpu.IF.instruction[56] = 32'b000000_00000_00111_00110_00000_101010; // slt $6,$zero,$7
    cpu.IF.instruction[60] = 32'b000101_00110_00000_11111_11111_110111; // bne $6,$zero,mod ?
    cpu.IF.instruction[64] = 32'b000100_00111_00000_11111_11111_011111; // beq $7,$zero,find ?
    cpu.IF.instruction[68] = 32'b000000_00101_00001_00101_00000_100000; // add $5,$5,1
    cpu.IF.instruction[72] = 32'b000010_00000_00000_00000_00000_101000; // j next_i  ?

    // print
    cpu.IF.instruction[76] = 32'b101011_01000_00011_00000_00000_000000; // sw $3,0($8)
    cpu.IF.instruction[80] = 32'b000000_00011_00010_00110_00000_101010; // slt $6,$3,$2
    cpu.IF.instruction[84] = 32'b000101_00110_00000_11111_11110_111111; // bne $6,$zero,B ?

    cpu.IF.PC = 0;
end

CPU cpu(
	.clk(CLK),
	.rst(BTNC),
	.SW(SW)
);

wire [31:0] primeA,primeB;
reg [17:0] counter;
reg [2:0] state;
reg [6:0] seg_number,seg_data;
reg [7:0] scan;

//FPGA verification

//output your answer
//assign number[31:0] = cpu.ID.REG[4];
assign primeA[31:0] = cpu.MEM.DM[1];
assign primeB[31:0] = cpu.MEM.DM[2];

assign AN[7:0] = scan;
assign DP = 1;

//choose which bit on 7-seg should be blinked (0~7)
always@(posedge CLK) begin
  counter <=(counter<=100000) ? (counter +1) : 0;
  state <= (counter==100000) ? (state + 1) : state;
   case(state)
	0:begin
	 seg_number <= primeB/1000; 
	  scan <= 8'b0111_1111;
	end
	1:begin
	  seg_number <=  primeB%1000/100;  
	  scan <= 8'b1011_1111;
	end
	2:begin
	  seg_number <= primeB%100/10; 
	  scan <= 8'b1101_1111;
	end
	3:begin
	 seg_number <= primeB%10; 
	  scan <= 8'b1110_1111;
	end
	4:begin
      seg_number <= primeA/1000;   
	  scan <= 8'b1111_0111;
	end
	5:begin
	  seg_number <= primeA%1000/100;  
	  scan <= 8'b1111_1011;
	end
	6:begin
	 seg_number <= primeA%100/10; 
	  scan <= 8'b1111_1101;
	end
	7:begin
	 seg_number <= primeA%10;  
	  scan <= 8'b1111_1110;
	end
	default: state <= state;
  endcase 
end  

//value of bit on 7-seg (0~9)
assign {CG,CF,CE,CD,CC,CB,CA} = seg_data;
always@(posedge CLK) begin  
  case(seg_number)
	16'd0:seg_data <= 7'b100_0000;
	16'd1:seg_data <= 7'b111_1001;
	16'd2:seg_data <= 7'b010_0100;
	16'd3:seg_data <= 7'b011_0000;
	16'd4:seg_data <= 7'b001_1001;
	16'd5:seg_data <= 7'b001_0010;
	16'd6:seg_data <= 7'b000_0010;
	16'd7:seg_data <= 7'b101_1000;
	16'd8:seg_data <= 7'b000_0000;
	16'd9:seg_data <= 7'b001_0000;
	default: seg_number <= seg_number;
  endcase
end 
endmodule

