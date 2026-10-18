# Run with: vivado -mode batch -source build_all_vivado.tcl
set root [file normalize [file dirname [info script]]]
set failed {}
foreach lab {Piano Traffic ADC} {
    puts "===== $lab: project, synthesis, implementation, bitstream ====="
    set ::env(LAB) $lab
    set project_file [file join $root vivado_projects $lab ${lab}.xpr]
    if {[file exists $project_file]} {
        open_project $project_file
    } else {
        if {[catch {source [file join $root create_vivado_project.tcl]} message]} {
            lappend failed "$lab project: $message"
            continue
        }
    }
    if {[catch {
        launch_runs synth_1 -jobs 4
        wait_on_run synth_1
        if {[get_property PROGRESS [get_runs synth_1]] ne "100%"} {
            error "synthesis progress: [get_property PROGRESS [get_runs synth_1]]"
        }
        launch_runs impl_1 -to_step write_bitstream -jobs 4
        wait_on_run impl_1
        set bitfiles [glob -nocomplain [file join $root vivado_projects $lab ${lab}.runs impl_1 *.bit]]
        if {[llength $bitfiles] == 0} { error "No .bit file was generated" }
        puts "PASS $lab bitstream: [lindex $bitfiles 0]"
    } message]} {
        lappend failed "$lab build: $message"
        puts "FAIL $lab build: $message"
    }
    close_project
}
if {[llength $failed]} { error "Vivado failures: [join $failed {; }]" }
puts "PASS all Vivado bitstreams"
