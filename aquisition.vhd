----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:23:25 05/27/2015 
-- Design Name: 
-- Module Name:    calib - Behavioral 
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

entity acquisition is
    Port ( clk : in  STD_LOGIC; -- 320MHz clock
           reset : in  STD_LOGIC;
           test_beam : in  STD_LOGIC;
					 calibration : in  STD_LOGIC;
           beam_trig : in  STD_LOGIC := '0';
           beam_halt : in  STD_LOGIC;
           start : in  STD_LOGIC;
					 shutter_delay : in std_logic_vector(3 downto 0) := (others => '0');
					 hitOR_p : in  STD_LOGIC;
           hitOR_n : in  STD_LOGIC;
           set_read_clk : out  STD_LOGIC;
					 done : out  STD_LOGIC;
					 shutter_p : out  STD_LOGIC;
           shutter_n : out  STD_LOGIC;
           shutter_open : out  STD_LOGIC;
           en_strip_out : out  STD_LOGIC;
					 calstrobe_p : out  STD_LOGIC;
           calstrobe_n : out  STD_LOGIC;
           ipb_clk : in  STD_LOGIC;
					 ipb_write : in std_logic;
					 ipb_strobe : in std_logic;
					 ipb_addr : in std_logic_vector(15 downto 0);
					 ipb_wdata : in std_logic_vector(31 downto 0);
           ipb_rdata : out  STD_LOGIC_VECTOR (31 downto 0);
			  tel_busy_p : IN STD_LOGIC := '0';
			  tel_busy_n : IN STD_LOGIC := '1'
			  );
end acquisition;

architecture Behavioral of acquisition is
constant zero : std_logic_vector(31 downto 0) := (others =>'0');
constant idle : std_logic_vector(2 downto 0) := "000";
constant init : std_logic_vector(2 downto 0) := "001";
constant up : std_logic_vector(2 downto 0) := "010";
constant down : std_logic_vector(2 downto 0) := "011";
constant wait4hit : std_logic_vector(2 downto 0) := "101";
constant fin : std_logic_vector(2 downto 0) := "100";
signal calstrobe : std_logic := '0';
signal calstrobe_o : std_logic_vector(1 downto 0) := (others =>'0');
signal beam_trig_dl : std_logic := '0';
signal beam_trig_dl_q : std_logic := '0';
signal shutter : std_logic := '0';
signal shutter_dl : std_logic := '0';
signal shutter_o : std_logic_vector(1 downto 0) := (others =>'0');
signal hitOR : std_logic := '0';
signal ipbus_calib : std_logic := '0';
--signal ipbus_start : std_logic := '0';
--signal calibration : std_logic := '0';
signal done_i : std_logic := '0';
signal done_sync : std_logic_vector(1 downto 0) := (others =>'0');
signal start_sync : std_logic_vector(4 downto 0) := (others =>'0');
signal tel_busy_sync : std_logic_vector(4 downto 0) := (others =>'0');
signal tel_busy_stop : std_logic_vector(4 downto 0) := (others =>'0');
signal start_while_busy : std_logic := '0';
signal HITOR_sync : std_logic_vector(4 downto 0) := (others =>'0');
signal state : std_logic_vector(2 downto 0) := idle;
signal npulse : std_logic_vector(15 downto 0) := x"0001";
signal pulse_len : std_logic_vector(15 downto 0) := x"0100";
signal pulse_dist : std_logic_vector(15 downto 0) := x"0001";
signal cnt_npulse : std_logic_vector(15 downto 0) := (others =>'0');
signal cnt_npulse_one : std_logic := '0';
signal cnt_del : std_logic_vector(15 downto 0) := (others =>'0');
signal cnt_del_zero : std_logic := '0';
signal init_del : std_logic_vector(15 downto 0) := x"0001";
signal time_out : std_logic_vector(31 downto 0) := (others =>'1');
signal time_cntr : std_logic_vector(31 downto 0) := (others =>'0');
signal time_cntr_high : std_logic := '0';
signal time_outed : std_logic := '0';
signal beam_trig_sync : std_logic_vector(4 downto 0) := (others =>'0');
signal beam_halt_sync : std_logic_vector(4 downto 0) := (others =>'0');
attribute IOB : string;
attribute IOB of calstrobe_o, shutter_o : signal is "true";

