module dsp48a1
            (
                CLK, RSTA, RSTB, RSTC, RSTD, RSTM, RSTOPMODE, RSTP, RSTCARRYIN,
                CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP, 
                A, B, C, D, BCIN, PCIN, CARRYIN, OPMODE, 
                CARRYOUT, CARRYOUTF, BCOUT, M, PCOUT, P
            );
    //! Parameter (Attributes):
//  The A0REG, A1REG, B0REG, and B1REG attributes can take values of 0 or 1. 
// these values define the number of pipeline registers in the A and B input paths.
// A0REG defaults to 0 (no register). A1REG defaults to 1 (register). B0REG defaults to 0 (no register) B1REG defaults to 1 (register). 
// A0 and B0 are the first stages of the pipelines. 
// A1 and B1 are the second stages of the pipelines
parameter A0REG       = 1'b0;
parameter A1REG       = 1'b1;
parameter B0REG       = 1'b0;
parameter B1REG       = 1'b1;

// These attributes can take a value of 0 or 1. 
// The number defines the number of pipeline stages. Default: 1 (registered)
parameter CREG        = 1'b1;
parameter DREG        = 1'b1;
parameter MREG        = 1'b1;
parameter PREG        = 1'b1;
parameter CARRYINREG  = 1'b1;
parameter CARRYOUTREG = 1'b1;
parameter OPMODEREG   = 1'b1;

// The CARRYINSEL attribute is used in the carry cascade input, either the CARRYIN input will be considered or the value of opcode[5]. 
// This attribute can be set to the string CARRYIN or OPMODE5. 
// Default: OPMODE5. Tie the output of the mux to 0 if none of these string values exist.
parameter CARRYINSEL  = "OPMODE5";

// The B_INPUT attribute defines whether the input to the B port is routed from the B input (attribute = DIRECT) or the cascaded input
// (BCIN) from the previous DSP48A1 slice (attribute = CASCADE).
// Default: DIRECT. Tie the output of the mux to 0 if none of these string values exist.
parameter B_INPUT     = "DIRECT";

// The RSTTYPE attribute selects whether all resets for the DSP48A1 slice should have a synchronous or asynchronous reset capability.
// This attribute can be set to ASYNC or SYNC. Default: SYNC.
parameter RSTTYPE     = "SYNC";
    // ! Data Ports:
input [17 : 0] A;  //18-bit data input to multiplier, and optionally to postadder subtracter depending on the value of OPMODE[1:0].
input [17 : 0] B;  //18-bit data input to pre-adder/subtracter, to multiplier depending on OPMODE[4], or to post-adder/subtracter depending onOPMODE[1:0].
input [47 : 0] C;  //48-bit data input to post-adder/subtracter.
input [17 : 0] D;  //18-bit data input to pre-adder/subtracter. D[11:0] are concatenated with A and B and optionally sent to post-adder/subtracter depending on the value of OPMODE[1:0].
input [17 : 0] BCIN;
input CARRYIN;     //carry input to the post-adder/subtracter
output [35 : 0] M; //36-bit buffered multiplier data output, routable to the FPGA logic. It either the output of the M register (MREG = 1) or the direct output of the multiplier (MREG = 0).
output [47 : 0] P; //Primary data output from the post-adder/subtracter. It is either the output of the P register (PREG = 1) or the direct output of the postadder/subtracter (PREG = 0).
output CARRYOUT;   //Cascade carry out signal from post-adder/subtracter. It can be registered in (CARRYOUTREG = 1) or unregistered (CARRYOUTREG = 0). This output is to be connected only to CARRYIN of adjacent DSP48A1 if multiple DSP blocks are used.
output CARRYOUTF;  //Carry out signal from post-adder/subtracter for use in the FPGA logic. It is a copy of the CARRYOUT signal that can be routed to the user logic.
    //! Control Input Ports
input CLK;         //DSP clock
input [7 : 0] OPMODE; //Control input to select the arithmetic operations of the DSP48A1 slice.
    //! Clock Enable Input Ports
input CEA;        //Clock enable for the A port registers: (A0REG & A1REG).
input CEB;        //Clock enable for the B port registers: (B0REG & B1REG).
input CEC;        //Clock enable for the C port registers (CREG).
input CECARRYIN;  //Clock enable for the carry-in register (CYI) and the carry-out register (CYO).
input CED;        //Clock enable for the D port register (DREG).
input CEM;        //Clock enable for the multiplier register (MREG).
input CEOPMODE;   //Clock enable for the opmode register (OPMODEREG).
input CEP;        //Clock enable for the P output port registers (PREG = 1).
    //! Reset Input Ports: All the resets are active high reset. They are either sync or async depending on the parameter RSTTYPE.
input RSTA;       //Reset for the A registers: (A0REG & A1REG).
input RSTB;       //Reset for the B registers: (B0REG & B1REG).
input RSTC;       //Reset for the C registers (CREG).
input RSTCARRYIN; //Reset for the carry-in register (CYI) and the carry-out register (CYO).
input RSTD;       //Reset for the D register (DREG).
input RSTM;       //Reset for the multiplier register (MREG).
input RSTOPMODE;  //Reset for the opmode register (OPMODEREG).
input RSTP;       //Reset for the P output registers (PREG = 1).
    //! Cascade Ports:
