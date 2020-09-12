----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:57:47 05/29/2020 
-- Design Name: 
-- Module Name:    clk_divider_250Hz - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

entity clk_divider_250Hz is
port( clk_in: in std_logic;
reset: in std_logic;
clk_out: out std_logic
);
end clk_divider_250Hz;

architecture Behavioral of clk_divider_250Hz is
signal cnt: integer:=1;
signal i : std_logic := '0';
  
begin
process(clk_in,reset)
begin
if(reset='1') then
cnt<=1;
i<='0';
elsif(clk_in'event and clk_in='1') then
cnt <= cnt+1;
if (cnt = 100000) then
i <= NOT i;
cnt <= 1;
end if;
end if;
clk_out <= i;
end process;
end Behavioral;

