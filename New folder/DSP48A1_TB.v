module DSP48A1_TB();
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
//INPUT STIMULS
reg [17:0] A,B,D,BCIN;
reg [47:0] C;
reg CARRYIN,CLK,CEA,CEC,CED,CEM,
CEOPMODE,CEP,CEB,RSTOPMODE,RSTA,RSTM,RSTP,RSTB,RSTC,RSTD,RSTCARRYIN,CECARRYIN;
reg [47:0] PCIN;
reg [7:0] OPMODE;
//********************************
//OUTPUT STIMLUS
wire CARRYOUT_dut,CARRYOUTF_dut;
wire [47:0] PCOUT_dut,P_dut;
wire [35:0] M_dut;
wire [17:0] BCOUT_dut;
//********************************
/////
reg CARRYOUT_expected,CARRYOUTF_expected;
reg [47:0] PCOUT_expected,P_expected;
reg [35:0] M_expected;
reg [17:0] BCOUT_expected;
reg [47:0] P_old;
reg CARROUT_old;
//int
DSP48A1 m1(A,B,C,D,M_dut,P_dut,CARRYIN,CLK,OPMODE,CEA,CEC,CED,CEM,
CEOPMODE,CEP,CEB,RSTOPMODE,RSTA,RSTM,RSTP,RSTB,RSTC,RSTD,RSTCARRYIN,
PCIN,PCOUT_dut,BCOUT_dut,CARRYOUT_dut,CARRYOUTF_dut,CECARRYIN,BCIN );

initial begin 
    CLK = 0;
    forever begin 
        #1 CLK = ~CLK;
    end 
end 

initial begin 
    RSTOPMODE=1;
    RSTA=1;
    RSTM=1;
    RSTP=1;
    RSTB=1;
    RSTC=1;
    RSTD=1;
    RSTCARRYIN=1;
    A = $random;
    B = $random;
    D = $random;
    BCIN = $random;
    C = $random;
    CARRYIN = $random;
    CEA = $random;
    CEC = $random;
    CED = $random;
    CEM = $random;
    CEOPMODE = $random;
    CEP = $random;
    CEB = $random;
    RSTOPMODE = 1;
    RSTA = 1;
    RSTM = 1;
    RSTP = 1;
    RSTB = 1;
    RSTC = 1;
    RSTD = 1;
    RSTCARRYIN = 1;
    CECARRYIN = $random;
    PCIN = $random;
    OPMODE = $random;
    @(negedge CLK);
    BCOUT_expected = 0; PCOUT_expected = 0; M_expected = 0; P_expected = 0; 
    CARRYOUT_expected = 0; CARRYOUTF_expected = 0; 
    if (P_dut == P_expected )
            $display("Reset Test Passed for P");
    else begin
        $display("Rest test failed for P");
    end        
    if (M_dut == M_expected )
        $display("Reset Test Passed for M");
    else begin
        $display("Rest test failed for M");
    end  
    if (BCOUT_dut == BCOUT_expected )
    $display("Reset Test Passed for BCOUT");
    else begin
        $display("Rest test failed for BCOUT");
    end  
    if (PCOUT_dut == PCOUT_expected )
    $display("Reset Test Passed for PCOUT");
    else begin
        $display("Rest test failed for PCOUT");
    end      
    if (CARRYOUT_dut == CARRYOUT_expected )
        $display("Reset Test Passed for CARRYOUT");
    else
        $display("Rest test failed for CARRYOUT");
    if (CARRYOUTF_dut == CARRYOUTF_expected)
    $display("Reset Test Passed for CARRYOUTF");
    else
        $display("Rest test failed for CARRYOUTF");
