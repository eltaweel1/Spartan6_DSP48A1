module DSP48A1(A,B,C,D,M,P,CARRYIN,CLK,OPMODE,CEA,CEC,CED,CEM,
CEOPMODE,CEP,CEB,RSTOPMODE,RSTA,RSTM,RSTP,RSTB,RSTC,RSTD,RSTCARRYIN,
PCIN,PCOUT,BCOUT,CARRYOUT,CARRYOUTF,CECARRYIN,BCIN );
input [17:0] A,B,D,BCIN;
input [47:0] C;
input CARRYIN,CLK,CEA,CEC,CED,CEM,
CEOPMODE,CEP,CEB,RSTOPMODE,RSTA,RSTM,RSTP,RSTB,RSTC,RSTD,RSTCARRYIN,CECARRYIN;
input [47:0] PCIN;
input [7:0] OPMODE;
output CARRYOUT,CARRYOUTF;
output [47:0] PCOUT,P;
output [35:0] M;
output [17:0] BCOUT;
// 1=registered 0 not registered
parameter A0REG=0, A1REG=1,B0REG=0,B1REG=1;
parameter CREG = 1;
parameter DREG = 1;
parameter MREG = 1;
parameter PREG = 1;
parameter CARRYINREG = 1;
parameter CARRYOUTREG = 1;
parameter OPMODEREG = 1;
parameter CARRYINSEL ="OPMODE5"; 
parameter RSTTYPE="SYNC"; 
parameter B_INPUT="DIRECT";
wire [17:0] A0_reg,B0_reg,D_reg;
wire [17:0] A1_reg,B1_reg;
wire [47:0] C_reg;
wire [35:0] M_reg;
wire [47:0] P_reg;
wire [7:0] OPMODE_reg;
wire CARROUT_reg,CARRYOUTF_reg;
wire [17 : 0] a1, b1; 
wire [17 : 0] B_SELECT; 
wire CYI;
wire CYO;
assign B_SELECT = (B_INPUT=="DIRECT")?B:(B_INPUT=="CASCADE")? BCIN:18'b0;
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(8)) OPMODE_REG (CLK, RSTOPMODE, CEOPMODE, 
OPMODEREG, OPMODE, OPMODE_reg);  
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(18)) D0_STAGE (CLK, RSTD, CED, DREG, D, D_reg); 
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(18)) B0_STAGE (CLK, RSTB, CEB, B0REG, 
B_SELECT, B0_reg);  
//pre-adder/subtracter
wire [17:0] pre_out;
assign pre_out = (~OPMODE_reg[4] )?//راجججع
                 B0_reg :
                 (OPMODE_reg[6] ? D_reg - B0_reg : D_reg + B0_reg);
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(18)) B1_STAGE (CLK, RSTB, CEB, B1REG, 
pre_out, B1_reg); 
//*********************
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(18)) A0_STAGE (CLK, RSTA, CEA, A0REG, A,A0_reg); 
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(18)) A1_STAGE (CLK, RSTA, CEA, A1REG, A0_reg, 
A1_reg); 
//multiplier
wire [35:0] MUL_out;
assign MUL_out = (B1_reg*A1_reg);
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(36)) M_STAGE (CLK, RSTM, CED, MREG, MUL_out, M_reg); 
assign M=M_reg;
//************************
//the X_MUX
wire [47:0] X_OUT;
wire [47:0] D_A_B_CONC;
assign D_A_B_CONC = {D_reg[11:0], A1_reg, B1_reg};
assign X_OUT = (OPMODE_reg[1:0] == 2'b00) ? 48'b0 :
               (OPMODE_reg[1:0] == 2'b01) ? {12'b0,M_reg} :
               (OPMODE_reg[1:0] == 2'b10) ? PCOUT :
               (OPMODE_reg[1:0] == 2'b11) ? D_A_B_CONC :
               48'b0;
//************************
//the Z_MUX
wire [47:0] Z_OUT;
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(48)) C0_STAGE (CLK, RSTC, CEC, CREG, C, C_reg); 
assign Z_OUT = (OPMODE_reg[3:2] == 2'b00) ? 48'b0 :
               (OPMODE_reg[3:2] == 2'b01) ? PCIN :
               (OPMODE_reg[3:2] == 2'b10) ? PCOUT :
               (OPMODE_reg[3:2] == 2'b11) ? C_reg :
               48'b0;
//************************
//THE CARRYIN
wire carry_select;
assign carry_select = (CARRYINSEL=="OPMODE5")?OPMODE_reg[5]:(CARRYINSEL=="CARRYIN")?CARRYIN:
1'b0;
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(1)) CARRYIN_STAGE (CLK, RSTCARRYIN, CECARRYIN, CARRYINREG, 
carry_select
,CYI); 
//************************

//post-adder/subtracter
wire carry_out;
wire [47:0] out_post;
assign {carry_out,out_post} = (OPMODE_reg[7]) ? 
               (Z_OUT - (X_OUT + {{47{1'b0}}, CYI})) :
               (Z_OUT + X_OUT + {{47{1'b0}}, CYI});
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(1)) CARRYOUT_STAGE (CLK, RSTCARRYIN, CECARRYIN, CARRYOUTREG, carry_out
,CYO); 
assign CARRYOUT=CYO;
assign CARRYOUTF=CARRYOUT;
//PCOUT BCOUT OUTPUTS
REG_MUX #(.sync_type(RSTTYPE), .WIDTH(48)) P_STAGE (CLK, RSTP, CEP,  PREG, out_post, P_reg); 
assign P=P_reg;
assign PCOUT=P_reg;
assign BCOUT = B1_reg; 
endmodule

module REG_MUX #(parameter [5:0] WIDTH = 8, parameter sync_type = "SYNC") (
    input clk, rst, clk_enable, select,
    input [WIDTH-1:0] in,
    output reg [WIDTH-1:0] out
);

reg [WIDTH-1:0] d_ff;

localparam synchronous = (sync_type == "SYNC");
localparam asynchronous = (sync_type == "ASYNC");

generate
    if (asynchronous) begin
        always @(posedge clk or posedge rst) begin
            if (rst)
                d_ff <= 0;
            else if (clk_enable)
                d_ff <= in;
        end
    end else if (synchronous) begin
        always @(posedge clk) begin
            if (rst)
                d_ff <= 0;
            else if (clk_enable)
                d_ff <= in;
        end
    end
endgenerate

always @(*) begin
    out = (select) ? d_ff : in;
end

endmodule
