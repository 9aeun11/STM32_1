# Run in Vivado Tcl Console after setting LAB to Piano, Traffic, or ADC.
# The pin constraints are taken from the supplied Xilinx S7 pin map and
# cross-checked against the vendor example XDC files.

if {![info exists ::env(LAB)] || $::env(LAB) ni {Piano Traffic ADC}} {
    error "Set LAB to Piano, Traffic, or ADC (e.g. set ::env(LAB) Piano)."
}
set lab $::env(LAB)
# Matches the part used by the existing Combo II-DLD course project.
set part xc7s75fgga484-1
if {[info exists ::env(FPGA_PART)] && $::env(FPGA_PART) ne ""} {
    set part $::env(FPGA_PART)
}
set module_name [string tolower $lab]
set design_top $module_name
set root [file normalize [file dirname [info script]]]
set src_dir [file join $root $lab]
set out_dir [file join $root vivado_projects $lab]
file mkdir [file dirname $out_dir]

if {[file exists [file join $out_dir ${lab}.xpr]]} {
    error "Project already exists at $out_dir; open it or remove that generated project before recreating it."
}
create_project $lab $out_dir -part $part
set_property target_language Verilog [current_project]
add_files -fileset sources_1 [file join $src_dir ${module_name}.sv]
if {$lab eq "ADC"} {
    add_files -fileset sources_1 [file join $src_dir adc_board.sv]
    set design_top adc_board
}
add_files -fileset constrs_1 [file join $src_dir pins.xdc]
switch -- $lab {
    Piano   { set sim_top tb_piano }
    Traffic { set sim_top tb_traffic }
    ADC     { set sim_top tb_adc }
}
add_files -fileset sim_1 [file join $src_dir tb_${module_name}.sv]
set_property top $design_top [get_filesets sources_1]
set_property top $sim_top [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
puts "Created $lab project for part $part; design top is $design_top; simulation top is $sim_top."
