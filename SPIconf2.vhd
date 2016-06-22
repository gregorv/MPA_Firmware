----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:39:40 06/02/2015 
-- Design Name: 
-- Module Name:    SPIconf - Behavioral 
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
-- June-3-2015
-- SPI mode fixed as 1
-- 6 MPAs are daisy chained, length for each MPA increased by one because of the dummy bit added at the LSB
library UNISIM;
use UNISIM.VComponents.all;
Library UNIMACRO;
use UNIMACRO.vcomponents.all;

entity SPIconf is
    Port ( reset : in  STD_LOGIC;
					 sysclk : in  STD_LOGIC;
					 conf_en_p : out  STD_LOGIC;
           conf_en_n : out  STD_LOGIC;
					 conf_clk_p : out  STD_LOGIC;
           conf_clk_n : out  STD_LOGIC;
					 conf_din_p : in  STD_LOGIC;
           conf_din_n : in  STD_LOGIC;
					 conf_dout_p : out  STD_LOGIC;
           conf_dout_n : out  STD_LOGIC;
           conf_done : out  STD_LOGIC;
					 nMPA : out std_logic_vector(2 downto 0);
           ipb_clk : in  STD_LOGIC;
					 ipb_write : in std_logic;
					 ipb_strobe : in std_logic;
					 ipb_addr : in std_logic_vector(15 downto 0);
					 ipb_wdata : in std_logic_vector(31 downto 0);
           ipb_rdata : out  STD_LOGIC_VECTOR (31 downto 0));
end SPIconf;

