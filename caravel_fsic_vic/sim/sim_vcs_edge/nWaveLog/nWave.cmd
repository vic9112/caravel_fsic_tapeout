wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/home/course/u110020015/lab_setup_for_saed32/lab_synthesis/sim_vcs_edge/top_bench.fsdb}
verdiSetActWin -win $_nWave1
wvResizeWindow -win $_nWave1 -10 20 1920 977
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/top_bench"
wvGetSignalSetScope -win $_nWave1 "/top_bench/uut/mprj/u_fsic"
wvGetSignalSetScope -win $_nWave1 "/top_bench/uut/mprj/u_fsic/AXIS_SW0"
wvGetSignalSetSignalFilter -win $_nWave1 "axis_clk"
wvSetPosition -win $_nWave1 {("G1" 1)}
wvSetPosition -win $_nWave1 {("G1" 1)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/axis_clk} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 )} 
wvSetPosition -win $_nWave1 {("G1" 1)}
wvGetSignalSetSignalFilter -win $_nWave1 "is_as_tvalid"
wvSetPosition -win $_nWave1 {("G1" 2)}
wvSetPosition -win $_nWave1 {("G1" 2)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/axis_clk} \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/is_as_tvalid} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 2 )} 
wvSetPosition -win $_nWave1 {("G1" 2)}
wvGetSignalSetSignalFilter -win $_nWave1 "as_is_tready"
wvSetPosition -win $_nWave1 {("G1" 3)}
wvSetPosition -win $_nWave1 {("G1" 3)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/axis_clk} \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/is_as_tvalid} \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/as_is_tready} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 3 )} 
wvSetPosition -win $_nWave1 {("G1" 3)}
wvGetSignalSetSignalFilter -win $_nWave1 "up_as_tvalid"
wvSetPosition -win $_nWave1 {("G1" 4)}
wvSetPosition -win $_nWave1 {("G1" 4)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/axis_clk} \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/is_as_tvalid} \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/as_is_tready} \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/up_as_tvalid} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 4 )} 
wvSetPosition -win $_nWave1 {("G1" 4)}
wvGetSignalSetSignalFilter -win $_nWave1 "as_up_tvalid"
wvSetPosition -win $_nWave1 {("G1" 5)}
wvSetPosition -win $_nWave1 {("G1" 5)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/axis_clk} \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/is_as_tvalid} \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/as_is_tready} \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/up_as_tvalid} \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/as_up_tvalid} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSetPosition -win $_nWave1 {("G1" 5)}
wvSetPosition -win $_nWave1 {("G1" 5)}
wvSetPosition -win $_nWave1 {("G1" 5)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/axis_clk} \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/is_as_tvalid} \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/as_is_tready} \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/up_as_tvalid} \
{/top_bench/uut/mprj/u_fsic/AXIS_SW0/as_up_tvalid} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSetPosition -win $_nWave1 {("G1" 5)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 29207586845.604946 -snap {("G1" 3)}
wvSetCursor -win $_nWave1 29253295119.228741 -snap {("G1" 2)}
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 2 )} 
wvSearchNext -win $_nWave1
wvSearchNext -win $_nWave1
wvSearchNext -win $_nWave1
wvSearchNext -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 3 )} 
wvSearchNext -win $_nWave1
wvSearchNext -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvResizeWindow -win $_nWave1 -10 20 1920 977
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G2" 0)}
wvSetPosition -win $_nWave1 {("G1" 4)}
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvExit
