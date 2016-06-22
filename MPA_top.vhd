----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:14:08 05/19/2015 
-- Design Name: 
-- Module Name:    top - Behavioral 
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

entity MPA_top is
    Port ( 
-- Gigabit Ethernet pins
				clk125 : in  STD_LOGIC;
           beam_clk : in  STD_LOGIC;
           beam_data : in  STD_LOGIC;
           led : out  STD_LOGIC_VECTOR(1 to 2);
-- MAP light pins
					 hitOR_p : in  STD_LOGIC;
           hitOR_n : in  STD_LOGIC;
					 shutter_p : out  STD_LOGIC;
           shutter_n : out  STD_LOGIC;
					 calstrobe_p : out  STD_LOGIC;
           calstrobe_n : out  STD_LOGIC;
					 conf_en_p : out  STD_LOGIC;
           conf_en_n : out  STD_LOGIC;
					 conf_clk_p : out  STD_LOGIC;
           conf_clk_n : out  STD_LOGIC;
					 conf_din_p : in  STD_LOGIC;
           conf_din_n : in  STD_LOGIC;
					 conf_dout_p : out  STD_LOGIC;
           conf_dout_n : out  STD_LOGIC;
					 read_clk_p : out  STD_LOGIC;
           read_clk_n : out  STD_LOGIC;
					 read_din_p : in  STD_LOGIC;
           read_din_n : in  STD_LOGIC;
					 read_dout_p : out  STD_LOGIC;
           read_dout_n : out  STD_LOGIC;
           mem_p : in  STD_LOGIC_VECTOR(5 downto 0);
           mem_n : in  STD_LOGIC_VECTOR(5 downto 0);
					 enutil_p : out  STD_LOGIC;
           enutil_n : out  STD_LOGIC;
					 util_clk_p : out  STD_LOGIC;
           util_clk_n : out  STD_LOGIC;
					 util_din_p : in  STD_LOGIC;
           util_din_n : in  STD_LOGIC;
					 util_dout_p : out  STD_LOGIC;
           util_dout_n : out  STD_LOGIC;
					 clk160_p : out  STD_LOGIC;
           clk160_n : out  STD_LOGIC;
           strip_strobe_in_p : in  STD_LOGIC_VECTOR(5 downto 0);
           strip_strobe_in_n : in  STD_LOGIC_VECTOR(5 downto 0);
           strip_data_in_p : in  STD_LOGIC_VECTOR(23 downto 0);
           strip_data_in_n : in  STD_LOGIC_VECTOR(23 downto 0);
           strip_strobe_out_p : out  STD_LOGIC_VECTOR(5 downto 0);
           strip_strobe_out_n : out  STD_LOGIC_VECTOR(5 downto 0);
           strip_data_out_p : out  STD_LOGIC_VECTOR(23 downto 0);
           strip_data_out_n : out  STD_LOGIC_VECTOR(23 downto 0);
					 ipb_clk : in std_logic;
					 ipb_write : in std_logic;
					 ipb_strobe : in std_logic;
           ipb_addr : in  STD_LOGIC_VECTOR(15 downto 0);
           ipb_wdata : in  STD_LOGIC_VECTOR(31 downto 0);
           ipb_rdata : out  STD_LOGIC_VECTOR(31 downto 0);
					 ipb_ack : out std_logic;
			-- Shutter Output	
			shutter_o : out STD_LOGIC
					 );
end MPA_top;

architecture Behavioral of MPA_top is
COMPONENT clocks
	PORT(
		clk125 : IN std_logic;
		beam_clk : IN std_logic;
		test_beam : IN std_logic;
		clk160_sel : IN std_logic;
		PS_reg : IN std_logic_vector(8 downto 0);          
		beam_clk_out : OUT std_logic;
		clk160from125 : OUT std_logic;
		clk400 : OUT std_logic;
		mpaclk_en : IN std_logic;
		clk320 : OUT std_logic;
		clk160_PS : OUT std_logic;
		PS_ready : OUT std_logic;
		clk160_p : OUT std_logic;
		clk160_n : OUT std_logic
		);
END COMPONENT;
COMPONENT strip_in
	PORT(
		clk : IN std_logic;
		sysclk : IN std_logic;
		reset : IN std_logic;
		rst_buffer : IN std_logic;
		shutter_open : IN std_logic;
		strip_strobe_in_p : IN std_logic_vector(5 downto 0);
		strip_strobe_in_n : IN std_logic_vector(5 downto 0);
		strip_data_in_p : IN std_logic_vector(23 downto 0);
		strip_data_in_n : IN std_logic_vector(23 downto 0);
		ipb_clk : IN std_logic;
		ipb_write : IN std_logic;
		ipb_strobe : IN std_logic;
		ipb_addr : IN std_logic_vector(15 downto 0);
		ipb_wdata : IN std_logic_vector(31 downto 0);          
		ipb_rdata : OUT std_logic_vector(31 downto 0)
		);
