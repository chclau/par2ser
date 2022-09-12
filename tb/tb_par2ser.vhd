----------------------------------------------------------------------------------
-- Company:  FPGA'er
-- Engineer: Claudio Avi Chami - FPGA'er Website
--           http://fpgaer.tech
-- Create Date: 11.09.2022 
-- Module Name: tb_par2ser.vhd
-- Description: Testbench for parallel to serial converter
-- Dependencies: par2ser.vhd
-- 
-- Revision: 1
-- Revision  1 - File Created
-- 
----------------------------------------------------------------------------------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
	use ieee.numeric_std.ALL;
    
entity tb_par2ser is
end entity;

architecture test of tb_par2ser is

    constant PERIOD  : time   := 20 ns;
    constant DATA_W  : natural := 4;
	
    signal clk       : std_logic := '0';
    signal load      : std_logic := '0';
    signal busy      : std_logic ;
    signal data_in   : std_logic_vector (3 downto 0);
    signal endSim	 : boolean   := false;

  component par2ser  is
	generic (
		DATA_W		: natural := 8
	);
	port (
		clk: 		in std_logic;
		
		-- inputs
		data_in:	in std_logic_vector (DATA_W-1 downto 0);
		load: 		in std_logic;
		
		-- outputs
		data_out: 	out std_logic;
		busy:		out std_logic;
		valid:		out std_logic;
		frame:		out std_logic
	);
    end component;
    

begin
    clk     <= not clk after PERIOD/2;

	-- Main simulation process
	process 
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
		endSim  <= true;

	end	process;	
		
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
  generic map (
		DATA_W	 => DATA_W
	)
  port map (
    clk      => clk,
    
    data_in  => data_in,
    load     => load,
    
    data_out => open,
    busy     => busy,
    valid    => open,
		frame	   => open
  );

end architecture;