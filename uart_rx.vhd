library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity uart is
generic (
CLK_FREQ : integer := 100_000_000;
BAUD_RATE : integer := 115_200;
STOP_BIT : integer := 1
);
port (
Data_out : out std_logic_vector(7 downto 0);
Rx_Done_Tick_O : out std_logic;
Clk : in std_logic;
D_in : in std_logic_vector(7 downto 0);
Rx_I : in std_logic);
end uart;
architecture Behavioral of uart is
type R_State is (Rx_IDLE,Rx_START,Rx_DATA,Rx_STOP);
signal Rx_State :R_State:=Rx_IDLE;
constant bit_timer_lim :integer := CLK_FREQ/BAUD_RATE;
constant halfbit_timer_lim :integer := bit_timer_lim/2;
signal bit_timer_Tx :integer := 0;
signal bit_cntr_Rx :integer := 0;
signal bit_timer_Rx :integer := 0;
signal bit_cntr_Tx :integer := 0;
uart_rx: process(Clk)
begin
if rising_edge(Clk) then
 if(Rx_I='1') and bit_timer_Rx = 0 then
Rx_State <= Rx_IDLE;
 else

bit_timer_Rx <= bit_timer_Rx + 1;
case Rx_State is
when Rx_IDLE =>
Rx_Done_Tick_O <='0';
if(Rx_I ='0') then
Rx_State <= Rx_Start;
end if;
when Rx_Start =>
if(bit_timer_Rx= halfbit_timer_lim-1) then
bit_timer_Rx <= halfbit_timer_lim;
Rx_State <= Rx_Data;
end if;
when Rx_Data =>
Data_out(bit_cntr_Rx)<= Rx_I;
if(bit_timer_Rx = bit_timer_lim+halfbit_timer_lim-1)then
bit_timer_Rx <=halfbit_timer_lim;
bit_cntr_Rx <= bit_cntr_Rx +1 ;
 if(bit_cntr_Rx =7) then
 Rx_State <= Rx_Stop;
 end if;
bit_cntr_Rx <= bit_cntr_Rx +1 ;
end if;
when Rx_Stop =>
if bit_timer_Rx = bit_timer_lim - 1 then
bit_timer_Rx <= 0;
Rx_Done_Tick_O <= '1';
bit_cntr_Rx <= 0;
Rx_State <= Rx_IDLE;
end if;
end case;
 end if;
end if;
end process uart_rx;
end Behavioral;
