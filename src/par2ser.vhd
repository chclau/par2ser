----------------------------------------------------------------------------------
-- Company:  FPGA'er
-- Engineer: Claudio Avi Chami - FPGA'er Website
--           http://fpgaer.tech
-- Create Date: 11.09.2022 
-- Module Name: par2ser.vhd
-- Description: Parallel to serial converter
-- Dependencies: none
-- 
-- Revision: 1
-- Revision  1 - File Created
-- 
----------------------------------------------------------------------------------------------------------------------------------------------------


library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity par2ser is
	generic (
		DATA_W		: natural := 8
	);
	port (
		clk       :  in std_logic;
		
		-- inputs
		data_in   :	 in std_logic_vector (DATA_W-1 downto 0);
		load      :  in std_logic;
		
		-- outputs
		data_out  : out std_logic;
		busy      :	out std_logic := '0';
		valid     :	out std_logic := '0';
		frame     :	out std_logic := '0'
	);
end par2ser;


architecture rtl of par2ser is
  function log2ceil (a : natural) return integer is
    variable calc : integer := 0;
    variable inp  : integer := a;
  begin
    while (inp > 0) loop
	    inp := inp/2;
	    if (calc < 31) then
        calc   := calc + 1;
      end if;
    end loop;
    return calc;
  end function log2ceil;

	constant CNT_W  : natural := log2ceil(DATA_W);	-- calculate needed width of internal counter
	signal cnt 		  : unsigned (CNT_W-1 downto 0) := (others => '0');
	signal reg 		  : std_logic_vector (DATA_W-1 downto 0) := (others => '0');
	signal frame_s 	: std_logic_vector (1 downto 0);

begin 

  par2ser_pr: process (clk) 
  begin 
    if (rising_edge(clk)) then
      if (load = '1') then				-- load parallel register
        reg		<= data_in;
        cnt 	<= to_unsigned(DATA_W-1, cnt'length);
      else
        if (cnt > 0) then				-- all data bits transferred?
          cnt		<= cnt - 1;			
        end if;	
      end if;	
    end if;
  end process par2ser_pr;

  data_out <= reg(to_integer(cnt));

  -- generate single clock pulse for frame
  frame_pr: process (clk) 
	begin 
    if (rising_edge(clk)) then
      frame_s(1) <= frame_s(0);		
    end if;
  end process;

  frame_s(0) <= '1' when (cnt = 0) else '0';
  frame <= '1' when frame_s = "01" else '0';
  busy  <= '1' when (cnt > 0) or frame='1' else '0';
  valid <= busy;

end rtl;

