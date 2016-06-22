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

entity strip_rx is
    Port ( clk : in  STD_LOGIC;
           rx_en : in  STD_LOGIC;
           shutter_open : in  STD_LOGIC;
           strobe_p : in  STD_LOGIC;
           strobe_n : in  STD_LOGIC;
           data_p : in  STD_LOGIC_VECTOR (3 downto 0);
           data_n : in  STD_LOGIC_VECTOR (3 downto 0);
           data_out : out  STD_LOGIC_VECTOR (3 downto 0);
           we : out  STD_LOGIC);
end strip_rx;

architecture Behavioral of strip_rx is
COMPONENT strip_rxdata
	PORT(
		clk : IN std_logic;
		s : IN std_logic;
		ce : IN std_logic;
		data_p : IN std_logic;
		data_n : IN std_logic;          
		data_out : OUT std_logic
		);
END COMPONENT;
signal en_capture : std_logic := '0';
signal shutter_open_q : std_logic := '0';
signal got_strobe : std_logic := '0';
signal got_strobe_q : std_logic := '0';
signal strobeDDR : std_logic := '0';
signal s : std_logic := '0';
signal ce_data : std_logic := '0';
signal ce_data_dl : std_logic_vector(1 downto 0) := (others =>'0');
signal strobep : std_logic_vector(1 downto 0) := (others =>'0');
signal strobe : std_logic_vector(1 downto 0) := (others =>'0');
signal data_o : std_logic_vector(3 downto 0) := (others =>'0');

begin
i_strobe_buf: IBUFDS generic map(DIFF_TERM => TRUE,IOSTANDARD => "LVDS_25") port map(i => strobe_p, ib => strobe_n, o => strobeDDR);
i_strobe_DDR : IDDR 
   generic map (
      DDR_CLK_EDGE => "SAME_EDGE") -- "OPPOSITE_EDGE", "SAME_EDGE" or "SAME_EDGE_PIPELINED"
   port map (
      Q1 => strobe(0), -- 1-bit output for positive edge of clock 
      Q2 => strobe(1), -- 1-bit output for negative edge of clock
      C => clk,   -- 1-bit clock input
      CE => '1', -- 1-bit clock enable input
      D => strobeDDR,   -- 1-bit DDR data input
      R => '0',   -- 1-bit reset
      S => '0'    -- 1-bit set
      );
process(clk)
begin
	if(clk'event and clk = '1')then
		data_out <= data_o;
		shutter_open_q <= shutter_open;
	end if;
end process;
process(clk,rx_en)
begin
	if(rx_en = '0')then
		en_capture <= '0';
		got_strobe <= '0';
		got_strobe_q <= '0';
		s <= '0';
		ce_data <= '0';
		we <= '0';
	elsif(clk'event and clk = '1')then
		if(shutter_open_q = '0')then
			en_capture <= '0';
		elsif(en_capture = '0' and strobe = "00")then
			en_capture <= '1';
		end if;
		if(strobe(0) = '1' and en_capture = '1')then
			got_strobe <= '1';
			got_strobe_q <= got_strobe;
		else
			got_strobe <= '0';
			got_strobe_q <= '0';
		end if;
		if(strobe(0) = '0' or ce_data = '1')then
			ce_data <= '0';
		elsif((got_strobe = '1' and got_strobe_q = '0') or (got_strobe = '0' and strobe(1) = '1'))then
			ce_data <= '1';
		elsif(s = '1')then
			ce_data <= ce_data_dl(0);
		else
			ce_data <= ce_data_dl(1);
		end if;
		if(got_strobe = '0')then
			ce_data_dl <= "00";
		else
			ce_data_dl <= ce_data_dl(0) & ce_data;
		end if;
		if(strobe(0) = '1' and got_strobe = '0')then
			s <= strobe(1);
		elsif(ce_data = '1')then
			s <= not s;
		end if;
		we <= ce_data_dl(1);
	end if;
end process;
g_data : for i in 0 to 3 generate
	Inst_strip_rxdata: strip_rxdata PORT MAP(
		clk => clk,
		s => s,
		ce => ce_data,
		data_p => data_p(i),
		data_n => data_n(i),
		data_out => data_o(i)
	);
end generate;
end Behavioral;

