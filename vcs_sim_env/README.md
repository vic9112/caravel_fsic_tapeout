首先先設定利用  https://hackmd.io/sJ_rN9onSlSbDC2pi6upDQ 中教學修改

要模擬個別可以進入到個別的dir來模擬，舉例模擬falcon演算法
```
cd lab_setup_for_saed32/lab_synthesis/sim_vcs_falcon/
make rtlcom
```

各位可以自行複製來撰寫新的tb。
```
cp -rf lab_setup_for_saed32/lab_synthesis/sim_vcs_edge lab_setup_for_saed32/lab_synthesis/sim_vcs_XXXXXX
```

註1: vic你要覆蓋的檔案在 lab_setup_for_saed32/fsic_new/ 中。

註2: 其他人如果原本就有架設好也可以把lab_setup_for_saed32/fsic_new/ 中的檔案覆蓋到commom/rtl原本的位置，但要注意有兩個檔案可能要修改caravel_top_analyze.tcl 跟caravel.f 要寄的加上原本沒有的檔名。
