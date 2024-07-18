# caravel_fsic_tapeout

You should download the latest version(2024) of `SAED32_EDK`
and place `SAED32_EDK` and `caravel_fsic_vic` in the same directory
```
/Your working directory
   - /caravel_fsic_vic
   - /SAED32_EDK
```
## Makefile
``` bash
$ cd caravel_fsic_vic
```

1. Synthesis
``` bash
$ make saed32_syn
```
2. Pre-sim
``` bash
$ make saed32_sim
```
3. Floorplan
``` bash
$ make saed32_planning
```
or directly `cd` to the workspace of each flow:
``` bash
$ cd caravel_fsic_vic/flow/0_synthesis/work
$ make all
```
**Notice that `caravel_fsic_vic/flow/ndm_libs` and its sub-directories need to be extracted**