END COMPONENT;
COMPONENT strip_out
	PORT(
		clk : IN std_logic;
		sysclk : IN std_logic;
		reset : IN std_logic;
		ipb_clk : IN std_logic;
		ipb_write : IN std_logic;
		ipb_strobe : IN std_logic;
		ipb_addr : IN std_logic_vector(15 downto 0);
		ipb_wdata : IN std_logic_vector(31 downto 0);          
		en_strip_out : OUT std_logic;
		strip_strobe_out_p : OUT std_logic_vector(5 downto 0);
		strip_strobe_out_n : OUT std_logic_vector(5 downto 0);
		strip_data_out_p : OUT std_logic_vector(23 downto 0);
		strip_data_out_n : OUT std_logic_vector(23 downto 0);
		ipb_rdata : OUT std_logic_vector(31 downto 0)
		);
END COMPONENT;
COMPONENT SPIconf
	PORT(
		reset : IN std_logic;
		sysclk : IN std_logic;
		conf_din_p : IN std_logic;
		conf_din_n : IN std_logic;
		ipb_clk : IN std_logic;
		ipb_write : IN std_logic;
		ipb_strobe : IN std_logic;
		ipb_addr : IN std_logic_vector(15 downto 0);
		ipb_wdata : IN std_logic_vector(31 downto 0);          
		conf_en_p : OUT std_logic;
		conf_en_n : OUT std_logic;
		conf_clk_p : OUT std_logic;
		conf_clk_n : OUT std_logic;
		conf_dout_p : OUT std_logic;
		conf_dout_n : OUT std_logic;
		conf_done : OUT std_logic;
		nMPA : out std_logic_vector(2 downto 0);
		ipb_rdata : OUT std_logic_vector(31 downto 0)
		);
END COMPONENT;
COMPONENT SPIutil
	PORT(
		reset : IN std_logic;
		start : IN std_logic;
		read_only : IN std_logic;
		SR_data : IN std_logic_vector(15 downto 0);
		util_din_p : IN std_logic;
		util_din_n : IN std_logic;
		ipb_clk : IN std_logic;
		ipb_write : IN std_logic;
		ipb_strobe : IN std_logic;
		ipb_addr : IN std_logic_vector(15 downto 0);
		ipb_wdata : IN std_logic_vector(31 downto 0);          
		done : OUT std_logic;
		mpa_empty : OUT std_logic_vector(5 downto 0);
		mpa_hitOR : OUT std_logic_vector(5 downto 0);
		enutil_p : OUT std_logic;
		enutil_n : OUT std_logic;
		util_clk_p : OUT std_logic;
		util_clk_n : OUT std_logic;
		util_dout_p : OUT std_logic;
		util_dout_n : OUT std_logic;
		ipb_rdata : OUT std_logic_vector(31 downto 0)
		);
END COMPONENT;
COMPONENT MPAread
	PORT(
		reset : IN std_logic;
		sysclk : IN std_logic;
		set_read_clk : IN std_logic;
		acq_done : IN std_logic;
		read_all : IN std_logic;
		buf_NUM : IN std_logic_vector(1 downto 0);
		read_din_p : IN std_logic;
		read_din_n : IN std_logic;
		mem_p : IN std_logic_vector(5 downto 0);
		mem_n : IN std_logic_vector(5 downto 0);
		nMPA : IN std_logic_vector(2 downto 0);
		ipb_clk : IN std_logic;
		ipb_write : IN std_logic;
		ipb_strobe : IN std_logic;
		ipb_addr : IN std_logic_vector(15 downto 0);
		ipb_wdata : IN std_logic_vector(31 downto 0);          
		read_clk_p : OUT std_logic;
		read_clk_n : OUT std_logic;
		read_dout_p : OUT std_logic;
		read_dout_n : OUT std_logic;
		read_done : OUT std_logic;
		ipb_rdata : OUT std_logic_vector(31 downto 0)
		);
