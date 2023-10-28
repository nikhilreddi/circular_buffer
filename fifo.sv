module fifo
  import dataTypes::*;
#(
  parameter SIZE = 8
)(
  rtl_if rif
);
  localparam PTR_WIDTH = $clog2(SIZE);

  logic [SIZE-1:0] buffer [0:SIZE-1];
  logic [PTR_WIDTH:0] write_ptr;
  logic [PTR_WIDTH:0] read_ptr;
  logic [PTR_WIDTH:0] next_write_ptr;
  logic [PTR_WIDTH:0] next_read_ptr;


  assign rif.fifo_full = (write_ptr == (read_ptr - 1)) || (write_ptr == (SIZE) && read_ptr == 0);
  assign rif.fifo_empty = (write_ptr == read_ptr);
  
  always_comb
    begin
      if(rif.rd_en && rif.wr_en && rif.fifo_empty) begin
          rif.rd_data  = rif.wr_data;
       

 
        end
      else if(rif.rd_en && !rif.fifo_empty) begin
        rif.rd_data = buffer[read_ptr];
         next_read_ptr = (read_ptr == SIZE) ? 0 : read_ptr + 1;
      end
      else begin
	rif.rd_data = 'x;
	
	end
    end

  always_comb 
     begin    
        
  next_write_ptr = write_ptr;
    if (rif.wr_en && !rif.fifo_full) begin
      next_write_ptr = (write_ptr == SIZE) ? 0 : write_ptr + 1;
  end
    if (rif.clear && !rif.fifo_empty) begin
      next_write_ptr = (write_ptr == 0) ? SIZE-1 : write_ptr - 1;
  end
      
end

  always_ff @(posedge rif.CLK) begin
    
          
    if (rif.RESET) begin
      		write_ptr <= 0;
      		read_ptr <= 0;
            buffer <= '{default:0};
    end
    if (rif.wr_en && !rif.fifo_full) begin
       		 buffer[write_ptr] <= rif.wr_data;
       		 write_ptr <= next_write_ptr;
      end
    if (rif.clear && !rif.fifo_empty) begin
       		 write_ptr <= next_write_ptr;
      end
    if(rif.rd_en && !rif.fifo_empty) begin
       		 read_ptr <= next_read_ptr;
      end
    
    
  end

  always_comb //error logic
    begin
      
      if((rif.fifo_empty && rif.rd_en && !rif.wr_en) || (rif.fifo_empty && rif.clear) || (rif.fifo_full  && rif.wr_en && !rif.rd_en) || (rif.fifo_empty && rif.rd_en && rif.clear) || (rif.clear  && rif.wr_en) || (rif.RESET && (rif.wr_en || rif.rd_en || rif. clear)))begin
        
        rif.error = 1;
        end
      
      else  rif.error = 0;
      
    end
  ////////properties for assertions
   property BypassLogic;
     @(posedge rif.CLK) disable iff(rif.RESET)
	rif.rd_en && rif.wr_en && rif.fifo_empty |-> (rif.rd_data  == rif.wr_data);
	endproperty
  
  property ReadData;
    @(posedge rif.CLK) disable iff(rif.RESET)
    rif.rd_en && !rif.fifo_empty |->  ((rif.rd_data>=0) && (rif.rd_data<256)) ;
	endproperty
  
  property WriteData;
    @(posedge rif.CLK) disable iff(rif.RESET)
    rif.wr_en && !rif.fifo_full |=> ((rif.wr_data>=0) && (rif.wr_data<256)) ;
	endproperty
  
  property ClearData;
    @(posedge rif.CLK) disable iff(rif.RESET)
    rif.clear && !rif.fifo_empty |=> ((rif.wr_data>=0) && (rif.wr_data<256));
	endproperty
  
  property ResetFIFO;
    @(posedge rif.CLK) 
	rif.RESET |=> (rif.fifo_empty == 1 &&  rif.fifo_full == 0);
	endproperty
  
  property FifoFull;
    @(posedge rif.CLK) disable iff(rif.RESET)
    $size(buffer)==7 |-> rif.fifo_full == 1;
	endproperty
  
  property FifoEmpty;
    @(posedge rif.CLK) disable iff(rif.RESET)
    $size(buffer)==0 |-> rif.fifo_empty == 1;
	endproperty
  
  
  property ErrorLogic1;
    @(posedge rif.CLK) disable iff(rif.RESET)
	rif.fifo_empty && rif.rd_en && !rif.wr_en |-> rif.error == 1;
	endproperty

  property ErrorLogic2;
    @(posedge rif.CLK) disable iff(rif.RESET)
	rif.fifo_empty && rif.clear |-> rif.error == 1;
	endproperty

  property ErrorLogic3;
    @(posedge rif.CLK) disable iff(rif.RESET)
	rif.fifo_full  && rif.wr_en && !rif.rd_en |-> rif.error == 1;
	endproperty

  property ErrorLogic4;
    @(posedge rif.CLK) disable iff(rif.RESET)
	rif.fifo_empty && rif.rd_en && rif.clear |-> rif.error == 1;
	endproperty

  property ErrorLogic5;
    @(posedge rif.CLK) disable iff(rif.RESET)
	rif.clear  && rif.wr_en |-> rif.error == 1;
	endproperty

  property ErrorLogic6;
    @(posedge rif.CLK) disable iff(rif.RESET)
	rif.RESET && (rif.wr_en || rif.rd_en || rif. clear) |-> rif.error == 1;
	endproperty

  
  a1:assert property(BypassLogic)
