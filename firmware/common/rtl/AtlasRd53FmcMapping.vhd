-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcMapping.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description: FMC mappipng
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the 
-- top-level directory of this distribution and at: 
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
-- No part of 'ATLAS RD53 DEV', including this file, 
-- may be copied, modified, propagated, or distributed except according to 
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.StdRtlPkg.all;
use work.AxiLitePkg.all;
use work.AxiStreamPkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcMapping is
   generic (
      TPD_G        : time    := 1 ns;
      SIMULATION_G : boolean := false;
      XIL_DEVICE_G : string  := "7SERIES");
   port (
      -- Timing Clock/Reset Interface
      clk640MHz    : out   sl;
      clk160MHz    : out   sl;
      rst160MHz    : out   sl;
      -- PLL Interface
      fpgaPllClkIn : in    sl;
      pllRst       : in    slv(3 downto 0);
      pllCsL       : in    sl;
      pllSck       : in    sl;
      pllSdi       : in    sl;
      pllSdo       : out   sl;
      -- mDP DATA/CMD Interface
      dPortDataP   : out   Slv4Array(3 downto 0);
      dPortDataN   : out   Slv4Array(3 downto 0);
      dPortCmdP    : in    slv(3 downto 0);
      dPortCmdN    : in    slv(3 downto 0);
      -- I2C Interface
      i2cScl       : inout slv(3 downto 0);
      i2cSda       : inout slv(3 downto 0);
      -- FMC LPC Ports
      fmcLaP       : inout slv(33 downto 0);
      fmcLaN       : inout slv(33 downto 0));
end AtlasRd53FmcMapping;

architecture mapping of AtlasRd53FmcMapping is

   signal pllReset : sl;
   signal pllClk   : slv(1 downto 0);

begin

   pllReset <= uOr(pllRst);

   GEN_PLL_CLK :
   for i in 1 downto 0 generate
      U_IBUFDS : IBUFDS
         port map (
            I  => fmcLaP(i+0),
            IB => fmcLaN(i+0),
            O  => pllClk(i));
   end generate GEN_PLL_CLK;

   U_FmcMmcm : entity work.AtlasRd53FmcMmcm
      generic map(
         TPD_G        => TPD_G,
         SIMULATION_G => SIMULATION_G)
      port map (
         pllClk    => pllClk(0),
         pllRst    => pllReset,
         -- Timing Clock/Reset Interface
         clk640MHz => clk640MHz,
         clk160MHz => clk160MHz,
         rst160MHz => rst160MHz);

   U_fpgaPllClk : entity work.ClkOutBufDiff
      generic map (
         TPD_G        => TPD_G,
         XIL_DEVICE_G => XIL_DEVICE_G)
      port map (
         clkIn   => fpgaPllClkIn,
         clkOutP => fmcLaP(2),
         clkOutN => fmcLaN(2));

   fmcLaP(3) <= pllSck;
   fmcLaN(3) <= pllSdi;
   fmcLaP(4) <= pllCsL;
   pllSdo    <= fmcLaN(4);

   GEN_DP :
   for i in 3 downto 0 generate

      fmcLaP(5+i*5) <= dPortCmdP(i);
      fmcLaN(5+i*5) <= dPortCmdN(i);

      GEN_LANE :
      for j in 3 downto 0 generate
         dPortDataP(i)(j) <= fmcLaP(6+i*5+j);
         dPortDataN(i)(j) <= fmcLaN(6+i*5+j);
      end generate GEN_LANE;

   end generate GEN_DP;

   GEN_I2C :
   for i in 3 downto 0 generate
      fmcLaP(30+i) <= i2cScl(i);
      fmcLaN(30+i) <= i2cSda(i);
   end generate GEN_I2C;

end mapping;