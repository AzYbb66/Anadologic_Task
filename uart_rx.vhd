library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity uart_rx is
 Port (
 clk : in STD_LOGIC;
 rst : in STD_LOGIC;
 rx_serial : in STD_LOGIC;
 rx_data : out STD_LOGIC_VECTOR(63 downto 0);
 rx_done : out STD_LOGIC
 );
end uart_rx;
architecture Behavioral of uart_rx is
 constant clk_freq : integer := 100_000_000;
 constant baud_rate : integer := 115_200;
 constant bit_period : integer := clk_freq / baud_rate;
 constant half_bit_period : integer := bit_period / 2;

 type rx_state_type is (IDLE, START, DATA, STOP);
 signal state : rx_state_type := IDLE;
 signal bit_timer : integer := 0;
 signal bit_count : integer := 0;
 signal shift_reg : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');

begin
 process(clk, rst)
 begin
 if rst = '1' then
 state <= IDLE;
 bit_timer <= 0;
 bit_count <= 0;
 shift_reg <= (others => '0');
 rx_done <= '0';
 elsif rising_edge(clk) then
 case state is
 when IDLE =>
 if rx_serial = '0' then
 state <= START;
 bit_timer <= 0;
 end if;
 when START =>
 if bit_timer = half_bit_period then
 if rx_serial = '0' then
 state <= DATA;
 bit_timer <= 0;
 bit_count <= 0;
 else
 state <= IDLE;
 end if;
 else
 bit_timer <= bit_timer + 1;
 end if;
 when DATA =>
 if bit_timer = bit_period then
 bit_timer <= 0;
 shift_reg(bit_count) <= rx_serial;
 bit_count <= bit_count + 1;
 if bit_count = 63 then
 state <= STOP;
 end if;
 else
 bit_timer <= bit_timer + 1;
 end if;
 when STOP =>
 if bit_timer = bit_period then
 state <= IDLE;
 rx_data <= shift_reg;
 rx_done <= '1';
 else
 bit_timer <= bit_timer + 1;
 end if;
 end case;
 end if;
 end process;
end Behavioral;
