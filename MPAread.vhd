----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:39:40 06/03/2015 
-- Design Name: 
-- Module Name:    MPAread - Behavioral 
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
-- 6 MPAs are daisy chained, length for each MPA increased by one because of the dummy bit added at the MSB
-- row2 pixel ordering reversed in saving to counter_rbuf
library UNISIM;
use UNISIM.VComponents.all;
Library UNIMACRO;
use UNIMACRO.vcomponents.all;

entity MPAread is
    Port ( reset : in  STD_LOGIC;
					 sysclk : in  STD_LOGIC;
					 set_read_clk : in  STD_LOGIC;
					 acq_done : in  STD_LOGIC;
					 read_all : in  STD_LOGIC;
           buf_NUM : in  STD_LOGIC_VECTOR(1 downto 0);
					 read_clk_p : out  STD_LOGIC;
           read_clk_n : out  STD_LOGIC;
					 read_din_p : in  STD_LOGIC;
           read_din_n : in  STD_LOGIC;
					 read_dout_p : out  STD_LOGIC;
           read_dout_n : out  STD_LOGIC;
           read_done : out  STD_LOGIC;
           mem_p : in  STD_LOGIC_VECTOR(5 downto 0);
           mem_n : in  STD_LOGIC_VECTOR(5 downto 0);
           nMPA : in  STD_LOGIC_VECTOR(2 downto 0);
           ipb_clk : in  STD_LOGIC;
					 ipb_write : in std_logic;
					 ipb_strobe : in std_logic;
					 ipb_addr : in std_logic_vector(15 downto 0);
					 ipb_wdata : in std_logic_vector(31 downto 0);
           ipb_rdata : out  STD_LOGIC_VECTOR (31 downto 0));
end MPAread;

architecture Behavioral of MPAread is
constant N : integer := 3;
constant zero : std_logic_vector(31 downto 0) := (others =>'0');
type array5x32 is array(0 to 4) of bit_vector(31 downto 0);--0,11,110,1001,1100,1111,10010
constant counter_length_INIT : array5x32 := (x"0000002a",x"00000066",x"00000034",x"00000038",x"00000040");
type array6x1 is array (0 to 5) of std_logic_vector(0 downto 0);
type array6x32 is array (0 to 5) of std_logic_vector(31 downto 0);
signal mem_rbuf_DI : array6x1 := (others => (others =>'0'));
signal mem_rbuf_DO : array6x32 := (others => (others =>'0'));
signal read_clk : std_logic := '0';
signal read_din : std_logic := '0';
signal read_dout : std_logic := '0';
signal mem_in : std_logic_vector(5 downto 0) := (others =>'0');
signal nMPAsub1 : std_logic_vector(2 downto 0) := (others =>'0');
signal DIV : std_logic_vector(N downto 0) := (others =>'0');
signal cnt : std_logic_vector(N downto 0) := (others =>'0');
signal read_clk_o : std_logic := '0';
signal start : std_logic := '0';
signal GO : std_logic := '0';
signal GO_q : std_logic := '0';
signal send : std_logic := '0';
signal rec : std_logic := '0';
signal en_rec : std_logic := '0';
signal end_of_rec : std_logic := '0';
signal en_counter_rec : std_logic := '0';
signal en_send : std_logic := '0';
signal wbuf_we : std_logic := '0';
signal counter_pixel : std_logic := '0';
signal pixel48 : std_logic := '0';
signal wbuf_addra : std_logic_vector(9 downto 0) := (others =>'0');
signal wbuf_ra : std_logic_vector(13 downto 0) := (others =>'0');
signal wbuf_DOA : std_logic_vector(31 downto 0) := (others =>'0');
signal wbuf_DOB : std_logic_vector(31 downto 0) := (others =>'0');
signal counter_rbuf_DO : std_logic_vector(31 downto 0) := (others =>'0');
signal counter_rbuf_DI : std_logic_vector(0 downto 0) := (others =>'0');
signal counter_rbuf_wa : std_logic_vector(14 downto 0) := (others =>'0');
signal counter_length : std_logic_vector(4 downto 0) := (others =>'0');
signal mem_rbuf_wa : std_logic_vector(14 downto 0) := (others =>'0');
signal rbuf_wren : std_logic := '0';
signal counter_rbuf_we : std_logic_vector(0 downto 0) := (others =>'0');
signal mem_rbuf_we : std_logic_vector(0 downto 0) := (others =>'0');
attribute IOB : string;
attribute IOB of read_clk, read_dout, counter_rbuf_DI, mem_rbuf_DI : signal is "true";
begin
g_mem_in : for i in 0 to 5 generate
	i_mem_in_buf: IBUFDS generic map(DIFF_TERM => TRUE,IOSTANDARD => "LVDS_25") port map(i => mem_p(i), ib => mem_n(i), o => mem_in(i));
