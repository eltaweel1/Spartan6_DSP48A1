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
