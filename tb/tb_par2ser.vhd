----------------------------------------------------------------------------------
-- Company:  FPGA'er
-- Engineer: Claudio Avi Chami - FPGA'er Website
--           http://fpgaer.tech
-- Create Date: 01.10.2022 
-- Module Name: tb_par2ser.vhd
-- Description: Testbench for parallel to serial converter
-- Dependencies: par2ser.vhd
-- 
-- Revision: 2
-- Revision  1 - File Created
--           2 - Changes for revision 2 of par2ser
----------------------------------------------------------------------------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
	use ieee.numeric_std.ALL;
    
entity tb_par2ser is
end entity;

architecture test of tb_par2ser is

    constant PERIOD  : time   := 20 ns;
    constant DATA_W  : natural := 4;
    constant DATA_W2 : natural := 4;
	
    signal clk       : std_logic := '0';
    signal load      : std_logic := '0';
    signal load2     : std_logic := '0';
    signal busy      : std_logic ;
    signal busy2     : std_logic ;
    signal data_in   : std_logic_vector(3 downto 0);
    signal data_in2  : std_logic_vector(8 downto 0);
    signal endSim	 : boolean   := false;

  component par2ser  is
	port (
		clk: 		in std_logic;
		
		-- inputs
		data_in:	in std_logic_vector;
		load: 		in std_logic;
		
		-- outputs
		data_out: 	out std_logic;
		busy:		out std_logic;
		frame:		out std_logic
	);
    end component;
    

begin
    clk     <= not clk after PERIOD/2;

	-- Main simulation process for data
	data_pr: process 
	begin
	
		wait until (rising_edge(clk));

		data_in <= x"a";
		load	<= '1';
		wait until (rising_edge(clk));
		load	<= '0';
		wait until (rising_edge(clk));
		wait until (busy = '0');
		wait until (rising_edge(clk));

		data_in <= x"9";
		load	<= '1';
		wait until (rising_edge(clk));
		load	<= '0';
		wait until (rising_edge(clk));
		wait until (busy = '0');
		wait until (rising_edge(clk));
		wait until (rising_edge(clk));

		data_in <= x"c";
		load	<= '1';
		wait until (rising_edge(clk));
		load	<= '0';
		wait until (rising_edge(clk));
		wait until (busy = '0');
		for i in 0 to DATA_W loop
		  wait until (rising_edge(clk));
		end loop;
        wait;
        
	end	process data_pr;	

	data_pr2: process 
	begin
	
		wait until (rising_edge(clk));

		data_in2 <= "011001010";
		load2	<= '1';
		wait until (rising_edge(clk));
		load2	<= '0';
		wait until (rising_edge(clk));
		wait until (busy2 = '0');
		wait until (rising_edge(clk));

		data_in2 <= "101011011";
		load2	<= '1';
		wait until (rising_edge(clk));
		load2	<= '0';
		wait until (rising_edge(clk));
		wait until (busy2 = '0');
		wait until (rising_edge(clk));
		wait until (rising_edge(clk));

        endSim <= true;        
	end	process data_pr2;	
		
	-- End the simulation
	process 
	begin
		if (endSim) then
			assert false 
				report "End of simulation." 
				severity failure; 
		end if;
		wait until (rising_edge(clk));
	end process;	

  par2ser_inst : par2ser
  port map (
    clk      => clk,
    
    data_in  => data_in,
    load     => load,
    
    data_out => open,
    busy     => busy,
		frame	   => open
  );
  
  par2ser_inst2 : par2ser
  port map (
    clk      => clk,
    
    data_in  => data_in2,
    load     => load2,
    
    data_out => open,
    busy     => busy2,
		frame	   => open
  );

end architecture;