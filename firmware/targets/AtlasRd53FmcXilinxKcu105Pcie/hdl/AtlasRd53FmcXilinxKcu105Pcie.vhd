-------------------------------------------------------------------------------
-- File       : AtlasRd53FmcXilinxKcu105Pcie.vhd
-- Company    : SLAC National Accelerator Laboratory
-------------------------------------------------------------------------------
-- Description:
-------------------------------------------------------------------------------
-- This file is part of 'ATLAS RD53 FMC DEV'.
-- It is subject to the license terms in the LICENSE.txt file found in the
-- top-level directory of this distribution and at:
--    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html.
-- No part of 'ATLAS RD53 FMC DEV', including this file,
-- may be copied, modified, propagated, or distributed except according to
-- the terms contained in the LICENSE.txt file.
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

library surf;
use surf.StdRtlPkg.all;
use surf.AxiLitePkg.all;
use surf.AxiStreamPkg.all;
use surf.SsiPkg.all;

library axi_pcie_core;
use axi_pcie_core.AxiPciePkg.all;

library unisim;
use unisim.vcomponents.all;

entity AtlasRd53FmcXilinxKcu105Pcie is
   generic (
      TPD_G          : time    := 1 ns;
      ROGUE_SIM_EN_G : boolean := false;
      BUILD_INFO_G   : BuildInfoType);
   port (
      ---------------------
      --  Application Ports
      ---------------------
      -- FMC Interface
      fmcHpcLaP  : inout slv(33 downto 0);
      fmcHpcLaN  : inout slv(33 downto 0);
      fmcLpcLaP  : inout slv(33 downto 0);
      fmcLpcLaN  : inout slv(33 downto 0);
      -- SFP Interface
      sfpClk156P : in    sl;
      sfpClk156N : in    sl;
      sfpTxP     : out   slv(1 downto 0);
      sfpTxN     : out   slv(1 downto 0);
      sfpRxP     : in    slv(1 downto 0);
      sfpRxN     : in    slv(1 downto 0);
      --------------
      --  Core Ports
      --------------
      -- System Ports
      emcClk     : in    sl;
      -- Boot Memory Ports
      flashCsL   : out   sl;
      flashMosi  : out   sl;
      flashMiso  : in    sl;
      flashHoldL : out   sl;
      flashWp    : out   sl;
      -- PCIe Ports
      pciRstL    : in    sl;
      pciRefClkP : in    sl;
      pciRefClkN : in    sl;
      pciRxP     : in    slv(7 downto 0);
      pciRxN     : in    slv(7 downto 0);
      pciTxP     : out   slv(7 downto 0);
      pciTxN     : out   slv(7 downto 0));
end AtlasRd53FmcXilinxKcu105Pcie;

architecture top_level of AtlasRd53FmcXilinxKcu105Pcie is

   constant DMA_AXIS_CONFIG_C : AxiStreamConfigType := (
      TSTRB_EN_C    => false,
      TDATA_BYTES_C => 8,               -- 64-bit data interface
      TDEST_BITS_C  => 8,
      TID_BITS_C    => 0,
      TKEEP_MODE_C  => TKEEP_COMP_C,
      TUSER_BITS_C  => 2,
      TUSER_MODE_C  => TUSER_FIRST_LAST_C);

   signal dmaClk       : sl;
   signal dmaRst       : sl;
   signal dmaObMasters : AxiStreamMasterArray(1 downto 0);
   signal dmaObSlaves  : AxiStreamSlaveArray(1 downto 0);
   signal dmaIbMasters : AxiStreamMasterArray(1 downto 0);
   signal dmaIbSlaves  : AxiStreamSlaveArray(1 downto 0);

   signal sfpClk156     : sl;
   signal sfpClk156Bufg : sl;
   signal iDelayCtrlRdy : sl;
   signal refClk300MHz  : sl;
   signal refRst300MHz  : sl;

   attribute IODELAY_GROUP                 : string;
   attribute IODELAY_GROUP of U_IDELAYCTRL : label is "rd53_aurora";

   attribute KEEP_HIERARCHY                 : string;
   attribute KEEP_HIERARCHY of U_IDELAYCTRL : label is "TRUE";

