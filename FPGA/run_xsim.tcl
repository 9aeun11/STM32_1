set root [file normalize [file dirname [info script]]]
foreach lab {Piano Traffic ADC} {
    set project_file [file join $root vivado_projects $lab ${lab}.xpr]
    puts "===== $lab: XSim behavioral simulation ====="
    open_project $project_file
    launch_simulation -simset sim_1 -mode behavioral
    run all
    close_sim
    close_project
    puts "FINISHED $lab XSim"
}
puts "XSim sequence finished"
