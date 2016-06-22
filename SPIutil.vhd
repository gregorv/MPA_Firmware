----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:29:46 05/26/2015 
-- Design Name: 
-- Module Name:    UTIL_SPI - Behavioral 
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

entity SPIutil is
    Port ( reset : in  STD_LOGIC;
           start : in  STD_LOGIC;
           read_only : in  STD_LOGIC;
           done : out  STD_LOGIC;
           SR_data : in  STD_LOGIC_VECTOR (15 downto 0);
           mpa_empty : out  STD_LOGIC_VECTOR (5 downto 0);
           mpa_hitOR : out  STD_LOGIC_VECTOR (5 downto 0);
					 enutil_p : out  STD_LOGIC;
           enutil_n : out  STD_LOGIC;
					 util_clk_p : out  STD_LOGIC;
           util_clk_n : out  STD_LOGIC;
					 util_din_p : in  STD_LOGIC;
           util_din_n : in  STD_LOGIC;
					 util_dout_p : out  STD_LOGIC;
           util_dout_n : out  STD_LOGIC;
           ipb_clk : in  STD_LOGIC;
					 ipb_write : in std_logic;
					 ipb_strobe : in std_logic;
					 ipb_addr : in std_logic_vector(15 downto 0);
					 ipb_wdata : in std_logic_vector(31 downto 0);
           ipb_rdata : out  STD_LOGIC_VECTOR (31 downto 0));
end SPIutil;

architecture Behavioral of SPIutil is
constant N : integer := 3;
constant zero : std_logic_vector(31 downto 0) := (others =>'0');
signal util_din_buf : std_logic := '0';
signal util_din : std_logic := '0';
signal enutil : std_logic := '0';
signal util_clk : std_logic := '0';
signal util_dout : std_logic := '0';
signal IS_DAC : std_logic := '0';
signal GO : std_logic := '0';
signal strobe : std_logic := '0';
signal done_i : std_logic := '0';
signal util_clk_o : std_logic := '0';
signal util_clk_dl : std_logic := '0';
signal DAC_data : std_logic_vector(31 downto 0) := (others =>'0');
signal old_SR_data : std_logic_vector(15 downto 0) := (others =>'0');
signal util_ctrl : std_logic_vector(15 downto 0) := (others =>'0');
signal MPA_status : std_logic_vector(11 downto 0) := (others =>'0');
signal ipb_start : std_logic_vector(1 downto 0) := (others =>'0');
signal sr_cnt : std_logic_vector(5 downto 0) := (others =>'0');
signal sr_out_dl : std_logic := '0';
signal sr : std_logic_vector(31 downto 0) := (others =>'0');
signal DIV : std_logic_vector(N downto 0) := (others =>'0');
signal cnt : std_logic_vector(N downto 0) := (others =>'0');
attribute IOB : string;
attribute IOB of enutil, util_clk, util_dout, util_din : signal is "true";

begin
done <= done_i;
mpa_hitOR <= MPA_status(11 downto 6);
mpa_empty <= MPA_status(5 downto 0);
i_util_din_buf: IBUFDS generic map(DIFF_TERM => TRUE,IOSTANDARD => "LVDS_25") port map(i => util_din_p, ib => util_din_n, o => util_din_buf);
i_enutil_obuf : OBUFDS generic map (IOSTANDARD => "LVDS_25") port map (O => enutil_p, OB => enutil_n, I => enutil);
i_util_clk_obuf : OBUFDS generic map (IOSTANDARD => "LVDS_25") port map (O => util_clk_p, OB => util_clk_n, I => util_clk);
i_util_dout_obuf : OBUFDS generic map (IOSTANDARD => "LVDS_25") port map (O => util_dout_p, OB => util_dout_n, I => util_dout);
i_sr_out_dl : SRLC32E
   generic map (
      INIT => X"00000000")
   port map (
      Q => sr_out_dl,        -- SRL data output
      Q31 => open,    -- SRL cascade output pin
      A => "01111",        -- 5-bit shift depth select input
      CE => strobe,      -- Clock enable input
      CLK => ipb_clk,    -- Clock input
      D => sr(31)         -- SRL data input
   );
