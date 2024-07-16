`include "behavioural.v"
module mips_32_tb();
  reg clock1, clock2;
  integer k;
  mips_32 behaviour(clock1, clock2);
  initial 
  begin
    clock1 = 0; clock2 = 0;
    repeat(20)
    begin
    #5 clock1 = 1; #5 clock1 = 0;
    #5 clock2 = 1; #5 clock2 = 0;
    end
  end
  initial
    begin
        for(k=0;k<31;k++)
        behaviour.REG[k] = k;

        behaviour.mem[0] = 32'h280a00c8;
        behaviour.mem[1] = 32'h28020001;
        behaviour.mem[2] = 32'h0e94a000;
        behaviour.mem[3] = 32'h21430000;
        behaviour.mem[4] = 32'h0e94a000;
        behaviour.mem[5] = 32'h14431000;
        behaviour.mem[6] = 32'h2c630001;
        behaviour.mem[7] = 32'h0e94a000;
        behaviour.mem[8] = 32'h3460fffc;
        behaviour.mem[9] = 32'h2542fffe;        
        behaviour.mem[10] =32'hfc000000;
        
        behaviour.mem[200] = 7;

        behaviour.halted       = 0;
        behaviour.pc           = 0;
        behaviour.taken_branch = 0;
        #5000 
        $display("mem[200]: %2d\nmem[198]: %6d", behaviour.mem[200], behaviour.mem[198]); 
         
  end
  initial 
  begin
    $dumpfile("behavioural_tb.vcd");
    $dumpvars(0,mips_32_tb);
    $monitor("R2: %4d", behaviour.REG[2]);
    #5000 $finish;
  end
endmodule