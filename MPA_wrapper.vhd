----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:03:44 06/26/2015 
-- Design Name: 
-- Module Name:    MPA_wrapper - Behavioral 
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
use work.ipbus.all;
use work.fmc_package.all;
-- for OBUFT
library unisim;
use unisim.vcomponents.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MPA_wrapper is
    Port ( 	clk125 : in  STD_LOGIC;
				beam_clk : in  STD_LOGIC;
				beam_data : in  STD_LOGIC;
				reset : in  STD_LOGIC;
				fmc1_clk1_M2C_p : in	 std_logic;
				fmc1_clk1_M2C_n : in	 std_logic;	
				fmc1_io_pin : inout fmc_io_pin_type;
				-- for DIO5 output
				--fmc2_io_pin : inout fmc_io_pin_type;
				ipb_clk : in  STD_LOGIC;
				ipb_miso_o : out ipb_rbus;
				ipb_mosi_i : in ipb_wbus;
				LED : out  STD_LOGIC_VECTOR(1 downto 0); 
				shutter_o : OUT STD_LOGIC
			);
end MPA_wrapper;

architecture Behavioral of MPA_wrapper is
COMPONENT MPA_top
	PORT(
		clk125 : IN std_logic;
		beam_clk : IN std_logic;
		beam_data : IN std_logic;
		hitOR_p : IN std_logic;
		hitOR_n : IN std_logic;
		conf_din_p : IN std_logic;
		conf_din_n : IN std_logic;
		read_din_p : IN std_logic;
		read_din_n : IN std_logic;
		mem_p : IN std_logic_vector(5 downto 0);
		mem_n : IN std_logic_vector(5 downto 0);
		util_din_p : IN std_logic;
		util_din_n : IN std_logic;
		strip_strobe_in_p : IN std_logic_vector(5 downto 0);
		strip_strobe_in_n : IN std_logic_vector(5 downto 0);
		strip_data_in_p : IN std_logic_vector(23 downto 0);
		strip_data_in_n : IN std_logic_vector(23 downto 0);
		ipb_clk : IN std_logic;
		ipb_write : IN std_logic;
		ipb_strobe : IN std_logic;
		ipb_addr : IN std_logic_vector(15 downto 0);
		ipb_wdata : IN std_logic_vector(31 downto 0);          
		led : OUT std_logic_vector(1 to 2);
		shutter_p : OUT std_logic;
		shutter_n : OUT std_logic;
		calstrobe_p : OUT std_logic;
		calstrobe_n : OUT std_logic;
		conf_en_p : OUT std_logic;
		conf_en_n : OUT std_logic;
		conf_clk_p : OUT std_logic;
		conf_clk_n : OUT std_logic;
		conf_dout_p : OUT std_logic;
		conf_dout_n : OUT std_logic;
		read_clk_p : OUT std_logic;
		read_clk_n : OUT std_logic;
		read_dout_p : OUT std_logic;
		read_dout_n : OUT std_logic;
		enutil_p : OUT std_logic;
		enutil_n : OUT std_logic;
		util_clk_p : OUT std_logic;
		util_clk_n : OUT std_logic;
		util_dout_p : OUT std_logic;
		util_dout_n : OUT std_logic;
		clk160_p : OUT std_logic;
		clk160_n : OUT std_logic;
		strip_strobe_out_p : OUT std_logic_vector(5 downto 0);
		strip_strobe_out_n : OUT std_logic_vector(5 downto 0);
		strip_data_out_p : OUT std_logic_vector(23 downto 0);
		strip_data_out_n : OUT std_logic_vector(23 downto 0);
		ipb_rdata : OUT std_logic_vector(31 downto 0);
		ipb_ack : OUT std_logic;
		shutter_o : OUT std_logic
		);
END COMPONENT;
signal mem_p : std_logic_vector(5 downto 0) := (others =>'0');
signal mem_n : std_logic_vector(5 downto 0) := (others =>'0');
signal strip_strobe_in_p : std_logic_vector(5 downto 0) := (others =>'0');
signal strip_strobe_in_n : std_logic_vector(5 downto 0) := (others =>'0');
signal strip_strobe_out_p : std_logic_vector(5 downto 0) := (others =>'0');
signal strip_strobe_out_n : std_logic_vector(5 downto 0) := (others =>'0');
signal strip_data_in_p : std_logic_vector(23 downto 0) := (others =>'0');
signal strip_data_in_n : std_logic_vector(23 downto 0) := (others =>'0');
signal strip_data_out_p : std_logic_vector(23 downto 0) := (others =>'0');
signal strip_data_out_n : std_logic_vector(23 downto 0) := (others =>'0');


