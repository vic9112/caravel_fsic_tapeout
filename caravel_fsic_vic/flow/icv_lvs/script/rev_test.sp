.GLOBAL VDD VSS
.GLOBAL VBP VBN

*.CONNECT VBP VDD
*.CONNECT VBN VSS


.subckt p08 VDD VSS VBP VBN
.ends p08

.subckt n08 VDD VSS VBP VBN
.ends n08

.subckt p08_hvt vdd vss vbp vbn
.ends p08_hvt

.subckt n08_hvt vdd vss vbp vbn
.ends n08_hvt

.subckt p08_lvt vdd vss vbp vbn
.ends p08_lvt

.subckt n08_lvt vdd vss vbp vbn
.ends n08_lvt

.subckt p08_rev vdd vss vbp vbn
.ends p08_rev

.subckt n08_rev vdd vss vbp vbn
.ends n08_rev

.subckt p08_rev2 vdd vss vbp vbn
.ends p08_rev2

.subckt n08_rev2 vdd vss vbp vbn
.ends n08_rev2

.subckt p08_rev3 vdd vss vbp vbn
.ends p08_rev3

.subckt n08_rev3 vdd vss vbp vbn
.ends n08_rev3

.subckt p08_rev4 vdd vss vbp vbn
.ends p08_rev4

.subckt n08_rev4 vdd vss vbp vbn
.ends n08_rev4
