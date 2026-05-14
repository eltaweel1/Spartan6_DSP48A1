module dsp48a1_tb();
//! 1. The parameters will remain unchanged.
//! Control Input Ports
reg CLK; 
reg [7 : 0] OPMODE;
//! Reset Input Ports: All the resets are active high reset. They are either sync or async depending on the parameter RSTTYPE.
reg RSTA, RSTB, RSTC, RSTCARRYIN, RSTD, RSTM, RSTOPMODE, RSTP;
//! Clock Enable Input Ports
reg CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP;

reg [17 : 0] A, D, B, BCIN;
reg CARRYIN; 
reg  [47 : 0] PCIN, C;
wire [17 : 0] BCOUT; 
wire [47 : 0] PCOUT, P;
wire [35 : 0] M;
wire CARRYOUT, CARRYOUTF;

//! out expected 
reg [17 : 0] BCOUT_expected;
reg [47 : 0] PCOUT_expected, P_expected;
reg [35 : 0] M_expected;
reg CARRYOUT_expected, CARRYOUTF_expected;
reg [47 : 0] past_Value_of_P;
reg past_value_of_CARRYOUT;
reg [48 : 0] result;

dsp48a1 uut(
                CLK, RSTA, RSTB, RSTC, RSTD, RSTM, RSTOPMODE, RSTP, RSTCARRYIN,
                CEA, CEB, CEC, CECARRYIN, CED, CEM, CEOPMODE, CEP, A, B, C, D, BCIN, PCIN, CARRYIN, OPMODE, 
                CARRYOUT, CARRYOUTF, BCOUT, M, PCOUT, P
            );
//! clock generation 
initial begin 
    CLK = 0;
    forever 
        #1 CLK = ~CLK; 