end generate;
i_read_din_buf: IBUFDS generic map(DIFF_TERM => TRUE,IOSTANDARD => "LVDS_25") port map(i => read_din_p, ib => read_din_n, o => read_din);
i_read_clk_obuf : OBUFDS generic map (IOSTANDARD => "LVDS_25") port map (O => read_clk_p, OB => read_clk_n, I => read_clk);
i_read_dout_obuf : OBUFDS generic map (IOSTANDARD => "LVDS_25") port map (O => read_dout_p, OB => read_dout_n, I => read_dout);
nMPAsub1 <= "000" when nMPA(2 downto 1) = "00" else nMPA - 1;
i_pixel48 : ROM256X1
   generic map (
      INIT => X"0000000000000000000000000020000010000008000004000002000001000000")
   port map (
      O => pixel48,   -- ROM output
      A0 => counter_rbuf_wa(5), -- ROM address[0]
      A1 => counter_rbuf_wa(6), -- ROM address[1]
      A2 => counter_rbuf_wa(7), -- ROM address[2]
      A3 => counter_rbuf_wa(8), -- ROM address[3]
      A4 => counter_rbuf_wa(9), -- ROM address[4]
      A5 => counter_rbuf_wa(10), -- ROM address[5]
      A6 => counter_rbuf_wa(11),  -- ROM address[6]
      A7 => counter_rbuf_wa(12)  -- ROM address[7]
   );
