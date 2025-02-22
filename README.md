# T18 Chip Implementation - Caravel SoC with Integrated FSIC and Falcon

| File Structure | Description |
| -------------- | ----------- |
|`/FPGA_val`     | FPGA Validation System |
|`/caravel_fsic` | ASIC Front-end/Back-end Implementation |
|`/chip_rtl`     | Concatenated RTL file of the whole chip |
|`/backup`       | Backup folders of contributors |
---
## Introduction

In this project, we built upon our previous work, where we developed a hardware IP to accelerate the post-quantum cryptography algorithm, Falcon, and implemented it using a hardware/software co-design approach in response to the threats posed by quantum computers. Rather than designing just an IP, we developed a complete system this time and tapeout. Our project introduces the following key contributions:

### :star:Contribution 1: FSIC Validation Architecture and IP
-	Description: A full-stack IC (FSIC) validation architecture and IP framework.
-	Benefit: Enables comprehensive silicon system-level validation, ensuring robust performance and reliability for integrated circuits.

### :star:Contribution 2: PQC Falcon Application Accelerator
-	Description: A powerful PQC (Post-Quantum Cryptography) Falcon IP accelerator.
-	Validation: Successfully validated within the FSIC system.
-	Application: Designed for seamless execution in real-world applications, enhancing security and processing speeds.

### :star:Contribution 3：Post-Silicon Validation System (Caravel FSIC FPGA)
-	Description: A general PCB design for IC system-level validation
-	Application: An online FPGA system is built to facilitate IC system-level validation. 
---
:hammer:***We want to build an IC Validation System that is scalable and easy to deploy***:hammer:

## System Overview
![SOC專題block diagram (1)](https://github.com/user-attachments/assets/8cd54385-f034-4435-9ce3-fb09ea7bccca)

## The Caravel FSIC - Falcon Chip
![螢幕擷取畫面 2024-12-02 183736](https://github.com/user-attachments/assets/fe4307b4-7884-4699-a136-1bbf99d707ae)

## Design Implementation

### Falcon Hardware Accelerator (Kernel)
![螢幕擷取畫面 2024-11-26 214656](https://github.com/user-attachments/assets/44516354-ecb1-4039-aaa5-8523b8bb278a)

### Integrate into FSIC
![螢幕擷取畫面 2024-11-26 214822](https://github.com/user-attachments/assets/a8767e7f-18a9-4e68-a821-b643f1157a23)

### Integrate Falcon & FSIC into Caravel SoC
![螢幕擷取畫面 2024-11-26 215217](https://github.com/user-attachments/assets/8edd1512-ee97-4fee-8885-037089e6c7bb)

### Design System Validation Board - KV260
![螢幕擷取畫面 2024-11-26 220155](https://github.com/user-attachments/assets/bf028cf1-0af2-4b60-b410-f19deb5b9253)

### Deploy the IC Validation System Online
![螢幕擷取畫面 2024-11-26 220550](https://github.com/user-attachments/assets/6f71b495-94af-4afc-91c0-8933c556d78d)




