library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.sorter_pkg.all;

entity sorter_tb is
end sorter_tb;

architecture Behavioral of sorter_tb is

    -- Constants
    constant indata_width : integer := 64;
    constant num_obj      : integer := 12;
   type data_array is array (0 to 44) of integer;
    constant input_data : data_array := (1,2,3,5,4,34, 77, 5, 89, 56, 23, 12, 68, 45, 99, 13, 29, 82, 64, 39, 20, 4, 95, 31, 52, 70, 6, 92, 14, 47, 85, 10, 67, 58, 33, 18, 76, 2, 83, 50, 41, 27, 96, 73, 22);


    -- Signals
    signal data         : std_logic_vector(indata_width - 1 downto 0);
    signal valid        : std_logic;
    signal rst          : std_logic;
    signal idxarray_out : outarray(num_obj - 1 downto 0);
    signal clk          : std_logic := '0';
    signal pos          : integer := 0;

    -- Clock period
    constant clk_period : time := 10 ns;

begin

    clk_process : process
    begin
        while True loop
            clk <= '1';
            wait for clk_period/2;
            clk <= '0';
            wait for clk_period/2;
        end loop;
    end process;
    uut: entity work.sorter
        generic map (
            indata_width => indata_width,
            num_obj      => num_obj
        )
        port map (
            data         => data,
            valid        => valid,
            rst          => rst,
            idxarray_out => idxarray_out,
            clk          => clk
        );

    -- Clock generation


    -- Stimulus process
    stim_proc: process
    begin
        valid <= '0';
            rst <= '1';
        wait for clk_period;
        rst <= '0';
    for i in 0 to 43 loop
            data <= std_logic_vector(to_unsigned(input_data(i), indata_width));
            valid <= '1';
            wait for clk_period;    -- Test case 1: Provide input data and assert valid signal
        end loop;

 
    end process stim_proc;

end Behavioral;