//********************************************
    RSTA = 0; RSTB = 0; RSTC = 0; RSTCARRYIN = 0; RSTD = 0; RSTM = 0; 
    RSTOPMODE = 0; RSTP = 0; CEA = 1; CEB = 1; CEC = 1; CECARRYIN = 1; 
    CED = 1; CEM = 1; CEOPMODE = 1; CEP = 1;        
    //TEST 2.2
    OPMODE = 8'b11011101;   
    A = 18'd20;
    B = 18'd10;
    C = 48'd350;
    D = 18'd25;
    BCIN=$random;
    PCIN=$random;
    CARRYIN=$random;
    BCOUT_expected = 18'hf;
    M_expected = 36'h12c;   
    P_expected = 48'h32;
    PCOUT_expected = 48'h32 ;
    CARRYOUT_expected =0;
    CARRYOUTF_expected = 0;
    repeat(4) @(negedge CLK); 
    if (P_dut === P_expected )
        $display("Path 1 test Passed for P");
    else begin
        $display("Path 1 test failed for P");
    end        
    if (M_dut === M_expected )
        $display("Path 1 test Passed for M");
    else begin
        $display("Path 1 test failed for M");
    end  
    if (BCOUT_dut === BCOUT_expected )
    $display("Path 1 test Passed for BCOUT");
    else begin
        $display("Path 1 test failed for BCOUT");
    end  
    if (PCOUT_dut === PCOUT_expected )
    $display("Path 1 test Passed for PCOUT");
    else begin
        $display("Path 1 test failed for PCOUT");
    end      
    if (CARRYOUT_dut === CARRYOUT_expected )
        $display("Path 1 test Passed for CARRYOUT");
    else
        $display("Path 1 test failed for CARRYOUT");
    if (CARRYOUTF_dut === CARRYOUTF_expected)
    $display("Path 1 test Passed for CARRYOUTF");
    else
        $display("Path 1 test failed for CARRYOUTF");   

    //Test 2.3
    OPMODE = 8'b00010000 ;   
    A = 18'd20;
    B = 18'd10;
    C = 48'd350;
    D = 18'd25;
    BCIN=$random;
    PCIN=$random;
    CARRYIN=$random;
    BCOUT_expected = 18'h23;
    M_expected = 36'h2bc;   
    P_expected = 48'h0;
    PCOUT_expected = 48'h0 ;
    CARRYOUT_expected =0;
    CARRYOUTF_expected = 0;
    repeat(3) @(negedge CLK); 
    if (P_dut === P_expected )
        $display("Path 2 test Passed for P");
    else begin
        $display("Path 2 test failed for P");
    end        
    if (M_dut === M_expected )
        $display("Path 2 test Passed for M");
    else begin
        $display("Path 2 test failed for M");
    end  
    if (BCOUT_dut === BCOUT_expected )
    $display("Path 2 test Passed for BCOUT");
    else begin
        $display("Path 12test failed for BCOUT");
    end  
    if (PCOUT_dut === PCOUT_expected )
    $display("Path 2 test Passed for PCOUT");
    else begin
        $display("Path 2 test failed for PCOUT");
    end      
    if (CARRYOUT_dut === CARRYOUT_expected )
        $display("Path 2 test Passed for CARRYOUT");
    else
        $display("Path 2 test failed for CARRYOUT");
    if (CARRYOUTF_dut === CARRYOUTF_expected)
    $display("Path 2 test Passed for CARRYOUTF");
    else
        $display("Path 2 test failed for CARRYOUTF");
    //Test 2.4    
    OPMODE = 8'b00001010;
    P_old=P_expected;
    CARROUT_old=CARRYOUT_expected;
    A = 18'd20;
    B = 18'd10;
    C = 48'd350;
    D = 18'd25;
    BCIN=$random;
    PCIN=$random;
    CARRYIN=$random;
    BCOUT_expected = 18'ha;
    M_expected = 36'h2c8;   
    P_expected = P_old;
    PCOUT_expected = P_old ;
    CARRYOUT_expected =CARROUT_old;
    CARRYOUTF_expected = CARROUT_old;
    repeat(3) @(negedge CLK); 
    if (P_dut === P_expected )
        $display("Path 3 test Passed for P");
    else begin
        $display("Path 3 test failed for P");
    end        
    if (M_dut === M_expected )
        $display("Path 3 test Passed for M");
    else begin
        $display("Path 3 test failed for M");
    end  
    if (BCOUT_dut === BCOUT_expected )
    $display("Path 3 test Passed for BCOUT");
    else begin
        $display("Path 12test failed for BCOUT");
    end  
    if (PCOUT_dut === PCOUT_expected )
    $display("Path 3 test Passed for PCOUT");
    else begin
        $display("Path 3 test failed for PCOUT");
    end      
    if (CARRYOUT_dut === CARRYOUT_expected )
        $display("Path 3 test Passed for CARRYOUT");
    else
        $display("Path 3 test failed for CARRYOUT");
    if (CARRYOUTF_dut === CARRYOUTF_expected)
            $display("Path 3 test Passed for CARRYOUTF");
    else
        $display("Path 23test failed for CARRYOUTF");
    // Test 2.5
    OPMODE = 8'b10100111;
    A = 5; B = 6; C = 350; D = 25; PCIN = 3000;
    BCIN=$random;
    CARRYIN=$random;
    BCOUT_expected = 'h6; PCOUT_expected = 'hfe6fffec0bb1; M_expected = 'h1e; 
    P_expected = 'hfe6fffec0bb1; CARRYOUT_expected = 1; CARRYOUTF_expected = 1;
    BCOUT_expected = 18'd6;
    M_expected = 36'h1e;   
    P_expected = 48'hfe6fffec0bb1;
    PCOUT_expected = 48'hfe6fffec0bb1 ;
    CARRYOUT_expected =1;
    CARRYOUTF_expected = 1;
    repeat(3) @(negedge CLK); 
    if (P_dut === P_expected )
        $display("Path 4 test Passed for P");
    else begin
        $display("Path 4 test failed for P");
    end        
    if (M_dut === M_expected )
        $display("Path 4 test Passed for M");
    else begin
        $display("Path 4 test failed for M");
    end  
    if (BCOUT_dut === BCOUT_expected )
    $display("Path 4 test Passed for BCOUT");
    else begin
        $display("Path 4 test failed for BCOUT");
    end  
    if (PCOUT_dut === PCOUT_expected )
    $display("Path 4 test Passed for PCOUT");
    else begin
        $display("Path 4 test failed for PCOUT");
    end      
    if (CARRYOUT_dut === CARRYOUT_expected )
        $display("Path 4 test Passed for CARRYOUT");
    else
        $display("Path 4 test failed for CARRYOUT");
    if (CARRYOUTF_dut === CARRYOUTF_expected)
    $display("Path 4 test Passed for CARRYOUTF");
    else
        $display("Path 4 test failed for CARRYOUTF");
    $stop;    */
   
end

endmodule