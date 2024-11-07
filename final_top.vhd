
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_unsigned.ALL; -- needed for conv_integer

ENTITY final_top IS
    PORT (
        CLK100MHZ : IN STD_LOGIC; -- System clock 
        btnC : IN STD_LOGIC;
        sw : IN STD_LOGIC_VECTOR (15 DOWNTO 0); -- 16 switch inputs
        LED : OUT STD_LOGIC_VECTOR (15 DOWNTO 0); -- 16 leds above switches
        JA : INOUT STD_LOGIC_VECTOR (5 DOWNTO 0)
    );
END final_top;

ARCHITECTURE final_top OF final_top IS

    --declare PLL to create 11.29 MHz master clock from 100 MHz system clock
   -- COMPONENT clk_wiz_0
   --     PORT (
   --         clk_in1 : IN STD_LOGIC := '0';
   --         clk_out1 : OUT STD_LOGIC);
   -- END COMPONENT;

    -- Reference: https://forum.digikey.com/t/i2s-pmod-quick-start-vhdl/13065
    -- The code above was used to create the 11.29 MHz master clock from 100 MHz system clock
    -- This PLL will help match the clock in order to pass the frequency

    SIGNAL clk1counter : STD_LOGIC_VECTOR(24 DOWNTO 0);
    -- signal clk2counter : integer := 0; - may need later
    SIGNAL output_square_wave : STD_LOGIC := '0';

    -- wires from switches
    SIGNAL x : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL l_data : STD_LOGIC_VECTOR(15 DOWNTO 0); --left channel data to transmit
    SIGNAL r_data : STD_LOGIC_VECTOR(15 DOWNTO 0); --right channel data to transmit    

BEGIN

    -- instantiate PLL to create master clock
   -- i2s_clock : clk_wiz_0
   -- PORT MAP(clk_in1 => clock, clk_out1 => master_clk);

    PROCESS (CLK100MHZ)
    BEGIN
        IF rising_edge(CLK100MHZ) THEN
            clk1counter <= clk1counter + '1';
            output_square_wave <= clk1counter(14); -- about 6,000 KHZ
            IF output_square_wave = '1' THEN
                l_data <= (OTHERS => '1'); -- Assigning '1's to l_data when output_square_wave is '1'
                r_data <= (OTHERS => '1'); -- Assigning '0's to r_data when output_square_wave is '1'
            ELSE
                l_data <= (OTHERS => '0'); -- Assigning '0's to l_data when output_square_wave is '0'
                r_data <= (OTHERS => '0'); -- Assigning '0's to r_data when output_square_wave is '0'
            END IF;
        END IF;
    END PROCESS;

    --LED(0) <= output_square_wave; -- instead of led(0) drive to speak
    i2s_unit : ENTITY work.i2s_transceiver
        PORT MAP(
            reset_n => btnC, --asynchronous active low reset
            mclk => CLK100MHZ, --master clock
            ws => JA(1), -- left right clock
            sclk => JA(2), --serial clock (or bit clock)
            sd_tx => JA(3),
            l_data_tx => l_data,
            r_data_tx => r_data
        );
    JA(0) <= CLK100MHZ;
END final_top;