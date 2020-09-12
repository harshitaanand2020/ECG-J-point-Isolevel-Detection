library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.NUMERIC_STD.ALL;

entity J_POINT_DETECTION is
port ( clk: STD_LOGIC
      );
end J_POINT_DETECTION;

architecture Behavioral of J_POINT_DETECTION is

--ECG Signal Sampled Data values 
--Index+1 of ECG_y is similar to time stamp sample 
-- 4ms is 1 time stamp
type ECG1_y is array (0 to 249) of std_logic_vector(15 downto 0);  
signal ECG_y : ECG1_y :=
(X"03BB",X"03B5",X"03B3",X"03B5",X"03B3",X"03B1",X"03AE",X"03AF",X"03AE",X"03AE",X"03AB",
 X"03AA",X"03AE",X"03AD",X"03A9",X"03AD",X"03AF",X"03B0",X"03B0",X"03B5",X"03BD",X"03BE",
 X"03BE",X"03C1",X"03C5",X"03C7",X"03C6",X"03C8",X"03CA",X"03CC",X"03CA",X"03CA",X"03CE",
 X"03CF",X"03CC",X"03CA",X"03CB",X"03CB",X"03CA",X"03C7",X"03CC",X"03CD",X"03CF",X"03CA",
 X"03CA",X"03CB",X"03CB",X"03C8",X"03C9",X"03CB",X"03CC",X"03C6",X"03C8",X"03CB",X"03CB",
 X"03C8",X"03C4",X"03C5",X"03C9",X"03C7",X"03C2",X"03C5",X"03C5",X"03C2",X"03C3",X"03C1",
 X"03C3",X"03C4",X"03C3",X"03C2",X"03C4",X"03C2",X"03C1",X"03C2",X"03C2",X"03C3",X"03C3",
 X"03C1",X"03C3",X"03C3",X"03C1",X"03C1",X"03C5",X"03C4",X"03C4",X"03BF",X"03C2",X"03C5",
 X"03C0",X"03BF",X"03C2",X"03C4",X"03C2",X"03C0",X"03C3",X"03C3",X"03C6",X"03C4",X"03C5",
 X"03C9",X"03CB",X"03CB",X"03C9",X"03CB",X"03CC",X"03CB",X"03CB",X"03D2",X"03D5",X"03D2",
 X"03CA",X"03C9",X"03CD",X"03CA",X"03C5",X"03C6",X"03C6",X"03C5",X"03C3",X"03C2",X"03C4",
 X"03C7",X"03C3",X"03C5",X"03C4",X"03C6",X"03C2",X"03C0",X"03C6",X"03C8",X"03C4",X"03C0",
 X"03BC",X"03B9",X"03B6",X"03AC",X"03B4",X"03CE",X"03E7",X"03F5",X"040E",X"042E",X"0445",
 X"0428",X"03D5",X"03A2",X"03A4",X"03B1",X"03B7",X"03BD",X"03BF",X"03BB",X"03B8",X"03BD",
 X"03BD",X"03BC",X"03BA",X"03BD",X"03BF",X"03BD",X"03BA",X"03BC",X"03BF",X"03BD",X"03BB",
 X"03BD",X"03C0",X"03BD",X"03BB",X"03BC",X"03C0",X"03BD",X"03BB",X"03BB",X"03BC",X"03BD",
 X"03BD",X"03BE",X"03C1",X"03C1",X"03BF",X"03BE",X"03BF",X"03BE",X"03BF",X"03BE",X"03BE",
 X"03C2",X"03BF",X"03BC",X"03BD",X"03C0",X"03BF",X"03BD",X"03BD",X"03BD",X"03BA",X"03B6",
 X"03B7",X"03BA",X"03BB",X"03B5",X"03B3",X"03B5",X"03B5",X"03AF",X"03AF",X"03AB",X"03AE",
 X"03A9",X"03A6",X"03A9",X"03AB",X"03AA",X"03A9",X"03AC",X"03AE",X"03B1",X"03B3",X"03B7",
 X"03BC",X"03BF",X"03BF",X"03C2",X"03C7",X"03CA",X"03C7",X"03C5",X"03C8",X"03CA",X"03C8",
 X"03C7",X"03C9",X"03CB",X"03C8",X"03C7",X"03C9",X"03CB",X"03CA",X"03C8",X"03CA",X"03CC",
 X"03CA",X"03C7",X"03C7",X"03CC",X"03CB",X"03C9",X"03C6",X"03CA");

-- "a" is the starting point of the search space
signal a: std_logic_vector(15 downto 0);

signal k,k1: std_logic_vector(15 downto 0):=X"0000"; -- Loop 1 variables

signal threshold: std_logic_vector(15 downto 0):=X"0001";-- 2.5uV/sec 

signal J_loc: std_logic_vector(15 downto 0); -- Position of J-point

-- "slope1/2/3" is the slope of point 1/2/3 
signal slope1, slope2, slope3: std_logic_vector(15 downto 0);

signal R_loc: std_logic_vector(15 downto 0):=X"0090"; -- Position of Rpeak

signal S_loc: std_logic_vector(15 downto 0):=X"0092"; -- Position of S-point

-- Stores all values which satisfies the condition of being J-point
type RedundantJ_loc is array (0 to 19) of std_logic_vector(15 downto 0); 
signal Red_j :  RedundantJ_loc;

signal j: integer:=1;

begin
process(clk,k1)
begin
-- a = R_loc + 20msec 
a<=R_loc+X"0004"; 

if(k1<x"0015") then -- stop condition is R_loc + 100msec
 slope1<=ECG_y(to_integer(unsigned(a+X"0001"+k1)))-ECG_y(to_integer(unsigned(a+X"0000"+k1)));
 slope2<=ECG_y(to_integer(unsigned(a+X"0002"+k1)))-ECG_y(to_integer(unsigned(a+X"0001"+k1)));
 slope3<=ECG_y(to_integer(unsigned(a+X"0003"+k1)))-ECG_y(to_integer(unsigned(a+X"0002"+k1)));  
  
-- three concecutive slope < threshold  
  if ((signed(slope1)<signed(threshold)) and (signed(slope2)<signed(threshold)) and (signed(slope3)<signed(threshold))) then
   Red_j(j)<=a+X"0002"+k1; -- Saving all points which satisfy the criteria
	j<=j+1;
  end if;
		
  k1<=k+"0000000000000001";
  k<=k1;
  J_loc<=Red_j(1); -- J-point is the first point that satisfies the criteria

else 
if(J_loc="UUUUUUUUUUUUUUUU") then 
   J_loc<=S_loc+x"000F"; -- else J_loc = S_loc + 60ms
end if;
end if;
end process;
end Behavioral;
