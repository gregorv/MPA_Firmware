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

entity strip_in is
    Port ( clk : in  STD_LOGIC;
           sysclk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           rst_buffer : in  STD_LOGIC;
           shutter_open : in  STD_LOGIC;
           strip_strobe_in_p : in  STD_LOGIC_VECTOR(5 downto 0);
           strip_strobe_in_n : in  STD_LOGIC_VECTOR(5 downto 0);
           strip_data_in_p : in  STD_LOGIC_VECTOR(23 downto 0);
           strip_data_in_n : in  STD_LOGIC_VECTOR(23 downto 0);
           ipb_clk : in  STD_LOGIC;
					 ipb_write : in std_logic;
					 ipb_strobe : in std_logic;
					 ipb_addr : in std_logic_vector(15 downto 0);
					 ipb_wdata : in std_logic_vector(31 downto 0);
           ipb_rdata : out  STD_LOGIC_VECTOR (31 downto 0));
end strip_in;

architecture Behavioral of strip_in is
COMPONENT strip_rx
	PORT(
		clk : IN std_logic;
		rx_en : IN std_logic;
    shutter_open : in  STD_LOGIC;
		strobe_p : IN std_logic;
		strobe_n : IN std_logic;
		data_p : IN std_logic_vector(3 downto 0);
		data_n : IN std_logic_vector(3 downto 0);          
		data_out : OUT std_logic_vector(3 downto 0);
		we : OUT std_logic
		);
END COMPONENT;
signal strip_data_in : std_logic_vector(23 downto 0) := (others =>'0');
signal strip_data_we : std_logic_vector(5 downto 0) := (others =>'0');
signal strip_rx_en : std_logic_vector(5 downto 0) := (others =>'0');
signal shutter_openSync : std_logic_vector(2 downto 0) := (others =>'0');
signal buf_full : std_logic_vector(5 downto 0) := (others =>'0');
type array6x1 is array(0 to 5) of std_logic_vector(0 downto 0);
signal buf_we : array6x1 := (others => (others =>'0'));
type array6x12 is array(0 to 5) of std_logic_vector(11 downto 0);
signal waddr : array6x12 := (others => (others =>'0'));
type array6x16 is array(0 to 5) of std_logic_vector(15 downto 0);
signal DO : array6x16 := (others => (others =>'0'));
begin
g_strip_rx : for i in 0 to 5 generate
	i_strip_rx: strip_rx PORT MAP(
		clk => clk,
		rx_en => strip_rx_en(i),
		shutter_open => shutter_openSync(2),
		strobe_p => strip_strobe_in_p(i),
		strobe_n => strip_strobe_in_n(i),
		data_p => strip_data_in_p(i*4+3 downto i*4),
		data_n => strip_data_in_n(i*4+3 downto i*4),
		data_out => strip_data_in(i*4+3 downto i*4),
		we => strip_data_we(i)
	);
	i_buf : BRAM_SDP_MACRO
   generic map (
      BRAM_SIZE => "18Kb", -- Target BRAM, "18Kb" or "36Kb" 
      DEVICE => "VIRTEX6", -- Target device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
      WRITE_WIDTH => 4,    -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
      READ_WIDTH => 16)     -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
    port map (
      DO => DO(i),         -- Output read data port, width defined by READ_WIDTH parameter
      DI => strip_data_in(i*4+3 downto i*4),         -- Input write data port, width defined by WRITE_WIDTH parameter
      RDADDR => ipb_addr(9 downto 0), -- Input read address, width defined by read port depth
      RDCLK => sysclk,   -- 1-bit input read clock
      RDEN => '1',     -- 1-bit input read port enable
      REGCE => '0',   -- 1-bit input read output register enable
      RST => '0',       -- 1-bit input reset 
      WE => buf_we(i),         -- Input write enable, width defined by write port depth
      WRADDR => waddr(i), -- Input write address, width defined by write port depth
      WRCLK => clk,   -- 1-bit input write clock
      WREN => strip_data_we(i)      -- 1-bit input write port enable
   );
end generate;
g_buf_we : for i in 0 to 5 generate
	buf_we(i)(0) <= not buf_full(i);
end generate;
process(clk,reset,rst_buffer)
begin
	if(reset = '1' or rst_buffer = '1')then
		waddr <= (others => (others =>'0'));
		buf_full <= (others =>'0');
	elsif(clk'event and clk = '1')then
		for i in 0 to 5 loop
			if(shutter_openSync(2) = '0')then
				waddr(i)(1 downto 0) <= "00";
			elsif(strip_data_we(i) = '1')then
				waddr(i)(1 downto 0) <= waddr(i)(1 downto 0) + 1;
			end if;
			if(strip_data_we(i) = '1' and waddr(i)(1 downto 0) = "11" and buf_full(i) = '0')then
				waddr(i)(11 downto 2) <= waddr(i)(11 downto 2) + 1;
				if(and_reduce(waddr(i)(11 downto 2)) = '1')then
					buf_full(i) <= '1';
				end if;
			end if;
		end loop;
	end if;
end process;
process(clk,reset)
begin
	if(reset = '1')then
		shutter_openSync <= (others =>'0');
	elsif(clk'event and clk = '1')then
		shutter_openSync <= shutter_openSync(1 downto 0) & shutter_open;
	end if;
end process;
process(ipb_clk,reset)
begin
	if(reset = '1')then
		strip_rx_en <= (others => '0');
	elsif(ipb_clk'event and ipb_clk = '1')then
		if(ipb_addr = x"3806" and ipb_write = '1' and ipb_strobe = '1')then
			strip_rx_en <= ipb_wdata(5 downto 0);
		end if;
	end if;
end process;
process(ipb_addr)
begin
	if(ipb_addr(15 downto 13) = "001")then
		case ipb_addr(12 downto 10) is
			when "000" => ipb_rdata <= x"0000" & DO(0);
			when "001" => ipb_rdata <= x"0000" & DO(1);
			when "010" => ipb_rdata <= x"0000" & DO(2);
			when "011" => ipb_rdata <= x"0000" & DO(3);
			when "100" => ipb_rdata <= x"0000" & DO(4);
			when "101" => ipb_rdata <= x"0000" & DO(5);
			when "110" =>
				case ipb_addr(2 downto 0) is
					when "000" => ipb_rdata <= x"00000" & waddr(0);
					when "001" => ipb_rdata <= x"00000" & waddr(1);
					when "010" => ipb_rdata <= x"00000" & waddr(2);
					when "011" => ipb_rdata <= x"00000" & waddr(3);
					when "100" => ipb_rdata <= x"00000" & waddr(4);
					when "101" => ipb_rdata <= x"00000" & waddr(5);
					when "110" => ipb_rdata <= x"000000" & "00" & strip_rx_en;
					when others => ipb_rdata <= (others => '0');
				end case;
			when others => ipb_rdata <= (others => '0');
		end case;
	else
		ipb_rdata <= (others => '0');
	end if;
end process;
end Behavioral;

