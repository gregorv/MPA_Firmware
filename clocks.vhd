----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:19:25 05/21/2015 
-- Design Name: 
-- Module Name:    clocks - Behavioral 
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
use work.fmc_package.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity clocks is
    Port ( clk125 : in  STD_LOGIC;
           beam_clk : in  STD_LOGIC;
           test_beam : in  STD_LOGIC;
           clk160_sel : in  STD_LOGIC;
           beam_clk_out : out  STD_LOGIC;
           clk160from125 : out  STD_LOGIC;
           clk400 : out  STD_LOGIC;
           PS_reg : in  STD_LOGIC_VECTOR (8 downto 0);
           mpaclk_en : in  STD_LOGIC;
           clk320 : out  STD_LOGIC;
           clk160_PS : out  STD_LOGIC;
           PS_ready : out  STD_LOGIC;
           clk160_p : out  STD_LOGIC;
           clk160_n : out  STD_LOGIC;
			  probe_p : out STD_LOGIC;
			  probe_n : out STD_LOGIC;
			  probe_en : out STD_LOGIC
			  );
end clocks;

architecture Behavioral of clocks is
signal rst_clk160 : std_logic := '0';
signal rst_clk160p : std_logic := '0';
signal rst_beam_clk160 : std_logic := '0';
signal test_beam_q : std_logic := '0';
signal clk160p_lock : std_logic := '0';
signal beam_clk160_lock : std_logic := '0';
signal clk160_lock : std_logic := '0';
signal clk320_dcm : std_logic := '0';
signal clk320_i : std_logic := '0';
signal mpaclk_enSync : std_logic_vector(1 downto 0) := (others =>'0');
signal beam_clk160 : std_logic := '0';
signal beam_clk160_dcm : std_logic := '0';
signal clk160p : std_logic := '0';
signal clk160p_dcm : std_logic := '0';
signal clk160 : std_logic := '0';
signal clk160_dcm : std_logic := '0';
signal clk160_o : std_logic := '0';
signal clk400_dcm : std_logic := '0';
signal clk160_PS_dcm : std_logic := '0';
signal CLKFB_dcm : std_logic := '0';
signal CLKFB : std_logic := '0';
signal CLKFB1_dcm : std_logic := '0';
signal CLKFB1 : std_logic := '0';
signal CLKFB2_dcm : std_logic := '0';
signal CLKFB2 : std_logic := '0';
signal CLKFB_toggle : std_logic := '0';
signal CLKFB_toggle_dl : std_logic := '0';
signal PSDONE : std_logic := '0';
signal PSEN : std_logic := '0';
signal PSinh : std_logic := '0';
signal PS_ready_i : std_logic := '0';
signal PSINCDEC : std_logic := '0';
signal PS_regp : std_logic_vector(8 downto 0) := (others =>'0');
signal PS_cntr : std_logic_vector(8 downto 0) := (others =>'0');

signal clk_probe : std_logic;	

begin
-- clk125 is the system clock
-- ipb_clk is clk125 divided by 4 and is the ipbus clock
-- clk400 is used to clock strip inputs
-- clk160 is the clock to drive MPA light
-- clk160_PS is used to clock strip outputs, its delay relative to clk160 can be finely tuned to adjust its phase to
-- the outgoing strip data
beam_clk_out <= CLKFB2;
PS_ready <= PS_ready_i;
clk320 <= clk320_i;
clk160from125 <= clk160p;
PS_regp <= PS_reg when PS_reg <= "100010111" else "100010111";
i_clk160_obuf : OBUFDS
   generic map (
      IOSTANDARD => "LVDS_25")
   port map (
      O => clk160_p,     -- Diff_p output (connect directly to top-level port)
      OB => clk160_n,   -- Diff_n output (connect directly to top-level port)
      I => clk160_o      -- Buffer input 
   );
i_clk160_DDR : ODDR
   generic map(
      DDR_CLK_EDGE => "OPPOSITE_EDGE", -- "OPPOSITE_EDGE" or "SAME_EDGE" 
      INIT => '0',   -- Initial value for Q port ('1' or '0')
      SRTYPE => "SYNC") -- Reset Type ("ASYNC" or "SYNC")
   port map (
      Q => clk160_o,   -- 1-bit DDR output
      C => clk160,    -- 1-bit clock input
      CE => '1',  -- 1-bit clock enable input
      D1 => mpaclk_en,  -- 1-bit data input (positive edge)
      D2 => '0',  -- 1-bit data input (negative edge)
      R => '0',    -- 1-bit reset input
      S => '0'     -- 1-bit set input
   );
--i_clk160_buf : BUFGMUX
--   port map (
--      O => clk160,   -- 1-bit output: Clock buffer output
--      I0 => clk160p, -- 1-bit input: Clock buffer input (S=0)
--      I1 => beam_clk160, -- 1-bit input: Clock buffer input (S=1)
--      S => clk160_sel    -- 1-bit input: Clock buffer select
--   );

