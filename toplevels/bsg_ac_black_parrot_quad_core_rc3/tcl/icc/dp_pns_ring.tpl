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

template : core_h10v9_prt(h_width,h_offset,h_spacing,v_width,v_offset,v_spacing) {
  side : horizontal {
    layer : M10
    width : @h_width
    spacing : @h_spacing
    offset : @h_offset
  }
  side : vertical {
    layer : M9
    width : @v_width
    spacing : @v_spacing
    offset : @v_offset
  }
  advanced_rule : on {
    corner_bridge : on
  }
}

template : block_v9h8_prt(h_width,h_offset,h_spacing,v_width,v_offset,v_spacing) {
  side : vertical {
    layer : M9
    width : @v_width
    spacing : @v_spacing
    offset : @v_offset
  }
  side : horizontal {
    layer : M8
    width : @h_width
    spacing : @h_spacing
    offset : @h_offset
  }
  advanced_rule : on {
    corner_bridge : on
  }
}

template : block_h8v7_prt(width,offset,spacing) {
  side : horizontal {
    layer : M8
    width : @width
    spacing : @spacing
    offset : @offset
  }
  side : vertical {
    layer : M7
    width : @width
    spacing : @spacing
    offset : @offset
  }
  advanced_rule : on {
    corner_bridge : on
  }
}
