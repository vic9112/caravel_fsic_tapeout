################################################################################
# Date: 7/26/2024            
# Name: Vic Chen             
################################################################################


# PERIOD 100ns for 10Mhz
# set PERIOD  100
# set CLOCK_NAME clock
# set TRANSITION 0.53
# set TRANSITION 0.2
# set UNCERTAINTY 0.3

# create_clock -period $PERIOD -name $CLOCK_NAME [get_ports $CLOCK_NAME]
# create_clock -period 25 -name ioclk_in [get_ports mprj_io[36] ]


# set_clock_uncertainty -setup $UNCERTAINTY [get_clocks $CLOCK_NAME]
# set_clock_transition -rise $TRANSITION [get_clocks $CLOCK_NAME]
# set_clock_transition -fall $TRANSITION [get_clocks $CLOCK_NAME]


### Caravel new Signoff SDC
### Date: 7/22/2024

# IO 4 mode is either SCK or GPIO (hkspi)
set io_4_mode SCK

puts "\[INFO\]: IO[4] is set as: $io_4_mode"
# IOs mode is either OUT or IN (GPIOs)
set ios_mode OUT
puts "\[INFO\]: GPIOs mode is set as: $ios_mode"

# IO ports to user's project wrapper are assumed to be asynchronous. If they're synchronous to the clock, update the variable IO_SYNC to 1
set ::env(IO_SYNC) 0

## MASTER CLOCKS
# set clk_period 100
set clk_period 20
create_clock -name clk -period $clk_period [get_ports {clock}]
puts "\[INFO\]: System clock period: $clk_period"

# set io_clk_period 25
set io_clk_period 5
create_clock -name ioclk_in -period $io_clk_period [get_ports mprj_io[36] ]
puts "\[INFO\]: io clock period: $io_clk_period"

create_clock -name hk_serial_clk -period 100 [get_pins {housekeeping/serial_clock}]
create_clock -name hk_serial_load -period 1000 [get_pins {housekeeping/serial_load}]
set_clock_uncertainty 0.1000 [get_clocks {clk hk_serial_clk hk_serial_load}]
# set_propagated_clock [get_clocks {clk hk_serial_clk hk_serial_load}]

set min_clk_tran 1
set max_clk_tran 1.5
puts "\[INFO\]: Clock transition range: $min_clk_tran : $max_clk_tran"

# Add clock transition
set_input_transition -min $min_clk_tran [get_ports {clock}]
set_input_transition -max $max_clk_tran [get_ports {clock}]

# create_generated_clock -name clk_to_csclk_mux -source [get_ports {clock}] -multiply_by 1 -add -master_clock clk [get_nets -hierarchical *csclk*]
# create_generated_clock -name hkspi_clk_to_csclk_mux -source [get_ports {mprj_io[4]}] -multiply_by 1 -add -master_clock hkspi_clk [get_nets -hierarchical *csclk*]


