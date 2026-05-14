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
            if(clk_enable)begin
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