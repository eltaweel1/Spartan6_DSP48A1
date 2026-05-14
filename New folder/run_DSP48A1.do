vlib work
vlog DSP48A1.v DSP48A1_regging_sync.v DSP48A1_TB.v
vsim -voptargs=+acc work.DSP48A1_TB
add wave *
run -all
#quit -sim