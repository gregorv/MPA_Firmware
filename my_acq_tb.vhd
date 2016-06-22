--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:22:58 06/22/2016
-- Design Name:   
-- Module Name:   /home/readout/Firmware_dev/my_acq_tb.vhd
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
 
ENTITY my_acq_tb IS
END my_acq_tb;
 
ARCHITECTURE behavior OF my_acq_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT acquisition
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         test_beam : IN  std_logic;
         calibration : IN  std_logic;
         beam_trig : IN  std_logic;
         beam_halt : IN  std_logic;
         start : IN  std_logic;
         shutter_delay : IN  std_logic_vector(3 downto 0);
         hitOR_p : IN  std_logic;
         hitOR_n : IN  std_logic;
         set_read_clk : OUT  std_logic;
         done : OUT  std_logic;
         shutter_p : OUT  std_logic;
         shutter_n : OUT  std_logic;
         shutter_open : OUT  std_logic;
         en_strip_out : OUT  std_logic;
         calstrobe_p : OUT  std_logic;
         calstrobe_n : OUT  std_logic;
         ipb_clk : IN  std_logic;
         ipb_write : IN  std_logic;
         ipb_strobe : IN  std_logic;
         ipb_addr : IN  std_logic_vector(15 downto 0);
         ipb_wdata : IN  std_logic_vector(31 downto 0);
         ipb_rdata : OUT  std_logic_vector(31 downto 0);
         tel_busy_p : IN  std_logic;
         tel_busy_n : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '1';
   signal test_beam : std_logic := '0';
   signal calibration : std_logic := '0';
   signal beam_trig : std_logic := '0';
   signal beam_halt : std_logic := '0';
   signal start : std_logic := '0';
   signal shutter_delay : std_logic_vector(3 downto 0) := (others => '0');
   signal hitOR_p : std_logic := '0';
   signal hitOR_n : std_logic := '1';
   signal ipb_clk : std_logic := '0';
   signal ipb_write : std_logic := '1';
   signal ipb_strobe : std_logic := '0';
   signal ipb_addr : std_logic_vector(15 downto 0) := x"0205";
   signal ipb_wdata : std_logic_vector(31 downto 0) := x"00000050";
   signal tel_busy_p : std_logic := '0';
   signal tel_busy_n : std_logic := '1';

 	--Outputs
   signal set_read_clk : std_logic;
   signal done : std_logic;
   signal shutter_p : std_logic;
   signal shutter_n : std_logic;
   signal shutter_open : std_logic;
   signal en_strip_out : std_logic;
   signal calstrobe_p : std_logic;
   signal calstrobe_n : std_logic;
   signal ipb_rdata : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
   constant set_read_clk_period : time := 10 ns;
   constant ipb_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: acquisition PORT MAP (
          clk => clk,
          reset => reset,
          test_beam => test_beam,
          calibration => calibration,
          beam_trig => beam_trig,
          beam_halt => beam_halt,
          start => start,
          shutter_delay => shutter_delay,
          hitOR_p => hitOR_p,
          hitOR_n => hitOR_n,
          set_read_clk => set_read_clk,
          done => done,
          shutter_p => shutter_p,
          shutter_n => shutter_n,
          shutter_open => shutter_open,
          en_strip_out => en_strip_out,
          calstrobe_p => calstrobe_p,
          calstrobe_n => calstrobe_n,
          ipb_clk => ipb_clk,
          ipb_write => ipb_write,
          ipb_strobe => ipb_strobe,
          ipb_addr => ipb_addr,
          ipb_wdata => ipb_wdata,
          ipb_rdata => ipb_rdata,
          tel_busy_p => tel_busy_p,
          tel_busy_n => tel_busy_n
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   set_read_clk_process :process
   begin
		set_read_clk <= '0';
		wait for set_read_clk_period/2;
		set_read_clk <= '1';
		wait for set_read_clk_period/2;
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
reset <= '1';
            -- hold reset state for 100 ns.
      wait for 100 ns;	
reset <= '0';
      wait for 100 ns;	
		
ipb_strobe <= '1';
      wait for 33 ns;	
ipb_strobe <= '0';
      wait for clk_period*10;
start <= '1';
      wait for clk_period*10;
start <= '0';
      -- insert stimulus here 

      wait;
   end process;

END;
