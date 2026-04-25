-- created by: yashar zavary rezaie
-- Date: April 25, 2025
-- subject: RAM structure
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity RAM is
port(
	enable: in std_logic;
	clk: in std_logic;
	w_address, r_address: in std_logic_vector(19 downto 0);
	r_out: out std_logic_vector(23 downto 0);
	w_in: in std_logic_vector(23 downto 0)

);
end RAM;


architecture ram_flow of RAM is
    type ram_type is array (0 to 2**20 - 1) of std_logic_vector(23 downto 0);
    signal ram : ram_type;
    signal r_reg : std_logic_vector(23 downto 0);
begin

    process(clk)
    begin
        if rising_edge(clk) then

            -- WRITE
            if enable = '1' then
                ram(to_integer(unsigned(w_address))) <= w_in;
            end if;

            -- READ (synchronous!)
            r_reg <= ram(to_integer(unsigned(r_address)));

        end if;
    end process;

    r_out <= r_reg;

end ram_flow;