if {$io_4_mode == "SCK"} {
   # deassert hkspi_disable
   #tony_debug set_case_analysis 0 [get_pins {housekeeping/_6817_/Q}]
   #tony_debug set_case_analysis 0 [get_pins {housekeeping/hkspi_disable_reg/Q}]
   # dessert CSB
   #tony_debug set_case_analysis 0 [get_ports {mprj_io[3]} ]

   create_clock -name hkspi_clk -period 100 [get_ports {mprj_io[4]} ]
   set_clock_uncertainty 0.1000 [get_clocks {hkspi_clk}]
   # set_propagated_clock [get_clocks {hkspi_clk}]

    
    set core_clk_pin {clock_ctrl/ext_clk}

    ## GENERATED CLOCKS
    # create_generated_clock -name core_clk -source $core_clk_pin -divide_by 1 [get_ports clock_ctrl/core_clk]


    ## GENERATED CLOCKS
    # NOTE: change the clock pins whenever the synthesis receipe changes 
    
##################################################################################
   # [Vic]: create generated clocks
    set wbbd_sck_pin [get_pins -of_objects housekeeping/wbbd_sck]
    create_generated_clock -name wbbd_sck \
                           -source [get_pins {housekeeping/wb_clk_i} ] \
                           -divide_by 2 $wbbd_sck_pin
   # [Vic]: csclk is the clock signal from  the output of MUX, 
   #        which decides signal between A1 and A2
    create_generated_clock -name hkspi_clk_to_csclk_mux \
                           -source [get_ports {mprj_io[4]}] \
                           -divide_by 1 [get_pins {housekeeping/csclk_MUX_dont_touch/A}]
    create_generated_clock -name wbbd_sck_to_csclk_mux \
                           -source [get_ports {clock}] \
                           -divide_by 2 [get_pins {housekeeping/csclk_MUX_dont_touch/B}]
##################################################################################
    # paths between wb_clk_i and sck shouldn't be timed
    # set_clock_groups -logically_exclusive -group clk -group hkspi_clk
    #create_generated_clock -name wbbd_sck_to_csclk_mux -source  $wbbd_sck_pin -divide_by 1 [get_pins housekeeping/C13888/Z_0]

    #set csclk_mux_out_pin [get_pins [all_connected housekeeping/csclk -leaf] -filter "@direction == out"]
    #set csclk_mux_out_pin [ get_pins -of_objects housekeeping/csclk_MUX_dont_touch -filter "lib_pin_name == X"]

    #set csclk_mux_out_pin [get_pins -of_objects housekeeping/pll_ena_reg -filter "lib_pin_name==clocked_on"]
    #create_generated_clock -name wbbd_sck_to_csclk_mux -source  $wbbd_sck_pin -divide_by 1 $csclk_mux_out_pin 


    #set_clock_groups -logically_exclusive -name csclk_mux -group wbbd_sck_to_csclk_mux -group hkspi_clk_to_csclk_mux 



    create_clock -name rxclk -period 5 [get_ports {mprj_io[21]} ]

#    create_generated_clock -name clk_to_csclk_mux -source [get_ports {clock}] -multiply_by 1 -add -master_clock clk [get_nets -hierarchical *csclk*]
#    create_generated_clock -name hkspi_clk_to_csclk_mux -source [get_ports {mprj_io[4]}] -multiply_by 1 -add -master_clock hkspi_clk [get_nets -hierarchical *csclk*]

   set_clock_groups \
   -name clock_group \
   -logically_exclusive \
   -group [get_clocks {clk }]\
   -group [get_clocks {ioclk_in rxclk}]\
   -group [get_clocks {hk_serial_clk}]\
   -group [get_clocks {hk_serial_load}]\
   -group [get_clocks {hkspi_clk }]
#   -group [get_generated_clock {wbbd_sck_to_csclk_mux}] \
#   -group [get_generated_clock {hkspi_clk_to_csclk_mux}]

} elseif {$io_4_mode == "GPIO"} {
   # assert hkspi_disable
   #tony_debug set_case_analysis 0 [get_pins {housekeeping/_6817_/Q}]
   #tony_debug set_case_analysis 0 [get_pins {housekeeping/hkspi_disable_reg/Q}]

   set_clock_groups \
   -name clock_group \
   -logically_exclusive \
   -group [get_clocks {clk}]\
   -group [get_clocks {ioclk_in}]\
   -group [get_clocks {hk_serial_clk}]\
   -group [get_clocks {hk_serial_load}]\
   -group [get_clocks {rxclk}]\
}
# Add case analysis for clock pad DM[2]==1'b0 & DM[1]==1'b0 & DM[0]==1'b1 to be input
#tony_debug set_case_analysis 0 [get_pins padframe/clock_pad/DM[2]]
#tony_debug set_case_analysis 0 [get_pins padframe/clock_pad/DM[1]]
#tony_debug set_case_analysis 1 [get_pins padframe/clock_pad/DM[0]]
#tony_debug set_case_analysis 0 [get_pins padframe/clock_pad/INP_DIS]
# hk_serial_clk period is x2 core clock
# clock <-> hk_serial_clk/load no paths
# future note: CDC stuff
# clock <-> hkspi_clk no paths with careful methods (clock is off)

# Set system monitoring mux select to zero so that the clock/user_clk monitoring is disabled
#tony_debug set_case_analysis 0 [get_pins housekeeping/_3949_/S]
#tony_debug set_case_analysis 0 [get_pins housekeeping/_3950_/S]

set input_delay_value 4
set rx_input_delay_value 1
set output_delay_value 4
set tx_output_delay_value 3.5
puts "\[INFO\]: Setting input delay to: $input_delay_value"
puts "\[INFO\]: Setting output delay to: $output_delay_value"

set min_in_tran 1
set max_in_tran 4
puts "\[INFO\]: Input transition range: $min_in_tran : $max_in_tran"

# 10 too high --> 4:7
set min_cap 4
set max_cap 7
puts "\[INFO\]: Cap load range: $min_cap : $max_cap"