signal tel_busy : std_logic := '0';

begin
i_hitOR_buf: IBUFDS generic map(DIFF_TERM => TRUE,IOSTANDARD => "LVDS_25") port map(i => hitOR_p, ib => hitOR_n, o => hitOR);
i_calstrobe_obuf : OBUFDS generic map (IOSTANDARD => "LVDS_25") port map (O => calstrobe_p, OB => calstrobe_n, I => calstrobe_o(1));
i_shutter_obuf : OBUFDS generic map (IOSTANDARD => "LVDS_25") port map (O => shutter_p, OB => shutter_n, I => shutter_o(1));

i_telBusy_ibuf : IBUFDS generic map (DIFF_TERM => TRUE, IOSTANDARD => "LVDS_25") port map (i => tel_busy_p, ib => tel_busy_n, o => tel_busy );

shutter_open <= shutter;
i_beam_trig_dl : SRL16
   port map (
      Q => beam_trig_dl,       -- SRL data output
      A0 => shutter_delay(0),     -- Select[0] input
      A1 => shutter_delay(1),     -- Select[1] input
      A2 => shutter_delay(2),     -- Select[2] input
      A3 => shutter_delay(3),     -- Select[3] input
      CLK => clk,   -- Clock input
      D => beam_trig_sync(4)        -- SRL data input
   );
