################################################################################
# Date: 7/30/2024            
# Name: Vic Chen             
################################################################################

## Create Routing Blockage on I/O pads to avoid routing on them

set LL [get_attribute cornerLL bbox]
set LR [get_attribute cornerLR bbox]
set UR [get_attribute cornerUR bbox]
set UL [get_attribute cornerUL bbox]

set x1 [lindex [lindex $LL 0] 0]
set y1 [lindex [lindex $LL 0] 1]

set x2 [lindex [lindex $LR 0] 0]
set y2 [lindex [lindex $LR 0] 1]

set x3 [lindex [lindex $LR 1] 0]
set y3 [lindex [lindex $LR 1] 1]

set x4 [lindex [lindex $UL 0] 0]
set y4 [lindex [lindex $UL 0] 1]

set x5 [lindex [lindex $UL 1] 0]
set y5 [lindex [lindex $UL 1] 1]

set x6 [lindex [lindex $UR 1] 0]
set y6 [lindex [lindex $UR 1] 1]

create_routing_blockage -name route_blk_0 -layers {METAL5} -boundary {{0 0} {185 4997}}

create_routing_blockage -name route_blk_1 -layers {METAL5} -boundary {{0 0} {5000 185}}

create_routing_blockage -name route_blk_2 -layers {METAL5} -boundary {{0 4812} {5000 4997}}

create_routing_blockage -name route_blk_3 -layers {METAL5} -boundary {{4815 0} {5000 4997}}