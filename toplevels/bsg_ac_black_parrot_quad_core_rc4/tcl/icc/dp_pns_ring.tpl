template : bsg_power_ring(h_layer,h_width,h_spacing,h_offset,v_layer,v_width,v_spacing,v_offset) { # ring template for power ring creation
side : horizontal {
	layer : @h_layer
	width : @h_width
	spacing : @h_spacing
	offset : @h_offset
}
side : vertical {
	layer : @v_layer
	width : @v_width
	spacing : @v_spacing
	offset : @v_offset
}

  # Advanced rules for power plan creation
    advanced_rule : on { #all the advanced rules are turned off
	corner_bridge : on #connecting all rings at the corners
	align_std_cell_rail : off #align horizontal ring segments with std cell rails
	honor_advanced_via_rule : off # honor advanced via rules
    }
}
