library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;

use std.textio.all;


entity EDIdevnullCS3 is
  port (
    EBICLK  : in    std_logic;
    EBICSN  : in    std_logic_vector (3 downto 0);
    EBIBE   : in    std_logic_vector (1 downto 0);
    EBIWEN  : in    std_logic;
    EBIOEN  : in    std_logic;
    EBIADDR : in    std_logic_vector (24 downto 0);
    EBIDQ   : inout std_logic_vector (15 downto 0)
    );
end EDIdevnullCS3;


architecture EBIdevnullCS3arch of EDIdevnullCS3 is

  signal EBICSN_int : std_logic_vector (3 downto 0);

begin  -- EBIdevnullCS3arch

  EBIDQ      <= (others => 'Z');
  EBICSN_int <= transport EBICSN after 1 ns;

-- process (EBICLK)
  process (EBIWEN)
    variable addr    : std_logic_vector (31 downto 0) := x"00000000";
    variable data_lo : std_logic_vector (15 downto 0);
    variable data_hi : std_logic_vector (15 downto 0);

    variable l   : line;
    -- file logfile : text is out "flashwrite.txt";
    file logfile : text open write_mode is "flashwrite.txt";
  begin  -- process
--    if EBICLK'event and EBICLK = '1' then  -- rising clock edge
    if EBIWEN'event and EBIWEN = '1' then    -- rising clock edge
      if EBICSN_int(3) = '0' then
        if EBIOEN = '1' then
          --         if EBIWEN = '0' then
          -- write to file
          --        hwrite(l, ("000" & EBIADDR), RIGHT, 10);
          --        write(l, ' ');
          --        hwrite(l, EBIDQ, RIGHT, 6);
--            writeline(logfile, l);
          --         end if;

          if EBIADDR(1) = '0' then
            addr (24 downto 0) := EBIADDR;
            data_lo            := EBIDQ;
          else
            data_hi            := EBIDQ;

            if addr(10 downto 0) = "00000000000" then
              write(l, ' ');
              writeline(logfile, l);
            end if;

            hwrite(l, addr, left, 8);
            write(l, ' ');
            hwrite(l, data_hi, left, 4);
            hwrite(l, data_lo, left, 4);
            writeline(logfile, l);
            addr    := (others => 'U');
            data_lo := (others => 'U');
            data_hi := (others => 'U');
          end if;
        end if;
      end if;
    end if;
  end process;

end EBIdevnullCS3arch;



