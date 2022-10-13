----------------------------------------------------------------------------------
-- Company:  FPGA'er
-- Engineer: Claudio Avi Chami - FPGA'er Website
--           http://fpgaer.tech
-- Create Date: 01.10.2022 
-- Module Name: par2ser.vhd
-- Description: Parallel to serial converter
-- Dependencies: none
-- 
-- Revision: 2
-- Revision  1 - File Created
--           2 - Simplified using unconstrained ports and Vivado built-in functions
--               Based heavily on code written by user "asp_digital" on Reddit
----------------------------------------------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity par2ser is
  port (
    clk      : in  std_logic;

    -- inputs
    data_in  : in  std_logic_vector;
    load     : in  std_logic;

    -- outputs
    data_out : out std_logic;
    busy     : out std_logic := '0';
    frame    : out std_logic := '0'
  );
end par2ser;
architecture rtl of par2ser is
  signal cnt : natural range 0 to data_in'left;
  signal reg : std_logic_vector (data_in'left downto 0) := (others => '0');

begin

  par2ser_pr : process (clk)
  begin
    if (rising_edge(clk)) then
      -- the bit counter, for framing, always counts down to zero and then stops.
      -- The counter is preset when the parallel register is loaded.
      BitCounter : if cnt > 0 then
        cnt <= cnt - 1;
      end if BitCounter;

      -- busy flag should be cleared when not shifting.
      -- It gets set immediately on load, overriding this.
      EndBusy : if cnt = 0 then
        busy <= '0';
      end if EndBusy;

      ParallelReg : if (load = '1') then
        reg <= data_in; -- load parallel register
        cnt <= data_in'left; -- size of the parallel register
        busy <= '1'; -- ensure immediate busy flag
      end if ParallelReg;

      -- frame strobe goes true when the count reaches zero, and is cleared right away.
      -- Let's take advantage of pipelining.
      AssertFrameStrobe : if cnt = 1 then
        frame <= '1';
      else
        frame <= '0';
      end if AssertFrameStrobe;

    end if;
  end process par2ser_pr;

  data_out <= reg(cnt);

end rtl;

