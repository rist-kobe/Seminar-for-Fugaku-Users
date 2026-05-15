#! /usr/bin/env python3
# Copyright 2025 Research Organization for Information Science and Technology
import sys
import textwrap
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pandas as pd

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

# kernel list
kerlst = ['simple', 'DGEMM', 'Rep-DGEMV'] 
collst = ['#1e90ff', '#228b22', '#dc143c']
mrklst = ['o', '^', 's']

# setting
vaxis = 'NSIZE'
vname = 'matrix dimension'
xminv = 3
xmaxv = 1530 #2030

# plot
plt.clf()
#plt.rc('figure',figsize=(5.44,4.08)) #(6.4,4.8)[inch]
plt.rc('figure',figsize=(10.2,3.7)) #(6.4,4.8)[inch]
plt.rc('figure',dpi=150)
#fig,ax = plt.subplots()
fig,(axx,ax) = plt.subplots(nrows=1,ncols=2,sharey=False)
#ax.set_aspect(2.5)

axx.set_xlim(left=xminv,right=xmaxv)
axx.set_xlabel(vname,fontsize='9')
axx.set_ylim(bottom=0,top=0.82)
axx.set_ylabel('Elapsed time /NITR (sec.)',fontsize='11')

ax.set_xlim(left=xminv,right=xmaxv)
ax.set_xlabel(vname,fontsize='9')
ax.set_ylim(bottom=1,top=72)
ax.set_ylabel('Gflop/s',fontsize='11')

for (kl, cl, ml) in zip(kerlst, collst, mrklst):
    fltp = ( data['kernel'] == kl )
    data_fltp = data[fltp]
    xt = data_fltp['NSIZE']
    yt = data_fltp['Elapsed_time_sec'] / data_fltp['NITR']
    #ax.plot(xt, yt,label=kl,color='black',\
    #      linestyle='--',linewidth=1.0,marker='s',markerfacecolor='none')
    axx.plot(xt, yt, color=cl, label=kl, linestyle='--',linewidth='1.0', marker=ml, markerfacecolor='none')

for (kl, cl, ml) in zip(kerlst, collst, mrklst):
    fltp = ( data['kernel'] == kl )
    data_fltp = data[fltp]
    xt = data_fltp['NSIZE']
    yt = data_fltp['Gflop/s']
    #ax.plot(xt, yt,label=kl,color='black',\
    #      linestyle='--',linewidth=1.0,marker='s',markerfacecolor='none')
    ax.plot(xt, yt, color=cl, label=kl, linestyle='--',linewidth='1.0', marker=ml, markerfacecolor='none')

axx.legend(ncol=5,fontsize='7.5')
#ax.legend(ncol=5,fontsize='7.5')

axx.grid(which='major',axis='y',color='gray',linestyle='--',linewidth=0.8)
ax.grid(which='major',axis='y',color='gray',linestyle='--',linewidth=0.8)

## A64FX
# L2/CMG: sqrt(L2CMG/(3*8B))
CS2MDIM=np.sqrt((8.0*1024*1024)/(3*8.0) )
axx.axvline(CS2MDIM, color='gray', linewidth=1.0)
ax.axvline(CS2MDIM, color='gray', linewidth=1.0)
# L2: sqrt(L2/(3*8B))
CS2MDIM=np.sqrt((32.0*1024*1024)/(3*8.0) )
axx.axvline(CS2MDIM, color='gray', linewidth=1.0)
ax.axvline(CS2MDIM, color='gray', linewidth=1.0)
# FP (DP) peak
ax.axhline(2.2*2*8*1, color='red', linewidth=2.0)

#ax.set_title('A64FX (2.2GHz) \nwith Fujitsu frtpx and SSL2(BLAS/LAPACK) [fj4.12.0]', fontsize='9')
fig.suptitle('Fugaku (freq=2200, eco_state=2) \nwith frtpx (-O3) and SSL2 (BLAS/LAPACK) [fj4.12.1]', fontsize='9')

ofn = 'out.png'
plt.savefig(ofn,format='png')

sys.exit(0)
