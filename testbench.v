`define CYCLE_TIME 20
`define INSTRUCTION_NUMBERS 20000
`timescale 1ns/1ps
`include "CPU.v"

module testbench;
reg Clk, Rst;
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
		cpu.IF.instruction[ 0] = 32'b100011_00000_00010_00000_00000_000000;	// lw $2,0($0)
		cpu.IF.instruction[ 4] = 32'b100011_00000_00011_00000_00000_000000;	// lw $3,0($0)
		cpu.IF.instruction[ 8] = 32'b000000_00000_00001_00100_00000_100010;	// sub $4,$zero,$1
		cpu.IF.instruction[12] = 32'b000000_00000_00001_01000_00000_100000; // add $8,$zero,$1
		cpu.IF.instruction[16] = 32'b000010_00000_00000_00000_00000_100000; // jump to find () ❗

		// B
		cpu.IF.instruction[20] = 32'b100011_00000_00011_00000_00000_000000;	// lw $3,0($0)
		cpu.IF.instruction[24] = 32'b000000_00000_00001_00100_00000_100000;	// add $4,$zero,$1
		cpu.IF.instruction[28] = 32'b000000_00001_00001_01000_00000_100000; // add $8,$1,$1

		// find
		cpu.IF.instruction[32] = 32'b000000_00011_00100_00011_00000_100000; // add $3,$3,$4
		cpu.IF.instruction[36] = 32'b000000_00001_00001_00101_00000_100000; // add $5,$1,$1

		// next_i
		cpu.IF.instruction[40] = 32'b000000_00101_00011_00110_00000_101010; // slt $6,$5,$3
		cpu.IF.instruction[44] = 32'b000100_00110_00000_00000_00000_011111; // beq $6,$zero,print ❗
		cpu.IF.instruction[48] = 32'b000000_00011_00000_00111_00000_100000; // add $7,$3,$zero

		// mod
		cpu.IF.instruction[52] = 32'b000000_00111_00101_00111_00000_100010; // sub $7,$7,$5
		cpu.IF.instruction[56] = 32'b000000_00000_00111_00110_00000_101010; // slt $6,$zero,$7
		cpu.IF.instruction[60] = 32'b000101_00110_00000_11111_11111_110111; // bne $6,$zero,mod ❗
		cpu.IF.instruction[64] = 32'b000100_00111_00000_11111_11111_011111; // beq $7,$zero,find ❗
		cpu.IF.instruction[68] = 32'b000000_00101_00001_00101_00000_100000; // add $5,$5,1
		cpu.IF.instruction[72] = 32'b000010_00000_00000_00000_00000_101000; // j next_i  ❗

		// print
		cpu.IF.instruction[76] = 32'b101011_01000_00011_00000_00000_000000; // sw $3,0($8)
		cpu.IF.instruction[80] = 32'b000000_00011_00010_00110_00000_101010; // slt $6,$3,$2
		cpu.IF.instruction[84] = 32'b000101_00110_00000_11111_11110_111111; // bne $6,$zero,B ❗

		cpu.IF.PC = 0;
end

//clock cycle time is 20ns, inverse Clk value per 10ns
initial Clk = 1'b1;
always #(`CYCLE_TIME/2) Clk = ~Clk;

//Rst signal
initial begin
	cycles = 32'b0;
	Rst = 1'b1;
	#12 Rst = 1'b0;
end

CPU cpu(
	.clk(Clk),
	.rst(Rst)
);

//display all Register value and Data memory content
always @(posedge Clk) begin
	cycles <= cycles + 1;
	if (cycles == `INSTRUCTION_NUMBERS) $finish; // Finish when excute the 24-th instruction (End label).
	if ((cpu.FD_PC>>2) > 100) $finish;

	$display("PC: %d cycles: %d", cpu.FD_PC>>2 , cycles);
	$display("  R00-R07: %08x %08x %08x %08x %08x %08x %08x %08x", cpu.ID.REG[0], cpu.ID.REG[1], cpu.ID.REG[2], cpu.ID.REG[3],cpu.ID.REG[4], cpu.ID.REG[5], cpu.ID.REG[6], cpu.ID.REG[7]);
	$display("  R08-R15: %08x %08x %08x %08x %08x %08x %08x %08x", cpu.ID.REG[8], cpu.ID.REG[9], cpu.ID.REG[10], cpu.ID.REG[11],cpu.ID.REG[12], cpu.ID.REG[13], cpu.ID.REG[14], cpu.ID.REG[15]);
	$display("  R16-R23: %08x %08x %08x %08x %08x %08x %08x %08x", cpu.ID.REG[16], cpu.ID.REG[17], cpu.ID.REG[18], cpu.ID.REG[19],cpu.ID.REG[20], cpu.ID.REG[21], cpu.ID.REG[22], cpu.ID.REG[23]);
	$display("  R24-R31: %08x %08x %08x %08x %08x %08x %08x %08x", cpu.ID.REG[24], cpu.ID.REG[25], cpu.ID.REG[26], cpu.ID.REG[27],cpu.ID.REG[28], cpu.ID.REG[29], cpu.ID.REG[30], cpu.ID.REG[31]);
	$display("  0x00   : %08x %08x %08x %08x %08x %08x %08x %08x", cpu.MEM.DM[0],cpu.MEM.DM[1],cpu.MEM.DM[2],cpu.MEM.DM[3],cpu.MEM.DM[4],cpu.MEM.DM[5],cpu.MEM.DM[6],cpu.MEM.DM[7]);
	$display("  0x08   : %08x %08x %08x %08x %08x %08x %08x %08x", cpu.MEM.DM[8],cpu.MEM.DM[9],cpu.MEM.DM[10],cpu.MEM.DM[11],cpu.MEM.DM[12],cpu.MEM.DM[13],cpu.MEM.DM[14],cpu.MEM.DM[15]);
end

//generate wave file, it can use gtkwave to display
initial begin
	$dumpfile("cpu_hw.vcd");
	$dumpvars;
end
endmodule

