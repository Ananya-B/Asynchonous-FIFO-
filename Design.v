module afifo(d_out,f_full_flag,f_half_full_flag,f_empty_flag,f_almost_full_flag,f_almost_empty_flag,d_in,r_en,w_en,r_clk,w_clk,reset);

parameter f_width=8;
parameter f_depth=16;
parameter f_ptr_width=4; 
parameter f_half_full_value=8;
parameter f_almost_full_value=14;
parameter f_almost_empty_value=2;

input [f_width-1:0] d_in;
input r_en,w_en,r_clk,w_clk;
input reset;

output wire [f_width-1:0] d_out;
output f_full_flag,f_half_full_flag,f_almost_full_flag,f_empty_flag,f_almost_empty_flag;


reg [f_ptr_width-1:0] r_ptr,w_ptr;
reg r_next_en,w_next_en;
reg [f_ptr_width-1:0] ptr_diff;

//dual port ram
dual_port_ram m1 (d_out,d_in,r_en,w_en,r_clk,w_clk,reset,f_full_flag,f_empty_flag,w_ptr,r_ptr);
//write up counter
cntr m2(w_ptr,reset,w_clk,w_next_en);
//read up counter
cntr m3(r_ptr,reset,r_clk,r_next_en);
//ptr difference
ptr_diff_gen m4 (w_ptr, r_ptr, ptr_diff);
//status generation logic
status_flag_gen m5 (ptr_diff,f_full_flag,f_half_full_flag,f_almost_full_flag,f_empty_flag,f_almost_empty_flag);
//next read control logic
next_state_logic_gen m6 (r_en,f_empty_flag,r_next_en);
//next write control logic
next_state_logic_gen m7(w_en,f_full_flag,w_next_en);

endmodule



module dual_port_ram(d_out,d_in,r_en,w_en,r_clk,w_clk,reset,f_full_flag,f_empty_flag,w_ptr,r_ptr);
parameter f_width=8; 
parameter f_depth=16;
parameter f_ptr_width=4;

input [f_width-1:0] d_in;
input r_en, w_en, r_clk, w_clk, reset, f_full_flag,f_empty_flag;
input [f_ptr_width-1:0] r_ptr,w_ptr;
output reg [f_width-1:0] d_out;

reg [f_width-1:0] f_memory[f_depth-1:0];


always @(posedge w_clk)//write
begin
if((!f_full_flag) && w_en)
begin
f_memory[w_ptr]<=d_in;
end
end


always @(posedge r_clk)
begin
if(reset)
d_out<=0;
else if(r_en)
begin
if(!f_empty_flag)
d_out<=f_memory[r_ptr];
end
else d_out<=0;
end
endmodule

module cntr(count,rst,clk,en);
parameter cntr_width=4; 
input rst,clk,en;
output reg [cntr_width-1:0] count; 
always @(posedge clk or posedge rst)
if (rst)
count <= 0;
else if(en)
count <= count + 1;
else
count<=count;
endmodule

module ptr_diff_gen(w_ptr, r_ptr, ptr_diff);
parameter f_depth=16;
parameter f_ptr_width=4; 
input [f_ptr_width-1:0]w_ptr, r_ptr;
output reg [f_ptr_width-1:0]ptr_diff;
always @ (w_ptr or r_ptr) 
begin 
if(w_ptr > r_ptr)
ptr_diff<=w_ptr-r_ptr;
else if(w_ptr < r_ptr)
ptr_diff<=((f_depth-r_ptr)+w_ptr);
else 
ptr_diff<=0;
end
endmodule

module status_flag_gen(ptr_diff,f_full_flag,f_half_full_flag,f_almost_full_flag,f_empty_flag,f_almost_empty_flag);

parameter f_ptr_width=4; 
parameter f_depth=16;
parameter f_half_full_value=8;
parameter f_almost_full_value=14;
parameter f_almost_empty_value=2;

input [f_ptr_width-1:0] ptr_diff;
output  f_full_flag,f_half_full_flag,f_almost_full_flag,f_empty_flag,f_almost_empty_flag;

assign f_full_flag=(ptr_diff==(f_depth-1));
assign f_empty_flag=(ptr_diff==0);
assign f_half_full_flag=(ptr_diff==f_half_full_value);
assign f_almost_full_flag=(ptr_diff==f_almost_full_value);
assign f_almost_empty_flag=(ptr_diff==f_almost_empty_value);
endmodule

module next_state_logic_gen(en,f_flag,next_en);
input en,f_flag;
output reg next_en;
always @(*)
begin 
if(en && (!f_flag))
next_en=1;
else 
next_en=0;
end
endmodule
