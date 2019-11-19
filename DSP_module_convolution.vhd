------------------------------------------------------------------
--Copyright 2019 Andrey S. Ionisyan (anserion@gmail.com)
--Licensed under the Apache License, Version 2.0 (the "License");
--you may not use this file except in compliance with the License.
--You may obtain a copy of the License at
--    http://www.apache.org/licenses/LICENSE-2.0
--Unless required by applicable law or agreed to in writing, software
--distributed under the License is distributed on an "AS IS" BASIS,
--WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--See the License for the specific language governing permissions and
--limitations under the License.
------------------------------------------------------------------

------------------------------------------------------------------------------
-- Engineer: Andrey S. Ionisyan <anserion@gmail.com>
-- 
-- Description:
-- DSP convolution modul.
------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity DSP_module_convolution is
   Port (
      clk : in STD_LOGIC;
      members_num: in std_logic_vector(15 downto 0);
      conv_res  : out std_logic_vector(55 downto 0);
      conv_ready: out   STD_LOGIC
	);
end DSP_module_convolution;

architecture ax309 of DSP_module_convolution is
   component rnd16_module is
   Port ( 
      clk: in  STD_LOGIC;
      seed : in STD_LOGIC_VECTOR(31 downto 0);
      rnd16: out STD_LOGIC_VECTOR(15 downto 0)
	);
   end component;
   signal seed1: std_logic_vector(31 downto 0):=conv_std_logic_vector(26535,32);
   signal rnd16_1: std_logic_vector(15 downto 0):=(others=>'0');
   signal seed2: std_logic_vector(31 downto 0):=conv_std_logic_vector(26515,32);
   signal rnd16_2: std_logic_vector(15 downto 0):=(others=>'0');
   signal seed3: std_logic_vector(31 downto 0):=conv_std_logic_vector(26035,32);
   signal rnd16_3: std_logic_vector(15 downto 0):=(others=>'0');
   signal seed4: std_logic_vector(31 downto 0):=conv_std_logic_vector(22535,32);
   signal rnd16_4: std_logic_vector(15 downto 0):=(others=>'0');
   signal seed5: std_logic_vector(31 downto 0):=conv_std_logic_vector(21535,32);
   signal rnd16_5: std_logic_vector(15 downto 0):=(others=>'0');
   signal seed6: std_logic_vector(31 downto 0):=conv_std_logic_vector(16535,32);
   signal rnd16_6: std_logic_vector(15 downto 0):=(others=>'0');
   signal seed7: std_logic_vector(31 downto 0):=conv_std_logic_vector(26545,32);
   signal rnd16_7: std_logic_vector(15 downto 0):=(others=>'0');
   signal seed8: std_logic_vector(31 downto 0):=conv_std_logic_vector(26530,32);
   signal rnd16_8: std_logic_vector(15 downto 0):=(others=>'0');
   signal seed9: std_logic_vector(31 downto 0):=conv_std_logic_vector(26530,32);
   signal rnd16_9: std_logic_vector(15 downto 0):=(others=>'0');
   signal seed10: std_logic_vector(31 downto 0):=conv_std_logic_vector(26531,32);
   signal rnd16_10: std_logic_vector(15 downto 0):=(others=>'0');

	signal dsp_op1 : std_logic_vector(55 downto 0) := (others => '0');
	signal dsp_op2 : std_logic_vector(55 downto 0) := (others => '0');
   signal dsp_mul_res : std_logic_vector(111 downto 0) := (others => '0');
   signal dsp_accum : std_logic_vector(55 downto 0) := (others => '0');
   signal conv_ready_flag: std_logic:='0';
begin
   --------------------------------
   -- RND section
   --------------------------------
   rnd16_chip_1: rnd16_module port map(clk,seed1,rnd16_1);
   rnd16_chip_2: rnd16_module port map(clk,seed2,rnd16_2);
   rnd16_chip_3: rnd16_module port map(clk,seed3,rnd16_3);
   rnd16_chip_4: rnd16_module port map(clk,seed4,rnd16_4);
   rnd16_chip_5: rnd16_module port map(clk,seed5,rnd16_5);
   rnd16_chip_6: rnd16_module port map(clk,seed6,rnd16_6);
   rnd16_chip_7: rnd16_module port map(clk,seed7,rnd16_7);
   rnd16_chip_8: rnd16_module port map(clk,seed8,rnd16_8);
   rnd16_chip_9: rnd16_module port map(clk,seed9,rnd16_9);
   rnd16_chip_10: rnd16_module port map(clk,seed10,rnd16_10);
   
   res1_process:
   process (clk)
   variable fsm:natural range 0 to 3 := 0;
   variable i:std_logic_vector(15 downto 0):=(others=>'0');
   begin
      if rising_edge(clk) then
         case fsm is
         when 0 =>
            conv_ready<='0';
            --prepare random operands for a dsp mul's
            dsp_op1<=rnd16_4(7 downto 0)&rnd16_3&rnd16_2&rnd16_1;
            dsp_op2<=rnd16_8(7 downto 0)&rnd16_7&rnd16_6&rnd16_5;
            fsm:=1;
         when 1 =>
            conv_ready<='0';
            dsp_mul_res<=dsp_op1*dsp_op2;
            fsm:=2;
         when 2 =>
            dsp_accum<=dsp_accum+dsp_mul_res(55 downto 0);
            if i=members_num then conv_res<=dsp_accum; end if;
            fsm:=3;
         when 3 =>
            if i=members_num
            then
               conv_ready<='1';
               dsp_accum<=(others=>'0');
               i:=(others=>'0');
            else i:=i+1; 
            end if;
            fsm:=0;            
         when others => fsm:=0;
         end case;
      end if;
   end process;
end ax309;