END COMPONENT;
COMPONENT acquisition
	PORT(
		clk : IN std_logic;
		reset : IN std_logic;
		beam_trig : IN std_logic;
		beam_halt : IN std_logic;
		test_beam : IN std_logic;
		calibration : IN std_logic;
		start : IN std_logic;
		shutter_delay : in std_logic_vector(3 downto 0);
		hitOR_p : in  STD_LOGIC;
    hitOR_n : in  STD_LOGIC;
--		IsCalib : IN std_logic;
		ipb_clk : IN std_logic;
		ipb_write : IN std_logic;
		ipb_strobe : IN std_logic;
		ipb_addr : IN std_logic_vector(15 downto 0);
		ipb_wdata : IN std_logic_vector(31 downto 0);          
		set_read_clk : OUT std_logic;
		en_strip_out : OUT std_logic;
		done : OUT std_logic;
		shutter_p : OUT std_logic;
		shutter_n : OUT std_logic;
		shutter_open : OUT std_logic;
		calstrobe_p : OUT std_logic;
		calstrobe_n : OUT std_logic;
		ipb_rdata : OUT std_logic_vector(31 downto 0)
		);
END COMPONENT;
--COMPONENT trigpattern
--  GENERIC (
--    PATTERN : STD_LOGIC_VECTOR(4 downto 0) := "00000";
--    CLOCK_EDGE : STRING := "FALLING";
--    WIDTH : INTEGER := 1
--  );
--	PORT(
--		CLK : IN std_logic;
--		D : IN std_logic;          
--		TRIGGER : OUT std_logic
--		);
--END COMPONENT;
COMPONENT External_Trigger_Handler
    Port ( xclk : in  STD_LOGIC;	 -- external clock
           ext_trig_line_in : in  STD_LOGIC;  -- "10100000..." is trigger 
           ext_trigger : out STD_LOGIC);
END COMPONENT;
COMPONENT RAM32x6Db
	PORT(
		wclk : IN std_logic;
		di : IN std_logic_vector(5 downto 0);
		we : IN std_logic;
		wa : IN std_logic_vector(4 downto 0);
		ra : IN std_logic_vector(4 downto 0);          
		do : OUT std_logic_vector(5 downto 0)
		);
END COMPONENT;
function CLOCK_EDGE(beam_clk_pol : std_logic) return string is
	begin
		if(beam_clk_pol = '0')then
			return "FALLING";
		else
			return "RISING";
		end if;
	end function;
