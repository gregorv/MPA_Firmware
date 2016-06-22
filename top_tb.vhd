--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   20:51:56 11/02/2015
-- Design Name:   
-- Module Name:   D:/iseproj/mpa_GLIB/top_tb.vhd
-- Project Name:  glib_v3_basic
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MPA_top
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY top_tb IS
END top_tb;
 
ARCHITECTURE behavior OF top_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MPA_top
    PORT(
         clk125 : IN  std_logic;
         beam_clk : IN  std_logic;
         beam_data : IN  std_logic;
         led : OUT  std_logic_vector(1 to 2);
         hitOR_p : IN  std_logic;
         hitOR_n : IN  std_logic;
         shutter_p : OUT  std_logic;
         shutter_n : OUT  std_logic;
         calstrobe_p : OUT  std_logic;
         calstrobe_n : OUT  std_logic;
         conf_en_p : OUT  std_logic;
         conf_en_n : OUT  std_logic;
         conf_clk_p : OUT  std_logic;
         conf_clk_n : OUT  std_logic;
         conf_din_p : IN  std_logic;
         conf_din_n : IN  std_logic;
         conf_dout_p : OUT  std_logic;
         conf_dout_n : OUT  std_logic;
         read_clk_p : OUT  std_logic;
         read_clk_n : OUT  std_logic;
         read_din_p : IN  std_logic;
         read_din_n : IN  std_logic;
         read_dout_p : OUT  std_logic;
         read_dout_n : OUT  std_logic;
         mem_p : IN  std_logic_vector(5 downto 0);
         mem_n : IN  std_logic_vector(5 downto 0);
         enutil_p : OUT  std_logic;
         enutil_n : OUT  std_logic;
         util_clk_p : OUT  std_logic;
         util_clk_n : OUT  std_logic;
         util_din_p : IN  std_logic;
         util_din_n : IN  std_logic;
         util_dout_p : OUT  std_logic;
         util_dout_n : OUT  std_logic;
         clk160_p : OUT  std_logic;
         clk160_n : OUT  std_logic;
         strip_strobe_in_p : IN  std_logic_vector(5 downto 0);
         strip_strobe_in_n : IN  std_logic_vector(5 downto 0);
         strip_data_in_p : IN  std_logic_vector(23 downto 0);
         strip_data_in_n : IN  std_logic_vector(23 downto 0);
         strip_strobe_out_p : OUT  std_logic_vector(5 downto 0);
         strip_strobe_out_n : OUT  std_logic_vector(5 downto 0);
         strip_data_out_p : OUT  std_logic_vector(23 downto 0);
         strip_data_out_n : OUT  std_logic_vector(23 downto 0);
         ipb_clk : IN  std_logic;
         ipb_write : IN  std_logic;
         ipb_strobe : IN  std_logic;
         ipb_addr : IN  std_logic_vector(15 downto 0);
         ipb_wdata : IN  std_logic_vector(31 downto 0);
         ipb_rdata : OUT  std_logic_vector(31 downto 0);
         ipb_ack : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk125 : std_logic := '0';
   signal beam_clk : std_logic := '0';
   signal beam_data : std_logic := '0';
   signal hitOR_p : std_logic := '0';
   signal hitOR_n : std_logic := '1';
   signal conf_din_p : std_logic := '0';
   signal conf_din_n : std_logic := '1';
   signal read_din_p : std_logic := '1';
   signal read_din_n : std_logic := '0';
   signal mem_p : std_logic_vector(5 downto 0) := (others => '0');
   signal mem_n : std_logic_vector(5 downto 0) := (others => '1');
   signal util_din_p : std_logic := '0';
   signal util_din_n : std_logic := '1';
   signal strip_strobe_in_p : std_logic_vector(5 downto 0) := (others => '0');
   signal strip_strobe_in_n : std_logic_vector(5 downto 0) := (others => '1');
   signal strip_data_in_p : std_logic_vector(23 downto 0) := (others => '0');
   signal strip_data_in_n : std_logic_vector(23 downto 0) := (others => '1');
   signal ipb_clk : std_logic := '0';
   signal ipb_write : std_logic := '1';
   signal ipb_strobe : std_logic := '0';
   signal ipb_addr : std_logic_vector(15 downto 0) := (others => '0');
   signal ipb_wdata : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal led : std_logic_vector(1 to 2);
   signal shutter_p : std_logic;
   signal shutter_n : std_logic;
   signal calstrobe_p : std_logic;
   signal calstrobe_n : std_logic;
   signal conf_en_p : std_logic;
   signal conf_en_n : std_logic;
   signal conf_clk_p : std_logic;
   signal conf_clk_n : std_logic;
   signal conf_dout_p : std_logic;
   signal conf_dout_n : std_logic;
   signal read_clk_p : std_logic;
   signal read_clk_n : std_logic;
   signal read_dout_p : std_logic;
   signal read_dout_n : std_logic;
   signal enutil_p : std_logic;
   signal enutil_n : std_logic;
   signal util_clk_p : std_logic;
   signal util_clk_n : std_logic;
   signal util_dout_p : std_logic;
   signal util_dout_n : std_logic;
   signal clk160_p : std_logic;
   signal clk160_n : std_logic;
   signal strip_strobe_out_p : std_logic_vector(5 downto 0);
   signal strip_strobe_out_n : std_logic_vector(5 downto 0);
   signal strip_data_out_p : std_logic_vector(23 downto 0);
   signal strip_data_out_n : std_logic_vector(23 downto 0);
   signal ipb_rdata : std_logic_vector(31 downto 0);
   signal ipb_ack : std_logic;

   -- Clock period definitions
   constant clk125_period : time := 8 ns;
   constant beam_clk_period : time := 38 ns;
--   constant clk160_p_period : time := 10 ns;
--   constant clk160_n_period : time := 10 ns;
   constant ipb_clk_period : time := 32 ns;
   signal cntr : std_logic_vector(23 downto 0) := (others => '0');
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MPA_top PORT MAP (
          clk125 => clk125,
          beam_clk => beam_clk,
          beam_data => beam_data,
          led => led,
          hitOR_p => hitOR_p,
          hitOR_n => hitOR_n,
          shutter_p => shutter_p,
          shutter_n => shutter_n,
          calstrobe_p => calstrobe_p,
          calstrobe_n => calstrobe_n,
          conf_en_p => conf_en_p,
          conf_en_n => conf_en_n,
          conf_clk_p => conf_clk_p,
          conf_clk_n => conf_clk_n,
          conf_din_p => conf_din_p,
          conf_din_n => conf_din_n,
          conf_dout_p => conf_dout_p,
          conf_dout_n => conf_dout_n,
          read_clk_p => read_clk_p,
          read_clk_n => read_clk_n,
          read_din_p => read_din_p,
          read_din_n => read_din_n,
          read_dout_p => read_dout_p,
          read_dout_n => read_dout_n,
          mem_p => mem_p,
          mem_n => mem_n,
          enutil_p => enutil_p,
          enutil_n => enutil_n,
          util_clk_p => util_clk_p,
          util_clk_n => util_clk_n,
          util_din_p => util_din_p,
          util_din_n => util_din_n,
          util_dout_p => util_dout_p,
          util_dout_n => util_dout_n,
          clk160_p => clk160_p,
          clk160_n => clk160_n,
          strip_strobe_in_p => strip_strobe_in_p,
          strip_strobe_in_n => strip_strobe_in_n,
          strip_data_in_p => strip_data_in_p,
          strip_data_in_n => strip_data_in_n,
          strip_strobe_out_p => strip_strobe_out_p,
          strip_strobe_out_n => strip_strobe_out_n,
          strip_data_out_p => strip_data_out_p,
          strip_data_out_n => strip_data_out_n,
          ipb_clk => ipb_clk,
          ipb_write => ipb_write,
          ipb_strobe => ipb_strobe,
          ipb_addr => ipb_addr,
          ipb_wdata => ipb_wdata,
          ipb_rdata => ipb_rdata,
          ipb_ack => ipb_ack
        );

   -- Clock process definitions
   clk125_process :process
   begin
		clk125 <= '0';
		wait for clk125_period/2;
		clk125 <= '1';
		wait for clk125_period/2;
   end process;
 
   beam_clk_process :process
   begin
		beam_clk <= '0';
		wait for beam_clk_period/2;
		beam_clk <= '1';
		wait for beam_clk_period/2;
   end process;
 
--   clk160_p_process :process
--   begin
--		clk160_p <= '0';
--		wait for clk160_p_period/2;
--		clk160_p <= '1';
--		wait for clk160_p_period/2;
--   end process;
-- 
--   clk160_n_process :process
--   begin
--		clk160_n <= '0';
--		wait for clk160_n_period/2;
--		clk160_n <= '1';
--		wait for clk160_n_period/2;
--   end process;
 
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
ipb_strobe <= '1';
ipb_wdata(15 downto 0) <= x"0001";
      wait for ipb_clk_period;
ipb_strobe <= '0';
      wait for ipb_clk_period;
ipb_addr(15 downto 0) <= x"6001";
ipb_wdata(15 downto 0) <= x"0002";
ipb_strobe <= '1';
      wait for ipb_clk_period;
ipb_strobe <= '0';
      wait for ipb_clk_period;
ipb_addr(15 downto 0) <= x"0002";
ipb_wdata(15 downto 0) <= x"000b";
ipb_strobe <= '1';
      wait for ipb_clk_period;
ipb_strobe <= '0';
ipb_addr(15 downto 0) <= x"9c02";
ipb_wdata(15 downto 0) <= x"0001";
ipb_strobe <= '1';
      wait for ipb_clk_period;
ipb_strobe <= '0';
      wait for ipb_clk_period;
ipb_addr(15 downto 0) <= x"0205";
ipb_wdata(15 downto 0) <= x"0800";
ipb_strobe <= '1';
      wait for ipb_clk_period;
ipb_strobe <= '0';
      wait for ipb_clk_period;
ipb_addr(15 downto 0) <= x"0000";
ipb_wdata(15 downto 0) <= x"0002";
ipb_strobe <= '1';
      wait for ipb_clk_period;
ipb_strobe <= '0';

      -- insert stimulus here 

      wait;
   end process;
process(beam_clk)
begin
	if(beam_clk'event and beam_clk = '1')then
		cntr <= cntr + 1;
		if(cntr = x"000090" or cntr = x"000091" or cntr = x"000093")then
			beam_data <= '1';
		elsif(cntr = x"0000a0" or cntr = x"0000a2" or cntr = x"0000c0" or cntr = x"0000c2" or cntr = x"0000e0" or cntr = x"0000e2" or cntr = x"000100" or cntr = x"000102")then
			beam_data <= '1';
		else
			beam_data <= '0';
		end if;
	end if;
end process;
END;
