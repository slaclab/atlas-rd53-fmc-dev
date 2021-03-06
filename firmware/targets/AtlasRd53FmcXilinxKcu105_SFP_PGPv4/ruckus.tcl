# Load RUCKUS environment and library
source -quiet $::env(RUCKUS_DIR)/vivado_proc.tcl

# Load common and sub-module ruckus.tcl files
loadRuckusTcl $::env(TOP_DIR)/submodules/surf
loadRuckusTcl $::env(TOP_DIR)/submodules/atlas-rd53-fw-lib
loadRuckusTcl $::env(TOP_DIR)/common/fmc

# Load local source Code and constraints
loadSource      -dir  "$::DIR_PATH/hdl"
loadConstraints -path "$::DIR_PATH/../../submodules/axi-pcie-core/hardware/XilinxKcu105/xdc/XilinxKcu105App.xdc"
loadConstraints -dir  "$::DIR_PATH/../AtlasRd53FmcXilinxKcu105Pcie/hdl"
loadConstraints -dir  "$::DIR_PATH/hdl"