constant beam_clk_pol : std_logic := '0';
constant beam_data_pol : std_logic := '0';
constant version : std_logic_vector(15 downto 0) := x"001d";
constant zero : std_logic_vector(31 downto 0) := (others =>'0');
signal test_beam : std_logic := '0';
signal calibration : std_logic := '0';
signal clk160_sel : std_logic := '0';
signal trig_clk : std_logic := '0';
signal sysclk : std_logic := '0';
signal reset : std_logic := '0';
signal clk320 : std_logic := '0';
signal clk400 : std_logic := '0';
signal mpaclk_en : std_logic := '0';
signal clk160_PS : std_logic := '0';
signal clk160from125 : std_logic := '0';
signal PS_ready : std_logic := '0';
signal PS_reg : std_logic_vector(8 downto 0) := (others =>'0');
signal sysclk_lock_n : std_logic := '0';
signal en_strip_out : std_logic := '0';
signal rst_strip_buffer : std_logic := '0';
signal strip_in_data : std_logic_vector(31 downto 0) := (others =>'0');
signal strip_out_data : std_logic_vector(31 downto 0) := (others =>'0');
signal conf_data : std_logic_vector(31 downto 0) := (others =>'0');
signal conf_done : std_logic := '0';
signal arm : std_logic := '0';
--signal en_arm : std_logic := '0';
signal armed : std_logic := '0';
signal armed_sync : std_logic_vector(3 downto 0) := (others =>'0');
signal set_read_clk : std_logic := '0';
signal read_all : std_logic := '0';
signal busy : std_logic := '0';
signal repeat : std_logic := '0';
signal restart : std_logic := '0';
signal restart_sync : std_logic_vector(3 downto 0) := (others =>'0');
signal read_done : std_logic := '0';
signal buf_NUM : std_logic_vector(1 downto 0) := (others =>'0');
signal buffer_avl : std_logic_vector(2 downto 0) := (others =>'0');
signal buffer_read : std_logic_vector(1 downto 0) := (others =>'0');
signal nMPA : std_logic_vector(2 downto 0) := (others =>'0');
signal read_data : std_logic_vector(31 downto 0) := (others =>'0');
signal util_start : std_logic := '0';
signal util_read_only : std_logic := '0';
signal util_done : std_logic := '0';
signal util_SR_data : std_logic_vector(15 downto 0) := (others =>'0');
signal util_data : std_logic_vector(31 downto 0) := (others =>'0');
signal mpa_empty : std_logic_vector(5 downto 0) := (others =>'0');
signal mpa_hitOR : std_logic_vector(5 downto 0) := (others =>'0');
signal acq_start : std_logic := '0';
signal acq_done : std_logic := '0';
signal acq_done_q : std_logic := '0';
signal shutter_open : std_logic := '0';
signal acq_data : std_logic_vector(31 downto 0) := (others =>'0');
signal reset_cntr : std_logic_vector(23 downto 0) := (others =>'0');
signal beam_trig : std_logic := '0';
signal beam_trigp : std_logic := '0';
signal en_beam_trig : std_logic := '0';
signal MPA_busy : std_logic := '0';
signal shutter_delay : std_logic_vector(3 downto 0) := (others =>'0');
signal beam_start : std_logic := '0';
--signal beam_startp : std_logic := '0';
signal beam_halt : std_logic := '0';
signal beam_datap : std_logic := '0';
signal beam_trig_sync : std_logic_vector(4 downto 0) := (others =>'0');
signal spill_on : std_logic := '0';
signal trig_countA_we : std_logic := '0';
signal wait_trig : std_logic := '0';
signal ec_trig_cntr : std_logic := '0';
signal accepted_trig : std_logic := '0';
signal beam_cntrA : std_logic_vector(31 downto 0) := (others =>'0');
signal trig_cntr : std_logic_vector(19 downto 0) := (others =>'0');
signal trig_bufA_wa : std_logic_vector(12 downto 0) := (others =>'0');
signal trig_bufB_wa : std_logic_vector(12 downto 0) := (others =>'0');
signal trig_bufA : std_logic_vector(31 downto 0) := (others =>'0');
signal beam_cntrB : std_logic_vector(31 downto 0) := (others =>'0');
signal trig_bufB_wren : std_logic := '0';
signal trig_bufB : std_logic_vector(31 downto 0) := (others =>'0');
signal halt_time : std_logic_vector(31 downto 0) := (others =>'0');
signal trig_buf_we : std_logic_vector(0 downto 0) := (others =>'0');
signal trig_countA_Di : std_logic_vector(35 downto 0) := (others =>'0');
signal trig_countA_Do : std_logic_vector(35 downto 0) := (others =>'0');
signal trig_count_wa : std_logic_vector(4 downto 0) := (others =>'0');
signal trig_count_ra : std_logic_vector(4 downto 0) := (others =>'0');
signal shutter_open_info : std_logic := '0';

begin


LED(1) <= 'Z';
LED(2) <= 'Z';

--shutter_o <= shutter_open;
shutter_open_info <= shutter_open;
shutter_o <= shutter_open_info;

i_clk40_buf: bufg port map(i => clk125, o => sysclk);
i_clocks: clocks PORT MAP(
		clk125 => sysclk,
		beam_clk => beam_clk,
		test_beam => test_beam,
		clk160_sel => clk160_sel,
		beam_clk_out => trig_clk,
		clk160from125 => clk160from125,
		clk400 => clk400,
		clk320 => clk320,
		PS_reg => PS_reg,
		mpaclk_en => mpaclk_en,
		clk160_PS => clk160_PS,
		PS_ready => PS_ready,
		clk160_p => clk160_p,
		clk160_n => clk160_n
	);
i_strip_in: strip_in PORT MAP(
		clk => clk400,
		sysclk => sysclk,
		reset => reset,
		rst_buffer => rst_strip_buffer,
		shutter_open => shutter_open,
		strip_strobe_in_p => strip_strobe_in_p,
		strip_strobe_in_n => strip_strobe_in_n,
		strip_data_in_p => strip_data_in_p,
		strip_data_in_n => strip_data_in_n,
		ipb_clk => ipb_clk,
		ipb_write => ipb_write,
		ipb_strobe => ipb_strobe,
		ipb_addr => ipb_addr,
		ipb_wdata => ipb_wdata,
		ipb_rdata => strip_in_data
	);
i_strip_out: strip_out PORT MAP(
		clk => clk160_PS,
		sysclk => sysclk,
		reset => reset,
		en_strip_out => en_strip_out,
		strip_strobe_out_p => strip_strobe_out_p,
		strip_strobe_out_n => strip_strobe_out_n,
		strip_data_out_p => strip_data_out_p,
		strip_data_out_n => strip_data_out_n,
		ipb_clk => ipb_clk,
		ipb_write => ipb_write,
		ipb_strobe => ipb_strobe,
		ipb_addr => ipb_addr,
		ipb_wdata => ipb_wdata,
		ipb_rdata => strip_out_data
	);
