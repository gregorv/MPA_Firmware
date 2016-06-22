library ieee;
use ieee.std_logic_1164.all;
 
package user_package is

	--=== system options ========--
   constant sys_eth_p1_enable       : boolean  := false;   
   constant sys_pcie_enable         : boolean  := false;      
  
	--=== i2c master components ==--
	constant i2c_master_enable			: boolean  := true;
	constant auto_eeprom_read_enable	: boolean  := true;    

	--=== wishbone slaves ========--
	constant number_of_wb_slaves		: positive := 1 ;
	
	constant user_wb_regs				: integer  := 0 ;
--	constant user_wb_timer				: integer  := 1 ;
	
	
	--=== ipb slaves =============--
	constant number_of_ipb_slaves		: positive := 1 ;
   
--	constant user_ipb_stat_regs		: integer  := 0 ;
--	constant user_ipb_ctrl_regs		: integer  := 1 ;
	constant MPA		: integer  := 0 ;

	constant mac_addr : std_logic_vector(47 downto 0) := x"080030F100af";
  constant  ip_addr : std_logic_vector(31 downto 0) := x"c0a800af";

	
end user_package;
   
package body user_package is
end user_package;