end 
//! 2. Stimulus Generation (Initial Block)
initial begin 
    //! initialize input 
    A = 0;  B = 0; C = 0;  D = 0;  BCIN = 0; CARRYIN = 0; OPMODE = 0;
    CEA = 0; CEB = 0; CEC = 0; CECARRYIN = 0; CED = 0; CEM = 0; CEOPMODE = 0; CEP = 0;
    PCIN = 0; BCOUT_expected = 0; PCOUT_expected = 0; M_expected = 0; P_expected = 0; 
    CARRYOUT_expected = 0; CARRYOUTF_expected = 0; past_Value_of_P = 0; result = 0;

    //! 2.1. Verify Reset Operation
    //Assert all active-high reset signals by setting them to 1.
    RSTA = 1; RSTB = 1; RSTC = 1; RSTCARRYIN = 1; RSTD = 1; RSTM = 1; RSTOPMODE = 1; RSTP = 1;
    //Drive remaining inputs with arbitrary (random) values.
    A = $random; B = $random; C = $random; D = $random; BCIN = $random;
    CARRYIN = $random; OPMODE = $random; PCIN = $random;
    CEA = $random; CEB = $random; CEC = $random; CECARRYIN = $random; CED = $random; CEM =$random; CEOPMODE = $random; CEP = $random;
    //Wait for the negative edge of the clock.
    @(negedge CLK);
    //Add a condition for self-checking to verify that all outputs are zero.
    BCOUT_expected = 0; PCOUT_expected = 0; M_expected = 0; P_expected = 0; CARRYOUT_expected = 0; CARRYOUTF_expected = 0;
    if(BCOUT_expected != BCOUT)
        $display("ERROR IN RESET BCOUNT");
    else 
        $display("RESET BCOUNT pass");
    if(PCOUT_expected != PCOUT) 
        $display("ERROR IN RESET PCOUT");
    else  
        $display("RESET PCOUT pass"); 
    if(M_expected != M)
        $display("ERROR IN RESET M");
    else 
        $display("RESET M pass"); 
    if(P_expected != P)
        $display("ERROR IN RESET P");
    else 
        $display("RESET P pass"); 
    if(CARRYOUT_expected != CARRYOUT)
        $display("ERROR IN RESET CARRYOUT");
    else 
        $display("RESET CARRYOUT pass"); 
    if(CARRYOUTF_expected != CARRYOUTF) 
        $display("ERROR IN RESET CARRYOUTF");
    else 
        $display("RESET CARRYOUTF pass"); 
    //Deassert all reset signals and assert all clock enable signals to validate the functionality of the subsequent DSP paths.
    RSTA = 0; RSTB = 0; RSTC = 0; RSTCARRYIN = 0; RSTD = 0; RSTM = 0; RSTOPMODE = 0; RSTP = 0;
    CEA = 1; CEB = 1; CEC = 1; CECARRYIN = 1; CED = 1; CEM = 1; CEOPMODE = 1; CEP = 1;

    //! 2.2. Verify DSP Path 1
    //corresponding to OPMODE = 8'b11011101.
    OPMODE = 8'b11011101;
    // Apply the following input values: A = 20, B = 10, C = 350, and D = 25.
    A = 20; B = 10; C = 350; D = 25;
    //Drive BCIN, PCIN, and CARRYIN with arbitrary (random) values.
    BCIN = $random; CARRYIN = $random; PCIN = $random;
    //The expected outputs are: BCOUT = 'hf, M = 'h12c, P = PCOUT = 'h32, and CARRYOUT = CARRYOUTF = 0.
    BCOUT_expected = 'hf; PCOUT_expected = 'h32; M_expected = 'h12c; P_expected = 'h32;  CARRYOUT_expected = 0; CARRYOUTF_expected = 0;
    //Wait for four negative clock edges, as the data propagates through four flip-flops (DREG, B1REG, MREG, and PREG)
    repeat(4) @(negedge CLK);
    //Add a condition for self-checking to verify that the design outputs with the expected outputs.
    if(BCOUT_expected != BCOUT)
        $display("ERROR IN Path 1 BCOUNT");
    else 
        $display("Path 1 BCOUNT pass"); 
    if(PCOUT_expected != PCOUT)
        $display("ERROR IN Path 1 PCOUT");
    else  
        $display("Path 1 PCOUT pass"); 
    if(M_expected != M) 
        $display("ERROR IN Path 1 M");
    else 
        $display("Path 1 M pass"); 
    if(P_expected != P)
        $display("ERROR IN Path 1 P");
    else 
        $display("Path 1 P pass"); 
    if(CARRYOUT_expected != CARRYOUT)
        $display("ERROR IN Path 1 CARRYOUT");
    else  
        $display("Path 1 CARRYOUT pass"); 
    if(CARRYOUTF_expected != CARRYOUTF)
        $display("ERROR IN Path 1 CARRYOUTF");
    else 
        $display("Path 1 CARRYOUTF pass"); 

    //! 2.3. Verify DSP Path 2
    // corresponding to OPMODE = 8'b00010000.
    OPMODE = 8'b00010000;
    //Apply the following input values: A = 20, B = 10, C = 350, and D = 25.
    A = 20; B = 10; C = 350; D = 25;
    //Drive BCIN, PCIN, and CARRYIN with arbitrary (random) values.
    BCIN = $random; CARRYIN = $random; PCIN = $random;
    // The expected outputs are: BCOUT = 'h23, M = 'h2bc, P = PCOUT = 0,and CARRYOUT = CARRYOUTF = 0.
    BCOUT_expected = 'h23; PCOUT_expected = 'h0; M_expected = 'h2bc; P_expected = 'h0;  CARRYOUT_expected = 0; CARRYOUTF_expected = 0;
    //Wait for three negative edges
    repeat(3) @(negedge CLK);
    //Add a condition for self-checking to verify that the design outputs with the expected outputs.
    if(BCOUT_expected != BCOUT)
        $display("ERROR IN Path 2 BCOUNT");
    else 
        $display("Path 2 BCOUNT pass"); 
    if(PCOUT_expected != PCOUT) 
        $display("ERROR IN Path 2 PCOUT");
    else  
        $display("Path 2 PCOUT pass"); 
    if(M_expected != M)
        $display("ERROR IN Path 2 M");
    else  
        $display("Path 2 M pass"); 
    if(P_expected != P) 
        $display("ERROR IN Path 2 P");
    else 
        $display("Path 2 P pass"); 
    if(CARRYOUT_expected != CARRYOUT)
        $display("ERROR IN Path 2 CARRYOUT");
    else 
        $display("Path 2 CARRYOUT pass"); 
    if(CARRYOUTF_expected != CARRYOUTF)
        $display("ERROR IN Path 2 CARRYOUTF");
    else  
        $display("Path 2 CARRYOUTF pass"); 

    //! 2.4. Verify DSP Path 3
    //corresponding to OPMODE = 8'b00001010
    past_Value_of_P = P;
    past_value_of_CARRYOUT = CARRYOUT;
    OPMODE = 8'b00001010;
    //Apply the following input values: A = 20, B = 10, C = 350, and D = 25.
    A = 20; B = 10; C = 350; D = 25;
    //Drive BCIN, PCIN, and CARRYIN with arbitrary (random) values.
    BCIN = $random; CARRYIN = $random; PCIN = $random;
    // The expected outputs are: BCOUT = 'ha, M = 'hc8, P = PCOUT which is the past Value of P, and CARRYOUT = CARRYOUTF which is the past value of CARRYOUT.
    BCOUT_expected = 'ha;
    result = 2 * past_Value_of_P;
    PCOUT_expected =  result[47 : 0];
    M_expected = 'hc8;
    P_expected = result[47 : 0];
    CARRYOUT_expected = result[48];
    CARRYOUTF_expected = result[48];
    //Wait for three negative edges
    repeat(3) @(negedge CLK);
    //Add a condition for self-checking to verify that the design outputs with the expected outputs.
    if(BCOUT_expected != BCOUT)
        $display("ERROR IN Path 3 BCOUNT");
    else 
        $display("Path 3 BCOUNT pass"); 
    if(PCOUT_expected != PCOUT)
        $display("ERROR IN Path 3 PCOUT");
    else 
        $display("Path 3 PCOUT pass"); 
    if(M_expected != M)
        $display("ERROR IN Path 3 M");
    else 
        $display("Path 3 M pass"); 
    if(P_expected != P)
        $display("ERROR IN Path 3 P");
    else 
        $display("Path 3 P pass"); 
    if(CARRYOUT_expected != CARRYOUT)
        $display("ERROR IN Path 3 CARRYOUT");
    else 
        $display("Path 3 CARRYOUT pass"); 
    if(CARRYOUTF_expected != CARRYOUTF)
        $display("ERROR IN Path 3 CARRYOUTF");
    else 
        $display("Path 3 CARRYOUTF pass"); 
    //! 2.5. Verify DSP Path 4
    //corresponding to OPMODE = 8'b10100111. 
    OPMODE = 8'b10100111;
    //Apply the following input values: A = 5, B = 6, C = 350, D = 25 and PCIN = 3000
    A = 5; B = 6; C = 350; D = 25; PCIN = 3000;
    // Drive BCIN, and CARRYIN with arbitrary (random) values.
    BCIN = $random; CARRYIN = $random;
    //The expected outputs are: BCOUT = 'h6, M = 'h1e, P = PCOUT = 'hfe6fffec0bb1, and CARRYOUT = CARRYOUTF = 1.
    BCOUT_expected = 'h6; PCOUT_expected = 'hfe6fffec0bb1; M_expected = 'h1e; P_expected = 'hfe6fffec0bb1; CARRYOUT_expected = 1; CARRYOUTF_expected = 1;
    //Wait for three negative edges
    repeat(3) @(negedge CLK);
    //Add a condition for self-checking to verify that the design outputs with the expected outputs.
    if(BCOUT_expected != BCOUT)
        $display("ERROR IN Path 4 BCOUNT");
    else  
        $display("Path 4 BCOUNT pass");
    if(PCOUT_expected != PCOUT)
        $display("ERROR IN Path 4 PCOUT");
    else 
        $display("Path 4 PCOUT pass"); 
    if(M_expected != M)
        $display("ERROR IN Path 4 M");
    else 
        $display("Path 4 M pass"); 
    if(P_expected != P)
        $display("ERROR IN Path 4 P");
    else 
        $display("Path 4 P pass"); 
    if(CARRYOUT_expected != CARRYOUT)
        $display("ERROR IN Path 4 CARRYOUT");
    else 
        $display("Path 4 CARRYOUT pass"); 
    if(CARRYOUTF_expected != CARRYOUTF) 
        $display("ERROR IN Path 4 CARRYOUTF");
    else  
        $display("Path 4 CARRYOUTF pass"); 
    $stop;
end  
endmodule 