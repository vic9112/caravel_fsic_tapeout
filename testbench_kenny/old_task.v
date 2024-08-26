	task test001_aa_internal_soc_cfg_full_range;
		begin

			//Test offset 0x100~0xfff for AA internal register 
			$display("test001_aa_internal_soc_cfg_full_range: AA internal register read/write test - start");
			for (i=0;i<32'h100;i=i+4) begin

				cfg_read_data_expect_value = 	32'ha5a5_a5a5;	
				soc_aa_cfg_write(AA_Internal_Reg_Offset + i, 4'b1111, cfg_read_data_expect_value);				
				soc_aa_cfg_read(AA_Internal_Reg_Offset + i, 4'b1111);

				check_cnt = check_cnt + 1;
				if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
					$display($time, "=> test001_aa_internal_soc_cfg_full_range [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
					error_cnt = error_cnt + 1;
				end	
				else
					$display($time, "=> test001_aa_internal_soc_cfg_full_range [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				$display("-----------------");
			end
			$display("test001_aa_internal_soc_cfg_full_range: AA Mail Box read/write test - end");
			$display("--------------------------------------------------------------------");

			#100;
		end
	endtask

    task test001_up_soc_cfg;
		begin
			//Test offset 0x00 for user project
			$display("test001_up_soc_cfg: soc cfg read/write test");

			cfg_read_data_expect_value = 32'ha5a5a5a5;	
			soc_up_cfg_write(0, 4'b1111, cfg_read_data_expect_value);
			soc_up_cfg_read(0, 4'b1111);

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
				$display($time, "=> test001_up_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				error_cnt = error_cnt + 1;
			end	
			else
				$display($time, "=> test001_up_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
			$display("-----------------");

			cfg_read_data_expect_value = $random;	
			soc_up_cfg_write(0, 4'b1111, cfg_read_data_expect_value);
			soc_up_cfg_read(0, 4'b1111);

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
				$display($time, "=> test001_up_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				error_cnt = error_cnt + 1;
			end	
			else
				$display($time, "=> test001_up_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
			$display("-----------------");
			$display("test001_up_soc_cfg: soc cfg read/write test - end");
			$display("--------------------------------------------------------------------");

			#100;
		end
	endtask
    
task test003;		//test003_fpga_axis_req
		begin
			for (i=0;i<CoreClkPhaseLoop;i=i+1) begin
				$display("test003: fpga_axis_req - loop %02d", i);
				fork 
					soc_apply_reset(40+i*10, 40);			//change coreclk phase in soc
					fpga_apply_reset(40,40);		//fix coreclk phase in fpga
				join
				#40;

				fpga_as_to_is_init();
				
				//soc_cc_is_enable=1;
				fpga_cc_is_enable=1;
				fork 
					soc_is_cfg_write(0, 4'b0001, 1);				//ioserdes rxen
					fpga_cfg_write(0,1,1,0);
				join
				$display($time, "=> soc rxen_ctl=1");
				$display($time, "=> fpga rxen_ctl=1");

				#400;
				fork 
					soc_is_cfg_write(0, 4'b0001, 3);				//ioserdes txen
					fpga_cfg_write(0,3,1,0);
				join
				$display($time, "=> soc txen_ctl=1");
				$display($time, "=> fpga txen_ctl=1");

				#200;
				fpga_as_is_tdata = 32'h5a5a5a5a;
				#40;
				#200;

                soc_to_fpga_axis_expect_count = 0;
				test003_fpga_axis_req();		//target to Axis Switch

				$display($time, "=> wait for soc_to_fpga_axis_event");
                @(soc_to_fpga_axis_event);
                $display($time, "=> soc_to_fpga_axis_expect_count = %d", soc_to_fpga_axis_expect_count);
                $display($time, "=> soc_to_fpga_axis_captured_count = %d", soc_to_fpga_axis_captured_count);
                
				check_cnt = check_cnt + 1;
				if ( soc_to_fpga_axis_expect_count != fpga_axis_test_length) begin
                    $display($time, "=> test003 [ERROR] soc_to_fpga_axis_expect_count = %d, soc_to_fpga_axis_captured_count = %d", soc_to_fpga_axis_expect_count, soc_to_fpga_axis_captured_count);
					error_cnt = error_cnt + 1;
				end	
				else 
                    $display($time, "=> test003 [PASS] soc_to_fpga_axis_expect_count = %d, soc_to_fpga_axis_captured_count = %d", soc_to_fpga_axis_expect_count, soc_to_fpga_axis_captured_count);

				
                for(idx3=0; idx3<fpga_axis_test_length; idx3=idx3+1)begin	
					check_cnt = check_cnt + 1;
                    if (soc_to_fpga_axis_expect_value[idx3] != soc_to_fpga_axis_captured[idx3] ) begin
                        $display($time, "=> test003 [ERROR] idx3=%d, soc_to_fpga_axis_expect_value[%d] = %x, soc_to_fpga_axis_captured[%d]  = %x", idx3, idx3, soc_to_fpga_axis_expect_value[idx3], idx3, soc_to_fpga_axis_captured[idx3]);
						error_cnt = error_cnt + 1;
					end
					else
                        $display($time, "=> test003 [PASS] idx3=%d, soc_to_fpga_axis_expect_value[%d] = %x, soc_to_fpga_axis_captured[%d]  = %x", idx3, idx3, soc_to_fpga_axis_expect_value[idx3], idx3, soc_to_fpga_axis_captured[idx3]);
					
                end
                soc_to_fpga_axis_captured_count = 0;		//reset soc_to_fpga_axis_captured_count for next loop


				#200;
			end
		end
	endtask


	task test003_fpga_axis_req;
		//input [7:0] compare_data;

		//FPGA to SOC Axilite test
		begin

			@ (posedge fpga_coreclk);
			fpga_as_is_tready <= 1;
			
			for(idx3=0; idx3<fpga_axis_test_length; idx3=idx3+1)begin		//
				fpga_axis_req(32'h11111111 * (idx3 & 32'h0000_000F), TID_DN_UP, 1);		//target to User Project
			end
			
			$display($time, "=> test003_fpga_axis_req done");
		end
	endtask

task test004;
		//input [7:0] compare_data;

		begin
			for (i=0;i<CoreClkPhaseLoop;i=i+1) begin
				$display("test004: TX/RX test - loop %02d", i);
				fork 
					soc_apply_reset(40+i*10, 40);			//change coreclk phase in soc
					fpga_apply_reset(40,40);		//fix coreclk phase in fpga
				join
				#40;
				fpga_as_to_is_init();
				//soc_cc_is_enable=1;
				fpga_cc_is_enable=1;
				fork 
					soc_is_cfg_write(0, 4'b0001, 1);				//ioserdes rxen
					fpga_cfg_write(0,1,1,0);
				join
				$display($time, "=> soc rxen_ctl=1");
				$display($time, "=> fpga rxen_ctl=1");

				#400;
				fork 
					soc_is_cfg_write(0, 4'b0001, 3);				//ioserdes txen
					fpga_cfg_write(0,3,1,0);
				join
				$display($time, "=> soc txen_ctl=1");
				$display($time, "=> fpga txen_ctl=1");

				#200;
				fpga_as_is_tdata = 32'h5a5a5a5a;
				#40;
				#200;

				test004_fpga_to_soc_mail_box_write();		//target to AA
				#200;
			end
		end
	endtask

	reg[31:0]idx1;

	task test004_fpga_to_soc_mail_box_write;
		//input [7:0] compare_data;

		//FPGA to SOC Axilite test
		begin
			@ (posedge fpga_coreclk);
			fpga_as_is_tready <= 1;
			
			for(idx1=0; idx1<32'h20/4; idx1=idx1+1)begin		//
				fpga_axilite_write(FPGA_to_SOC_AA_BASE + AA_MailBox_Reg_Offset + idx1*4, 4'b1111, 32'h11111111 * idx1);
					//mailbox supported range address = 0x0000_2000 ~ 0000_201F
					//BE = 4'b1111
					//data = 32'h11111111 * idx1
			end

			$display($time, "=> test004_fpga_to_soc_mail_box_write done");
		end
	endtask

    task test005;
		begin
			$display("test005: soc mail box cfg write/read test");

			#100;
			soc_apply_reset(40,40);
			fpga_apply_reset(40,40);

			#100;
			
			//soc_cc_is_enable=1;
			fpga_cc_is_enable=1;

			fpga_as_to_is_init();

			fork 
				soc_is_cfg_write(0, 4'b0001, 1);				//ioserdes rxen
				fpga_cfg_write(0,1,1,0);
			join
			$display($time, "=> soc rxen_ctl=1");
			$display($time, "=> fpga rxen_ctl=1");

			#400;
			fork 
				soc_is_cfg_write(0, 4'b0001, 3);				//ioserdes txen
				fpga_cfg_write(0,3,1,0);
			join
			$display($time, "=> soc txen_ctl=1");
			$display($time, "=> fpga txen_ctl=1");

			#200;
			fpga_as_is_tdata = 32'h5a5a5a5a;
		
			#200;

			test005_aa_mailbox_soc_cfg();
			
			#100;
		end
	endtask

	task test005_aa_mailbox_soc_cfg;
		begin 
			//Test offset 0x00~0xff for mail box write to AA
			$display("test005_aa_mailbox_soc_cfg: soc cfg read/write test - check soc cfg read value part");

			$display("test005_aa_mailbox_soc_cfg: AA Mail Box read/write test - start");
			for (i=0;i<32'h20;i=i+4) begin

				cfg_read_data_expect_value = 	32'ha5a5_a5a5;	
				soc_aa_cfg_write(AA_MailBox_Reg_Offset + i, 4'b1111, cfg_read_data_expect_value);				
				soc_aa_cfg_read(AA_MailBox_Reg_Offset + i, 4'b1111);

				check_cnt = check_cnt + 1;
				if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
					$display($time, "=> test005_aa_mailbox_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
					error_cnt = error_cnt + 1;
				end
				else
					$display($time, "=> test005_aa_mailbox_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				$display("-----------------");
			end
			$display("test005_aa_mailbox_soc_cfg: AA Mail Box read/write test - end");
			$display("--------------------------------------------------------------------");

			$display("test005_aa_mailbox_soc_cfg: soc cfg read/write test - check soc to fpga cfg write value part");

			$display("test005_aa_mailbox_soc_cfg: AA Mail Box read/write test - start");
			for (i=0;i<32'h20;i=i+4) begin

				soc_to_fpga_mailbox_write_addr_expect_value =  SOC_to_FPGA_MailBox_Base + i;				
				soc_to_fpga_mailbox_write_addr_BE_expect_value = 4'b1111;
				soc_to_fpga_mailbox_write_data_expect_value = 	32'ha5a5_a5a5;
				soc_aa_cfg_write(AA_MailBox_Reg_Offset + i, soc_to_fpga_mailbox_write_addr_BE_expect_value, soc_to_fpga_mailbox_write_data_expect_value);
				@ (soc_to_fpga_mailbox_write_event) ;		//wait for fpga get the mail box write from soc.
				$display($time, "=> test005_aa_mailbox_soc_cfg : got soc_to_fpga_mailbox_write_event");

				//Address part
				check_cnt = check_cnt + 1;
				if ( soc_to_fpga_mailbox_write_addr_expect_value !== soc_to_fpga_mailbox_write_addr_captured[27:0]) begin
					$display($time, "=> test005_aa_mailbox_soc_cfg [ERROR] soc_to_fpga_mailbox_write_addr_expect_value=%x, soc_to_fpga_mailbox_write_addr_captured[27:0]=%x", soc_to_fpga_mailbox_write_addr_expect_value, soc_to_fpga_mailbox_write_addr_captured[27:0]);
					error_cnt = error_cnt + 1;
				end	
				else
					$display($time, "=> test005_aa_mailbox_soc_cfg [PASS] soc_to_fpga_mailbox_write_addr_expect_value=%x, soc_to_fpga_mailbox_write_addr_captured[27:0]=%x", soc_to_fpga_mailbox_write_addr_expect_value, soc_to_fpga_mailbox_write_addr_captured[27:0]);

				//BE part
				check_cnt = check_cnt + 1;
				if ( soc_to_fpga_mailbox_write_addr_BE_expect_value !== soc_to_fpga_mailbox_write_addr_captured[31:28]) begin
					$display($time, "=> test005_aa_mailbox_soc_cfg [ERROR] soc_to_fpga_mailbox_write_addr_BE_expect_value=%x, soc_to_fpga_mailbox_write_addr_captured[31:28]=%x", soc_to_fpga_mailbox_write_addr_BE_expect_value, soc_to_fpga_mailbox_write_addr_captured[31:28]);
					error_cnt = error_cnt + 1;
				end	
				else
					$display($time, "=> test005_aa_mailbox_soc_cfg [PASS] soc_to_fpga_mailbox_write_addr_BE_expect_value=%x, soc_to_fpga_mailbox_write_addr_captured[31:28]=%x", soc_to_fpga_mailbox_write_addr_BE_expect_value, soc_to_fpga_mailbox_write_addr_captured[31:28]);

				//data part
				check_cnt = check_cnt + 1;
				if (soc_to_fpga_mailbox_write_data_expect_value !== soc_to_fpga_mailbox_write_data_captured) begin
					$display($time, "=> test005_aa_mailbox_soc_cfg [ERROR] soc_to_fpga_mailbox_write_data_expect_value=%x, soc_to_fpga_mailbox_write_data_captured=%x", soc_to_fpga_mailbox_write_data_expect_value, soc_to_fpga_mailbox_write_data_captured);
					error_cnt = error_cnt + 1;
				end	
				else
					$display($time, "=> test005_aa_mailbox_soc_cfg [PASS] soc_to_fpga_mailbox_write_data_expect_value=%x, soc_to_fpga_mailbox_write_data_captured=%x", soc_to_fpga_mailbox_write_data_expect_value, soc_to_fpga_mailbox_write_data_captured);
				$display("-----------------");
			end
			$display("test005_aa_mailbox_soc_cfg: AA Mail Box read/write test - end");
			$display("--------------------------------------------------------------------");

			$display("test005_aa_mailbox_soc_cfg: soc cfg read/write test - check soc cfg read value part with random value");

			$display("test005_aa_mailbox_soc_cfg: AA Mail Box read/write test - start");
			for (i=0;i<32'h20;i=i+4) begin

				cfg_read_data_expect_value = 	$random;	
				soc_aa_cfg_write(AA_MailBox_Reg_Offset + i, 4'b1111, cfg_read_data_expect_value);				
				soc_aa_cfg_read(AA_MailBox_Reg_Offset + i, 4'b1111);

				check_cnt = check_cnt + 1;
				if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
					$display($time, "=> test005_aa_mailbox_soc_cfg [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
					error_cnt = error_cnt + 1;
				end	
				else
					$display($time, "=> test005_aa_mailbox_soc_cfg [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				$display("-----------------");
			end
			$display("test005_aa_mailbox_soc_cfg: AA Mail Box read/write test - end");
			$display("--------------------------------------------------------------------");
			$display("test005_aa_mailbox_soc_cfg: soc cfg read/write test - check soc to fpga cfg write value part with random value");

			$display("test005_aa_mailbox_soc_cfg: AA Mail Box read/write test - start");
			for (i=0;i<32'h20;i=i+4) begin

				soc_to_fpga_mailbox_write_addr_expect_value =  SOC_to_FPGA_MailBox_Base + i;				
				soc_to_fpga_mailbox_write_addr_BE_expect_value = 4'b1111;
				soc_to_fpga_mailbox_write_data_expect_value = 	$random;
				soc_aa_cfg_write(i, soc_to_fpga_mailbox_write_addr_BE_expect_value, soc_to_fpga_mailbox_write_data_expect_value);
				repeat(20) @(posedge fpga_coreclk);		//wait for fpga get the data by delay, 10T should be ok, i use 20T for better margin, TODO use event to snyc it or support pipeline test

				//Address part
				check_cnt = check_cnt + 1;
				if ( soc_to_fpga_mailbox_write_addr_expect_value !== soc_to_fpga_mailbox_write_addr_captured[27:0]) begin
					$display($time, "=> test005_aa_mailbox_soc_cfg [ERROR] soc_to_fpga_mailbox_write_addr_expect_value=%x, soc_to_fpga_mailbox_write_addr_captured[27:0]=%x", soc_to_fpga_mailbox_write_addr_expect_value, soc_to_fpga_mailbox_write_addr_captured[27:0]);
					error_cnt = error_cnt + 1;
				end	
				else
					$display($time, "=> test005_aa_mailbox_soc_cfg [PASS] soc_to_fpga_mailbox_write_addr_expect_value=%x, soc_to_fpga_mailbox_write_addr_captured[27:0]=%x", soc_to_fpga_mailbox_write_addr_expect_value, soc_to_fpga_mailbox_write_addr_captured[27:0]);

				//BE part
				check_cnt = check_cnt + 1;
				if ( soc_to_fpga_mailbox_write_addr_BE_expect_value !== soc_to_fpga_mailbox_write_addr_captured[31:28]) begin
					$display($time, "=> test005_aa_mailbox_soc_cfg [ERROR] soc_to_fpga_mailbox_write_addr_BE_expect_value=%x, soc_to_fpga_mailbox_write_addr_captured[31:28]=%x", soc_to_fpga_mailbox_write_addr_BE_expect_value, soc_to_fpga_mailbox_write_addr_captured[31:28]);
					error_cnt = error_cnt + 1;
				end	
				else
					$display($time, "=> test005_aa_mailbox_soc_cfg [PASS] soc_to_fpga_mailbox_write_addr_BE_expect_value=%x, soc_to_fpga_mailbox_write_addr_captured[31:28]=%x", soc_to_fpga_mailbox_write_addr_BE_expect_value, soc_to_fpga_mailbox_write_addr_captured[31:28]);

				//data part
				check_cnt = check_cnt + 1;
				if (soc_to_fpga_mailbox_write_data_expect_value !== soc_to_fpga_mailbox_write_data_captured) begin
					$display($time, "=> test005_aa_mailbox_soc_cfg [ERROR] soc_to_fpga_mailbox_write_data_expect_value=%x, soc_to_fpga_mailbox_write_data_captured=%x", soc_to_fpga_mailbox_write_data_expect_value, soc_to_fpga_mailbox_write_data_captured);
					error_cnt = error_cnt + 1;
				end	
				else
					$display($time, "=> test005_aa_mailbox_soc_cfg [PASS] soc_to_fpga_mailbox_write_data_expect_value=%x, soc_to_fpga_mailbox_write_data_captured=%x", soc_to_fpga_mailbox_write_data_expect_value, soc_to_fpga_mailbox_write_data_captured);
				$display("-----------------");
			end
			$display("test005_aa_mailbox_soc_cfg: AA Mail Box read/write test - end");
			$display("--------------------------------------------------------------------");

			#100;
		end
	endtask

    task test006;
		//input [7:0] compare_data;

		begin
			for (i=0;i<CoreClkPhaseLoop;i=i+1) begin
				$display("test006: fpga to soc cfg write test - loop %02d", i);
				fork 
					soc_apply_reset(40+i*10, 40);			//change coreclk phase in soc
					fpga_apply_reset(40,40);		//fix coreclk phase in fpga
				join
				
				#40;
				
				fpga_as_to_is_init();	
				
				//soc_cc_is_enable=1;
				fpga_cc_is_enable=1;
				fork 
					soc_is_cfg_write(0, 4'b0001, 1);				//ioserdes rxen
					fpga_cfg_write(0,1,1,0);
				join
				$display($time, "=> soc rxen_ctl=1");
				$display($time, "=> fpga rxen_ctl=1");

				#400;
				fork 
					soc_is_cfg_write(0, 4'b0001, 3);				//ioserdes txen
					fpga_cfg_write(0,3,1,0);
				join
				$display($time, "=> soc txen_ctl=1");
				$display($time, "=> fpga txen_ctl=1");

				#200;
				fpga_as_is_tdata = 32'h5a5a5a5a;
				#40;
				#200;

				test006_fpga_to_soc_cfg_write();

				#200;
			end
		end
	endtask

	reg[31:0]idx6;

	task test006_fpga_to_soc_cfg_write;		//target to AA internal register
		//input [7:0] compare_data;

		//FPGA to SOC Axilite test
		begin

			@ (posedge fpga_coreclk);
			fpga_as_is_tready <= 1;
			
			//step 1. check default value
			$display($time, "=> test006_fpga_to_soc_cfg_write - for AA_Internal_Reg default value check");
			cfg_read_data_expect_value = 	32'h0;			//default value after reset = 0
			soc_aa_cfg_read(AA_Internal_Reg_Offset, 4'b1111);

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
				$display($time, "=> test006_fpga_to_soc_cfg_write [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				error_cnt = error_cnt + 1;
			end	
			else
				$display($time, "=> test006_fpga_to_soc_cfg_write [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
			$display("-----------------");


			//step 2. fpga issue fpga to soc cfg write request
			@ (posedge fpga_coreclk);
			cfg_read_data_expect_value = 	32'h1;	
			fpga_axilite_write_req(FPGA_to_SOC_AA_BASE + AA_Internal_Reg_Offset , 4'b0001, cfg_read_data_expect_value);
				//write address = h0000_2100 ~ h0000_2FFF for AA internal register
			//step 3. fpga wait for write to soc
			repeat(100) @ (posedge soc_coreclk);    //TODO fpga wait for write to soc
			//fpga_is_as_data_valid();

			soc_aa_cfg_read(AA_Internal_Reg_Offset, 4'b1111);

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
				$display($time, "=> test006_fpga_to_soc_cfg_write [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				error_cnt = error_cnt + 1;
			end	
			else
				$display($time, "=> test006_fpga_to_soc_cfg_write [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
			$display("-----------------");
	
			$display($time, "=> test006_fpga_to_soc_cfg_write done");
		end
	endtask

    task test007;
		begin
			$display("test007: mailbox interrupt test");

			#100;
			test007_initial();
			
			test007_aa_internal_soc_mb_interrupt_en();
            test007_fpga_mail_box_write();
            test007_soc_mb_read();
            test007_aa_internal_soc_mb_interrupt_status();
		end
	endtask
	
	
	task test007_initial;
	   begin
           $display("test007: TX/RX test");
            fork 
                soc_apply_reset(40, 40);			//change coreclk phase in soc
                fpga_apply_reset(40, 40);		//fix coreclk phase in fpga
            join
            #40;
            fpga_as_to_is_init();
            //soc_cc_is_enable=1;
            fpga_cc_is_enable=1;
            fork 
                soc_is_cfg_write(0, 4'b0001, 1);				//ioserdes rxen
                fpga_cfg_write(0,1,1,0);
            join
            $display($time, "=> soc rxen_ctl=1");
            $display($time, "=> fpga rxen_ctl=1");

            #400;
            fork 
                soc_is_cfg_write(0, 4'b0001, 3);				//ioserdes txen
                fpga_cfg_write(0,3,1,0);
            join
            $display($time, "=> soc txen_ctl=1");
            $display($time, "=> fpga txen_ctl=1");

            #200;
            fpga_as_is_tdata = 32'h5a5a5a5a;
            #40;
            #200;	   
	   end
    endtask

	task test007_aa_internal_soc_mb_interrupt_en;
		begin
			$display("Enable interrupt, set aa_regs offset 0, bit 0 = 1"); 
			cfg_read_data_expect_value = 32'h1;	
			soc_aa_cfg_write(AA_Internal_Reg_Offset + 0, 4'b1111, cfg_read_data_expect_value);				
			soc_aa_cfg_read(AA_Internal_Reg_Offset + 0, 4'b1111);

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured !== cfg_read_data_expect_value)  begin
				$display($time, "=> test007_aa_internal_soc_mb_interrupt_en [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				error_cnt = error_cnt+1;
			end
			else
				$display($time, "=> test007_aa_internal_soc_mb_interrupt_en [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);

            $display("Read interrupt status, aa_regs offset 4, bit 0 should be 0 by default"); 
			cfg_read_data_expect_value = 32'h0;	
            soc_aa_cfg_read(AA_Internal_Reg_Offset + 4, 4'b1111); 
			
			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured[0] !== cfg_read_data_expect_value[0])  begin
				$display($time, "=> test007_aa_internal_soc_mb_interrupt_en [ERROR] cfg_read_data_expect_value[0]=%x, cfg_read_data_captured[0]=%x", cfg_read_data_expect_value[0], cfg_read_data_captured[0]);
				error_cnt = error_cnt+1;
			end
			else
				$display($time, "=> test007_aa_internal_soc_mb_interrupt_en [PASS] cfg_read_data_expect_value[0]=%x, cfg_read_data_captured[0]=%x", cfg_read_data_expect_value[0], cfg_read_data_captured[0]);
            
			#100;
		end
	endtask



	task test007_aa_internal_soc_mb_interrupt_status;
		begin
			$display("Check interrupt status, read aa_regs offset 4, bit 0"); 
			cfg_read_data_expect_value = 32'h1;	
				
			soc_aa_cfg_read(AA_Internal_Reg_Offset + 4, 4'b1111);

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured[0] !== cfg_read_data_expect_value[0]) begin
				$display($time, "=> Read soc_mb_interrupt_status [ERROR] cfg_read_data_expect_value[0]=%x, cfg_read_data_captured[0]=%x", cfg_read_data_expect_value[0], cfg_read_data_captured[0]);
				error_cnt = error_cnt+1;
			end
			else
				$display($time, "=> Read soc_mb_interrupt_status [PASS] cfg_read_data_expect_value[0]=%x, cfg_read_data_captured[0]=%x", cfg_read_data_expect_value[0], cfg_read_data_captured[0]);

            $display("Clear interrupt status, write aa_regs offset 4, bit 0 = 1");	
			soc_aa_cfg_write(AA_Internal_Reg_Offset + 4, 4'b1111, 1);

			cfg_read_data_expect_value = 32'h0;	
				
			soc_aa_cfg_read(AA_Internal_Reg_Offset + 4, 4'b1111);

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured[0] !== cfg_read_data_expect_value[0]) begin
				$display($time, "=> Read soc_mb_interrupt_status [ERROR] cfg_read_data_expect_value[0]=%x, cfg_read_data_captured[0]=%x", cfg_read_data_expect_value[0], cfg_read_data_captured[0]);
				error_cnt = error_cnt+1;
			end 
			else
				$display($time, "=>Read soc_mb_interrupt_status [PASS] cfg_read_data_expect_value[0]=%x, cfg_read_data_captured[0]=%x", cfg_read_data_expect_value[0], cfg_read_data_captured[0]);
            
			#100;
		end
	endtask

	task test007_fpga_mail_box_write;
		//input [7:0] compare_data;

		//FPGA to SOC Axilite test
		begin
			@ (posedge fpga_coreclk);
			fpga_as_is_tready <= 1;
			
            fpga_axilite_write(FPGA_to_SOC_AA_BASE + AA_MailBox_Reg_Offset, 4'b1111, 32'h11111111);

			$display($time, "=> test007_fpga_mail_box_write done");
		end
	endtask


	task test007_soc_mb_read;
		begin
			$display("Read mb_regs offset 0"); 
			cfg_read_data_expect_value = 32'h11111111;					
			soc_aa_cfg_read(AA_MailBox_Reg_Offset, 4'b1111);

			check_cnt = check_cnt + 1;
			if (cfg_read_data_captured !== cfg_read_data_expect_value) begin
				$display($time, "=> Result: mb_regs offset 0 [ERROR] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);
				error_cnt = error_cnt+1;
			end
			else
				$display($time, "=> Result: mb_regs offset 0 [PASS] cfg_read_data_expect_value=%x, cfg_read_data_captured=%x", cfg_read_data_expect_value, cfg_read_data_captured);            
			#100;
		end
	endtask

    task  test1  ;
          begin
                // write len           
                soc_cfg_write(32'h3000_0010, 4'b0001, 64);
                // write coef                
                for(k=0; k< 11; k=k+1) begin
                soc_cfg_write(32'h3000_0020+4*k, 4'b0001, coef[k]);
                end
                // FIR start
                soc_cfg_write(32'h3000_0000, 4'b0001, 1);
                // mailbox
                soc_to_fpga_mailbox_write_addr_expect_value =  SOC_to_FPGA_MailBox_Base ;				
		soc_to_fpga_mailbox_write_addr_BE_expect_value = 4'b1111;
	        soc_to_fpga_mailbox_write_data_expect_value =    32'ha5a5_a5a5;
	        soc_cfg_write(AA_BASE + AA_MailBox_Reg_Offset, soc_to_fpga_mailbox_write_addr_BE_expect_value,soc_to_fpga_mailbox_write_data_expect_value);
		@ (soc_to_fpga_mailbox_write_event) ;		//wait for fpga get the mail box write from soc.
		$display($time, "got soc_to_fpga_mailbox_write_event");
                //check data (mailbox)
	        if (soc_to_fpga_mailbox_write_data_expect_value !== soc_to_fpga_mailbox_write_data_captured) begin
	        $display($time, " mailbox data FAIL");
	        error_cnt=error_cnt+1;
	        end	
		else begin
		$display($time, " mailbox data PASS");
		$display("-----------------");
		end
		$display("mailbox check finish");    
		
		
		// FPGA side AXI-Stream data in data out  
                              
                soc_to_fpga_axis_expect_count = 0;
		fpga_x_stream_in();
		$display($time, "=> wait all y receieve");
                while (soc_to_fpga_axis_captured_count != 64) begin		// wait util fpga_is_as_tready == 1 then change data
		 @ (posedge fpga_coreclk);
		 end
		 //  I check data first 32th 64th
	        if ((soc_to_fpga_axis_captured[63][31:0]!=10614)|(soc_to_fpga_axis_captured[0][31:0]!=0)|(soc_to_fpga_axis_captured[31][31:0]!=4758)) begin
	        $display($time, " FIR FAIL");
	        error_cnt=error_cnt+1;
	        end	
		else begin
		$display($time, " FIR from soc side PASS");
		end
		$display("-----------------");            
          end       
       endtask
       
       task test2    ;
          begin
                //write len
                fpga_to_soc_cfg_write(28'h10,64);
                // write coef 
                for(k=0; k< 11; k=k+1) begin
                fpga_to_soc_cfg_write(28'h20+4*k, coef[k]);
                end
                //FIR start
                fpga_to_soc_cfg_write(28'h00,1);
                // FPGA side AXI-Stream data in data out  
               soc_to_fpga_axis_expect_count = 0;
		fpga_x_stream_in();
		$display($time, "=> wait all y receieve");
                while (soc_to_fpga_axis_captured_count != 64) begin		// wait util fpga_is_as_tready == 1 then change data
		 @ (posedge fpga_coreclk);
		 end
		 //  I check data first 32th 64th
	        if ((soc_to_fpga_axis_captured[63][31:0]!=10614)|(soc_to_fpga_axis_captured[0][31:0]!=0)|(soc_to_fpga_axis_captured[31][31:0]!=4758)) begin
	        $display($time, " FIR FAIL");
	        error_cnt=error_cnt+1;
	        end	
		else begin
		$display($time, " FIR from fpga side PASS");
		end
		$display("-----------------");    
          
          end
       
       endtask

       task fpga_axis_req_FIR;
		input [31:0] data;
		input [1:0] tid;
		input mode;	//o ffor noram, 1 for random data
		`ifdef USER_PROJECT_SIDEBAND_SUPPORT
		input [pUSER_PROJECT_SIDEBAND_WIDTH-1:0] upsb;
		`endif
		reg [31:0] tdata;
		`ifdef USER_PROJECT_SIDEBAND_SUPPORT
			reg [pUSER_PROJECT_SIDEBAND_WIDTH-1:0]tupsb;
		`endif
		reg [3:0] tstrb;
		reg [3:0] tkeep;
		reg tlast;
		
                reg [31:0] exp_data;

		begin
			if (mode) begin		//for random data
				tdata = $random;
				`ifdef USER_PROJECT_SIDEBAND_SUPPORT
					tupsb = $random;
				`endif
				tstrb = $random;
				tkeep = $random;
				tlast = $random;
                                exp_data = tdata;
			end
			else begin
				tdata = data;
				`ifdef USER_PROJECT_SIDEBAND_SUPPORT
					//tupsb = 5'b00000;
					//tupsb = tdata[4:0];
                                        tupsb = upsb;
				`endif
				tstrb = 4'b0000;
				tkeep = 4'b0000;
				//tstrb = 4'b1111;
				//tkeep = 4'b1111;
                               tlast = (data==63)?1'b1:1'b0;   //set tlast = eol
                                //exp_data = {tst_img_out_buf[idx3+3], tst_img_out_buf[idx3+2], tst_img_out_buf[idx3+1], tst_img_out_buf[idx3+0]};
			end
			`ifdef USER_PROJECT_SIDEBAND_SUPPORT
				fpga_as_is_tupsb <= tupsb;
			`endif
			fpga_as_is_tstrb <=  tstrb;
			fpga_as_is_tkeep <=  tkeep;
			fpga_as_is_tlast <=  tlast;
			fpga_as_is_tdata <= tdata;	//for axis write data
			`ifdef USER_PROJECT_SIDEBAND_SUPPORT
				$strobe($time, "=> fpga_axis_req send data,data = %x", fpga_as_is_tdata);
			`else	
				$strobe($time, "=> fpga_axis_req send data,data = %x", fpga_as_is_tdata);
			`endif
			fpga_as_is_tid <=  tid;		//set target
			fpga_as_is_tuser <=  TUSER_AXIS;		//for axis req
			fpga_as_is_tvalid <= 1;
			soc_to_fpga_axis_expect_count <= soc_to_fpga_axis_expect_count+1;

			@ (posedge fpga_coreclk);
			while (fpga_is_as_tready == 0) begin		// wait util fpga_is_as_tready == 1 then change data
					@ (posedge fpga_coreclk);
			end
			fpga_as_is_tvalid <= 0;
		
		end
	endtask

     task fpga_x_stream_in;
     		`ifdef USER_PROJECT_SIDEBAND_SUPPORT
		reg [pUSER_PROJECT_SIDEBAND_WIDTH-1:0]upsb;
		`endif
		begin
		       soc_to_fpga_axis_expect_count=0;
			@ (posedge fpga_coreclk);
			fpga_as_is_tready <= 1;
			for (j=0;j<64;j=j+1)begin
			soc_to_fpga_axis_expect_count<=soc_to_fpga_axis_expect_count+1;
                          `ifdef USER_PROJECT_SIDEBAND_SUPPORT
                           upsb = 0; 
		            fpga_axis_req_FIR(j, TID_DN_UP, 0, upsb);	//target to User Project
                          `else
		            fpga_axis_req_FIR(j, TID_DN_UP, 0);		//target to User Project
                          `endif
			end
			$display($time, "=> FIR x done");
		end
     endtask