if {$ios_mode == "IN"} {  

    # tony current mode is OUT, I remove it

} elseif {$ios_mode == "OUT"} {

   # Add case analysis for pads DM[2]==1'b1 & DM[1]==1'b1 & DM[0]==1'b0 to be outputs
   #tony_debug set_case_analysis 1 [get_pins padframe/*mprj*/DM[2]]
   #tony_debug set_case_analysis 1 [get_pins padframe/*mprj*/DM[1]]
   #tony_debug set_case_analysis 0 [get_pins padframe/*mprj*/DM[0]]
   #tony_debug set_case_analysis 0 [get_pins padframe/*mprj*/OE_N]

   # add loads for output ports (pads)
   set_load -min $min_cap [get_ports {mprj_io[*]}]
   set_load -max $max_cap [get_ports {mprj_io[*]}]

   ## INPUT DELAYS
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[0]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[5]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[6]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[7]}]
   set_input_delay $rx_input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[8]}]
   set_input_delay $rx_input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[9]}]
   set_input_delay $rx_input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[10]}]
   set_input_delay $rx_input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[11]}]
   set_input_delay $rx_input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[12]}]
   set_input_delay $rx_input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[13]}]
   set_input_delay $rx_input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[14]}]
   set_input_delay $rx_input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[15]}]
   set_input_delay $rx_input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[16]}]
   set_input_delay $rx_input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[17]}]
   set_input_delay $rx_input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[18]}]
   set_input_delay $rx_input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[19]}]
   set_input_delay $rx_input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[20]}]
   #set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[21]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[22]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[23]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[24]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[25]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[26]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[27]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[28]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[29]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[30]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[31]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[32]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[33]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[34]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[35]}]
   #set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[36]}]
   set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[37]}]

   ## OUTPUT DELAYS
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[0]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[5]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[6]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[7]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[8]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[9]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[10]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[11]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[10]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[11]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[12]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[13]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[14]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[15]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[16]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[17]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[18]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[19]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[20]}]
   # set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[21]}]
   set_output_delay $tx_output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[22]}]
   set_output_delay $tx_output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[23]}]
   set_output_delay $tx_output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[24]}]
   set_output_delay $tx_output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[25]}]
   set_output_delay $tx_output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[26]}]
   set_output_delay $tx_output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[27]}]
   set_output_delay $tx_output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[28]}]
   set_output_delay $tx_output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[29]}]
   set_output_delay $tx_output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[30]}]
   set_output_delay $tx_output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[31]}]
   set_output_delay $tx_output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[32]}]
   set_output_delay $tx_output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[33]}]
   set_output_delay $tx_output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[34]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[35]}]
   # set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[36]}]
   set_output_delay $output_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {mprj_io[37]}]
   if {$io_4_mode == "SCK"} {
      # SCK, CSB, SDI are inputs
      #tony_debug set_case_analysis 0 [get_pins padframe/\mprj_pads.area1_io_pad[4]/DM[2]]
      #tony_debug set_case_analysis 0 [get_pins padframe/\mprj_pads.area1_io_pad[4]/DM[1]]
      #tony_debug set_case_analysis 1 [get_pins padframe/\mprj_pads.area1_io_pad[4]/DM[0]]
      #tony_debug set_case_analysis 0 [get_pins padframe/\mprj_pads.area1_io_pad[4]/INP_DIS]
      #tony_debug set_case_analysis 0 [get_pins padframe/\mprj_pads.area1_io_pad[3]/DM[2]]
      #tony_debug set_case_analysis 0 [get_pins padframe/\mprj_pads.area1_io_pad[3]/DM[1]]
      #tony_debug set_case_analysis 1 [get_pins padframe/\mprj_pads.area1_io_pad[3]/DM[0]]
      #tony_debug set_case_analysis 0 [get_pins padframe/\mprj_pads.area1_io_pad[3]/INP_DIS]
      #tony_debug set_case_analysis 0 [get_pins padframe/\mprj_pads.area1_io_pad[2]/DM[2]]
      #tony_debug set_case_analysis 0 [get_pins padframe/\mprj_pads.area1_io_pad[2]/DM[1]]
      #tony_debug set_case_analysis 1 [get_pins padframe/\mprj_pads.area1_io_pad[2]/DM[0]]
      #tony_debug set_case_analysis 0 [get_pins padframe/\mprj_pads.area1_io_pad[2]/INP_DIS]
      set_output_delay $output_delay_value  -clock [get_clocks {hkspi_clk}] [get_ports {mprj_io[1]}]
      set_input_delay $input_delay_value  -clock [get_clocks {hkspi_clk}] [get_ports {mprj_io[2]}]
      set_input_delay $input_delay_value  -clock [get_clocks {hkspi_clk}] [get_ports {mprj_io[3]}]
      set_input_transition -min $min_in_tran [get_ports {mprj_io[2] mprj_io[2]}]
      set_input_transition -max $max_in_tran [get_ports {mprj_io[3] mprj_io[3]}]
      if { !($::env(IO_SYNC)) } {
         set_false_path -to [get_ports mprj_io[0]]
         set_false_path -to [get_ports mprj_io[5]]
         set_false_path -to [get_ports mprj_io[6]]
         set_false_path -to [get_ports mprj_io[7]]
         set_false_path -to [get_ports mprj_io[8]]
         set_false_path -to [get_ports mprj_io[9]]
         set_false_path -to [get_ports mprj_io[10]]
         set_false_path -to [get_ports mprj_io[11]]
         set_false_path -to [get_ports mprj_io[12]]
         set_false_path -to [get_ports mprj_io[13]]
         set_false_path -to [get_ports mprj_io[14]]
         set_false_path -to [get_ports mprj_io[15]]
         set_false_path -to [get_ports mprj_io[16]]
         set_false_path -to [get_ports mprj_io[17]]
         set_false_path -to [get_ports mprj_io[18]]
         set_false_path -to [get_ports mprj_io[19]]
         set_false_path -to [get_ports mprj_io[20]]
         set_false_path -to [get_ports mprj_io[21]]
         set_false_path -to [get_ports mprj_io[22]]
         set_false_path -to [get_ports mprj_io[23]]
         set_false_path -to [get_ports mprj_io[24]]
         set_false_path -to [get_ports mprj_io[25]]
         set_false_path -to [get_ports mprj_io[26]]
         set_false_path -to [get_ports mprj_io[27]]
         set_false_path -to [get_ports mprj_io[28]]
         set_false_path -to [get_ports mprj_io[29]]
         set_false_path -to [get_ports mprj_io[30]]
         set_false_path -to [get_ports mprj_io[31]]
         set_false_path -to [get_ports mprj_io[32]]
         set_false_path -to [get_ports mprj_io[33]]
         set_false_path -to [get_ports mprj_io[34]]
         set_false_path -to [get_ports mprj_io[35]]
         set_false_path -to [get_ports mprj_io[36]]
         set_false_path -to [get_ports mprj_io[37]]
      }
   } elseif {$io_4_mode == "GPIO"} {
        # tony current mode is SCK, I remove it
   }
}