output [17 : 0] BCOUT; //Cascade output for Port B.
input  [47 : 0] PCIN;  //Cascade input for Port P.
output [47 : 0] PCOUT; //Cascade output for Port P.

// !first stage
//regester -> A0REG, BOREG, DREG, CREG, OPMODEREG
wire [17 : 0] a0, b0, d;    // A0REG, BOREG, DREG
wire [47 : 0] c;            //CREG
wire [7 : 0] opmode_reg;    //OPMODEREG

wire [17 : 0] b_select;     // regster to select B or BCIN to store it in B0REG based on the value of B_INPUT  
                            /*
                            The B_INPUT attribute defines whether the input to the B port is routed from the B input (attribute = DIRECT) or the cascaded input
                            (BCIN) from the previous DSP48A1 slice (attribute = CASCADE).
                            Default: DIRECT. Tie the output of the mux to 0 if none of these string values exist.
                            */
assign b_select = (B_INPUT == "DIRECT") ? B : (B_INPUT == "CASCADE") ? BCIN : 18'b0;

REG_MUX #(.sync_type(RSTTYPE), .WIDTH(8)) OPMODE_REG (CLK, RSTOPMODE, CEOPMODE, OPMODEREG, OPMODE, opmode_reg); 
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(18)) A0_STAGE (CLK, RSTA, CEA, A0REG, A, a0);
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(18)) B0_STAGE (CLK, RSTB, CEB, B0REG, b_select, b0); 
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(48)) C0_STAGE (CLK, RSTC, CEC, CREG, C, c);
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(18)) D0_STAGE (CLK, RSTD, CED, DREG, D, d);

//! pre_adder/subtarcter 
wire [17 : 0] out_pre;
assign out_pre = (opmode_reg[6] == 0) ? (d + b0) : (d - b0);

wire [17 : 0] out_mux_opmode_4;
assign out_mux_opmode_4 = (opmode_reg[4] == 1) ? out_pre : b0;

//! second stage 
wire [17 : 0] a1, b1;
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(18)) B1_STAGE (CLK, RSTB, CEB, B1REG, out_mux_opmode_4, b1);
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(18)) A1_STAGE (CLK, RSTA, CEA, A1REG, a0, a1);
assign BCOUT = b1;

//! multiplication 
wire [35 : 0] out_mul, mul_reg;
assign out_mul = b1 * a1;
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(36)) mul (CLK, RSTM, CEM, MREG, out_mul, mul_reg);
assign M = mul_reg;

//! x_multiplexer  
wire [47 : 0] x_mux;
assign x_mux = (opmode_reg[1 : 0] == 2'b11) ? {d[11 : 0], a1[17 : 0], b1[17 : 0]} : 
                (opmode_reg[1 : 0] == 2'b10) ?  PCOUT  : (opmode_reg[1 : 0] == 2'b01) ? {12'b0, mul_reg} : 0;

//! z_multiplexer
wire [47 : 0] z_mux;
assign z_mux = (opmode_reg[3 : 2] == 2'b11) ? c : (opmode_reg[3 : 2] == 2'b10) ? PCOUT  : (opmode_reg[3 : 2] == 2'b01) ? PCIN : 0;

//!carry in
wire carry_select;
wire cin;
assign carry_select = (CARRYINSEL == "OPMODE5") ? opmode_reg[5] : (CARRYINSEL == "CARRYIN") ? CARRYIN : 1'b0;
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(1)) CY1 (CLK, RSTCARRYIN, CECARRYIN, CARRYINREG, carry_select, cin);

//! post_adder/subtarcter
wire [47 : 0] out_post;
wire carry_out;
wire c_out;
assign {carry_out, out_post} = (opmode_reg[7] == 0) ? (z_mux + x_mux + cin) : (z_mux - (x_mux + cin));

//! carry out 
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(1)) CYO (CLK, RSTCARRYIN, CECARRYIN, CARRYOUTREG, carry_out, c_out);
assign CARRYOUT = c_out;
assign CARRYOUTF = CARRYOUT;

// //! output p
wire [47 : 0] out_p;
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(48)) OUT_P_REG (CLK, RSTP, CEP, PREG, out_post, out_p);
assign P = out_p;
assign PCOUT = P;
endmodule 

module REG_MUX(clk, rst, clk_enable, select, in, out);
parameter sync_type = "SYNC";
localparam synchronous = (sync_type == "SYNC");
localparam asynchronous = (sync_type == "ASYNC");

parameter WIDTH = 18;
input clk;
input rst;
input clk_enable;
input select;
input [WIDTH - 1 : 0] in;
output reg [WIDTH - 1 : 0] out; 

reg [WIDTH - 1 : 0] d_ff;
generate 
    if(synchronous) begin 
        always@(posedge clk) begin 
            if(rst) begin 
                d_ff <= 0;
            end 
            else if(clk_enable)begin 
                d_ff <= in;
            end
        end 
    end 
    else if(asynchronous) begin 
        always@(posedge clk or posedge rst) begin 
            if(rst) begin 
                d_ff <= 0;
            end 
            else if(clk_enable)begin
                d_ff <= in;
            end 
        end 
    end 
endgenerate 

always@(*) begin
    if(select == 1) begin 
        out = d_ff;
    end 
    else begin 
        out = in;
    end  
end 
endmodule