process(clk,reset)
begin
	if(reset = '1')then
		beam_trig_dl_q <= '0';
		beam_trig_sync <= (others => '0');
		beam_halt_sync <= (others => '0');
		start_sync <= (others => '0');
		tel_busy_sync <= (others => '0');
		tel_busy_stop <= (others => '0');
		start_while_busy <= '0';
		HITOR_sync <= (others => '0');
		set_read_clk <= '0';
		state <= idle;
		done_i <= '0';
		cnt_npulse <= (others => '0');
		cnt_del <= (others => '0');
		cnt_del_zero <= '0';
		calstrobe_o <= (others => '0');
		calstrobe <= '0';
		shutter_o <= (others => '0');
		shutter <= '0';
		time_cntr <= (others => '1');
		time_outed <= '0';
		en_strip_out <= '0';
	elsif(clk'event and clk = '1')then
		beam_trig_dl_q <= beam_trig_dl;
		beam_trig_sync(3 downto 0) <= beam_trig_sync(2 downto 0) & beam_trig;
		beam_trig_sync(4) <= not beam_trig_sync(3) and beam_trig_sync(2);
		beam_halt_sync(3 downto 0) <= beam_halt_sync(2 downto 0) & beam_halt;
		beam_halt_sync(4) <= not beam_halt_sync(3) and beam_halt_sync(2);
		start_sync(3 downto 0) <= start_sync(2 downto 0) & start;
		start_sync(4) <= start_sync(3) and not start_sync(2);
		tel_busy_sync(3 downto 0) <= tel_busy_sync(2 downto 0) & tel_busy;
		tel_busy_sync(4) <= not tel_busy_sync(3) and tel_busy_sync(2);
		tel_busy_stop(3 downto 0) <= tel_busy_stop(2 downto 0) & tel_busy;
		tel_busy_stop(4) <= tel_busy_stop(3) and not tel_busy_stop(2); -- stop busy
		HITOR_sync(3 downto 0) <= HITOR_sync(2 downto 0) & HITOR;
		HITOR_sync(4) <= not HITOR_sync(3) and HITOR_sync(2);
		calstrobe_o <= calstrobe_o(0) & calstrobe;
		shutter_o <= shutter_o(0) & shutter;
		if(shutter = '0')then
			time_cntr <= time_out;
		-- counter during open shutter
		elsif(or_reduce(time_cntr(3 downto 0)) = '1' or time_cntr_high = '1')then
			time_cntr(3 downto 0) <= time_cntr(3 downto 0) - 1;
			if(time_cntr(3 downto 0) = x"0")then
				time_cntr(31 downto 4) <= time_cntr(31 downto 4) - 1;
			end if;
		end if;
		time_cntr_high <= or_reduce(time_cntr(31 downto 4));
		if(shutter = '0')then
			time_outed <= '0';
		elsif((time_cntr_high = '0' and time_cntr(3 downto 0) = x"1") or beam_halt_sync(4) = '1')then
			time_outed <= '1';
		end if;
		case state is
			when idle =>
				done_i <= '0';
				calstrobe <= '0';
				set_read_clk <= '0';
				cnt_del_zero <= '0';
				-- if time out occurs jump to wait4hit which will close the shiutter and start the readout
				if(time_outed = '1' and shutter = '1')then
					state <= wait4hit;
				-- open shutter if - start_acq from MPA_top is 1 and telscope is not busy or
				--                 - we got the start signal (start_while_busy) and the telescope is not busy anymore
				elsif((test_beam = '0' and start_sync(4) = '1' and tel_busy_sync(4) = '0')
						or (test_beam = '0' and start_while_busy = '1' and tel_busy_stop(4) = '1')
						or (test_beam = '1' and time_outed = '0' and beam_trig_dl_q = '1'))then
					start_while_busy <= '0';
					shutter <= '1';
					if(calibration = '0')then
						state <= wait4hit;
					else
						state <= init;
						cnt_npulse <= npulse;
						if(npulse = x"0001")then
							cnt_npulse_one <= '1';
						else
							cnt_npulse_one <= '0';
						end if;
						cnt_del <= init_del;
						if(init_del = x"0001" or test_beam = '1')then
							cnt_del_zero <= '1';
						else
							cnt_del_zero <= '0';
						end if;
					end if;
				-- we got the start signal but the telescope is busy -> start as soon as the telescope is not busy anymore
				elsif(test_beam = '0' and start_sync(4) = '1' and tel_busy_sync(4) = '1')then
					start_while_busy <= '1';
				end if;
			when init =>
				cnt_del <= cnt_del - 1;
				if(cnt_del_zero = '1')then
					state <= up;
					cnt_del <= pulse_len;
					if(pulse_len = x"0001")then
						cnt_del_zero <= '1';
					else
						cnt_del_zero <= '0';
					end if;
					calstrobe <= '1';
				else
					if(cnt_del = x"0002")then
						cnt_del_zero <= '1';
					else
						cnt_del_zero <= '0';
					end if;
				end if;
			when up =>
				cnt_del <= cnt_del - 1;
				if(cnt_del_zero = '1')then
					if(test_beam = '0')then
						state <= down;
					elsif(time_outed = '1')then
						state <= wait4hit;
					else
						state <= idle;
					end if;
					calstrobe <= '0';
					cnt_del <= pulse_dist;
					if(pulse_dist = x"0001")then
						cnt_del_zero <= '1';
					else
						cnt_del_zero <= '0';
					end if;
				else
					if(cnt_del = x"0002")then
						cnt_del_zero <= '1';
					else
						cnt_del_zero <= '0';
					end if;
				end if;
			when down =>
				cnt_del <= cnt_del - 1;
				if(cnt_del_zero = '1')then
					cnt_del_zero <= '0';
					cnt_npulse <= cnt_npulse - 1;
					if(cnt_npulse = x"0002")then
						cnt_npulse_one <= '1';
					else
						cnt_npulse_one <= '0';
					end if;
					if(cnt_npulse_one = '1')then
						state <= fin;
						cnt_del <= x"000f";
						set_read_clk <= '1';
					else
						state <= up;
						cnt_del <= pulse_len;
						if(pulse_len = x"0001")then
							cnt_del_zero <= '1';
						end if;
						calstrobe <= '1';
					end if;
				else
					if(cnt_del = x"0002")then
						cnt_del_zero <= '1';
					else
						cnt_del_zero <= '0';
					end if;
				end if;
			when wait4hit =>
				if(shutter = '0')then
					state <= idle;
				-- Start readout if shutter exceeds shutter duration or telescope is busy
				elsif((test_beam = '0' and HITOR_sync(4) = '1') or time_outed = '1' or tel_busy = '1')then
					state <= fin;
					cnt_del <= x"000f";
					set_read_clk <= '1';
				end if;
			when others => --including "fin"
				set_read_clk <= '0';
				cnt_del <= cnt_del - 1;
				if(cnt_del_zero = '1')then
					cnt_del_zero <= '0';
					done_i <= '1';
					state <= idle;
					shutter <= '0';
				else
					if(cnt_del = x"0002")then
						cnt_del_zero <= '1';
					else
						cnt_del_zero <= '0';
					end if;
				end if;
		end case;
		if(state = fin)then
			en_strip_out <= '0';
		elsif(shutter_dl = '1')then
			en_strip_out <= '1';
		end if;
	end if;
end process;
i_shutter_dl : SRL16
   port map (
      Q => shutter_dl,       -- SRL data output
      A0 => '1',     -- Select[0] input
      A1 => '1',     -- Select[1] input
      A2 => '1',     -- Select[2] input
      A3 => '1',     -- Select[3] input
      CLK => clk,   -- Clock input
      D => shutter        -- SRL data input
   );
	
-- IPBus
	
process(ipb_clk,reset,done_i)
begin
	if(reset = '1')then
		done_sync <= (others =>'0');
	elsif(done_i = '1')then
		done_sync <= (others =>'1');
	elsif(ipb_clk'event and ipb_clk = '1')then
		done_sync <= done_sync(0) & '0';
	end if;
end process;
process(ipb_clk)
begin
	if(ipb_clk'event and ipb_clk = '1')then
		if(ipb_addr = x"0201" and ipb_write = '1' and ipb_strobe = '1')then
			if(ipb_wdata(15 downto 0) = x"0000")then
				npulse <= x"0001";
			else
				npulse <= ipb_wdata(15 downto 0);
			end if;
		end if;
		if(ipb_addr = x"0202" and ipb_write = '1' and ipb_strobe = '1')then
			if(ipb_wdata(15 downto 0) = x"0000")then
				pulse_len <= x"0001";
			else
				pulse_len <= ipb_wdata(15 downto 0);
			end if;
		end if;
		if(ipb_addr = x"0203" and ipb_write = '1' and ipb_strobe = '1')then
			if(ipb_wdata(15 downto 0) = x"0000")then
				pulse_dist <= x"0001";
			else
				pulse_dist <= ipb_wdata(15 downto 0);
			end if;
		end if;
		if(ipb_addr = x"0204" and ipb_write = '1' and ipb_strobe = '1')then
			if(ipb_wdata(15 downto 0) = x"0000")then
				init_del <= x"0001";
			else
				init_del <= ipb_wdata(15 downto 0);
			end if;
		end if;
		if(ipb_addr = x"0205" and ipb_write = '1' and ipb_strobe = '1')then
			if(ipb_wdata = x"00000000")then
				time_out <= x"00000001";
			else
				time_out <= ipb_wdata(31 downto 0);
			end if;
		end if;
	end if;
end process;
process(ipb_clk,reset)
begin
	if(reset = '1')then
		done <= '0';
	elsif(ipb_clk'event and ipb_clk = '1')then
		done <= done_sync(1) and not done_sync(0);
	end if;
end process;
process(ipb_addr)
begin
	if(ipb_addr(15 downto 4) = x"020")then
		case ipb_addr(3 downto 0) is
			when x"1" => ipb_rdata <= x"0000" & npulse;
			when x"2" => ipb_rdata <= x"0000" & pulse_len;
			when x"3" => ipb_rdata <= x"0000" & pulse_dist;
			when x"4" => ipb_rdata <= x"0000" & init_del;
			when x"5" => ipb_rdata <= time_out;
			when others => ipb_rdata <= (others => '0');
		end case;
	else
		ipb_rdata <= (others => '0');
	end if;
end process;
end Behavioral;