i_SPIconf: SPIconf PORT MAP(
		reset => reset,
		sysclk => sysclk,
		conf_en_p => conf_en_p,
		conf_en_n => conf_en_n,
		conf_clk_p => conf_clk_p,
		conf_clk_n => conf_clk_n,
		conf_din_p => conf_din_p,
		conf_din_n => conf_din_n,
		conf_dout_p => conf_dout_p,
		conf_dout_n => conf_dout_n,
		conf_done => conf_done,
		nMPA => nMPA,
		ipb_clk => ipb_clk,
		ipb_write => ipb_write,
		ipb_strobe => ipb_strobe,
		ipb_addr => ipb_addr,
		ipb_wdata => ipb_wdata,
		ipb_rdata => conf_data
	);
i_SPIutil: SPIutil PORT MAP(
		reset => reset,
		start => util_start,
		read_only => util_read_only,
		done => util_done,
		SR_data => util_SR_data,
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
		ipb_rdata => util_data
	);
i_MPAread: MPAread PORT MAP(
		reset => reset,
		sysclk => sysclk,
		set_read_clk => set_read_clk,
		acq_done => acq_done,
		read_all => read_all,
		buf_NUM => buf_NUM,
		read_clk_p => read_clk_p,
		read_clk_n => read_clk_n,
		read_din_p => read_din_p,
		read_din_n => read_din_n,
		read_dout_p => read_dout_p,
		read_dout_n => read_dout_n,
		read_done => read_done,
		mem_p => mem_p,
		mem_n => mem_n,
		nMPA => nMPA,
		ipb_clk => ipb_clk,
		ipb_write => ipb_write,
		ipb_strobe => ipb_strobe,
		ipb_addr => ipb_addr,
		ipb_wdata => ipb_wdata,
		ipb_rdata => read_data
	);
i_acquisition: acquisition PORT MAP(
		clk => clk320,
		reset => reset,
		beam_trig => beam_trig,
		beam_halt => beam_halt,
		test_beam => test_beam,
		calibration => calibration,
		start => acq_start,
		shutter_delay => shutter_delay,
		hitOR_p => hitOR_p,
		hitOR_n => hitOR_n,
		set_read_clk => set_read_clk,
		done => acq_done,
		en_strip_out => en_strip_out,
		shutter_p => shutter_p,
		shutter_n => shutter_n,
		shutter_open => shutter_open,
		calstrobe_p => calstrobe_p,
		calstrobe_n => calstrobe_n,
		ipb_clk => ipb_clk,
		ipb_write => ipb_write,
		ipb_strobe => ipb_strobe,
		ipb_addr => ipb_addr,
		ipb_wdata => ipb_wdata,
		ipb_rdata => acq_data
	);
beam_datap <= beam_data_pol xor beam_data;
--i_trigpattern: trigpattern generic map(pattern => "01010", CLOCK_EDGE => CLOCK_EDGE(beam_clk_pol)) PORT MAP(
--		CLK => beam_clk,
--		D => beam_datap,
--		TRIGGER => beam_trigp
--	);
--i_startpattern: trigpattern generic map(pattern => "01101", CLOCK_EDGE => CLOCK_EDGE(beam_clk_pol), width => 4) PORT MAP(
--		CLK => beam_clk,
--		D => beam_datap,
--		TRIGGER => beam_startp
--	);
--i_haltpattern: trigpattern generic map(pattern => "00111", CLOCK_EDGE => CLOCK_EDGE(beam_clk_pol), width => 2) PORT MAP(
--		CLK => beam_clk,
--		D => beam_datap,
--		TRIGGER => beam_halt
--	);
i_External_Trigger_Handler : External_Trigger_Handler
    Port map( 
			xclk => beam_clk,
      ext_trig_line_in => beam_datap,
      ext_trigger => beam_trigp
		);
