--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:22:03 11/20/2015
-- Design Name:   
-- Module Name:   D:/iseproj/mpa_GLIB/pattern_tb.vhd
-- Project Name:  glib_v3_basic
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: trigpattern
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
 
ENTITY pattern_tb IS
END pattern_tb;
 
ARCHITECTURE behavior OF pattern_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT trigpattern
  GENERIC (
    PATTERN : STD_LOGIC_VECTOR(4 DOWNTO 0) := "01101";
    CLOCK_EDGE : STRING := "FALLING";
    WIDTH : INTEGER := 1
  );
    PORT(
         CLK : IN  std_logic;
         D : IN  std_logic;
         TRIGGER : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal D : std_logic := '0';

 	--Outputs
   signal TRIGGER : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: trigpattern PORT MAP (
          CLK => CLK,
          D => D,
          TRIGGER => TRIGGER
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 20 ns;	
d <= '1';
      wait for CLK_period*2;
d <= '0';
      wait for CLK_period*2;
d <= '1';
      wait for CLK_period*2;
d <= '0';
--      wait for CLK_period*2;
--d <= '1';
--      wait for CLK_period;
--d <= '0';
      wait for CLK_period;
d <= '1';
      wait for CLK_period;
d <= '0';
      wait for CLK_period;
d <= '1';
      wait for CLK_period*2;
d <= '0';
      wait for CLK_period*2;
d <= '1';
      wait for CLK_period*2;
d <= '0';
      wait for CLK_period*2;

      -- insert stimulus here 

      wait;
   end process;

END;
