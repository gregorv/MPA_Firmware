----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:59:57 05/21/2009 
-- Design Name: 
-- Module Name:    External_Trigger_Handler - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
																	  
entity External_Trigger_Handler is
    Port ( xclk : in  STD_LOGIC;	 -- external clock
           ext_trig_line_in : in  STD_LOGIC;  -- "10100000..." is trigger 
           ext_trigger : out STD_LOGIC);
end External_Trigger_Handler;

architecture Behavioral of External_Trigger_Handler is
	 	
	signal shift_reg : std_logic_vector(3 downto 0); 

begin
	 	 
														   
	process(xclk)
	begin
	
		if rising_edge(xclk) then	
			
			ext_trigger <= '0';
								  
			shift_reg(3) <= ext_trig_line_in;
			shift_reg(2 downto 0) <= shift_reg(3 downto 1);
			
			if shift_reg = "0100" and ext_trig_line_in = '1' then  --TRIGGER found!!
				ext_trigger <= '1'; 	  
			end if;
							
		end if;
		
	end process;

end Behavioral;


