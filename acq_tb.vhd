--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:31:09 11/02/2015
-- Design Name:   
-- Module Name:   D:/iseproj/mpa_GLIB/acq_tb.vhd
-- Project Name:  glib_v3_basic
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: acquisition
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
 
ENTITY acq_tb IS
END acq_tb;
 
ARCHITECTURE behavior OF acq_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT acquisition
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         test_beam : IN  std_logic;
         beam_start : IN  std_logic;
         beam_halt : IN  std_logic;
         start : IN  std_logic;
         hitOR_p : IN  std_logic;
         hitOR_n : IN  std_logic;
         IsCalib : IN  std_logic;
         setCLKOR : OUT  std_logic;
         done : OUT  std_logic;
         shutter_p : OUT  std_logic;
         shutter_n : OUT  std_logic;
         calstrobe_p : OUT  std_logic;
         calstrobe_n : OUT  std_logic;
         ipb_clk : IN  std_logic;
         ipb_write : IN  std_logic;
         ipb_strobe : IN  std_logic;
         ipb_addr : IN  std_logic_vector(15 downto 0);
         ipb_wdata : IN  std_logic_vector(31 downto 0);
         ipb_rdata : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '1';
   signal test_beam : std_logic := '1';
   signal beam_start : std_logic := '0';
   signal beam_halt : std_logic := '0';
   signal start : std_logic := '0';
   signal hitOR_p : std_logic := '0';
   signal hitOR_n : std_logic := '1';
   signal IsCalib : std_logic := '0';
   signal ipb_clk : std_logic := '0';
   signal ipb_write : std_logic := '1';
   signal ipb_strobe : std_logic := '0';
   signal ipb_addr : std_logic_vector(15 downto 0) := x"0205";
   signal ipb_wdata : std_logic_vector(31 downto 0) := x"00000050";

 	--Outputs
   signal setCLKOR : std_logic;
   signal done : std_logic;
   signal shutter_p : std_logic;
   signal shutter_n : std_logic;
   signal calstrobe_p : std_logic;
   signal calstrobe_n : std_logic;
   signal ipb_rdata : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 3 ns;
   constant ipb_clk_period : time := 32 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: acquisition PORT MAP (
          clk => clk,
          reset => reset,
          test_beam => test_beam,
          beam_start => beam_start,
          beam_halt => beam_halt,
          start => start,
          hitOR_p => hitOR_p,
          hitOR_n => hitOR_n,
          IsCalib => IsCalib,
          setCLKOR => setCLKOR,
          done => done,
          shutter_p => shutter_p,
          shutter_n => shutter_n,
          calstrobe_p => calstrobe_p,
          calstrobe_n => calstrobe_n,
          ipb_clk => ipb_clk,
          ipb_write => ipb_write,
          ipb_strobe => ipb_strobe,
          ipb_addr => ipb_addr,
          ipb_wdata => ipb_wdata,
          ipb_rdata => ipb_rdata
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   ipb_clk_process :process
   begin
		ipb_clk <= '0';
		wait for ipb_clk_period/2;
		ipb_clk <= '1';
		wait for ipb_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
reset <= '0';
      wait for 100 ns;	
ipb_strobe <= '1';
      wait for 33 ns;	
ipb_strobe <= '0';
      wait for clk_period*10;
beam_start <= '1';
      wait for clk_period*10;
beam_start <= '0';
      -- insert stimulus here 

      wait;
   end process;

END;
