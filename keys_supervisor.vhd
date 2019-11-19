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

----------------------------------------------------------------------------------
-- Engineer: Andrey S. Ionisyan <anserion@gmail.com>
-- 
-- Description: keys supervisor.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity keys_supervisor is
   Port ( 
      clk : in std_logic;
      en  : in std_logic;
      key : in std_logic_vector(3 downto 0);
      key_rst: in std_logic;
      param1 : out std_logic_vector(31 downto 0);
      param2 : out std_logic_vector(31 downto 0);
      reset_out: out std_logic
	);
end keys_supervisor;

architecture ax309 of keys_supervisor is
   signal fsm: natural range 0 to 7 := 0;
   signal debounce_cnt: natural range 0 to 1023 :=0;
   signal param1_reg: std_logic_vector(31 downto 0):=conv_std_logic_vector(1,32);
   signal param2_reg: std_logic_vector(31 downto 0):=conv_std_logic_vector(2500,32);
   signal reset_out_reg: std_logic:='0';
begin
   param1<=param1_reg;
   param2<=param2_reg;
   reset_out<=reset_out_reg;
   process(clk)
   begin
      if rising_edge(clk) and en='1' then
         case fsm is
         -- wait for press any control key
         when 0 =>
            if (key(0)='0')or(key(1)='0')or(key(2)='0')or(key(3)='0')or(key_rst='0')
            then debounce_cnt<=0; fsm<=1;
            end if;
         -- debounce
         when 1 =>
            if debounce_cnt=500
            then fsm<=2;
            else debounce_cnt<=debounce_cnt+1;
            end if;
         -- change registers
         when 2 =>
            if (key(0)='0')and(param1_reg>=1)then param1_reg<=param1_reg-1;end if;
            if (key(1)='0')and(param1_reg<=3)then param1_reg<=param1_reg+1;end if;
            if (key(2)='0')and(param2_reg>=1000)then param2_reg<=param2_reg-100;end if;
            if (key(3)='0')and(param2_reg<=3000)then param2_reg<=param2_reg+100;end if;
            if key_rst='0' then
               reset_out_reg<=not(reset_out_reg);
               param1_reg<=conv_std_logic_vector(0,32);
               param2_reg<=conv_std_logic_vector(2500,32);
            end if;
            fsm<=3;
         -- wait for release all control keys
         when 3 =>
            if (key(0)='1')and(key(1)='1')and(key(2)='1')and(key(3)='1')and(key_rst='1')
            then debounce_cnt<=0; fsm<=4;
            end if;
         -- debounce
         when 4 =>
            if debounce_cnt=500
            then fsm<=0;
            else debounce_cnt<=debounce_cnt+1;
            end if;
         when others => null;
         end case;
      end if;
   end process;
end;
