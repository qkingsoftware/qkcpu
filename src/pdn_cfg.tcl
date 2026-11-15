# The SRAM power pins are on Metal3. Connect them to the vertical core grid.
source $::env(SCRIPTS_DIR)/openroad/common/pdn_cfg.tcl

add_pdn_connect \
    -grid macro \
    -layers "Metal3 $::env(PDN_VERTICAL_LAYER)"