process(beam_clk,restart)
begin
	if(restart = '1')then
		restart_sync <= x"3";
	elsif(beam_clk'event and beam_clk = '0')then
		restart_sync <= restart_sync(2 downto 0) & '0';
	end if;
end process;
process(beam_clk,reset,acq_done_q)
begin
	if(reset = '1' or acq_done_q = '1')then
		trig_bufA_wa(10 downto 0) <= (others => '0');
		trig_countA_Di(11) <= '0';
	elsif(beam_clk'event and beam_clk = '0')then
		if(beam_start = '1')then
			trig_bufA_wa(10 downto 0) <= (others => '0');
			trig_countA_Di(11) <= '0';
		elsif(beam_trig = '1' and trig_buf_we(0) = '1')then
			if(trig_bufA_wa(10 downto 0) = "11111111111")then
				trig_countA_Di(11) <= '1';
			end if;
			trig_bufA_wa(10 downto 0) <= trig_bufA_wa(10 downto 0) + 1;
		end if;
	end if;
end process;
trig_bufA_wa(12 downto 11) <= buf_NUM;
trig_bufB_wa(12 downto 11) <= buf_NUM;
process(beam_clk,reset, acq_done)
begin
	if(reset = '1' or acq_done = '1')then
		en_beam_trig <= '0';
	elsif(beam_clk'event and beam_clk = '0')then
		if(test_beam = '0' or beam_halt = '1')then
			en_beam_trig <= '0';
		elsif(beam_start = '1' or restart_sync(3 downto 2) = "10")then
			en_beam_trig <= '1';
		end if;
	end if;
end process;
process(beam_clk,reset)
begin
	if(reset = '1')then
--		spill_on <= '0';
		ec_trig_cntr <= '0';
		trig_cntr <= (others => '0');
		beam_cntrA <= (others => '0');
		beam_trig <= '0';
		wait_trig <= '0';
	elsif(beam_clk'event and beam_clk = '0')then
--		if(beam_start = '1')then
--			spill_on <= '1';
--		elsif(beam_halt = '1')then
--			spill_on <= '0';
--		end if;
		ec_trig_cntr <= beam_trigp;
		if(beam_start = '1')then
			trig_cntr <= (others => '0');
		elsif(ec_trig_cntr = '1')then
			trig_cntr <= trig_cntr + 1;
		end if;
		if(beam_start = '1')then
			beam_cntrA <= (others => '0');
		else
			beam_cntrA <= beam_cntrA + 1;
		end if;
		beam_trig <= beam_trigp and en_beam_trig;
		if(beam_trig = '1' or beam_halt = '1')then
			wait_trig <= '0';
		elsif(beam_start = '1' or restart_sync(3 downto 2) = "10")then
			wait_trig <= '1';
		end if;
	end if;
end process;
process(beam_clk,acq_done)
begin
	if(acq_done = '1')then
		trig_buf_we <= "0";
	elsif(beam_clk'event and beam_clk = '0')then
		if(beam_trig = '1' and trig_bufA_wa(10 downto 0) = "11111111111")then
			trig_buf_we <= "0";
		elsif(beam_start = '1' or restart_sync(3 downto 2) = "10")then
			trig_buf_we <= "1";
		end if;
	end if;
end process;
process(beam_clk)
begin
	if(beam_clk'event and beam_clk = '0')then
		armed_sync <= armed_sync(2 downto 0) & armed;
		beam_start <= not armed_sync(3) and armed_sync(2);
		beam_halt <= armed_sync(3) and not armed_sync(2);
--		beam_start <= beam_startp and armed;
		if(beam_halt = '1')then
			halt_time <= beam_cntrA;
		end if;
		accepted_trig <= beam_trig and trig_buf_we(0);
	end if;
end process;
process(clk160from125,reset)
begin
	if(reset = '1')then
		beam_trig_sync <= (others => '0');
	elsif(clk160from125'event and clk160from125 = '1')then
		beam_trig_sync(3 downto 0) <= beam_trig_sync(2 downto 0) & accepted_trig;
		beam_trig_sync(4) <= not beam_trig_sync(3) and beam_trig_sync(2);
	end if;
end process;
process(clk160from125,beam_start)
begin
	if(beam_start = '1')then
		beam_cntrB <= (others => '0');
	elsif(clk160from125'event and clk160from125 = '1')then
		beam_cntrB <= beam_cntrB + 1;
	end if;
end process;
process(clk160from125,reset,beam_start,acq_done)
begin
	if(reset = '1' or beam_start = '1' or acq_done = '1')then
		trig_bufB_wa(10 downto 0) <= (others => '0');
	elsif(clk160from125'event and clk160from125 = '1')then
		if(beam_trig_sync(4) = '1')then
			trig_bufB_wa(10 downto 0) <= trig_bufB_wa(10 downto 0) + 1;
		end if;
	end if;
end process;
i_trig_countA_l: RAM32x6Db PORT MAP(
		wclk => ipb_clk,
		di => trig_countA_Di(5 downto 0),
		we => acq_done,
		wa => trig_count_wa,
		ra => trig_count_ra,
		do => trig_countA_Do(5 downto 0)
	);
i_trig_countA_h: RAM32x6Db PORT MAP(
		wclk => ipb_clk,
		di => trig_countA_Di(11 downto 6),
		we => acq_done,
		wa => trig_count_wa,
		ra => trig_count_ra,
		do => trig_countA_Do(11 downto 6)
	);
g_trig_countA : for i in 0 to 3 generate
	i_trig_countA: RAM32x6Db PORT MAP(
		wclk => beam_clk,
		di => trig_countA_Di(6*i+17 downto 6*i+12),
		we => trig_countA_we,
		wa => trig_count_wa,
		ra => trig_count_ra,
		do => trig_countA_Do(6*i+17 downto 6*i+12)
	);
end generate;
trig_countA_we <= beam_trig and wait_trig;
trig_countA_Di(31 downto 12) <= trig_cntr;
trig_countA_Di(10 downto 0) <= trig_bufA_wa(10 downto 0);
trig_count_wa <= "000" & buf_NUM;
trig_count_ra <= "000" & ipb_addr(1 downto 0);
g_trig_buf : for i in 0 to 7 generate
	i_trig_bufA : BRAM_SDP_MACRO
   generic map (
      BRAM_SIZE => "36Kb", -- Target BRAM, "18Kb" or "36Kb" 
      DEVICE => "VIRTEX6", -- Target device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
      WRITE_WIDTH => 4,    -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
      READ_WIDTH => 4)     -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
    port map (
      DO => trig_bufA(i*4+3 downto i*4),         -- Output read data port, width defined by READ_WIDTH parameter
      DI => beam_cntrA(i*4+3 downto i*4),         -- Input write data port, width defined by WRITE_WIDTH parameter
      RDADDR => ipb_addr(12 downto 0), -- Input read address, width defined by read port depth
      RDCLK => sysclk,   -- 1-bit input read clock
      RDEN => '1',     -- 1-bit input read port enable
      REGCE => '0',   -- 1-bit input read output register enable
      RST => '0',       -- 1-bit input reset 
      WE => trig_buf_we,         -- Input write enable, width defined by write port depth
      WRADDR => trig_bufA_wa, -- Input write address, width defined by write port depth
      WRCLK => beam_clk,   -- 1-bit input write clock
      WREN => beam_trig      -- 1-bit input write port enable
   );
	i_trig_bufB : BRAM_SDP_MACRO
   generic map (
      BRAM_SIZE => "36Kb", -- Target BRAM, "18Kb" or "36Kb" 
      DEVICE => "VIRTEX6", -- Target device: "VIRTEX5", "VIRTEX6", "SPARTAN6" 
      WRITE_WIDTH => 4,    -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
      READ_WIDTH => 4)     -- Valid values are 1-72 (37-72 only valid when BRAM_SIZE="36Kb")
    port map (
      DO => trig_bufB(i*4+3 downto i*4),         -- Output read data port, width defined by READ_WIDTH parameter
      DI => beam_cntrB(i*4+3 downto i*4),         -- Input write data port, width defined by WRITE_WIDTH parameter
      RDADDR => ipb_addr(12 downto 0), -- Input read address, width defined by read port depth
      RDCLK => sysclk,   -- 1-bit input read clock
      RDEN => '1',     -- 1-bit input read port enable
      REGCE => '0',   -- 1-bit input read output register enable
      RST => '0',       -- 1-bit input reset 
      WE => "1",         -- Input write enable, width defined by write port depth
      WRADDR => trig_bufB_wa, -- Input write address, width defined by write port depth
      WRCLK => clk160from125,   -- 1-bit input write clock
      WREN => beam_trig_sync(4)      -- 1-bit input write port enable
   );
end generate;
process(ipb_clk)
begin
	if(ipb_clk'event and ipb_clk = '1')then
		if(ipb_addr = x"0000" and ipb_write = '1' and ipb_strobe = '1')then
			reset <= ipb_wdata(0);
			armed <= ipb_wdata(1);
			rst_strip_buffer <= ipb_wdata(2);
		else
			reset <= '0';
--			if(en_arm = '0')then
--				armed <= '1';
--			elsif(acq_done = '1')then
--				armed <= '0';
--			end if;
			rst_strip_buffer <= '0';
		end if;
		acq_done_q <= acq_done;
		if(ipb_addr = x"0001" and ipb_write = '1' and ipb_strobe = '1')then
			PS_reg <= ipb_wdata(8 downto 0);
		end if;
		if(ipb_addr = x"0002" and ipb_write = '1' and ipb_strobe = '1')then
			mpaclk_en <= ipb_wdata(0);
			test_beam <= ipb_wdata(1);
			clk160_sel <= ipb_wdata(2);
			calibration <= ipb_wdata(3);
			read_all <= ipb_wdata(4);
--			en_arm <= ipb_wdata(5);
		end if;
		if(ipb_addr = x"0004" and ipb_write = '1' and ipb_strobe = '1')then
			shutter_delay <= ipb_wdata(3 downto 0);
		end if;
	end if;
end process;
process(ipb_clk, beam_trig)
begin
	if(beam_trig = '1')then
		MPA_busy <= '1';
	elsif(ipb_clk'event and ipb_clk = '1')then
		if(reset = '1' or read_done = '1')then
			MPA_busy <= '0';
		end if;
	end if;
end process;
process(ipb_clk, beam_start)
begin
	if(beam_start = '1')then
		repeat <= '1';
		buf_NUM <= (others => '0');
		buffer_read <= (others => '0');
		buffer_avl <= "100";
	elsif(ipb_clk'event and ipb_clk = '1')then
		if(reset = '1')then
			buffer_avl <= "100";
			buffer_read <= (others => '0');
		elsif(read_done = '1')then
			buffer_avl <= buffer_avl - 1;
		elsif(ipb_addr(15 downto 13) = "100" and ipb_addr(12 downto 10) /= "111" and ipb_write = '0' and ipb_strobe = '1')then
			buffer_read <= ipb_addr(9 downto 8);
			if(buffer_read /= ipb_addr(9 downto 8) and repeat = '1')then
				buffer_avl <= buffer_avl + 1;
			end if;
		elsif(ipb_addr = x"0080" and ipb_write = '1' and ipb_strobe = '1')then
			buffer_avl <= "100";
			if(ipb_wdata(4) = '1')then
				buffer_read <= "00";
			end if;
		end if;
		if(reset = '1')then
			busy <= '0';
			acq_start <= '0';
			buf_NUM <= (others => '0');
			repeat <= '0';
			restart <= '0';
		elsif(ipb_addr = x"0080" and ipb_write = '1' and ipb_strobe = '1')then
			busy <= '1';
			acq_start <= '1';
			restart <= '0';
			if(ipb_wdata(4) = '0')then
				buf_NUM <= ipb_wdata(3 downto 2);
				repeat <= '0';
			else
				buf_NUM <= "00";
				repeat <= '1';
			end if;
		else
			if(restart = '1' and or_reduce(buffer_avl) = '1' and test_beam = '0')then
				acq_start <= '1';
			else
				acq_start <= '0';
			end if;
			if(read_done = '1' and repeat = '1')then
				restart <= '1';
			elsif(or_reduce(buffer_avl) = '1')then
				restart <= '0';
			end if;
			if(read_done = '1')then
				if(repeat = '1')then
					buf_NUM <= buf_NUM + 1;
				else
					busy <= '0';
				end if;
			end if;
		end if;
	end if;
end process;
process(ipb_addr)
begin
	if(ipb_addr(15 downto 4) = x"000")then
		case ipb_addr(3 downto 0) is
			when x"0" => ipb_rdata <= version & zero(15 downto 2) & armed & '0';
			when x"1" => ipb_rdata <= zero(31 downto 9) & PS_reg;
			when x"2" => ipb_rdata <= zero(31 downto 5) & read_all & calibration & clk160_sel & test_beam & mpaclk_en;
			when x"3" => ipb_rdata <= zero(31 downto 20) & trig_cntr;
			when x"4" => ipb_rdata <= zero(31 downto 4) & shutter_delay;
			when x"5" => ipb_rdata <= halt_time;
			when x"8" | x"9" | x"a" | x"b" => ipb_rdata <= trig_countA_Do(31 downto 0);
			when others => ipb_rdata <= (others => '0');
		end case;
	elsif(ipb_addr = x"0080")then
		ipb_rdata <= busy & zero(30 downto 12) & buffer_read & MPA_busy & spill_on & buffer_avl & repeat & buf_NUM & "00";
	elsif(ipb_addr(15 downto 13) = "101")then
		ipb_rdata <= trig_bufA;
	elsif(ipb_addr(15 downto 13) = "110")then
		ipb_rdata <= trig_bufB;
	else
		ipb_rdata <= strip_in_data or strip_out_data or conf_data or util_data or read_data or acq_data;
	end if;
end process;
ipb_ack <= ipb_strobe;
end Behavioral;

