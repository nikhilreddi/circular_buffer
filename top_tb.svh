class random_stimulus_packet;
  rand bit [7:0] indata;
endclass


class tester;
  
  virtual rtl_if vif;
  random_stimulus_packet random_packet;
  
  
  function new(virtual rtl_if rif);
    vif = rif;
  endfunction : new
  
  
  
 
  

  task reset_fifo();
	vif.reset();
  endtask


  task write_fifo();
      random_packet = new();
      assert(random_packet.randomize());
	vif.write_fifo(random_packet.indata);
	@(negedge vif.CLK);
endtask

task clear_fifo();
	vif.clear_fifo();
endtask

 /////////////Task 1////////////////////////////// 
 task write_until_full();
   
    while(!vif.fifo_full)begin
   
      write_fifo();
      @(negedge vif.CLK);
     end

endtask


//////////////Task 2////////////////////////////////
task read_until_empty();

       while(!vif.fifo_empty) begin

		vif.read_fifo();
		@(negedge vif.CLK);
	end
endtask


/////////////Task 3/////////////////////////////////
task read_after_empty();
     
        read_until_empty();
        vif.read_fifo();
	@(negedge vif.CLK);
endtask


////////////Task 4///////////////////////////////////
task clear_after_empty();

	read_until_empty();
	vif.clear_fifo();
	@(negedge vif.CLK);
endtask

////////////Task 5 ///////////////////////////////

task corner_data_write_cases();

	vif.write_fifo('hFF);
	@(negedge vif.CLK);
	vif.write_fifo('h00);
	@(negedge vif.CLK);
	vif.write_fifo('hAA);
	@(negedge vif.CLK);
	vif.write_fifo('h55);
	@(negedge vif.CLK);
endtask


/////////////Task 6///////////////////////////////////
task reset_and_clear();
         
	vif.clear_and_reset();
	@(negedge vif.CLK);
endtask

/////////////Task 7//////////////////////////////////	
task readEn_and_writeEn();
         
	vif.readEn_and_writeEn();
	@(negedge vif.CLK);
endtask	


////////////Task 8///////////////////////////////////
task fe_re_we();

	read_until_empty();
	vif.readEn_and_writeEn();
	@(negedge vif.CLK);
endtask


/////////////Task 9/////////////////////////////////
task ff_re_we();

	write_until_full();
	vif.readEn_and_writeEn();
	@(negedge vif.CLK);
endtask

/////////////Task 10////////////////////////////////
task ff_reset();

	write_until_full();
	reset_fifo();
endtask

////////////Task 11//////////////////////////////////
task fe_reset();

	read_until_empty();
	reset_fifo();
endtask

///////////////Task 12///////////////////////////////
task clear_we;

	vif.clear_we();
	@(negedge vif.CLK);
endtask


///////////////Task 13///////////////////////////////
task clear_re;

	vif.clear_re();
	@(negedge vif.CLK);
endtask


///////////////Task 14///////////////////////////////
task write_on_fifo_full();

	write_until_full();
	write_fifo();
	@(negedge vif.CLK);
endtask


//////////////Task 15///////////////////////////////
task read_on_fifo_empty();

	read_until_empty();
	vif.read_fifo();
	@(negedge vif.CLK);
endtask

////////////Task 16/////////////////////////////

task fifo_empty_clear_read_enable();

	read_until_empty();
	vif.clear_re();
	@(negedge vif.CLK);
endtask
	
task execute();


	repeat(1000) begin
randsequence (taskSequence)
    taskSequence : one | two | three | four | five | six | seven | eight | nine | ten | eleven | twelve | thirteen | fourteen | fifteen | sixteen | seventeen;
      one : {reset_fifo();};
      two : {write_until_full();};
      three : {read_until_empty();};
      four : {read_after_empty();};
      five : {clear_after_empty();};
      six : {readEn_and_writeEn();};
      seven : {fe_re_we();};
      eight : {ff_re_we();};
      nine : {ff_reset();};
      ten : {fe_reset();};
      eleven : {clear_we;};
      twelve : {clear_re;};
      thirteen : {write_on_fifo_full();};
      fourteen : {read_on_fifo_empty();};
      fifteen : { corner_data_write_cases();};
      sixteen : {reset_and_clear();};
      seventeen : {fifo_empty_clear_read_enable();};
      
   
    
  endsequence

end
	$finish;
endtask
endclass



class checker_fifo;
  // Declare an array of FIFO queues
  localparam SIZE = 8;
  logic [7:0] fifo[$:SIZE];
  int count =0;
  logic [7:0]rd_data_ex;
  logic queue_full;
  logic queue_empty;
  logic expected_error;

  virtual rtl_if vif1;

  function new(virtual rtl_if rif);
    vif1 = rif;
  endfunction : new



task ref_model();

	forever begin
	
	@(posedge vif1.CLK)
      
      if(vif1.RESET)begin
        fifo.delete();
        queue_full = 0;
        queue_empty= 1;
      end
      
      if($size(fifo) == SIZE-1) begin
		queue_full=1;
		queue_empty =0;
	  end
	  
	  if($size(fifo) == 0) begin
		queue_empty=1;
		queue_full=0;
	
	end
      if((vif1.wr_en) && (!vif1.rd_en) && (!queue_full)) begin
		
		queue_empty=0;
		fifo.push_back( vif1.wr_data);
		
	end
      if ((vif1.rd_en) && (!vif1.wr_en) && (!queue_empty)) begin
		rd_data_ex = fifo.pop_front();
		queue_full=0;
	
	end
	
	if(vif1.clear)begin
	
		fifo.pop_back();
	end
	
	if(vif1.rd_data == rd_data_ex) begin
		
      $display("Output Matched : Actual Output Read = %d, Expected Output Read = %d",vif1.rd_data,rd_data_ex);
	end
	
     if(vif1.rd_data != rd_data_ex)begin
        
        $error("WRONG OUTPUT : Actual Output Read = %d,Expected Output Read = %d",vif1.rd_data,rd_data_ex);
      end
      
     if(vif1.rd_en && vif1.wr_en && queue_empty)begin
        rd_data_ex = vif1.wr_data;
      end
      
     if((queue_empty && vif1.rd_en && !vif1.wr_en) || (queue_empty && vif1.clear) || (queue_full  && vif1.wr_en && !vif1.rd_en) || (queue_empty && vif1.rd_en && vif1.clear) || (vif1.clear  && vif1.wr_en) || (vif1.RESET && (vif1.wr_en || vif1.rd_en || vif1. clear)))
        
        expected_error = 1'b1;
      end
        
	
	
   

	$finish;
endtask

  
  
  
      
                                        
                       
                       
  
  // Task to run the simulation
  task run();

	
  
    
    ref_model();
  




    
  endtask
  
  
  
     
endclass

class testbench;
  tester tester_h;
  checker_fifo c_inst;
  

  function new(virtual rtl_if rif);
    tester_h = new(rif);
     c_inst = new(rif);
  endfunction : new


 task run();

	fork
	tester_h.execute();
	c_inst.run();
	join
endtask
		




     

endclass : testbench




///////////////////////////////////////////////////////////////////////////

module top_tb;

localparam CLOCK_PERIOD = 1000;

  rtl_if rif();
  fifo test_rtl( .rif(rif.dut) );
  testbench testbench_h;
  
  


  initial begin : main_sequence
    $display("\n\t Test Begin\n");
    testbench_h = new(rif);
    testbench_h.run();
    
	
  end : main_sequence
  
    




  final begin
    $display("\n\t Test End\n");
  end 

endmodule