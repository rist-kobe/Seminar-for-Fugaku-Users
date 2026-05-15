#! /usr/bin/env/python3
# Copyright 2025 Research Organization for Information Science and Technology
import sys
import textwrap
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

## command-line option
argc = len(sys.argv)

if argc != 2:
     usage_msg = '''
     [usage] viz.py (arg1) 
     (arg1): input file name (char; csv)
     '''
     print(textwrap.dedent(usage_msg).strip())
     sys.exit(0)

# filtering 
data = pd.read_csv(sys.argv[1],sep=',',header=0)

data1 = data[ (data['BN'] == "simd") ]
data2 = data[ (data['BN'] == "swp") ]
data3 = data[ (data['BN'] == "nosimd") ]
         
plt.clf()
plt.rc('figure',figsize=(10.2,3.7)) #(6.4,4.8)[inch]
plt.rc('figure',dpi=150)
fig,(ax1,ax2) = plt.subplots(nrows=1,ncols=2,sharey=False)
#ax.set_aspect(2.5)
#ax1.set_yscale('log')
#ax2.set_yscale('log')

fmalst = data1['FMA']
fmalen = len(fmalst)
ind = np.arange(1.0,fmalen+1,1.0)

xminv=0.7
xmaxv=fmalen+0.3
ax1.set_xlim(left=xminv,right=xmaxv)
ax2.set_xlim(left=xminv,right=xmaxv)

yminv = 0
ymaxv = 18*1.17
ax1.set_ylim(bottom=yminv,top=ymaxv)

# peak_gfs=70.4
peak_gfs=2.2*2*8*1
yminv = 0
ymaxv = peak_gfs * 1.17
ax2.set_ylim(bottom=yminv,top=ymaxv)

ax1.plot(ind,data1['ELP_sec'],label=(data1['BN'].iloc[0]),\
         color='red',linestyle='--',linewidth='1.3', \
         marker='o',markersize='6',markerfacecolor='None')
ax1.plot(ind,data2['ELP_sec'],label=(data2['BN'].iloc[0]),\
         color='green',linestyle='--',linewidth='1.3', \
         marker='^',markersize='6',markerfacecolor='None')
ax1.plot(ind,data3['ELP_sec'],label=(data3['BN'].iloc[0]),\
         color='blue',linestyle='--',linewidth='1.3', \
         marker='s',markersize='6',markerfacecolor='None')
#ax1.plot(ind,data4['ELP_sec'],label=(data4['BN'].iloc[0]),\
#         color='magenta',linestyle='--',linewidth='1.3', \
#         marker='o',markersize='6') #,markerfacecolor='None')
#ax1.plot(ind,data5['ELP_sec'],label=(data5['BN'].iloc[0]),\
#         color='#4169e1',linestyle='--',linewidth='1.3', \
#         marker='^',markersize='6') #,markerfacecolor='None')

ax2.plot(ind,data1['Gflops'],label=(data1['BN'].iloc[0]),\
         color='red',linestyle='--',linewidth='1.3', \
         marker='o',markersize='6',markerfacecolor='None')
ax2.plot(ind,data2['Gflops'],label=(data2['BN'].iloc[0]),\
         color='green',linestyle='--',linewidth='1.3', \
         marker='^',markersize='6',markerfacecolor='None')
ax2.plot(ind,data3['Gflops'],label=(data3['BN'].iloc[0]),\
         color='blue',linestyle='--',linewidth='1.3', \
         marker='s',markersize='6',markerfacecolor='None')
#ax2.plot(ind,data4['Gflops'],label=(data4['BN'].iloc[0]),\
#         color='magenta',linestyle='--',linewidth='1.3', \
#         marker='o',markersize='6') #,markerfacecolor='None')
#ax2.plot(ind,data5['Gflops'],label=(data5['BN'].iloc[0]).lstrip("fj"),\
#         color='#4169e1',linestyle='--',linewidth='1.3', \
#         marker='^',markersize='6') #,markerfacecolor='None')

ax1.grid(which='major',axis='y',color='gray',linestyle='--',linewidth='0.6')
ax2.grid(which='major',axis='y',color='gray',linestyle='--',linewidth='0.6')

ax1.legend(loc='upper left',ncol=2,fontsize='small')

ax1.set_xticks(ind)
ax1.set_xticklabels(data1['FMA'])
ax1.set_xlabel('Number of FMA')
ax1.set_ylabel('Elapsed time (sec.)')
ax2.set_xticks(ind)
ax2.set_xticklabels(data1['FMA'])
ax2.set_xlabel('Number of FMA')
ax2.set_ylabel('Gflop/s')

# fig.suptitle('polynomial [A64FX(2.2GHz), frtpx, fj4.12.0]',fontsize='10')
fig.suptitle('polynomial [Fugaku (freq=2200, eco_state=2), frtpx, fj4.12.1]',fontsize='10')

ax2.axhline(y=peak_gfs,xmin=0,xmax=xmaxv,linewidth='2',color='red')

ofn = sys.argv[1].rstrip('csv')
ofn = ofn +'png'
plt.savefig(ofn,format='png')
