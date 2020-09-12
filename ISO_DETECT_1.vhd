----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:04:17 05/26/2020 
-- Design Name: 
-- Module Name:    ISO_DETECT_1 - Behavioral 
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
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity ISO_DETECT_1 is
PORT(  clk: std_logic
     );
end ISO_DETECT_1;

architecture Behavioral of ISO_DETECT_1 is

--ECG Signal Sampled Data values 
--Index+1 of ECG_y is similar to time stamp sample 
-- 4ms is 1 time stamp
type ECG1_y is array (0 to 249) of std_logic_vector(15 downto 0);  
signal ECG_y : ECG1_y := (X"03BB",X"03B5",X"03B3",X"03B5",X"03B3",X"03B1",X"03AE",X"03AF",X"03AE",X"03AE",X"03AB",X"03AA",X"03AE",X"03AD",X"03A9",X"03AD",X"03AF",X"03B0",X"03B0",X"03B5",X"03BD",X"03BE",X"03BE",X"03C1",X"03C5",X"03C7",X"03C6",X"03C8",X"03CA",X"03CC",X"03CA",X"03CA",X"03CE",X"03CF",X"03CC",X"03CA",X"03CB",X"03CB",X"03CA",X"03C7",X"03CC",X"03CD",X"03CF",X"03CA",X"03CA",X"03CB",X"03CB",X"03C8",X"03C9",X"03CB",X"03CC",X"03C6",X"03C8",X"03CB",X"03CB",X"03C8",X"03C4",X"03C5",X"03C9",X"03C7",X"03C2",X"03C5",X"03C5",X"03C2",X"03C3",X"03C1",X"03C3",X"03C4",X"03C3",X"03C2",X"03C4",X"03C2",X"03C1",X"03C2",X"03C2",X"03C3",X"03C3",X"03C1",X"03C3",X"03C3",X"03C1",X"03C1",X"03C5",X"03C4",X"03C4",X"03BF",X"03C2",X"03C5",X"03C0",X"03BF",X"03C2",X"03C4",X"03C2",X"03C0",X"03C3",X"03C3",X"03C6",X"03C4",X"03C5",X"03C9",X"03CB",X"03CB",X"03C9",X"03CB",X"03CC",X"03CB",X"03CB",X"03D2",X"03D5",X"03D2",X"03CA",X"03C9",X"03CD",X"03CA",X"03C5",X"03C6",X"03C6",X"03C5",X"03C3",X"03C2",X"03C4",X"03C7",X"03C3",X"03C5",X"03C4",X"03C6",X"03C2",X"03C0",X"03C6",X"03C8",X"03C4",X"03C0",X"03BC",X"03B9",X"03B6",X"03AC",X"03B4",X"03CE",X"03E7",X"03F5",X"040E",X"042E",X"0445",X"0428",X"03D5",X"03A2",X"03A4",X"03B1",X"03B7",X"03BD",X"03BF",X"03BB",X"03B8",X"03BD",X"03BD",X"03BC",X"03BA",X"03BD",X"03BF",X"03BD",X"03BA",X"03BC",X"03BF",X"03BD",X"03BB",X"03BD",X"03C0",X"03BD",X"03BB",X"03BC",X"03C0",X"03BD",X"03BB",X"03BB",X"03BC",X"03BD",X"03BD",X"03BE",X"03C1",X"03C1",X"03BF",X"03BE",X"03BF",X"03BE",X"03BF",X"03BE",X"03BE",X"03C2",X"03BF",X"03BC",X"03BD",X"03C0",X"03BF",X"03BD",X"03BD",X"03BD",X"03BA",X"03B6",X"03B7",X"03BA",X"03BB",X"03B5",X"03B3",X"03B5",X"03B5",X"03AF",X"03AF",X"03AB",X"03AE",X"03A9",X"03A6",X"03A9",X"03AB",X"03AA",X"03A9",X"03AC",X"03AE",X"03B1",X"03B3",X"03B7",X"03BC",X"03BF",X"03BF",X"03C2",X"03C7",X"03CA",X"03C7",X"03C5",X"03C8",X"03CA",X"03C8",X"03C7",X"03C9",X"03CB",X"03C8",X"03C7",X"03C9",X"03CB",X"03CA",X"03C8",X"03CA",X"03CC",X"03CA",X"03C7",X"03C7",X"03CC",X"03CB",X"03C9",X"03C6",X"03CA");