begin

   U_TERM_GTs : entity surf.Gthe3ChannelDummy
      generic map (
         TPD_G   => TPD_G,
         WIDTH_G => 2)
      port map (
         refClk => sfpClk156Bufg,
         gtRxP  => sfpRxP,
         gtRxN  => sfpRxN,
         gtTxP  => sfpTxP,
         gtTxN  => sfpTxN);

   U_IBUFDS_GTE3 : IBUFDS_GTE3
      generic map (
         REFCLK_EN_TX_PATH  => '0',
         REFCLK_HROW_CK_SEL => "00",    -- 2'b00: ODIV2 = O
         REFCLK_ICNTL_RX    => "00")
      port map (
         I     => sfpClk156P,
         IB    => sfpClk156N,
         CEB   => '0',
         ODIV2 => sfpClk156,
         O     => open);

   U_BUFG_GT : BUFG_GT
      port map (
         I       => sfpClk156,
         CE      => '1',
         CEMASK  => '1',
         CLR     => '0',
         CLRMASK => '1',
         DIV     => "000",
         O       => sfpClk156Bufg);

   U_MMCM : entity surf.ClockManagerUltraScale
      generic map(
         TPD_G              => TPD_G,
         SIMULATION_G       => ROGUE_SIM_EN_G,
         TYPE_G             => "MMCM",
         INPUT_BUFG_G       => false,
         FB_BUFG_G          => true,
         RST_IN_POLARITY_G  => '1',
         NUM_CLOCKS_G       => 1,
         -- MMCM attributes
         BANDWIDTH_G        => "OPTIMIZED",
         CLKIN_PERIOD_G     => 6.4,
         DIVCLK_DIVIDE_G    => 1,
         CLKFBOUT_MULT_F_G  => 6.0,
         CLKOUT0_DIVIDE_F_G => 3.125)   -- 300 MHz = 937.5 MHz/3.125
      port map(
         clkIn     => sfpClk156Bufg,
         rstIn     => dmaRst,
         clkOut(0) => refClk300MHz,
         rstOut(0) => refRst300MHz);

   U_IDELAYCTRL : IDELAYCTRL
      generic map (
         SIM_DEVICE => "ULTRASCALE")
      port map (
         RDY    => iDelayCtrlRdy,
         REFCLK => refClk300MHz,
         RST    => refRst300MHz);

   -----------------------
   -- axi-pcie-core module
   -----------------------
   U_Core : entity axi_pcie_core.XilinxKcu105Core
      generic map (
         TPD_G                => TPD_G,
         ROGUE_SIM_EN_G       => ROGUE_SIM_EN_G,
         ROGUE_SIM_PORT_NUM_G => 8000,
         ROGUE_SIM_CH_COUNT_G => 8,
         BUILD_INFO_G         => BUILD_INFO_G,
         DMA_AXIS_CONFIG_G    => DMA_AXIS_CONFIG_C,
         DMA_SIZE_G           => 2)
      port map (
         ------------------------
         --  Top Level Interfaces
         ------------------------
         -- DMA Interfaces
         dmaClk         => dmaClk,
         dmaRst         => dmaRst,
         dmaObMasters   => dmaObMasters,
         dmaObSlaves    => dmaObSlaves,
         dmaIbMasters   => dmaIbMasters,
         dmaIbSlaves    => dmaIbSlaves,
         -- Application AXI-Lite Interfaces [0x00080000:0x00FFFFFF]
         appClk         => dmaClk,
         appRst         => dmaRst,
         ------------------------------------------------------------------------------------------------------
         -- Not using IOMEMORY interface because the slow I2C transactions would bottleneck the CPU performance
         -- We will use SRPv3 on the DMA to do register access through a messaging protocol instead
         ------------------------------------------------------------------------------------------------------
         appReadMaster  => open,
         appReadSlave   => AXI_LITE_READ_SLAVE_EMPTY_OK_C,
         appWriteMaster => open,
         appWriteSlave  => AXI_LITE_WRITE_SLAVE_EMPTY_OK_C,
         --------------
         --  Core Ports
         --------------
         -- System Ports
         emcClk         => emcClk,
         -- Boot Memory Ports
         flashCsL       => flashCsL,
         flashMosi      => flashMosi,
         flashMiso      => flashMiso,
         flashHoldL     => flashHoldL,
         flashWp        => flashWp,
         -- PCIe Ports
         pciRstL        => pciRstL,
         pciRefClkP     => pciRefClkP,
         pciRefClkN     => pciRefClkN,
         pciRxP         => pciRxP,
         pciRxN         => pciRxN,
         pciTxP         => pciTxP,
         pciTxN         => pciTxN);

   -------------
   -- FMC Module
   -------------
   U_App : entity work.AtlasRd53FmcCore
      generic map (
         TPD_G             => TPD_G,
         BUILD_INFO_G      => BUILD_INFO_G,
         SIMULATION_G      => ROGUE_SIM_EN_G,
         DMA_AXIS_CONFIG_G => DMA_AXIS_CONFIG_C,
         DMA_CLK_FREQ_G    => DMA_CLK_FREQ_C,
         XIL_DEVICE_G      => "ULTRASCALE")
      port map (
         -- I/O Delay Interfaces
         iDelayCtrlRdy => iDelayCtrlRdy,
         -- DMA Interface (dmaClk domain)
         dmaClk        => dmaClk,
         dmaRst        => dmaRst,
         dmaObMasters  => dmaObMasters,
         dmaObSlaves   => dmaObSlaves,
         dmaIbMasters  => dmaIbMasters,
         dmaIbSlaves   => dmaIbSlaves,
         -- FMC LPC Ports
         fmcLaP        => fmcHpcLaP,
         fmcLaN        => fmcHpcLaN);

end top_level;
