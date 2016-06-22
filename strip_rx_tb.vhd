--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:26:17 05/21/2015
-- Design Name:   
-- Module Name:   D:/iseproj/MPA/strip_rx_tb.vhd
-- Project Name:  MPA
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: strip_rx
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY strip_rx_tb IS
END strip_rx_tb;
 
ARCHITECTURE behavior OF strip_rx_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT strip_rx
    PORT(
         clk : IN  std_logic;
         rx_en : IN  std_logic;
         shutter_open : in  STD_LOGIC;
         strobe_p : IN  std_logic;
         strobe_n : IN  std_logic;
         data_p : IN  std_logic_vector(3 downto 0);
         data_n : IN  std_logic_vector(3 downto 0);
         data_out : OUT  std_logic_vector(3 downto 0);
         we : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rx_en : std_logic := '1';
   signal shutter_open : std_logic := '0';
   signal strobe_p : std_logic := '1';
   signal strobe_n : std_logic := '0';
   signal data_p : std_logic_vector(3 downto 0) := (others => '0');
   signal data_n : std_logic_vector(3 downto 0) := (others => '1');

 	--Outputs
   signal data_out : std_logic_vector(3 downto 0);
   signal we : std_logic;

   -- Clock period definitions
   constant clk_period : time := 2.5 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: strip_rx PORT MAP (
          clk => clk,
          rx_en => rx_en,
					shutter_open => shutter_open,
          strobe_p => strobe_p,
          strobe_n => strobe_n,
          data_p => data_p,
          data_n => data_n,
          data_out => data_out,
          we => we
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
strobe_n <= not strobe_p; 
data_n <= not data_p; 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 80 ns;	
strobe_p <= '0';
      wait for 103 ns;	
shutter_open <= '1';
      wait for 20 ns;	
strobe_p <= '1';
      wait for 20 ns;	
data_p(0) <= '1';
      wait for clk_period*2.5;
data_p(0) <= '0';
      wait for clk_period*2.5;
data_p(0) <= '1';
      wait for clk_period*2.5;
data_p(0) <= '0';
      wait for clk_period*2.5;
data_p(0) <= '1';
      wait for clk_period*2.5;
data_p(0) <= '0';
      wait for clk_period*2.5;
data_p(0) <= '1';
      wait for clk_period*2.5;
data_p(0) <= '0';
      wait for clk_period*2.5;
data_p(0) <= '1';
      wait for clk_period*2.5;
data_p(0) <= '0';
      wait for clk_period*2.5;
data_p(0) <= '1';
      wait for clk_period*2.5;
data_p(0) <= '0';
      wait for clk_period*2.5;
data_p(0) <= '1';
      wait for clk_period*2.5;
data_p(0) <= '0';
      wait for clk_period*2.5;
data_p(0) <= '1';
      wait for clk_period*2.5;
data_p(0) <= '0';
      wait for clk_period*2.5;
      wait for 103 ns;	
shutter_open <= '0';

      -- insert stimulus here 

      wait;
   end process;

END;
