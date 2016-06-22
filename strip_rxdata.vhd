----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:17:02 05/21/2015 
-- Design Name: 
-- Module Name:    strip_rx - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity strip_rxdata is
    Port ( clk : in  STD_LOGIC;
           s : in  STD_LOGIC;
           ce : in  STD_LOGIC;
           data_p : in  STD_LOGIC;
           data_n : in  STD_LOGIC;
           data_out : out  STD_LOGIC);
end strip_rxdata;

architecture Behavioral of strip_rxdata is
signal dataDDR : std_logic := '0';
signal data : std_logic_vector(1 downto 0) := (others =>'0');
signal data_q : std_logic_vector(1 downto 0) := (others =>'0');

begin
i_data_buf: IBUFDS generic map(DIFF_TERM => TRUE,IOSTANDARD => "LVDS_25") port map(i => data_p, ib => data_n, o => dataDDR);
i_data_DDR : IDDR 
   generic map (
      DDR_CLK_EDGE => "SAME_EDGE_PIPELINED") -- "OPPOSITE_EDGE", "SAME_EDGE" or "SAME_EDGE_PIPELINED"
   port map (
      Q1 => data(0), -- 1-bit output for positive edge of clock 
      Q2 => data(1), -- 1-bit output for negative edge of clock
      C => clk,   -- 1-bit clock input
      CE => '1', -- 1-bit clock enable input
      D => dataDDR,   -- 1-bit DDR data input
      R => '0',   -- 1-bit reset
      S => '0'    -- 1-bit set
      );
process(clk)
begin
	if(clk'event and clk = '1')then
		data_q <= data;
		if(ce = '1')then
			if(s = '0')then
				data_out <= data(0);
			else
				data_out <= data(1);
			end if;
		end if;
	end if;
end process;

end Behavioral;

