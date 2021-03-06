// VGA/HDMI Driver Includes
$include('../common/vga.ice')
$include('../common/uart.ice')

// Multiplexed Display Includes
$include('../terminal.ice')
$include('../character_map.ice')
$include('../bitmap.ice')
$include('../gpu.ice')
$include('../background.ice')
$include('../sprite_layer.ice')

import('../common/de10nano_clk_100_25.v')
import('../common/reset_conditioner.v')

$include('../j1eforth.ice')
