vlib work
vlog DSP48A1.v DSP48A1_tb.v
vsim -voptargs=+acc work.dsp48a1_tb
add wave *
run -all
#quit -sim