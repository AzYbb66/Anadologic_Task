library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity uart_tx is
 Port (
 clk : in STD_LOGIC;
 rst : in STD_LOGIC;
 tx_start : in STD_LOGIC;
 tx_data : in STD_LOGIC_VECTOR(23 downto 0); -- 3 byte
 tx_serial : out STD_LOGIC;
 tx_done : out STD_LOGIC
 );
end uart_tx;
architecture Behavioral of uart_tx is
 constant clk_freq : integer := 100_000_000;
 constant baud_rate : integer := 115_200;
 constant bit_period : integer := clk_freq / baud_rate;

 type tx_state_type is (IDLE, START, DATA, STOP);
 signal state : tx_state_type := IDLE;
 signal bit_timer : integer := 0;
 signal bit_count : integer := 0;
 signal shift_reg : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');

begin
 process(clk, rst)
 begin
 if rst = '1' then
 state <= IDLE;
 bit_timer <= 0;
 bit_count <= 0;
 shift_reg <= (others => '0');
 tx_serial <= '1';
 tx_done <= '0';
 elsif rising_edge(clk) then
 case state is
 when IDLE =>
 if tx_start = '1' then
 state <= START;
 shift_reg <= tx_data;
 bit_timer <= 0;
 bit_count <= 0;
 tx_serial <= '0';
 end if;
 when START =>
 if bit_timer = bit_period - 1 then
 state <= DATA;
 bit_timer <= 0;
 else
 bit_timer <= bit_timer + 1;
 end if;
 when DATA =>
 if bit_timer = bit_period - 1 then
 bit_timer <= 0;
 tx_serial <= shift_reg(0);
 shift_reg <= '0' & shift_reg(23 downto 1);
 bit_count <= bit_count + 1;
 if bit_count = 23 then
 state <= STOP;
 end if;
 else
 bit_timer <= bit_timer + 1;
 end if;
 when STOP =>
 if bit_timer = bit_period - 1 then
 state <= IDLE;
 bit_timer <= 0;
 tx_serial <= '1';
 tx_done <= '1';
 else
 bit_timer <= bit_timer + 1;
 end if;
 end case;
 end if;
 end process;
end Behavioral;