i_rst_clk160p : SRL16 generic map(INIT => x"ffff")
   port map (
      Q => rst_clk160p,       -- SRL data output
      A0 => '1',     -- Select[0] input
      A1 => '1',     -- Select[1] input
      A2 => '1',     -- Select[2] input
      A3 => '1',     -- Select[3] input
      CLK => clk125,   -- Clock input
      D => '0'        -- SRL data input
   );
i_MMCM_clk160p : MMCM_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- Jitter programming ("HIGH","LOW","OPTIMIZED")
      CLKFBOUT_MULT_F => 32.0,    -- Multiply value for all CLKOUT (5.0-64.0).
      CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (0.00-360.00).
      CLKIN1_PERIOD => 8.0,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      CLKOUT0_DIVIDE_F => 5.0,   -- Divide amount for CLKOUT0 (1.000-128.000).
      DIVCLK_DIVIDE => 5        -- Master division value (1-80)
   )
   port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0 => clk160p_dcm,     -- 1-bit output: CLKOUT0 output
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => CLKFB1_dcm,   -- 1-bit output: Feedback clock output
      -- Status Port: 1-bit (each) output: MMCM status ports
      LOCKED => clk160p_lock,       -- 1-bit output: LOCK output
      -- Clock Input: 1-bit (each) input: Clock input
      CLKIN1 => clk125,
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN => '0',       -- 1-bit input: Power-down input
      RST => rst_clk160p,             -- 1-bit input: Reset input
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => CLKFB1      -- 1-bit input: Feedback clock input
   );
i_CLKFB1_buf: bufg port map(i => CLKFB1_dcm, o => CLKFB1);
i_clk160p_buf: bufg port map(i => clk160p_dcm, o => clk160p);
i_MMCM_beam_clk160 : MMCM_BASE
   generic map (
      BANDWIDTH => "OPTIMIZED",  -- Jitter programming ("HIGH","LOW","OPTIMIZED")
      --CLKFBOUT_MULT_F => 36.0,    -- Multiply value for all CLKOUT (5.0-64.0).
      CLKFBOUT_MULT_F => 16.0,
		CLKFBOUT_PHASE => 0.0,     -- Phase offset in degrees of CLKFB (0.00-360.00).
		--CLKIN1_PERIOD => 37.736,      -- Input clock period in ns to ps resolution (i.e. 33.333 is 30 MHz).
      CLKIN1_PERIOD => 25.0,
		--CLKOUT0_DIVIDE_F => 6.0,   -- Divide amount for CLKOUT0 (1.000-128.000).
      CLKOUT0_DIVIDE_F => 4.0,
		DIVCLK_DIVIDE => 1        -- Master division value (1-80)
   )
   port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0 => beam_clk160_dcm,     -- 1-bit output: CLKOUT0 output
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => CLKFB2_dcm,   -- 1-bit output: Feedback clock output
      -- Status Port: 1-bit (each) output: MMCM status ports
      LOCKED => beam_clk160_lock,       -- 1-bit output: LOCK output
      -- Clock Input: 1-bit (each) input: Clock input
      CLKIN1 => beam_clk,
      -- Control Ports: 1-bit (each) input: MMCM control ports
      PWRDWN => '0',       -- 1-bit input: Power-down input
      RST => rst_beam_clk160,             -- 1-bit input: Reset input
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => CLKFB2      -- 1-bit input: Feedback clock input
   );
