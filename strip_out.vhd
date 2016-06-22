----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:12:20 05/21/2015 
-- Design Name: 
-- Module Name:    strip_in - Behavioral 
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
use IEEE.std_logic_misc.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;
Library UNIMACRO;
use UNIMACRO.vcomponents.all;

entity strip_out is
    Port ( clk : in  STD_LOGIC;
           sysclk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           en_strip_out : in  STD_LOGIC;
           strip_strobe_out_p : out  STD_LOGIC_VECTOR(5 downto 0);
           strip_strobe_out_n : out  STD_LOGIC_VECTOR(5 downto 0);
           strip_data_out_p : out  STD_LOGIC_VECTOR(23 downto 0);
           strip_data_out_n : out  STD_LOGIC_VECTOR(23 downto 0);
           ipb_clk : in  STD_LOGIC;
					 ipb_write : in std_logic;
					 ipb_strobe : in std_logic;
					 ipb_addr : in std_logic_vector(15 downto 0);
					 ipb_wdata : in std_logic_vector(31 downto 0);
           ipb_rdata : out  STD_LOGIC_VECTOR (31 downto 0));
end strip_out;

architecture Behavioral of strip_out is
constant zero : std_logic_vector(31 downto 0) := (others =>'0');
signal strip_data_out : std_logic_vector(23 downto 0) := (others =>'0');
signal strip_data_out_o : std_logic_vector(23 downto 0) := (others =>'0');
signal start_send : std_logic := '0';
signal start_send_sync : std_logic_vector(2 downto 0) := (others =>'0');
signal en_strip_out_sync : std_logic_vector(2 downto 0) := (others =>'0');
signal strip2send : std_logic_vector(5 downto 0) := (others =>'0');
signal strip_strobe_out : std_logic_vector(5 downto 0) := (others =>'0');
signal strip_strobe_out_o : std_logic_vector(5 downto 0) := (others =>'0');
signal nibble_cnt : std_logic_vector(2 downto 0) := "100";
type array6x16 is array(0 to 5) of std_logic_vector(15 downto 0);
signal strip : array6x16 := (others => (others =>'0'));
begin
g_strip_strobe_out : for i in 0 to 5 generate
	i_strip_strobe_out_obuf : OBUFDS generic map (IOSTANDARD => "LVDS_25") port map (O => strip_strobe_out_p(i), OB => strip_strobe_out_n(i), I => strip_strobe_out_o(i));
end generate;
g_strip_data_out : for i in 0 to 23 generate
	i_strip_data_out_obuf : OBUFDS generic map (IOSTANDARD => "LVDS_25") port map (O => strip_data_out_p(i), OB => strip_data_out_n(i), I => strip_data_out_o(i));
end generate;
process(clk)
begin
	if(clk'event and clk = '1')then
		strip_data_out_o <= strip_data_out;
		strip_strobe_out_o <= strip_strobe_out;
		for i in 0 to 5 loop
			strip_strobe_out(i) <= not nibble_cnt(2) and strip2send(i);
			case nibble_cnt(1 downto 0) is
				when "00" => strip_data_out(4*i+3 downto 4*i) <= strip(i)(3 downto 0);
				when "01" => strip_data_out(4*i+3 downto 4*i) <= strip(i)(7 downto 4);
				when "10" => strip_data_out(4*i+3 downto 4*i) <= strip(i)(11 downto 8);
				when others => strip_data_out(4*i+3 downto 4*i) <= strip(i)(15 downto 12);
			end case;
		end loop;
	end if;
end process;
process(clk,reset,start_send)
begin
	if(reset = '1')then
		nibble_cnt <= "100";
		start_send_sync <= (others =>'0');
		en_strip_out_sync <= (others =>'0');
	elsif(start_send = '1')then
		start_send_sync <= (others =>'1');
	elsif(clk'event and clk = '1')then
		if(start_send_sync(2 downto 1) = "10" or en_strip_out_sync(2 downto 1) = "01")then
			nibble_cnt <= "000";
		elsif(nibble_cnt(2) = '0' or en_strip_out_sync(2) = '1')then
			nibble_cnt(2) <= not en_strip_out_sync(2) and nibble_cnt(1) and nibble_cnt(0);
			nibble_cnt(1) <= nibble_cnt(1) xor nibble_cnt(0);
			nibble_cnt(0) <= not nibble_cnt(0);
		end if;
		start_send_sync <= start_send_sync(1 downto 0) & '0';
		en_strip_out_sync <= en_strip_out_sync(1 downto 0) & en_strip_out;
	end if;
end process;
process(ipb_clk,reset)
begin
	if(reset = '1')then
		strip <= (others => (others => '0'));
		strip2send <= (others => '0');
		start_send <= '0';
	elsif(ipb_clk'event and ipb_clk = '1')then
		if(ipb_addr(15 downto 4) = x"400" and ipb_write = '1' and ipb_strobe = '1')then
			case ipb_addr(3 downto 0) is
				when x"0" => strip(0) <= ipb_wdata(15 downto 0);
				when x"1" => strip(1) <= ipb_wdata(15 downto 0);
				when x"2" => strip(2) <= ipb_wdata(15 downto 0);
				when x"3" => strip(3) <= ipb_wdata(15 downto 0);
				when x"4" => strip(4) <= ipb_wdata(15 downto 0);
				when x"5" => strip(5) <= ipb_wdata(15 downto 0);
				when x"6" => strip2send <= ipb_wdata(5 downto 0);
				when others => NULL;
			end case;
			start_send <= '1';
		else
			start_send <= '0';
		end if;
	end if;
end process;
process(ipb_addr)
begin
	if(ipb_addr(15 downto 4) = x"400")then
		case ipb_addr(3 downto 0) is
			when x"0" => ipb_rdata <= x"0000" & strip(0);
			when x"1" => ipb_rdata <= x"0000" & strip(1);
			when x"2" => ipb_rdata <= x"0000" & strip(2);
			when x"3" => ipb_rdata <= x"0000" & strip(3);
			when x"4" => ipb_rdata <= x"0000" & strip(4);
			when x"5" => ipb_rdata <= x"0000" & strip(5);
			when x"6" => ipb_rdata <= zero(31 downto 6) & strip2send;
			when others => ipb_rdata <= (others => '0');
		end case;
	else
		ipb_rdata <= (others => '0');
	end if;
end process;
end Behavioral;