# flash_* are output except for io1
#tony_debug set_case_analysis 1 [get_pins padframe/flash_*pad/DM[2]]
#tony_debug set_case_analysis 1 [get_pins padframe/flash_*pad/DM[1]]
#tony_debug set_case_analysis 0 [get_pins padframe/flash_*pad/DM[0]]
#tony_debug set_case_analysis 0 [get_pins padframe/flash_*pad/INP_DIS]
#tony_debug set_case_analysis 0 [get_pins padframe/flash_io1_pad/DM[2]]
#tony_debug set_case_analysis 0 [get_pins padframe/flash_io1_pad/DM[1]]
#tony_debug set_case_analysis 1 [get_pins padframe/flash_io1_pad/DM[0]]
#tony_debug set_case_analysis 0 [get_pins padframe/flash_io1_pad/OE_N]

#flash interface input transition from the datasheet
set flash_min_tran 4
set flash_max_tran 6
puts "\[INFO\]: Flash interface transition range: $flash_min_tran : $flash_max_tran"
set_input_transition -min $flash_min_tran [get_ports {flash_io1}]
set_input_transition -max $flash_max_tran [get_ports {flash_io1}]

set flash_min_cap 6
set flash_max_cap 8
puts "\[INFO\]: Flash interface cap load range: $flash_min_cap : $flash_max_cap"
set_load -min $min_cap [get_ports {flash_csb flash_clk flash_io0}]
set_load -max $max_cap [get_ports {flash_csb flash_clk flash_io0}]

set flash_in_delay 4
set flash_out_delay 4
set_output_delay $flash_out_delay  -clock [get_clocks {clk}] -add_delay [get_ports {flash_clk}]
set_output_delay $flash_out_delay  -clock [get_clocks {clk}] -add_delay [get_ports {flash_io0}]
set_input_delay $flash_in_delay -clock [get_clocks {clk}] -add_delay [get_ports {flash_io1}]

# gpio_pad is set as input pad
#tony_debug set_case_analysis 0 [get_pins padframe/gpio_pad/DM[2]]
#tony_debug set_case_analysis 0 [get_pins padframe/gpio_pad/DM[1]]
#tony_debug set_case_analysis 1 [get_pins padframe/gpio_pad/DM[0]]
#tony_debug set_case_analysis 0 [get_pins padframe/gpio_pad/INP_DIS]
set_input_transition -min $min_in_tran [get_ports {gpio}]
set_input_transition -max $max_in_tran [get_ports {gpio}]

set_input_delay $input_delay_value  -clock [get_clocks {clk}] -add_delay [get_ports {gpio}]

# Maximum Fanout soft constraint
set_max_fanout 18 [current_design]
# synthesis max fanout is 18

## FALSE PATHS (ASYNCHRONOUS I/Os)
set_false_path -from [get_ports resetb]
set_false_path -from [get_ports gpio]

# check ocv table (not provided)
set derate 0.0375
puts "\[INFO\]: Setting derate factor to: [expr $derate * 100] %"
set_timing_derate -early [expr 1-$derate]
set_timing_derate -late [expr 1+$derate]