i_CLKFB2_buf: bufg port map(i => CLKFB2_dcm, o => CLKFB2);
i_beam_clk160_buf: bufg port map(i => beam_clk160_dcm, o => beam_clk160);
i_MMCM_clk160 : MMCM_ADV
   generic map (
      BANDWIDTH => "OPTIMIZED",      -- Jitter programming ("HIGH","LOW","OPTIMIZED")
      CLKFBOUT_MULT_F => 5.0,        -- Multiply value for all CLKOUT (5.0-64.0).
      CLKIN1_PERIOD => 6.25,
      CLKIN2_PERIOD => 6.29,
      DIVCLK_DIVIDE => 1,            -- Master division value (1-80)
      CLKOUT0_DIVIDE_F => 2.5,       -- Divide amount for CLKOUT0 (1.000-128.000).
			CLKOUT1_DIVIDE => 5,
			CLKOUT2_DIVIDE => 5,
			CLKOUT3_DIVIDE => 2,
      CLKOUT1_USE_FINE_PS => TRUE
   )
   port map (
      -- Clock Outputs: 1-bit (each) output: User configurable clock outputs
      CLKOUT0 => clk320_dcm,           -- 1-bit output: CLKOUT0 output
      CLKOUT1 => clk160_PS_dcm,
      CLKOUT2 => clk160_dcm,
      CLKOUT3 => clk400_dcm,
      -- DRP Ports: 16-bit (each) output: Dynamic reconfigration ports
      DO => open,                     -- 16-bit output: DRP data output
      DRDY => open,                 -- 1-bit output: DRP ready output
      -- Dynamic Phase Shift Ports: 1-bit (each) output: Ports used for dynamic phase shifting of the outputs
      PSDONE => PSDONE,             -- 1-bit output: Phase shift done output
      -- Feedback Clocks: 1-bit (each) output: Clock feedback ports
      CLKFBOUT => CLKFB_dcm,         -- 1-bit output: Feedback clock output
      CLKFBOUTB => open,       -- 1-bit output: Inverted CLKFBOUT
      -- Status Ports: 1-bit (each) output: MMCM status ports
      CLKFBSTOPPED => open, -- 1-bit output: Feedback clock stopped output
      CLKINSTOPPED => open, -- 1-bit output: Input clock stopped output
      LOCKED => clk160_lock,             -- 1-bit output: LOCK output
      -- Clock Inputs: 1-bit (each) input: Clock inputs
      CLKIN1 => beam_clk160,             -- 1-bit input: Primary clock input
      CLKIN2 => clk160p,             -- 1-bit input: Secondary clock input
      -- Control Ports: 1-bit (each) input: MMCM control ports
      CLKINSEL => clk160_sel,         -- 1-bit input: Clock select input
      PWRDWN => '0',             -- 1-bit input: Power-down input
      RST => rst_clk160,                   -- 1-bit input: Reset input
      -- DRP Ports: 7-bit (each) input: Dynamic reconfigration ports
      DADDR => (others => '0'),               -- 7-bit input: DRP adrress input
      DCLK => '0',                 -- 1-bit input: DRP clock input
      DEN => '0',                   -- 1-bit input: DRP enable input
      DI => (others => '0'),                     -- 16-bit input: DRP data input
      DWE => '0',                   -- 1-bit input: DRP write enable input
      -- Dynamic Phase Shift Ports: 1-bit (each) input: Ports used for dynamic phase shifting of the outputs
      PSCLK => clk125,               -- 1-bit input: Phase shift clock input
      PSEN => PSEN,                 -- 1-bit input: Phase shift enable input
      PSINCDEC => PSINCDEC,         -- 1-bit input: Phase shift increment/decrement input
      -- Feedback Clocks: 1-bit (each) input: Clock feedback ports
      CLKFBIN => CLKFB            -- 1-bit input: Feedback clock input
   );

rst_clk160 <= not clk160p_lock when clk160_sel = '0' else not beam_clk160_lock; 
i_CLKFB_buf: bufg port map(i => CLKFB_dcm, o => CLKFB);
i_clk160_buf: bufg port map(i => clk160_dcm, o => clk160);
i_clk320_buf: bufg port map(i => clk320_dcm, o => clk320_i);
i_clk400_buf: bufg port map(i => clk400_dcm, o => clk400);
i_clk160_dl_buf: bufg port map(i => clk160_PS_dcm, o => clk160_PS);
process(clk125,clk160_lock)
begin
	if(clk160_lock = '0')then
		PS_ready_i <= '1';
		PSINCDEC <= '1';
		PSEN <= '0';
		PSinh <= '0';
		PS_cntr <= (others => '0');
	elsif(clk125'event and clk125 = '1')then
		if(PS_regp = PS_cntr)then
			PS_ready_i <= '1';
		else
			PS_ready_i <= '0';
		end if;
		if(('0' & PS_regp) > ('0' & PS_cntr))then
			PSINCDEC <= '1';
		else
			PSINCDEC <= '0';
		end if;
		if(PS_ready_i = '1' or PSinh = '1' or PSEN = '1' or (PS_cntr = "100010111" and PSINCDEC = '1'))then
			PSEN <= '0';
		else
			PSEN <= '1';
		end if;
		if(PSDONE = '1')then
			PSinh <= '0';
		elsif(PSEN = '1')then
			PSinh <= '1';
		end if;
		if(PSEN = '1' and PSINCDEC = '1')then
			PS_cntr <= PS_cntr + 1;
		elsif(PSEN = '1' and PSINCDEC = '0')then
			PS_cntr <= PS_cntr - 1;
		end if;
	end if;
end process;
--process(beam_clk,test_beam)
--begin
--	if(test_beam = '0')then
--		rst_beam_clk160 <= '1';
--		test_beam_q <= '0';
--	elsif(beam_clk'event and beam_clk = '1')then
--		test_beam_q <= test_beam;
--		rst_beam_clk160 <= not test_beam_q;
--	end if;
--end process;



--------------------------
-- Output on LEMO0 --
--------------------------

clk_probe <= beam_clk;

i_test_out_p: OBUFDS generic map(IOSTANDARD => "LVDS_25")
	port map (
		I => clk_probe,
		O => probe_p,
		OB => probe_n
	);
	
-- Enable output
i_out_en: OBUFT generic map(IOSTANDARD => "lvcmos25")
	port map (
		I => '0',
		O => probe_en,
		T => '0'
	);


end Behavioral;

