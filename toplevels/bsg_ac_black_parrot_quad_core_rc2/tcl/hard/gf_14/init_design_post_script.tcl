if { $DESIGN_NAME == "bsg_chip" } {
proc bsg_dont_touch_regexp {arg1} {
    set pattern "full_name=~$arg1";
    set mycells [get_cells -hier -filter $pattern]
    puts [concat "BSG: set dont_touch'ing " $pattern "=" [collection_to_list $mycells]]
    set_dont_touch $mycells
}

proc bsg_dont_touch_regexp_type {arg1} {
    set pattern "ref_name=~$arg1";
    set mycells [get_cells -hier -filter $pattern]
    puts [concat "BSG: set dont_touch'ing " $pattern "=" [collection_to_list $mycells]]
    set_dont_touch $mycells
}

bsg_dont_touch_regexp */adt/*
bsg_dont_touch_regexp */cdt/*
bsg_dont_touch_regexp */fdt/*
bsg_dont_touch_regexp *BSG_BAL41MUX*
bsg_dont_touch_regexp_type *SYNC*SDFF*
}