else $error("Bypass Logic Failed");
    
    a2:assert property(ReadData)
else $error("Read Data is invalid or not within the range");
      
      a3:assert property(WriteData)
else $error("Write Data is invalid or not within the range");

      
          
          
  a4:assert property(ResetFIFO)
else $error("Reset of the fifo is Failed");

    a5:assert property(FifoFull)
else $error("Fifo full is not happening");
      
      a6:assert property(FifoEmpty)
else $error("Fifo empty is not happening");
        
       

  
 a7:assert property(ErrorLogic1)
else $error("Fifo Empty and rd_en is asserted but no error is seen");


a8:assert property(ErrorLogic2)
else $error("Fifo Empty and clear is asserted but no error is seen");
  
  
a9:assert property(ErrorLogic3)
else $error("Fifo full and wr_en is asserted but no error is seen"); 


a10:assert property(ErrorLogic4)
else $error("Fifo Empty,rd_en and clear is asserted but no error is seen");


a11:assert property(ErrorLogic5)
else $error("Wr_en and clear is asserted but no error is seen");

 
a12:assert property(ErrorLogic6)
else $error("No error is seen when Reset and either of wr_en,rd_en and clear is asserted"); 
  
  
  

endmodule : fifo



module coverage
  
import dataTypes::*;
(
  rtl_if.cov covg
);

  
  
  covergroup cg @(posedge covg.CLK);
  	Reset : coverpoint covg.RESET;	
  	read: 	coverpoint covg.rd_en;
  	write:	coverpoint covg.wr_en;
  	clear:	coverpoint covg.clear;
    fifo_empty:	coverpoint covg.fifo_empty;
    fifo_full:	coverpoint covg.fifo_full;
    error: coverpoint covg.error;
    
    fifo_empty_rd_en:	cross fifo_empty,read; 
    
    fifo_full_wr_en:	cross fifo_full,write;
    
    clear_fifo_empty:	cross clear,fifo_empty;

    rd_en_wr_en:    cross read,write;
    
    clear_wr_en:	cross clear,write;
    
    reset_fifo_empty:	cross Reset,fifo_empty;
    
    reset_fifo_full:	cross Reset,fifo_full;

    
    read_data : coverpoint covg.rd_data{
      bins r1[1] = {[0:255]};
    }
    
    write_data : coverpoint covg.wr_data{
      bins w1[1] = {[0:255]};
    }

  	
    reset_clear:	cross Reset,clear;
    
    rd_wr_fifo_empty:	cross read,write,fifo_empty;
    
    rd_wr_fifo_full:	cross read,write,fifo_full;
        
   
  endgroup: cg
  
  cg cg_inst;
  
  initial begin
    cg_inst = new();
  end
  
endmodule