##############################################################################
## This file is part of 'ATLAS RD53 FMC DEV'.
## It is subject to the license terms in the LICENSE.txt file found in the 
## top-level directory of this distribution and at: 
##    https://confluence.slac.stanford.edu/display/ppareg/LICENSE.html. 
## No part of 'ATLAS RD53 FMC DEV', including this file, 
## may be copied, modified, propagated, or distributed except according to 
## the terms contained in the LICENSE.txt file.
##############################################################################



set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_App/U_FmcMapping/U_Selectio/U_Bufg160/O]] -group [get_clocks -of_objects [get_pins U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]]

set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_App/U_FmcMapping/U_Selectio/U_Bufg160/O]] -group [get_clocks -of_objects [get_pins U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]] -group [get_clocks -of_objects [get_pins {U_PGPv3/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_6G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe4_top.Pgp3GthUsIp6G_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_tx_user_clocking_internal.gen_single_instance.gtwiz_userclk_tx_inst/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]] -group [get_clocks -of_objects [get_pins {U_PGPv3/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_6G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe4_top.Pgp3GthUsIp6G_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_rx_user_clocking_internal.gen_single_instance.gtwiz_userclk_rx_inst/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_PGPv3/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_6G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe4_top.Pgp3GthUsIp6G_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_tx_user_clocking_internal.gen_single_instance.gtwiz_userclk_tx_inst/gen_gtwiz_userclk_tx_main.bufg_gt_usrclk2_inst/O}]] -group [get_clocks -of_objects [get_pins {U_PGPv3/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_6G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe4_top.Pgp3GthUsIp6G_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_rx_user_clocking_internal.gen_single_instance.gtwiz_userclk_rx_inst/gen_gtwiz_userclk_rx_main.bufg_gt_usrclk2_inst/O}]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {U_PGPv3/REAL_PGP.GEN_LANE[0].U_Pgp/U_Pgp3GthUsIpWrapper_1/GEN_6G.U_Pgp3GthUsIp/inst/gen_gtwizard_gthe4_top.Pgp3GthUsIp6G_gtwizard_gthe4_inst/gen_gtwizard_gthe4.gen_channel_container[2].gen_enabled_channel.gthe4_channel_wrapper_inst/channel_inst/gthe4_channel_gen.gen_gthe4_channel_inst[0].GTHE4_CHANNEL_PRIM_INST/RXOUTCLKPCS}]] -group [get_clocks -of_objects [get_pins U_MMCM/MmcmGen.U_Mmcm/CLKOUT1]]

set_clock_groups -asynchronous -group [get_clocks {sfpClk156P}] -group [get_clocks -include_generated_clocks {fmcHpc0LaP0}]
set_clock_groups -asynchronous -group [get_clocks {sfpClk156P}] -group [get_clocks -include_generated_clocks {fmcHpc0LaP1}]
set_clock_groups -asynchronous -group [get_clocks {sfpClk156P}] -group [get_clocks {clk160MHz}]