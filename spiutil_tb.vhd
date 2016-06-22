--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:04:18 09/30/2015
-- Design Name:   
-- Module Name:   D:/iseproj/mpa_GLIB/spiutil_tb.vhd
-- Project Name:  glib_v3_basic
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SPIutil
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.std_logic_misc.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY spiutil_tb IS
END spiutil_tb;
 
ARCHITECTURE behavior OF spiutil_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SPIutil
    PORT(
         reset : IN  std_logic;
         start : IN  std_logic;
         read_only : IN  std_logic;
         done : OUT  std_logic;
         SR_data : IN  std_logic_vector(15 downto 0);
         mpa_empty : OUT  std_logic_vector(5 downto 0);
         mpa_hitOR : OUT  std_logic_vector(5 downto 0);
         enutil_p : OUT  std_logic;
         enutil_n : OUT  std_logic;
         util_clk_p : OUT  std_logic;
         util_clk_n : OUT  std_logic;
         util_din_p : IN  std_logic;
         util_din_n : IN  std_logic;
         util_dout_p : OUT  std_logic;
         util_dout_n : OUT  std_logic;
         ipb_clk : IN  std_logic;
         ipb_write : IN  std_logic;
         ipb_strobe : IN  std_logic;
         ipb_addr : IN  std_logic_vector(15 downto 0);
         ipb_wdata : IN  std_logic_vector(31 downto 0);
         ipb_rdata : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal reset : std_logic := '1';
   signal start : std_logic := '0';
   signal read_only : std_logic := '0';
   signal SR_data : std_logic_vector(15 downto 0) := (others => '0');
   signal util_din_p : std_logic := '0';
   signal util_din_n : std_logic := '0';
   signal ipb_clk : std_logic := '0';
   signal ipb_write : std_logic := '1';
   signal ipb_strobe : std_logic := '0';
   signal ipb_addr : std_logic_vector(15 downto 0) := x"0102";
   signal ipb_wdata : std_logic_vector(31 downto 0) := x"00001234";

 	--Outputs
   signal done : std_logic;
   signal mpa_empty : std_logic_vector(5 downto 0);
   signal mpa_hitOR : std_logic_vector(5 downto 0);
   signal enutil_p : std_logic;
   signal enutil_n : std_logic;
   signal util_clk_p : std_logic;
   signal util_clk_n : std_logic;
   signal util_dout_p : std_logic;
   signal util_dout_n : std_logic;
   signal ipb_rdata : std_logic_vector(31 downto 0);
   signal cntr : std_logic_vector(15 downto 0) := x"0000";

   -- Clock period definitions
   constant ipb_clk_period : time := 32 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SPIutil PORT MAP (
          reset => reset,
          start => start,
          read_only => read_only,
          done => done,
          SR_data => SR_data,
          mpa_empty => mpa_empty,
          mpa_hitOR => mpa_hitOR,
          enutil_p => enutil_p,
          enutil_n => enutil_n,
          util_clk_p => util_clk_p,
          util_clk_n => util_clk_n,
          util_din_p => util_din_p,
          util_din_n => util_din_n,
          util_dout_p => util_dout_p,
          util_dout_n => util_dout_n,
          ipb_clk => ipb_clk,
          ipb_write => ipb_write,
          ipb_strobe => ipb_strobe,
          ipb_addr => ipb_addr,
          ipb_wdata => ipb_wdata,
          ipb_rdata => ipb_rdata
        );

   -- Clock process definitions
   ipb_clk_process :process
   begin
		ipb_clk <= '0';
		wait for ipb_clk_period/2;
		ipb_clk <= '1';
		wait for ipb_clk_period/2;
   end process;
process(ipb_clk)
begin
	if(ipb_clk'event and ipb_clk = '1')then
		cntr <= cntr + 1;
		if(cntr = x"0010")then
			ipb_strobe <= '1';
		else
			ipb_strobe <= '0';
		end if;
	end if;
end process; 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
reset <= '0';
      wait for ipb_clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
