library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use work.sorter_pkg.all;
--use UNISIM.VComponents.all;

entity sorter is
    generic (
        indata_width : integer := 64;
        num_obj      : integer := 12
    );
    port (
        data         : in std_logic_vector (indata_width - 1 downto 0);
        valid        : in std_logic;
        rst          : in std_logic;
        idxarray_out : out outarray(num_obj - 1 downto 0);
        clk          : in std_logic);
end sorter;

architecture Behavioral of sorter is
    type storagearray is array(natural range <>) of std_logic_vector(indata_width - 1 downto 0);
    signal datastorage : storagearray(num_obj - 1 downto 0);
    signal datastorage_temp : storagearray(num_obj - 1 downto 0);
    signal datastorage_out : storagearray(num_obj - 1 downto 0);
    signal idxarray : outarray(num_obj - 1 downto 0) := (others => 0);
    signal idxarray_temp : outarray(num_obj - 1 downto 0) := (others => 0);


    type t_state is (Start, Running, Idle);
    signal state : t_state;
    signal next_state : t_state;
    signal count : natural range 0 to num_obj - 1 := 0;
    signal data_count : natural range 0 to num_obj - 1 := 0;
    signal data_count_temp : natural range 0 to num_obj - 1 := 0;
    --    signal position_temp : natural range 0 to num_obj -1 := 0;
    signal valid_del : std_logic;
begin
    process (clk) is
    begin
        if rising_edge(clk) then
            valid_del <= valid;
        end if;
    end process;
    process (clk) is
    begin
        if rising_edge(clk) then
               if count = 0 then
                    datastorage_out <= datastorage;
                    idxarray_out <= idxarray;
                end if;
            if rst = '1' then
                state <= Idle;
                data_count <= 0;
                count <= 0;
                datastorage <= (others => (others => '0'));
                idxarray <= (others => 0);
            else if valid and not valid_del then 
                state <= Start;
                data_count <= 0;
                count <= 0;
                datastorage <= (others => (others => '0'));
                idxarray <= (others => 0);
            else
                state <= next_state;
                data_count <= data_count_temp;
                if count = num_obj - 1 then
                    count <= 0;
                else
                    count <= count + 1;
                end if;
                --                count <= count_temp;
                --                position <= position_temp;
                datastorage <= datastorage_temp;
                idxarray <= idxarray_temp;


            end if;
        end if;
        end if;
    end process;
    process (all) is
        variable position_temp : integer range 0 to num_obj - 1 := 0;
        variable count_temp : integer range 0 to num_obj - 1 := 0;
--        variable datastorage_calc : storagearray(num_obj - 1 downto 0) := (others => (others => '0'));
--        variable idxarray_calc : outarray(num_obj - 1 downto 0) := (others => 0);
--        variable datacount_calc : integer range 0 to num_obj - 1 := 0;
    begin
        next_state <= state;
        count_temp := count;
        datastorage_temp <= datastorage;
        idxarray_temp <= idxarray;


        --        position_temp <= position;
        data_count_temp <= data_count;
        case state is
            when Start =>
                datastorage_temp <= (others => (others => '0'));
                if valid = '1' then
                    position_temp := 0;
                    next_state <= Running;
                    --                    count_temp :=  0;
                    data_count_temp <= 1;
                    datastorage_temp(num_obj - 1 downto 1) <= (others => (others => '0'));
                    datastorage_temp(0) <= data;
                    idxarray_temp(0) <= count;
                    idxarray_temp(num_obj - 1 downto 1) <=  (others => 0);
                else
                    position_temp := 0;
                    data_count_temp <= 0;
                    idxarray_temp(num_obj - 1 downto 0) <=  (others => 0);
                    datastorage_temp(num_obj - 1 downto 0) <= (others => (others => '0'));
                    next_state <= Running;
                    --                    count_temp :=  0;
                end if;
            when Running =>
                if valid = '1' then
                    if data_count = 0 then
                        
                        datastorage_temp(constval downto 0) <= datastorage(constval downto 0);
                        datastorage_temp(0) <= data;
                        data_count_temp <= 1;
                        
                        idxarray_temp(constval downto 0) <= idxarray(constval downto 0);
                        idxarray_temp(0) <= count;
                    elsif datastorage(0) > data then
                        position_temp := 0;
                        datastorage_temp(datastorage_temp'high downto 1) <= datastorage(datastorage'high - 1 downto 0);
                        datastorage_temp(0) <= data;
                        idxarray_temp(idxarray_temp'high downto 1) <= idxarray(idxarray'high - 1 downto 0);
                        idxarray_temp(0) <= count;
                        data_count_temp <= data_count + 1;
                    elsif datastorage(data_count - 1) < data then
                        datastorage_temp <= datastorage;
                        datastorage_temp(data_count) <= data;
                        data_count_temp <= data_count + 1;
                        idxarray_temp <= idxarray;
                        idxarray_temp(data_count) <= count;

                    else
                        for item in 1 to 10 loop
                            if datastorage(item - 1) < data and datastorage(item) >= data then
                                datastorage_temp(datastorage_temp'high downto  item + 1) <= datastorage(datastorage'high - 1 downto item);
                                datastorage_temp(item) <= data;
                                idxarray_temp(idxarray_temp'high downto item + 1) <= idxarray(idxarray'high - 1 downto item); 
                                idxarray_temp(item) <= count;
                            end if;
                        end loop;
                        data_count_temp <= data_count + 1;
                    end if;
                else
                    data_count_temp <= data_count;
                    --                    position_temp <= constval;
                end if;

                if count = num_obj - 1 then
                    next_state <= Start;
                    --                    count_temp <= count + 1;
                else
                    next_state <= Running;
                    --                    count_temp <= count + 1;
                end if;
            when Idle =>
                next_state <= Idle;
        end case;
    end process;

end Behavioral;