-- "a" is the starting point of the search space
signal a: std_logic_vector(15 downto 0);

-- "min" is the slope of point 1, simultaneously d1, d2, d3, d4 are slopes of points 2, 3, 4, 5 resp.
signal min, d1, d2, d3, d4: std_logic_vector(15 downto 0);

signal k,k1: std_logic_vector(15 downto 0):=X"0000"; -- Loop 1 variables
signal i,i1: std_logic_vector(15 downto 0):=X"0003"; -- Loop 2 variables
signal R_loc: std_logic_vector(15 downto 0):=X"0090"; -- Position of Rpeak

-- Temporarily stores minimum slopes out of 20ms(5 points) duration in every loop iteration
signal min1: std_logic_vector(15 downto 0); 

-- Stores min1 value for every duration of 20ms(5 points)
type minarray is array (0 to 21) of std_logic_vector(15 downto 0);
signal minarr : minarray ;

-- Stores minimum slope value out of "minarr" array and counter stores the index of same
signal counter, min2: std_logic_vector(15 downto 0);

signal num: std_logic_vector(15 downto 0); -- numerator of avg

signal j: integer; -- Loop element

signal iso: integer; -- Base-level 

begin

process(clk,k1)
begin
-- "a" is the starting point of the search space i.e. R_loc-100ms (R_loc-25)
a<=R_loc-X"001A";
j<=0;

-- LOOP-1: Calculating minimum slope out of 5 slopes for 20ms duration from R_loc-100ms to R_loc-40ms
if(k1<x"000A") then
  -- Calculating slope for 20ms duration ( 5 points slope)
  min<=ECG_y(to_integer(unsigned(a+X"0001"+k1)))-ECG_y(to_integer(unsigned(a+X"0000"+k1)));
  d1<=ECG_y(to_integer(unsigned(a+X"0002"+k1)))-ECG_y(to_integer(unsigned(a+X"0001"+k1)));
  d2<=ECG_y(to_integer(unsigned(a+X"0003"+k1)))-ECG_y(to_integer(unsigned(a+X"0002"+k1)));  
  d3<=ECG_y(to_integer(unsigned(a+X"0004"+k1)))-ECG_y(to_integer(unsigned(a+X"0003"+k1)));
  d4<=ECG_y(to_integer(unsigned(a+X"0005"+k1)))-ECG_y(to_integer(unsigned(a+X"0004"+k1)));
  
  -- provide the least valued slope out of each 20ms duration
  min1<=min;
  
  if(signed(d1)<signed(min)) then
     min1<=d1;
  end if;
  
  if(signed(d2)<signed(min)) then
     min1<=d2;
  end if;
  
  if (signed(d3)<signed(min)) then
     min1<=d3;
  end if;
  
  if(signed(d4)<signed(min)) then
     min1<=d4;  
  end if;
  
   minarr(j)<=min1;
	j<=j+1;
  
k1<=k+"0000000000000001";
k<=k1;
end if;
end process;

-- LOOP 2: Calculating the minimum slope and selecting the Duration with the minimum slope 
process(clk,i1)
begin

min2<=minarr(3);
counter<=x"0003";

if(k1=X"000A") then
   if(i1<X"0013") then 
        if(minarr(to_integer(unsigned(i1)))<min2) then
               min2<=minarr(to_integer(unsigned(i1)));
               counter<=i1+X"0001";
end if;
i1<=i+X"0001";
i<=i1;
end if;
end if;					
end process;

-- Calculating selected Durations average amplitude which is ISO-LEVEL
num<=ECG_y(to_integer(unsigned(a+counter)))+ECG_y(to_integer(unsigned(a+counter-X"0001")))+ECG_y(to_integer(unsigned(a+counter-X"0002")))+ECG_y(to_integer(unsigned(a+counter-X"0003")))+ECG_y(to_integer(unsigned(a+counter-X"0004")));

iso<=to_integer(unsigned(num))/5;

end Behavioral;

