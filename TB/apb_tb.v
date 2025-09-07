module apb_tb ();

 reg tb_clk, tb_write, tb_reset, tb_sel, enable;
 reg [31:0] tb_wdata;
  reg [5:0] tb_addr;
 //reg [4:0] strobe; 
 wire [31:0] tb_rdata;
 wire ready;
 wire slvrr;
 
 reg[31:0]data;
 reg[4:0]addr;

 apb_slave dut (.pclk(tb_clk), .pwrite(tb_write), .pwdata(tb_wdata), .preset(tb_reset), .paddr(tb_addr), 
	 .psel(tb_sel), .penable(enable), .prdata(tb_rdata), .pready(ready), .pslvrr(slvrr));

 initial begin
	 tb_reset = 1'b0;
	 tb_sel = 1'b0;
	 enable = 1'b0;
	 tb_clk = 1'b0;
	 forever begin 
	     #5 tb_clk = !tb_clk;
     end 
     end 

     task delay ( input integer n ); begin 
	     repeat ( n ) @(negedge tb_clk); end 
     endtask 

     task write ( input [31:0]data, input [5:0]addr ); begin 
	     tb_wdata = data; tb_addr = addr; tb_write = 1'b1; end
     endtask 

     task read ( input [5:0]addr ); begin 
	    tb_write = 1'b0; tb_addr = addr; end
    endtask 

     initial begin

	   delay(1);
	   tb_reset = 1'b1;
	   tb_sel = 1'b1;
	   write ( {$random} , 6'b000000 ); 

	   delay(1);
	   enable = 1'b1;  //write
       
       wait(ready === 1'b1 );
       delay (1); 
	   enable = 1'b0;
	   tb_sel = 1'b0;
	   
       delay(1);
	   tb_sel=1'b1;
	   read ( 6'b000000 );
	   
       delay(1);
	   enable=1'b1; //read 

       wait(ready === 1'b1 );
       delay(1);  //transfer and slave ready // psel = 1 after access/transfer
	   enable = 1'b0;
	   tb_sel = 1'b1;	  
	   write ( {$random} , 6'b111111 );

	   delay(1);
	   enable = 1'b1; //verifying pslvrr

       delay (1);
	   tb_sel = 1'b0;
	   enable = 1'b0;
       
       delay(1);
	   tb_sel=1'b1;
       read ( 6'b111111 );
       
       delay(1);
	   enable=1'b1; //read 
       
       delay(4);
	   $finish;

   end 
  
   initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
   end
endmodule
