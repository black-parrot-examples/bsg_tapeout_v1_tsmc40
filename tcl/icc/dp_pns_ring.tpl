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

template : block_v9h8_prt(width,offset,spacing) {
  side : vertical {
    layer : M9
    width : @width
    spacing : @spacing
    offset : @offset
  }
  side : horizontal {
    layer : M8
    width : @width
    spacing : @spacing
    offset : @offset
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
}
