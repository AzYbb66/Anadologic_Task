library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
entity top is
 Port (
 clk : in STD_LOGIC;
 rst : in STD_LOGIC;
 rx_serial : in STD_LOGIC;
 tx_serial : out STD_LOGIC;
 tx_done : out STD_LOGIC
 );
end top;
architecture Behavioral of top is
 signal rx_data : STD_LOGIC_VECTOR(63 downto 0);
 signal rx_done : STD_LOGIC;
 signal tx_data : STD_LOGIC_VECTOR(23 downto 0);
 signal tx_start : STD_LOGIC;
 signal tx_done_int : STD_LOGIC; -- tx_done_int sinyali eklendi
 constant HEADER : std_logic_vector(15 downto 0) := x"BACD";
 constant RESPONSE_HDR : std_logic_vector(15 downto 0) := x"ABCD";
 signal num1 : signed(15 downto 0);
 signal num2 : signed(15 downto 0);
 signal opcode : std_logic_vector(7 downto 0);
 signal checksum : std_logic_vector(7 downto 0);
 signal result : signed(15 downto 0);
 signal checksum_calc : unsigned(7 downto 0);
begin
 uart_rx_inst : entity work.uart_rx
 port map (
 clk => clk,
 rst => rst,
 rx_serial => rx_serial,
 rx_data => rx_data,
 rx_done => rx_done
 );
 uart_tx_inst : entity work.uart_tx
 port map (
 clk => clk,
 rst => rst,
 tx_start => tx_start,
 tx_data => tx_data,
 tx_serial => tx_serial,
 tx_done => tx_done_int
 );
 tx_done <= tx_done_int;
 process(clk, rst)
 begin
 if rst = '1' then
 tx_start <= '0';
 tx_data <= (others => '0');
 elsif rising_edge(clk) then
 if rx_done = '1' then
 if rx_data(63 downto 48) = HEADER then
 num1 <= signed(rx_data(47 downto 32));
 num2 <= signed(rx_data(31 downto 16));
 opcode <= rx_data(15 downto 8);
 checksum <= rx_data(7 downto 0);

 checksum_calc <= unsigned(HEADER) + unsigned(num1) + unsigned(num2) +
unsigned(opcode);
 if std_logic_vector(checksum_calc) = checksum then
 if opcode = x"00" then
 result <= num1 + num2;
 elsif opcode = x"01" then
 result <= num1 - num2;
 end if;
 tx_data <= RESPONSE_HDR & std_logic_vector(result) & (not
std_logic_vector(checksum_calc(7 downto 0)));
 tx_start <= '1';
 end if;
 end if;
 else
 tx_start <= '0';
 end if;
 end if;
 end process;
end Behavioral;
