library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity tb_uart is
end tb_uart;
architecture Behavioral of tb_uart is
 signal clk : std_logic := '0';
 signal rst : std_logic := '0';
 signal rx_serial : std_logic := '1';
 signal tx_serial : std_logic;
 signal tx_done : std_logic;
 signal rx_data : std_logic_vector(63 downto 0);
 signal rx_done : std_logic;
 constant clk_period : time := 10 ns;
 component top
 Port (
 clk : in STD_LOGIC;
 rst : in STD_LOGIC;
 rx_serial : in STD_LOGIC;
 tx_serial : out STD_LOGIC
 --tx_done : out STD_LOGIC
 );
 end component;
begin
 dut: top
 Port map (
 clk => clk,
 rst => rst,
 rx_serial => rx_serial,
 tx_serial => tx_serial
 --tx_done => tx_done
 );
 clk_process : process
 begin
 while true loop
 clk <= '0';
 wait for clk_period / 2;
 clk <= '1';
 wait for clk_period / 2;
 end loop;
 end process;

 stimulus_process: process
 procedure send_uart_message(message: in std_logic_vector) is
 begin
 for i in 0 to message'length - 1 loop
 rx_serial <= message(i);
 wait for clk_period;
 end loop;
 rx_serial <= '1'; -- Stop
 wait for clk_period;
 end procedure;
 begin
 -- Reset the system
 rst <= '1';
 wait for clk_period * 10;
 rst <= '0';
 send_uart_message(x"BACD001000200049");
 wait until tx_done = '1';
 send_uart_message(x"BACD001000201048");
 wait until tx_done = '1';
 send_uart_message(x"BACD001000201049");
 wait until tx_done = '1';
 -- Finish simulation
 wait for clk_period * 100;
 assert false
 report "SIMULATION FINISHED"
 severity failure;
 wait;
 end process;
end Behavioral;