process(ipb_clk)
begin
	if(ipb_clk'event and ipb_clk = '1')then
		if(rec = '1')then
			if(pixel48 = '1' and counter_rbuf_wa(4 downto 0) = "11111")then
				counter_rbuf_DI(0) <= '0';
			else
				counter_rbuf_DI(0) <= read_din;
			end if;
			for i in 0 to 5 loop
				mem_rbuf_DI(i)(0) <= mem_in(i);
			end loop;
		end if;
		if(send = '1')then
			read_dout <= wbuf_DOB(conv_integer(wbuf_ra(4 downto 0)));
		end if;
		read_clk <= read_clk_o;
		if(acq_done = '1')then
			if(read_all = '1')then
				wbuf_ra <= "10000111111101";
			else
				wbuf_ra <= '0' & nMPAsub1 & "1100011101";
			end if;
		elsif(send = '1')then
			if(or_reduce(wbuf_ra(9 downto 0)) = '0')then
				wbuf_ra(9 downto 0) <= "1100011111";
				wbuf_ra(13 downto 10) <= wbuf_ra(13 downto 10) - 1;
			else
				wbuf_ra(9 downto 0) <= wbuf_ra(9 downto 0) - 1;
			end if;
		end if;
		if(acq_done = '1')then
--			mem_rbuf_wa <= buf_NUM & "1101011111111";
			mem_rbuf_wa <= buf_NUM & "1101100000000";
		elsif(rbuf_wren = '1')then
			mem_rbuf_wa <= mem_rbuf_wa - 1;
		end if;
		if(acq_done = '1')then
			counter_rbuf_wa <= buf_NUM & counter_length & nMPAsub1 & "11111";
		elsif(rbuf_wren = '1')then
			counter_rbuf_wa(12 downto 0) <= counter_rbuf_wa(12 downto 0) - 1;
		end if;
	end if;
end process;
g_counter_length: for i in 0 to 4 generate
  i_counter_length : ROM32X1
   generic map (
      INIT => counter_length_INIT(i))
   port map (
      O => counter_length(i),   -- ROM output
      A0 => nMPA(0), -- ROM address[0]
      A1 => nMPA(1), -- ROM address[1]
      A2 => nMPA(2), -- ROM address[2]
      A3 => '0', -- ROM address[3]
      A4 => '0'  -- ROM address[4]
   );
end generate;
process(ipb_clk,reset,set_read_clk)
begin
	if(reset = '1')then
		read_clk_o <= '0';
	elsif(set_read_clk = '1')then
		read_clk_o <= '1';
	elsif(ipb_clk'event and ipb_clk = '1')then
		if(acq_done = '1')then
			read_clk_o <= '0';
		elsif(start = '1')then
			read_clk_o <= '1';
		elsif(or_reduce(cnt(N downto 1)) = '0')then
			if(GO = '1')then
				read_clk_o <= not read_clk_o;
			end if;
		end if;
	end if;
end process;
i_start : SRL16 generic map(INIT => x"ffff")
   port map (
      Q => start,       -- SRL data output
      A0 => '1',     -- Select[0] input
      A1 => '0',     -- Select[1] input
      A2 => '0',     -- Select[2] input
      A3 => '0',     -- Select[3] input
      CLK => ipb_clk,   -- Clock input
      D => acq_done        -- SRL data input
   );
process(ipb_clk,reset)
begin
	if(reset = '1')then
		DIV   <= (others =>'0');
		cnt   <= (others =>'0');
		GO    <= '0';
		GO_q    <= '0';
		send     <= '0';
		rec      <= '0';
		en_rec <= '0';
		en_send <= '0';
		rbuf_wren <= '0';
		counter_pixel <= '1';
		read_done <= '0';
	elsif(ipb_clk'event and ipb_clk = '1')then
		if(ipb_addr = x"9c02" and ipb_write = '1' and ipb_strobe = '1')then
			DIV <= ipb_wdata(N downto 0);
		end if;
		if(start = '1')then
			GO <= '1';
		elsif(or_reduce(cnt(N downto 1)) = '0' and en_send = '0')then
			GO <= '0';
		end if;
		GO_q <= GO;
		if(start = '1')then
			cnt <= DIV;
		elsif(GO = '1' or or_reduce(cnt(N downto 1)) = '1')then
			if(or_reduce(cnt(N downto 1)) = '0')then
				cnt <= DIV;
			else 
				cnt <= cnt - 1;
			end if;
		end if;
		if(start = '1')then
			counter_rbuf_we <= "1";
		elsif(or_reduce(counter_rbuf_wa(12 downto 0)) = '0' and rbuf_wren = '1')then
			counter_rbuf_we <= "0";
		end if;
		if(start = '1')then
			en_rec <= '1';
		elsif(or_reduce(cnt(N downto 1)) = '0' and en_send = '0' and read_clk_o = '1')then
			en_rec <= '0';
		end if;
		if(start = '1')then
			en_send <= '1';
		elsif(or_reduce(cnt(N downto 1)) = '0' and or_reduce(wbuf_ra) = '0' and read_clk_o = '0')then
			en_send <= '0';
		end if;
		if(acq_done ='1' or (or_reduce(cnt(N downto 1)) = '0' and en_rec = '1' and read_clk_o = '1'))then
			rec <= '1';
		else
			rec <= '0';
		end if;
		if(or_reduce(cnt(N downto 1)) = '0' and en_send = '1' and read_clk_o = '0')then
			send <= '1';
		else
			send <= '0';
		end if;
		rbuf_wren <= rec;
		read_done <= not GO and GO_q;
		if(start = '1')then
			counter_pixel <= '1';
		elsif(send = '1' and wbuf_ra(4 downto 0) = "00000")then
			if(wbuf_ra(9 downto 5) = "00001")then
				counter_pixel <= '0';
			else
				counter_pixel <= '1';
			end if;
		end if;
	end if;
end process;
g_wbuf : for i in 0 to 31 generate
   i_wbuf : RAM32X1D
   generic map (
      INIT => X"ffff00ff") -- Initial contents of RAM
   port map (
      DPO => wbuf_DOB(i),     -- Read-only 1-bit data output
      SPO => wbuf_DOA(i),     -- R/W 1-bit data output
      A0 => ipb_addr(0),       -- R/W address[0] input bit
      A1 => ipb_addr(1),       -- R/W address[1] input bit
      A2 => ipb_addr(2),       -- R/W address[2] input bit
      A3 => '0',       -- R/W address[3] input bit
      A4 => '0',       -- R/W address[4] input bit
      D => ipb_wdata(i),         -- Write 1-bit data input
      DPRA0 => wbuf_ra(10), -- Read-only address[0] input bit
      DPRA1 => wbuf_ra(11), -- Read-only address[1] input bit
      DPRA2 => wbuf_ra(12), -- Read-only address[2] input bit
      DPRA3 => counter_pixel, -- Read-only address[3] input bit
      DPRA4 => '0', -- Read-only address[4] input bit
      WCLK => ipb_clk,   -- Write clock input
      WE => wbuf_we        -- Write enable input
   );
end generate;
wbuf_we <= '1' when ipb_addr(15 downto 4) = x"9c1" and ipb_addr(3) = '0' and ipb_write = '1' and ipb_strobe = '1' else '0';
i_counter_rbuf : BRAM_SDP_MACRO
   generic map (
      BRAM_SIZE => "36Kb", -- Target BRAM, "18Kb" or "36Kb" 
      DEVICE => "VIRTEX6", -- Target device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
      WRITE_WIDTH => 1,    -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
      READ_WIDTH => 32)     -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
    port map (
      DO => counter_rbuf_DO,         -- Output read data port, width defined by READ_WIDTH parameter
      DI => counter_rbuf_DI,         -- Input write data port, width defined by WRITE_WIDTH parameter
      RDADDR => ipb_addr(9 downto 0), -- Input read address, width defined by read port depth
      RDCLK => sysclk,   -- 1-bit input read clock
      RDEN => '1',     -- 1-bit input read port enable
      REGCE => '0',   -- 1-bit input read output register enable
      RST => '0',       -- 1-bit input reset 
      WE => counter_rbuf_we,         -- Input write enable, width defined by write port depth
      WRADDR => counter_rbuf_wa, -- Input write address, width defined by write port depth
      WRCLK => ipb_clk,   -- 1-bit input write clock
      WREN => rbuf_wren      -- 1-bit input write port enable
   );
g_mem_rbuf : for i in 0 to 5 generate
	i_mem_rbuf : BRAM_SDP_MACRO
   generic map (
      BRAM_SIZE => "36Kb", -- Target BRAM, "18Kb" or "36Kb" 
      DEVICE => "VIRTEX6", -- Target device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
      WRITE_WIDTH => 1,    -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
      READ_WIDTH => 32)     -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
    port map (
      DO => mem_rbuf_DO(i),         -- Output read data port, width defined by READ_WIDTH parameter
      DI => mem_rbuf_DI(i),         -- Input write data port, width defined by WRITE_WIDTH parameter
      RDADDR => ipb_addr(9 downto 0), -- Input read address, width defined by read port depth
      RDCLK => sysclk,   -- 1-bit input read clock
      RDEN => '1',     -- 1-bit input read port enable
      REGCE => '0',   -- 1-bit input read output register enable
      RST => '0',       -- 1-bit input reset 
      WE => mem_rbuf_we,         -- Input write enable, width defined by write port depth
      WRADDR => mem_rbuf_wa, -- Input write address, width defined by write port depth
      WRCLK => ipb_clk,   -- 1-bit input write clock
      WREN => rbuf_wren      -- 1-bit input write port enable
   );
end generate;
mem_rbuf_we(0) <= read_all;
process(ipb_addr)
begin
	if(ipb_addr(15 downto 13) = "100")then
		case ipb_addr(12 downto 10) is
			when "000" => ipb_rdata <= mem_rbuf_DO(0);
			when "001" => ipb_rdata <= mem_rbuf_DO(1);
			when "010" => ipb_rdata <= mem_rbuf_DO(2);
			when "011" => ipb_rdata <= mem_rbuf_DO(3);
			when "100" => ipb_rdata <= mem_rbuf_DO(4);
			when "101" => ipb_rdata <= mem_rbuf_DO(5);
			when "110" => ipb_rdata <= counter_rbuf_DO;
			when "111" =>
				if(ipb_addr(9 downto 4) = "000000")then
					case ipb_addr(3 downto 0) is
						when x"2" => ipb_rdata <= zero(31 downto N+1) & DIV;
						when x"3" => ipb_rdata <= zero(31 downto 14) & wbuf_ra;
						when x"4" => ipb_rdata <= zero(31 downto 15) & counter_rbuf_wa;
						when x"5" => ipb_rdata <= zero(31 downto 15) & mem_rbuf_wa;
						when others => ipb_rdata <= (others => '0');
					end case;
				elsif(ipb_addr(9 downto 4) = "000001")then
					ipb_rdata <= wbuf_DOA;
				else
					ipb_rdata <= (others => '0');
				end if;
			when others =>
				ipb_rdata <= (others => '0');
		end case;
	else
		ipb_rdata <= (others => '0');
	end if;
end process;
end Behavioral;

