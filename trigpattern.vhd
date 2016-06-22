--------------------------------------------------------------------------------
--
-- Company:
-- Engineer:       Matthew Jones - Purdue University
-- 
-- Create Date:    22:05:55 11/06/2013 
-- Design Name:    stib
-- Module Name:    trigpattern - RTL
-- Project Name:   STIB firmware
-- Target Devices: xc4vlx25ff668-10
-- Tool versions:  ISE 14.4 / 14.6
-- Description:    Matches serial trigger pattern
--
-- Dependencies:
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
--------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY trigpattern IS
  GENERIC (
    PATTERN : STD_LOGIC_VECTOR(4 DOWNTO 0) := "00000";
    CLOCK_EDGE : STRING := "RISING";
    WIDTH : INTEGER := 1
  );
  PORT (
    CLK : IN STD_LOGIC;
    D : IN STD_LOGIC;
    TRIGGER : OUT STD_LOGIC
  );
END trigpattern;

ARCHITECTURE RTL OF trigpattern IS
  CONSTANT N : INTEGER := PATTERN'LENGTH;
  SIGNAL SR : STD_LOGIC_VECTOR(N-1 DOWNTO 0) := ( OTHERS => '0' );
  SIGNAL DLY : STD_LOGIC_VECTOR(WIDTH DOWNTO 0) := ( OTHERS => '0' );
  SIGNAL MATCH : STD_LOGIC;
BEGIN

  ASSERT ( CLOCK_EDGE = "RISING" OR CLOCK_EDGE = "FALLING" )
    REPORT "Invalid CLOCK_EDGE" SEVERITY ERROR;

  RISING: IF ( CLOCK_EDGE = "RISING" ) GENERATE
    PROCESS ( CLK, D ) BEGIN
      IF ( CLK'EVENT AND CLK = '1' ) THEN
        IF ( MATCH = '1' ) THEN
          DLY <= ( OTHERS => '1' );
        ELSE
          DLY <= DLY(WIDTH-1 DOWNTO 0) & '0';
        END IF;
        SR <= SR(N-2 DOWNTO 0) & D;
      END IF;
    END PROCESS;
  END GENERATE;
  FALLING : IF ( CLOCK_EDGE = "FALLING" ) GENERATE
    PROCESS ( CLK, D ) BEGIN
      IF ( CLK'EVENT AND CLK = '0' ) THEN
        IF ( MATCH = '1' ) THEN
          DLY <= ( OTHERS => '1' );
        ELSE
          DLY <= DLY(WIDTH-1 DOWNTO 0) & '0';
        END IF;
        SR <= SR(N-2 DOWNTO 0) & D;
      END IF;
    END PROCESS;
  END GENERATE;

  MATCH <= '1' WHEN SR = PATTERN ELSE '0';
  TRIGGER <= DLY(WIDTH-1);

END RTL;

