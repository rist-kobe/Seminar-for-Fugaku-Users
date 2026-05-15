# Copyright 2024 Research Organization for Information Science and Technology 
set terminal png enhanced 
set output 'mem_rd_P1.256.png'
#set terminal postscript eps enhanced color 
#set output 'mem_rd_P1.1024MB.eps
#set datafile separator "," 
##### SET STYLE #####
set style line 1 lw 2 lc rgb "#ff0000" pt 4 ps 2
set style line 2 lw 2 lc rgb "#0000ff" pt 6 ps 2
set style line 3 lw 2 lc rgb "#00ff00" pt 8 ps 2
set style line 4 lw 2 lc rgb "#ff00ff" pt 3 ps 1.4
set style line 5 lw 2 lc rgb "#ffa500" pt 2 ps 1.4 
set style line 6 lw 2 lc rgb "#00ffff" pt 1 ps 1.4 
#Shadecolor1="#eecccc"
#Shadecolor2="#ccccee"
#Shadecolor3="#cceecc"
#Shadecolor4="#cceeee"
#Shadecolor5="#eeeecc"
#Shadecolor6="#eeccee"
##### SET STYLE: END #####
set logscale xy
set xlabel "{/=14 Range (MiB)}"
set ylabel "{/=14 Latency (ns)}"
#set xtics ("2" 2, "4" 4, "6" 6, "8" 8, "12" 12, "16" 16, "24" 24, "32" 32, "48" 48)
set xrange [0.0010:256.000]
set yrange[1:400]
set grid xtics ytics mytics
set key left top
## L1 data cache
#L1D=32768.0/(1024*1024)
L1D=65536.0/(1024*1024)
set arrow from L1D,1 to L1D,400 nohead dashtype"--" 
set label 1 "  L1D" at L1D,200
## L2 cache 
#L2=524288.0/(1024*1024)
L2=32.0
set arrow from L2,1 to L2,400 nohead dashtype"--"
set label 2 "  L2" at L2,300
## L2 cache per CMG
L2CMG=8.0
set arrow from L2CMG,1 to L2CMG,400 nohead dashtype"--"
set label 3 "  L2/CMG" at L2CMG,200
## L3 cache
#L3=268435456.0/(1024*1024)
#set arrow from L3,1 to L3,200 nohead dashtype"--"
#set label 3 "$L3" at L3,120
## L3 on Complex Core Die for 3rd Gen
#L3CCD=32
#set arrow from L3CCD,1 to L3CCD,200 nohead dashtype"--"
#set label 4 "$L3/CCD" at L3CCD,120
#
set title "{/=12 LMbench:lat-mem-rd (-P 1 256) at A64FX(fj4.12.1; freq=2200, eco state=2)}"
#
plot \
    "<awk -F ',' '($1==64){print $2,$3}' P1.256MB.csv" \
    using 1:2 with line ls 5  title 'stride 64' , \
    "<awk -F ',' '($1==128){print $2,$3}' P1.256MB.csv" \
    using 1:2 with line ls 4  title 'stride 128' , \
    "<awk -F ',' '($1==256){print $2,$3}' P1.256MB.csv" \
    using 1:2 with line ls 3  title 'stride 256' , \
    "<awk -F ',' '($1==512){print $2,$3}' P1.256MB.csv" \
    using 1:2 with line ls 2  title 'stride 512' , \
    "<awk -F ',' '($1==1024){print $2,$3}' P1.256MB.csv" \
    using 1:2 with line ls 1  title 'stride 1024' , \


set output
reset
