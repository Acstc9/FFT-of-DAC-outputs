vlib work
vlog dds_rom_3bit.v
vlog tb_dds_rom_3bit.v
vsim work.tb_dds_rom_3bit

add wave -position insertpoint sim:/tb_dds_rom_3bit/clk
add wave -position insertpoint sim:/tb_dds_rom_3bit/rst_n
add wave -position insertpoint -radix unsigned -format Analog-Step -min 0 -max 7 sim:/tb_dds_rom_3bit/dac_code

run -all