architecture Behavioral of SPIconf is
constant N : integer := 3;
signal MODE : std_logic_vector(1 downto 0) := "01";
constant zero : std_logic_vector(31 downto 0) := (others =>'0');
signal conf_en : std_logic := '0';
signal conf_en_q : std_logic := '0';
signal conf_clk : std_logic := '0';
signal conf_din : std_logic := '0';
signal conf_dout : std_logic := '0';
signal nMPA_i : std_logic_vector(2 downto 0) := "110";
signal MPA_cnt : std_logic_vector(2 downto 0) := (others =>'0');
signal DIV : std_logic_vector(N downto 0) := (others =>'0');
signal cnt : std_logic_vector(N downto 0) := (others =>'0');
signal CLKCONF_o : std_logic := '0';
signal start : std_logic := '0';
signal GO : std_logic := '0';
signal GO_q : std_logic := '0';
signal send : std_logic := '0';
signal rec : std_logic := '0';
signal en_rec : std_logic := '0';
signal en_send : std_logic := '0';
signal toggle : std_logic := '0';
signal toggle_q : std_logic := '0';
--signal strobe : std_logic_vector(2 downto 0) := (others =>'0');
signal wbuf_we : std_logic_vector(3 downto 0) := (others =>'0');
signal wbuf_addra : std_logic_vector(9 downto 0) := (others =>'0');
signal wbuf_ra : std_logic_vector(14 downto 0) := (others =>'0');
signal wbuf_DOA : std_logic_vector(31 downto 0) := (others =>'0');
signal wbuf_DOB : std_logic_vector(0 downto 0) := (others =>'0');
signal rbuf_DO : std_logic_vector(31 downto 0) := (others =>'0');
signal rbuf_DI : std_logic_vector(0 downto 0) := (others =>'0');
signal rbuf_wa : std_logic_vector(14 downto 0) := (others =>'0');
signal rbuf_we : std_logic := '0';
attribute IOB : string;
attribute IOB of conf_en, conf_clk, conf_dout, rbuf_DI : signal is "true";
begin
nMPA <= nMPA_i;
i_conf_din_buf: IBUFDS generic map(DIFF_TERM => TRUE,IOSTANDARD => "LVDS_25") port map(i => conf_din_p, ib => conf_din_n, o => conf_din);
i_conf_en_obuf : OBUFDS generic map (IOSTANDARD => "LVDS_25") port map (O => conf_en_p, OB => conf_en_n, I => conf_en);
i_conf_clk_obuf : OBUFDS generic map (IOSTANDARD => "LVDS_25") port map (O => conf_clk_p, OB => conf_clk_n, I => conf_clk);
i_conf_dout_obuf : OBUFDS generic map (IOSTANDARD => "LVDS_25") port map (O => conf_dout_p, OB => conf_dout_n, I => conf_dout);
process(ipb_clk)
begin
	if(ipb_clk'event and ipb_clk = '1')then
		if(rec = '1')then
			rbuf_DI(0) <= conf_din;
		end if;
		if(send = '1')then
			conf_dout <= wbuf_DOB(0);
		end if;
		conf_clk <= CLKCONF_o;
		if(ipb_addr = x"6000" and ipb_write = '1' and ipb_strobe = '1')then
			wbuf_ra <= ipb_wdata(4 downto 0) & "1100010011";
		elsif(send = '1')then
			if(wbuf_ra(4 downto 0) = "00000")then
				if(wbuf_ra(9 downto 5) = "00000")then
					wbuf_ra(9 downto 5) <= "11000";
					wbuf_ra(14 downto 10) <= wbuf_ra(14 downto 10) - 1;
				else
					wbuf_ra(9 downto 5) <= wbuf_ra(9 downto 5) - 1;
				end if;
				if(wbuf_ra(9 downto 6) = x"0")then
					if(wbuf_ra(5) = '1')then
						wbuf_ra(4 downto 0) <= "11111";
					else
						wbuf_ra(4 downto 0) <= "10100";
					end if;
				else
					wbuf_ra(4 downto 0) <= "10011";
				end if;
			else
				wbuf_ra(4 downto 0) <= wbuf_ra(4 downto 0) - 1;
			end if;
		end if;
		if(start = '1' or rbuf_we = '1')then
			rbuf_wa <= wbuf_ra;
		end if;
		if(start = '1')then
			MPA_cnt <= nMPA_i;
		elsif(send = '1' and wbuf_ra(9 downto 0) = "1100010100")then
			MPA_cnt <= MPA_cnt - 1;
		end if;
	end if;
end process;
process(ipb_clk,reset)
begin
	if(reset = '1')then
		DIV   <= (others =>'0');
		nMPA_i   <= "110";
		cnt   <= (others =>'0');
		start    <= '0';
		GO    <= '0';
		GO_q    <= '0';
		CLKCONF_o <= '0';
		send     <= '0';
		rec      <= '0';
		en_rec <= '0';
		en_send <= '0';
		rbuf_we <= '0';
		conf_en <= '0';
		conf_en_q <= '0';
		conf_done <= '0';
	elsif(ipb_clk'event and ipb_clk = '1')then
		if(ipb_addr = x"6000" and ipb_write = '1' and ipb_strobe = '1')then
			start <= '1';
		else
			start <= '0';
		end if;
		if(ipb_addr = x"6001" and ipb_write = '1' and ipb_strobe = '1')then
			nMPA_i <= ipb_wdata(2 downto 0);
		end if;
		if(ipb_addr = x"6002" and ipb_write = '1' and ipb_strobe = '1')then
			DIV <= ipb_wdata(N downto 0);
		end if;
		if(start = '1')then
			GO <= '1';
		elsif(or_reduce(cnt(N downto 1)) = '0' and en_send = '0' and (MODE(0) = '1' or en_rec = '0'))then
			GO <= '0';
		end if;
		GO_q <= GO;
		if(start = '1' or (GO = '0' and GO_q = '1'))then
			cnt <= DIV;
		elsif(GO = '1' or or_reduce(cnt(N downto 1)) = '1')then
			if(or_reduce(cnt(N downto 1)) = '0')then
				cnt <= DIV;
			else 
				cnt <= cnt - 1;
			end if;
		end if;
		if(start = '1')then
			en_rec <= '1';
		elsif(or_reduce(cnt(N downto 1)) = '0' and en_send = '0' and xor_reduce(MODE & CLKCONF_o) = '0')then
			en_rec <= '0';
		end if;
		if(start = '1')then
			en_send <= '1';
		elsif(or_reduce(MPA_cnt(2 downto 1)) = '0' and or_reduce(cnt(N downto 1)) = '0' and wbuf_ra(9 downto 0) = "1100010100" and xor_reduce(MODE & CLKCONF_o) = '1')then
			en_send <= '0';
		end if;
		if(or_reduce(cnt(N downto 1)) = '0')then
			if(GO = '0')then
				CLKCONF_o <= MODE(1);
			else
				CLKCONF_o <= not CLKCONF_o;
			end if;
		end if;
		if(or_reduce(cnt(N downto 1)) = '0' and en_rec = '1' and xor_reduce(MODE & CLKCONF_o) = '0')then
			rec <= '1';
		else
			rec <= '0';
		end if;
		if(start = '1' and MODE(0) = '0')then
			send <= '1';
		elsif(or_reduce(cnt(N downto 1)) = '0' and en_send = '1' and xor_reduce(MODE & CLKCONF_o) = '1')then
			send <= '1';
		else
			send <= '0';
		end if;
		rbuf_we <= rec;
		conf_en <= start or GO or GO_q or or_reduce(cnt(N downto 1));
		conf_en_q <= conf_en;
		conf_done <= not conf_en and conf_en_q;
	end if;
end process;
process(ipb_clk,reset)
begin
	if(reset = '1')then
		toggle <= '0';
	elsif(ipb_clk'event and ipb_clk = '1')then
		toggle <= not toggle;
	end if;
end process;
process(sysclk,reset)
begin
	if(reset = '1')then
		toggle_q <= '0';
--		strobe <= (others => '0');
		wbuf_we <= (others => '0');
	elsif(sysclk'event and sysclk = '1')then
		toggle_q <= toggle;
--		strobe <= strobe(1 downto 0) & (toggle_q xor toggle);
--		if(ipb_addr(15 downto 10) = "011001" and ipb_write = '1' and ipb_strobe = '1' and strobe(2) = '1')then
		if(ipb_addr(15 downto 10) = "011001" and ipb_write = '1' and ipb_strobe = '1' and toggle /= toggle_q)then
			wbuf_we <= x"f";
		else
			wbuf_we <= x"0";
		end if;		
	end if;
end process;
i_wbuf : BRAM_TDP_MACRO
   generic map (
      BRAM_SIZE => "36Kb", -- Target BRAM, "18Kb" or "36Kb" 
      DEVICE => "VIRTEX6", -- Target device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
      READ_WIDTH_A => 32,   -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      READ_WIDTH_B => 1,   -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      WRITE_WIDTH_A => 32, -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      WRITE_WIDTH_B => 1) -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
    port map (
      DOA => wbuf_DOA,       -- Output port-A data, width defined by READ_WIDTH_A parameter
      DOB => wbuf_DOB,       -- Output port-B data, width defined by READ_WIDTH_B parameter
      ADDRA => ipb_addr(9 downto 0),   -- Input port-A address, width defined by Port A depth
      ADDRB => wbuf_ra,   -- Input port-B address, width defined by Port B depth
      CLKA => sysclk,     -- 1-bit input port-A clock
      CLKB => ipb_clk,     -- 1-bit input port-B clock
      DIA => ipb_wdata,       -- Input port-A data, width defined by WRITE_WIDTH_A parameter
      DIB => "0",       -- Input port-B data, width defined by WRITE_WIDTH_B parameter
      ENA => '1',       -- 1-bit input port-A enable
      ENB => '1',       -- 1-bit input port-B enable
      REGCEA => '0', -- 1-bit input port-A output register enable
      REGCEB => '0', -- 1-bit input port-B output register enable
      RSTA => '0',     -- 1-bit input port-A reset
      RSTB => '0',     -- 1-bit input port-B reset
      WEA => wbuf_we,       -- Input port-A write enable, width defined by Port A depth
      WEB => "0"       -- Input port-B write enable, width defined by Port B depth
   );
i_rbuf : BRAM_SDP_MACRO
   generic map (
      BRAM_SIZE => "36Kb", -- Target BRAM, "18Kb" or "36Kb" 
      DEVICE => "VIRTEX6", -- Target device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
      WRITE_WIDTH => 1,    -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
      READ_WIDTH => 32)     -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
    port map (
      DO => rbuf_DO,         -- Output read data port, width defined by READ_WIDTH parameter
      DI => rbuf_DI,         -- Input write data port, width defined by WRITE_WIDTH parameter
      RDADDR => ipb_addr(9 downto 0), -- Input read address, width defined by read port depth
      RDCLK => sysclk,   -- 1-bit input read clock
      RDEN => '1',     -- 1-bit input read port enable
      REGCE => '0',   -- 1-bit input read output register enable
      RST => '0',       -- 1-bit input reset 
      WE => "1",         -- Input write enable, width defined by write port depth
      WRADDR => rbuf_wa, -- Input write address, width defined by write port depth
      WRCLK => ipb_clk,   -- 1-bit input write clock
      WREN => rbuf_we      -- 1-bit input write port enable
   );
process(ipb_addr)
begin
	if(ipb_addr(15 downto 4) = x"600")then
		case ipb_addr(3 downto 0) is
			when x"0" => ipb_rdata <= zero(31 downto 1) & GO;
			when x"1" => ipb_rdata <= zero(31 downto 3) & nMPA_i;
			when x"2" => ipb_rdata <= zero(31 downto N+1) & DIV;
			when x"3" => ipb_rdata <= zero(31 downto 15) & wbuf_ra;
			when x"4" => ipb_rdata <= zero(31 downto 15) & rbuf_wa;
			when others => ipb_rdata <= (others => '0');
		end case;
	elsif(ipb_addr(15 downto 10) = "011001")then
		ipb_rdata <= wbuf_DOA;
	elsif(ipb_addr(15 downto 10) = "011010")then
		ipb_rdata <= rbuf_DO;
	else
		ipb_rdata <= (others => '0');
	end if;
end process;
end Behavioral;

