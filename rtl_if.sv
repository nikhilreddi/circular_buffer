parameter SIZE = 8;

interface rtl_if
  import dataTypes::*;
(
  
);

  logic clear;
  logic rd_en;
  logic wr_en;
  data_packet_sp wr_data;
  data_packet_sp rd_data;
  logic fifo_empty;
  logic fifo_full;
  logic CLK;
  logic RESET;
  logic error;
  //data_packet_sp wr_data_ex;

  
  localparam CLOCK_PERIOD = 1000;
  localparam RESET_CYCLES = 5;
  
 

  modport dut (
    input CLK, RESET, clear, rd_en, wr_en, wr_data,
    output rd_data,error, fifo_empty, fifo_full
  );

  modport cov (
    input CLK, RESET, clear, rd_en, wr_en, wr_data, rd_data, fifo_empty, fifo_full,error
  );
  
  
  initial begin : CLK_driver
    CLK = 0;
    forever #(CLOCK_PERIOD/2) CLK = ~CLK;
  end : CLK_driver
    
  

  
  task reset();
    RESET = 0;
    repeat(RESET_CYCLES) @(negedge CLK);
    RESET = 1;
    clear = 0;
    rd_en = 0;
    wr_en = 0;
    wr_data = '0;
    repeat(RESET_CYCLES) @(negedge CLK);
    RESET = 0;
  endtask : reset

  


task write_fifo(input logic [7:0] data11);
    RESET = 1'b0;
    wr_en = 1;
    rd_en = 0;
    clear = 0;
    wr_data = data11;
    
     
  endtask : write_fifo
  
  
  
  task read_fifo();
    RESET = 1'b0;
    wr_en = 1'b0;
    clear = 1'b0;
    rd_en = 1'b1;
    
  endtask: read_fifo
  
  
  
  task clear_fifo();
        RESET = 1'b0;
        rd_en = 1'b0;
        wr_en = 1'b0;
        clear = 1'b1;
       
  endtask : clear_fifo


  
  task clear_and_reset;
    	RESET = 1'b1;
        rd_en = 1'b0;
        wr_en = 1'b0;
        clear = 1'b1;
  endtask


 task readEn_and_writeEn;
    	RESET = 1'b0;
        rd_en = 1'b1;
        wr_en = 1'b1;
        clear = 1'b0;
  endtask


 task clear_we;
	RESET = 1'b0;
        rd_en = 1'b0;
        wr_en = 1'b1;
        clear = 1'b1;
 endtask

 task clear_re;
	RESET = 1'b0;
        rd_en = 1'b1;
        wr_en = 1'b0;
        clear = 1'b1;
 endtask



    
endinterface : rtl_if