begin
mem_p(0) <= fmc1_io_pin.hb_p(20);
mem_n(0) <= fmc1_io_pin.hb_n(20);
mem_p(1) <= fmc1_io_pin.hb_p(17);
mem_n(1) <= fmc1_io_pin.hb_n(17);
mem_p(2) <= fmc1_io_pin.hb_p(18);
mem_n(2) <= fmc1_io_pin.hb_n(18);
mem_p(3) <= fmc1_io_pin.hb_p(14);
mem_n(3) <= fmc1_io_pin.hb_n(14);
mem_p(4) <= fmc1_io_pin.hb_p(15);
mem_n(4) <= fmc1_io_pin.hb_n(15);
mem_p(5) <= fmc1_io_pin.hb_p(13);
mem_n(5) <= fmc1_io_pin.hb_n(13);
strip_strobe_in_p(0) <= fmc1_io_pin.hb_p(16);
strip_strobe_in_n(0) <= fmc1_io_pin.hb_n(16);
strip_strobe_in_p(1) <= fmc1_io_pin.hb_p(6);
strip_strobe_in_n(1) <= fmc1_io_pin.hb_n(6);
strip_strobe_in_p(2) <= fmc1_io_pin.hb_p(4);
strip_strobe_in_n(2) <= fmc1_io_pin.hb_n(4);
strip_strobe_in_p(3) <= fmc1_io_pin.ha_p(21);
strip_strobe_in_n(3) <= fmc1_io_pin.ha_n(21);
strip_strobe_in_p(4) <= fmc1_io_pin.la_p(10);
strip_strobe_in_n(4) <= fmc1_io_pin.la_n(10);
strip_strobe_in_p(5) <= fmc1_io_pin.ha_p(11);
strip_strobe_in_n(5) <= fmc1_io_pin.ha_n(11);
strip_data_in_p(0) <= fmc1_io_pin.hb_p(19);
strip_data_in_n(0) <= fmc1_io_pin.hb_n(19);
strip_data_in_p(1) <= fmc1_io_pin.hb_p(10);
strip_data_in_n(1) <= fmc1_io_pin.hb_n(10);
strip_data_in_p(2) <= fmc1_io_pin.hb_p(12);
strip_data_in_n(2) <= fmc1_io_pin.hb_n(12);
strip_data_in_p(3) <= fmc1_io_pin.hb_p(11);
strip_data_in_n(3) <= fmc1_io_pin.hb_n(11);
strip_data_in_p(4) <= fmc1_io_pin.hb_p(8);
strip_data_in_n(4) <= fmc1_io_pin.hb_n(8);
strip_data_in_p(5) <= fmc1_io_pin.hb_p(7);
strip_data_in_n(5) <= fmc1_io_pin.hb_n(7);
strip_data_in_p(6) <= fmc1_io_pin.hb_p(9);
strip_data_in_n(6) <= fmc1_io_pin.hb_n(9);
strip_data_in_p(7) <= fmc1_io_pin.hb_p(0);
strip_data_in_n(7) <= fmc1_io_pin.hb_n(0);
strip_data_in_p(8) <= fmc1_io_pin.hb_p(1);
strip_data_in_n(8) <= fmc1_io_pin.hb_n(1);
strip_data_in_p(9) <= fmc1_io_pin.hb_p(5);
strip_data_in_n(9) <= fmc1_io_pin.hb_n(5);
strip_data_in_p(10) <= fmc1_io_pin.hb_p(2);
strip_data_in_n(10) <= fmc1_io_pin.hb_n(2);
strip_data_in_p(11) <= fmc1_io_pin.hb_p(3);
strip_data_in_n(11) <= fmc1_io_pin.hb_n(3);
strip_data_in_p(12) <= fmc1_io_pin.ha_p(18);
strip_data_in_n(12) <= fmc1_io_pin.ha_n(18);
strip_data_in_p(13) <= fmc1_io_pin.la_p(11);
strip_data_in_n(13) <= fmc1_io_pin.la_n(11);
strip_data_in_p(14) <= fmc1_io_pin.ha_p(17);
strip_data_in_n(14) <= fmc1_io_pin.ha_n(17);
strip_data_in_p(15) <= fmc1_io_pin.la_p(12);
strip_data_in_n(15) <= fmc1_io_pin.la_n(12);
strip_data_in_p(16) <= fmc1_io_pin.la_p(9);
strip_data_in_n(16) <= fmc1_io_pin.la_n(9);
strip_data_in_p(17) <= fmc1_io_pin.ha_p(12);
strip_data_in_n(17) <= fmc1_io_pin.ha_n(12);
strip_data_in_p(18) <= fmc1_io_pin.ha_p(10);
strip_data_in_n(18) <= fmc1_io_pin.ha_n(10);
strip_data_in_p(19) <= fmc1_io_pin.ha_p(13);
strip_data_in_n(19) <= fmc1_io_pin.ha_n(13);
strip_data_in_p(20) <= fmc1_io_pin.ha_p(8);
strip_data_in_n(20) <= fmc1_io_pin.ha_n(8);
strip_data_in_p(21) <= fmc1_io_pin.ha_p(6);
strip_data_in_n(21) <= fmc1_io_pin.ha_n(6);
strip_data_in_p(22) <= fmc1_io_pin.la_p(3);
strip_data_in_n(22) <= fmc1_io_pin.la_n(3);
strip_data_in_p(23) <= fmc1_io_pin.ha_p(7);
strip_data_in_n(23) <= fmc1_io_pin.ha_n(7);
fmc1_io_pin.la_p(32) <= strip_strobe_out_p(0);
fmc1_io_pin.la_n(32) <= strip_strobe_out_n(0);
fmc1_io_pin.la_p(29) <= strip_strobe_out_p(1);
fmc1_io_pin.la_n(29) <= strip_strobe_out_n(1);
fmc1_io_pin.la_p(17) <= strip_strobe_out_p(2);
fmc1_io_pin.la_n(17) <= strip_strobe_out_n(2);
fmc1_io_pin.la_p(28) <= strip_strobe_out_p(3);
fmc1_io_pin.la_n(28) <= strip_strobe_out_n(3);
fmc1_io_pin.la_p(15) <= strip_strobe_out_p(4);
fmc1_io_pin.la_n(15) <= strip_strobe_out_n(4);
fmc1_io_pin.la_p(4) <= strip_strobe_out_p(5);
fmc1_io_pin.la_n(4) <= strip_strobe_out_n(5);
fmc1_io_pin.hb_p(21) <= strip_data_out_p(0);
fmc1_io_pin.hb_n(21) <= strip_data_out_n(0);
fmc1_io_pin.la_p(33) <= strip_data_out_p(1);
fmc1_io_pin.la_n(33) <= strip_data_out_n(1);
fmc1_io_pin.la_p(30) <= strip_data_out_p(2);
fmc1_io_pin.la_n(30) <= strip_data_out_n(2);
fmc1_io_pin.la_p(31) <= strip_data_out_p(3);
fmc1_io_pin.la_n(31) <= strip_data_out_n(3);
fmc1_io_pin.la_p(24) <= strip_data_out_p(4);
fmc1_io_pin.la_n(24) <= strip_data_out_n(4);
fmc1_io_pin.la_p(25) <= strip_data_out_p(5);
fmc1_io_pin.la_n(25) <= strip_data_out_n(5);
fmc1_io_pin.la_p(26) <= strip_data_out_p(6);
fmc1_io_pin.la_n(26) <= strip_data_out_n(6);
fmc1_io_pin.la_p(21) <= strip_data_out_p(7);
fmc1_io_pin.la_n(21) <= strip_data_out_n(7);
fmc1_io_pin.la_p(16) <= strip_data_out_p(8);
fmc1_io_pin.la_n(16) <= strip_data_out_n(8);
fmc1_io_pin.la_p(7) <= strip_data_out_p(9);
fmc1_io_pin.la_n(7) <= strip_data_out_n(9);
fmc1_io_pin.ha_p(5) <= strip_data_out_p(10);
fmc1_io_pin.ha_n(5) <= strip_data_out_n(10);
fmc1_io_pin.la_p(0) <= strip_data_out_p(11);
fmc1_io_pin.la_n(0) <= strip_data_out_n(11);
fmc1_io_pin.la_p(27) <= strip_data_out_p(12);
fmc1_io_pin.la_n(27) <= strip_data_out_n(12);
fmc1_io_pin.la_p(22) <= strip_data_out_p(13);
fmc1_io_pin.la_n(22) <= strip_data_out_n(13);
fmc1_io_pin.la_p(18) <= strip_data_out_p(14);
fmc1_io_pin.la_n(18) <= strip_data_out_n(14);
fmc1_io_pin.la_p(19) <= strip_data_out_p(15);
fmc1_io_pin.la_n(19) <= strip_data_out_n(15);
fmc1_io_pin.ha_p(20) <= strip_data_out_p(16);
fmc1_io_pin.ha_n(20) <= strip_data_out_n(16);
fmc1_io_pin.ha_p(16) <= strip_data_out_p(17);
fmc1_io_pin.ha_n(16) <= strip_data_out_n(17);
fmc1_io_pin.la_p(5) <= strip_data_out_p(18);
fmc1_io_pin.la_n(5) <= strip_data_out_n(18);
fmc1_io_pin.la_p(6) <= strip_data_out_p(19);
fmc1_io_pin.la_n(6) <= strip_data_out_n(19);
fmc1_io_pin.ha_p(9) <= strip_data_out_p(20);
fmc1_io_pin.ha_n(9) <= strip_data_out_n(20);
fmc1_io_pin.la_p(1) <= strip_data_out_p(21);
fmc1_io_pin.la_n(1) <= strip_data_out_n(21);
fmc1_io_pin.ha_p(4) <= strip_data_out_p(22);
fmc1_io_pin.ha_n(4) <= strip_data_out_n(22);
fmc1_io_pin.ha_p(1) <= strip_data_out_p(23);
fmc1_io_pin.ha_n(1) <= strip_data_out_n(23);


