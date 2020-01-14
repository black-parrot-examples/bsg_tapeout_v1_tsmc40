template : m10_strap_ppt(w,s,p,o) {
  layer : M10 {
    direction : horizontal
    width : @w
    spacing : @s
    number :
    pitch : @p
    offset_type : edge                  # the offset is the distance between the routing region boundary and the edge of the first strap.
    offset_start : boundary             # the placement begins at the boundary of the routing area defined in the strategy.
    offset : @o
    trim_strap : false
  }

  advanced_rule : on {
    stack_vias: specified { 
      connect_layers : {M5 M10}
    }
    align_strap_with_stdcell_rail : off {
      layer : M10
      align_with_rail : true
      put_strap_in_row : false
    }
  }
}

template : m9_strap_ppt(w,s,p,o) {
  layer : M9 {
    direction : vertical
    width : @w
    spacing : @s
    number :
    pitch : @p
    offset_type : edge                  # the offset is the distance between the routing region boundary and the edge of the first strap.
    offset_start : boundary             # the placement begins at the boundary of the routing area defined in the strategy.
    offset : @o
    trim_strap : false
  }

  advanced_rule: on {
    stack_vias: adjacent
    optimize_routing_tracks: on {
      layer : M9
      alignment : false
      sizing : false
    }
  }
}

template : m8_strap_ppt(w,s,p,o) {
  layer : M8 {
    direction : horizontal
    width : @w
    spacing : @s
    number :
    pitch : @p
    offset_type : edge                  # the offset is the distance between the routing region boundary and the edge of the first strap.
    offset_start : boundary             # the placement begins at the boundary of the routing area defined in the strategy.
    offset : @o
    trim_strap : false
  }

  advanced_rule : on {
    stack_vias: adjacent
    align_strap_with_stdcell_rail : off {
      layer : M8
      align_with_rail : true
      put_strap_in_row : false
    }
  }
}

template : m7_strap_ppt(w,s,p,o) {
  layer : M7 {
    direction : vertical
    width : @w
    spacing : @s
    number :
    pitch : @p
    offset_type : edge                  # the offset is the distance between the routing region boundary and the edge of the first strap.
    offset_start : boundary             # the placement begins at the boundary of the routing area defined in the strategy.
    offset : @o
    trim_strap : false
  }

  advanced_rule: on {
    stack_vias: adjacent
    optimize_routing_tracks: off {
      layer : M7
      alignment : true
      sizing : false
    }
  }
}

template : m6_strap_ppt(w,s,p,o) {
  layer : M6 {
    direction : vertical
    width : @w
    spacing : @s
    number :
    pitch : @p
    offset_type : edge                  # the offset is the distance between the routing region boundary and the edge of the first strap.
    offset_start : boundary             # the placement begins at the boundary of the routing area defined in the strategy.
    offset : @o
    trim_strap : false
  }

  advanced_rule: on {
    stack_vias: adjacent
    optimize_routing_tracks: off {
      layer : M6
      alignment : true
      sizing : false
    }
  }
}

template : m5_strap_ppt(w,s,p,o) {
  layer : M5 {
    direction : vertical
    width : @w
    spacing : @s
    number :
    pitch : @p
    offset_type : edge                  # the offset is the distance between the routing region boundary and the edge of the first strap.
    offset_start : boundary             # the placement begins at the boundary of the routing area defined in the strategy.
    offset : @o
    trim_strap : false
  }

  advanced_rule: on {
    stack_vias: adjacent
    optimize_routing_tracks: off {
      layer : M5
      alignment : true
      sizing : false
    }
  }
}