process(ipb_clk)
begin
	if(ipb_clk'event and ipb_clk = '1')then
		if(strobe = '1')then
			util_din <= util_din_buf;
		end if;
		if(strobe = '1')then
			util_dout <= sr_out_dl;
		end if;
		util_clk <= util_clk_o;
	end if;
end process;
process(ipb_clk,reset)
begin
	if(reset = '1')then
		enutil <= '0';
		util_clk_dl <= '0';
		util_clk_o <= '0';
		GO <= '0';
		IS_DAC <= '0';
		strobe <= '0';
		done_i <= '0';
		ipb_start   <= (others =>'0');
		DAC_data   <= (others =>'0');
		DIV   <= (others =>'0');
		cnt   <= (others =>'0');
		sr_cnt   <= (others =>'0');
		sr <= (others =>'0');
		old_SR_data <= (others =>'0');
	elsif(ipb_clk'event and ipb_clk = '1')then
		if(ipb_addr = x"0100" and ipb_write = '1' and ipb_strobe = '1')then
			DIV <= ipb_wdata(N downto 0);
		end if;
		if(ipb_addr = x"0101" and ipb_write = '1' and ipb_strobe = '1')then
			DAC_data(15 downto 0) <= ipb_wdata(15 downto 0);
			ipb_start(0) <= '1';
		else
			ipb_start(0) <= '0';
		end if;
		if(start = '1')then
			if(read_only = '0')then
				old_SR_data <= SR_data;
			end if;
			ipb_start(1) <= '0';
		elsif(ipb_addr = x"0102" and ipb_write = '1' and ipb_strobe = '1')then
			if(ipb_wdata(31) = '0')then
				old_SR_data <= ipb_wdata(15 downto 0);
			end if;
			ipb_start(1) <= '1';
		else
			ipb_start(1) <= '0';
		end if;
		util_clk_dl <= util_clk_o;
		done_i <= util_clk_dl and not util_clk_o and not GO;
		if(or_reduce(ipb_start) = '1' or start = '1')then
			enutil <= '1';
		elsif(GO = '0' and util_clk_o = '0' and util_clk_dl = '0')then
			enutil <= '0';
		end if;
		if(or_reduce(ipb_start) = '1' or start = '1')then
			GO <= '1';
			sr_cnt <= (others =>'0');
		elsif(strobe = '1')then
		  if(sr_cnt = "101111")then
				GO <= '0';
			end if;
			sr_cnt <= sr_cnt + 1;
		end if;
		if(or_reduce(ipb_start) = '1' or start = '1')then
			cnt <= DIV;
		elsif(GO = '1')then
			if(util_clk_o = '0')then
				cnt <= DIV;
			else 
				cnt <= cnt - 1;
			end if;
		end if;
		if(GO = '0')then
			util_clk_o <= '0';
		elsif(util_clk_o = '0')then
			util_clk_o <= '1';
		elsif(or_reduce(cnt(N downto 1)) = '0')then
			util_clk_o <= '0';
		end if;
		if(GO = '1' and util_clk_o = '0')then
			strobe <= '1';
		else
			strobe <= '0';
		end if;
		if(ipb_start(0) = '1')then
			sr <= old_SR_data & DAC_data(15 downto 0);
		elsif(ipb_start(1) = '1')then
			sr <= old_SR_data & x"0000";
		elsif(start = '1')then
			sr <= SR_data & x"0000";
		elsif(util_clk_o = '0' and util_clk_dl = '1')then
			sr <= sr(30 downto 0) & util_din;
		end if;
		if(done_i = '1' and IS_DAC = '1')then
			DAC_data(31 downto 16) <= sr(15 downto 0);
		end if;
		if(sr_cnt = "010000" and strobe = '1')then
			MPA_status <= sr(11 downto 0);
		end if;
		if(done_i = '1')then
			util_ctrl <= sr(31 downto 16);
		end if;
		if(ipb_start(0) = '1')then
			IS_DAC <= '1';
		elsif(done_i = '1')then
			IS_DAC <= '0';
		end if;
	end if;
end process;
process(ipb_addr)
begin
	if(ipb_addr(15 downto 4) = x"010")then
		case ipb_addr(3 downto 0) is
			when x"0" => ipb_rdata <= zero(31 downto N+1) & DIV;
			when x"1" => ipb_rdata <= DAC_data;
			when x"2" => ipb_rdata <= zero(31 downto 16) & old_SR_data;
			when x"3" => ipb_rdata <= zero(31 downto 1) & GO;
			when x"4" => ipb_rdata <= zero(31 downto 16) & util_ctrl;
			when x"5" => ipb_rdata <= zero(31 downto 12) & MPA_status;
			when others => ipb_rdata <= (others => '0');
		end case;
	else
		ipb_rdata <= (others => '0');
	end if;
end process;


end Behavioral;

