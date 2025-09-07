module apb_slave (pclk, pwrite, pwdata, preset, paddr, psel, penable, prdata, pready, pslvrr);

 parameter addr = 6;
 parameter width = 32;
 parameter depth = 2**addr;

 input pclk, pwrite, preset, psel, penable;
 input [(width-1) : 0] pwdata;
 input [(addr-1) : 0] paddr;
                                          // input [(width/8) : 0)] pstrb;
 output reg [(width-1) : 0] prdata;
 output reg pready;
 output reg pslvrr;

 reg [(width-1) : 0] ram [0 : (depth-1)];
 reg [1:0] pr_state, nx_state;
 integer i;

 parameter idle = 2'b00;
 parameter setup = 2'b01;
 parameter access = 2'b10;

 always @(posedge pclk or negedge preset) begin

	 if ( !preset ) begin                         //preset
		 pready <= 1'b0;
		 prdata <= 32'b0;
		 pr_state <= idle;
		 pslvrr <= 1'b0;

		 for ( i=0; i<depth; i=i+1) begin 
			 ram[i] <= {width{1'b0}} ;           //initializing memory 
		 end 
	 end 
	 else begin

		 case (pr_state)  
			 idle : begin 
			 	  if ( psel ) begin 
					      nx_state <= setup;
				      end                        	      //state change at idle 
				    else nx_state <= idle;
			        end 

		      setup : begin 
                              if ( penable && psel ) begin          //state change at setup
					    nx_state <= access;
				    end
				    else nx_state <= setup;
			      end 

		    access : begin
			    if (  psel && penable && pready ) begin                   //transfer with slave ready 
					nx_state <= setup;
				end
			    else if ( psel && penable && !pready ) begin             //transfer but slave not ready
					nx_state <= access;
				end
		            else if ( psel && !penable )
                                        nx_state <= setup;
                            else if ( !psel )
                                       nx_state <= idle;
 
		            end
		   default : nx_state = idle;
	   endcase
	   
   end 
end 
 
 always @(nx_state) begin 
	 
	 pr_state <= nx_state;               //updating state
	 
	 case (nx_state)

		 idle : begin 
		 	       prdata <= 32'b0;
				   pslvrr <= 1'b0;
		        end 

		setup : begin
			       prdata <= 32'b0;
				   pslvrr <= 1'b0;
			    end 

		access : begin
			
			 if ( pwrite && pready) begin
				 
				 if ( paddr >= (depth-1) ) begin           //if pslvrr no write operation
					pslvrr <= 1'b1;
				  end
				  
				  else begin
					ram[paddr] <= pwdata;           //write data 
					pslvrr <= 1'b0;
				   end 
			
				/*for ( i=0; i<=width/8; i=i+1 )begin 
					ram[addr][8i+7 : 8i] = pstrb[i] && pwdata[8i+7 : 8i];  */
			end
			
			else if ( pready && !pwrite ) begin
				if ( paddr >= (depth-1) ) begin
					pslvrr <= 1'b1;
				end 
				else begin
					prdata <= ram[paddr];              //read data
					pslvrr <= 1'b0;
				end 
			end
			end
		default : begin
			prdata <= 32'b0;
			pslvrr <= 1'b0;
		end

	endcase
end 



 always @(*) begin

	if ( penable ) begin
		pready <= 1'b1;       //making pready depend on penable    //no wait  
	end 
	else pready <= 1'b0;
end 

endmodule