i_MPA_top: MPA_top PORT MAP(
		clk125 => clk125,
		beam_clk => beam_clk,
		beam_data => beam_data,
		led => LED,
		hitOR_p => fmc1_clk1_M2C_p,
		hitOR_n => fmc1_clk1_M2C_n,
		calstrobe_p => fmc1_io_pin.la_p(14),
		calstrobe_n => fmc1_io_pin.la_n(14),
		conf_en_p => fmc1_io_pin.ha_p(2),
		conf_en_n => fmc1_io_pin.ha_n(2),
		conf_clk_p => fmc1_io_pin.la_p(2),
		conf_clk_n => fmc1_io_pin.la_n(2),
		conf_din_p => fmc1_io_pin.ha_p(0),
		conf_din_n => fmc1_io_pin.ha_n(0),
		conf_dout_p => fmc1_io_pin.la_p(8),
		conf_dout_n => fmc1_io_pin.la_n(8),
		read_clk_p => fmc1_io_pin.la_p(13),
		read_clk_n => fmc1_io_pin.la_n(13),
		read_din_p => fmc1_io_pin.ha_p(3),
		read_din_n => fmc1_io_pin.ha_n(3),
		read_dout_p => fmc1_io_pin.ha_p(14),
		read_dout_n => fmc1_io_pin.ha_n(14),
		mem_p => mem_p,
		mem_n => mem_n,
		enutil_p => fmc1_io_pin.la_p(23),
		enutil_n => fmc1_io_pin.la_n(23),
		util_clk_p => fmc1_io_pin.ha_p(15),
		util_clk_n => fmc1_io_pin.ha_n(15),
		util_din_p => fmc1_io_pin.ha_p(23),
		util_din_n => fmc1_io_pin.ha_n(23),
		util_dout_p => fmc1_io_pin.la_p(20),
		util_dout_n => fmc1_io_pin.la_n(20),
		clk160_p => fmc1_io_pin.ha_p(22),
		clk160_n => fmc1_io_pin.ha_n(22),
		strip_strobe_in_p => strip_strobe_in_p,
		strip_strobe_in_n => strip_strobe_in_n,
		strip_data_in_p => strip_data_in_p,
		strip_data_in_n => strip_data_in_n,
		strip_strobe_out_p => strip_strobe_out_p,
		strip_strobe_out_n => strip_strobe_out_n,
		strip_data_out_p => strip_data_out_p,
		strip_data_out_n => strip_data_out_n,
		ipb_clk => ipb_clk,
		ipb_write => ipb_mosi_i.ipb_write,
		ipb_strobe => ipb_mosi_i.ipb_strobe,
		ipb_addr => ipb_mosi_i.ipb_addr(15 downto 0),
		ipb_wdata => ipb_mosi_i.ipb_wdata,
		ipb_rdata => ipb_miso_o.ipb_rdata,
		ipb_ack => ipb_miso_o.ipb_ack,
		shutter_o => shutter_o
	);


end Behavioral;

