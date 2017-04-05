--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:24:49 04/02/2017
-- Design Name:   
-- Module Name:   C:/Users/Erik Piehl/Dropbox/Omat/trunk/EP994A/fpga/src/tb_tms9900.vhd
-- Project Name:  ep994a
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: tms9900
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
 
ENTITY tb_tms9900 IS
END tb_tms9900;
 
ARCHITECTURE behavior OF tb_tms9900 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT tms9900
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         addr : OUT  std_logic_vector(15 downto 0);
         data_in : IN  std_logic_vector(15 downto 0);
         data_out : OUT  std_logic_vector(15 downto 0);
         rd : OUT  std_logic;
         wr : OUT  std_logic;
         ready : IN  std_logic;
         iaq : OUT  std_logic;
         as : OUT  std_logic;
			test_out : OUT  std_logic_vector(15 downto 0);
         stuck : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal data_in : std_logic_vector(15 downto 0) := (others => '0');
   signal ready : std_logic := '0';

 	--Outputs
   signal addr : std_logic_vector(15 downto 0);
   signal data_out : std_logic_vector(15 downto 0);
   signal rd : std_logic;
   signal wr : std_logic;
   signal iaq : std_logic;
   signal as : std_logic;
	signal test_out : STD_LOGIC_VECTOR (15 downto 0);
   signal stuck : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
	
	
--	type		kbBuffArray is array (0 to 7) of std_logic_vector(6 downto 0);
--	signal	kbBuffer : kbBuffArray;
--	signal	kbInPointer: integer range 0 to 15 :=0;	
	-- Program ROM
	type pgmRomArray is array(0 to 7) of STD_LOGIC_VECTOR (15 downto 0);
	constant pgmRom : pgmRomArray := (
		x"8300", -- initial W
		x"0008", -- initial PC
		x"BEEF",
		x"BEEF",
		x"1000",
		x"02E0",
		x"5678",
		x"10FC"
	);
	signal pgmRomIndex : integer range 0 to 15 := 0;
	
	-- RAM block to 8300
	type ramArray is array (0 to 127) of STD_LOGIC_VECTOR (15 downto 0);
	signal scratchpad : ramArray;
	signal ramIndex : integer range 0 to 15 := 0;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: tms9900 PORT MAP (
          clk => clk,
          reset => reset,
          addr => addr,
          data_in => data_in,
          data_out => data_out,
          rd => rd,
          wr => wr,
          ready => ready,
          iaq => iaq,
          as => as,
			 test_out => test_out,
          stuck => stuck
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
	
   -- Stimulus process
   stim_proc: process
	variable addr_int : integer range 0 to 32767 := 0;
   begin		
      -- hold reset state for 100 ns.
		reset <= '1';
      wait for 100 ns;	
		reset <= '0';
      -- wait for clk_period*20;
      -- insert stimulus here 
		
		for i in 0 to 199 loop
			wait for clk_period/2;
			
			if rd='1' then
				addr_int := to_integer( unsigned( addr(15 downto 1) ));	-- word address
				if addr_int >= 0 and addr_int <= 7 then
					data_in <= pgmRom( addr_int );
				elsif addr_int >= 16768 and addr_int < 16896 then	-- scratch pad memory range in words
					-- we're in the scratchpad
					data_in <= scratchpad( addr_int - 16768 );
				else
					data_in <= x"DEAD";
				end if;
			else
				data_in <= (others => 'Z');
			end if;
			
			if wr = '1' then
				addr_int := to_integer( unsigned( addr(15 downto 1) ));	-- word address
				if addr_int >= 16768 and addr_int < 16896 then	-- scratch pad memory range in words
					-- we're in the scratchpad
					scratchpad( addr_int - 16768 ) <= data_out;
				end if;
			end if;
			
		end loop;
		

      wait;
   end process;

END;