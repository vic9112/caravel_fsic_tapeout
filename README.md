![SOC專題block diagram (1)](https://github.com/user-attachments/assets/b075847f-6418-489e-997d-410d0ec610c1)# caravel_fsic_tapeout

<!--
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
**Be sure to extract `caravel_fsic_vic/flow/ndm_libs` and its sub-directories**
-->
In this project, we built upon our previous work, where we developed a hardware IP to accelerate the post-quantum cryptography algorithm, Falcon, and implemented it using a hardware/software co-design approach in response to the threats posed by quantum computers. Rather than designing just an IP, we developed a complete system this time and tapeout. Our project introduces the following key contributions:

Contribution 1: FSIC Validation Architecture and IP
-	Description: A full-stack IC (FSIC) validation architecture and IP framework.
-	Benefit: Enables comprehensive silicon system-level validation, ensuring robust performance and reliability for integrated circuits.

Contribution 2: PQC Falcon Application Accelerator
-	Description: A powerful PQC (Post-Quantum Cryptography) Falcon IP accelerator.
-	Validation: Successfully validated within the FSIC system.
-	Application: Designed for seamless execution in real-world applications, enhancing security and processing speeds.

Contribution 3：Post-Silicon Validation System (Caravel FSIC FPGA)
-	Description: A general PCB design for IC system-level validation
-	Application: An online FPGA system is built to facilitate IC system-level validation. 

We want to build an IC Validation System that is scalable and easy to deploy

## System Overview
![SOC專題block diagram (1)](https://github.com/user-attachments/assets/8cd54385-f034-4435-9ce3-fb09ea7bccca)



