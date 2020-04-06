`timescale 1ns/1ns
module afifo_tb();
parameter f_width=8;
parameter f_depth=16;
reg [f_width-1:0] d_in;
reg r_en,w_en,r_clk,w_clk,reset;
wire [f_width-1:0] d_out;
wire f_full_flag,f_half_full_flag,f_almost_full_flag,f_empty_flag,f_almost_empty_flag;
reg [f_width-1:0]temp_address;

afifo n1(d_out,f_full_flag,f_half_full_flag,f_empty_flag,f_almost_full_flag,f_almost_empty_flag,d_in,r_en,w_en,r_clk,w_clk,reset);

initial
begin
#10 r_clk=0;
forever #10 r_clk=~r_clk;
end
always
#5 temp_address=n1.m1.temp_address;
initial
begin
#5 w_clk=0;
forever #50 w_clk=~w_clk;
end
initial
begin
reset=1; w_en=1; r_en=0;
#10 reset=0;
#200 r_en=1; w_en=0;
#550 w_en=1;
//#800 w_en=1; r_en=0;
end
initial
begin
d_in=1;
@(posedge w_en);
repeat(200) @(posedge w_clk) d_in=d_in+2;
repeat(20) @(posedge w_clk) d_in=d_in-1;
end
initial
begin
$timeformat (-9,3,"ns.",3);
$monitor ("Time = %0t", $time, "The value of d_in=%0b \t d_out=%0b \t, temp_address=%b " , d_in,d_out,temp_address);
#2000 $stop;
end
endmodule
