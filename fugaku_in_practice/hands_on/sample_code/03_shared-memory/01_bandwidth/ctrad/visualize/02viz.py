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

#if argc != 3:
if argc < 3:
     usage_msg = '''
     [usage] viz.py (arg1) (arg2) (arg3)
     (arg1): input file name (char; csv)
     (arg2): Function name (Copy, Scale, Add, Triad)
     (arg3): data for compare
     '''
     print(textwrap.dedent(usage_msg).strip())
     sys.exit(0)

# filtering     
data = pd.read_csv(sys.argv[1],sep=',',header=0)
fltp = ( data['Function'] == sys.argv[2] )
data_fltp = data[fltp]
#print(data_fltp)

# if arg3 exists:
if argc == 4:
     data2 = pd.read_csv(sys.argv[3],sep=',',header=0)
     data2_fltp = data2[fltp]
         
plt.clf()
plt.rc('figure',figsize=(5.44,4.08)) #(6.4,4.8)[inch]
plt.rc('figure',dpi=150)
fig,ax = plt.subplots()
#ax.set_aspect(1.5)

x = data_fltp['NT']
y = data_fltp['Rate_MB/s'] * 1.0e-3
lb = data_fltp['BN'].iloc[0]
if lb == 'fj_zfill':
     lb = 'zfill,512-bits'
else:
     lb = 'nozfill,512-bits'
ax.plot(x,y,linestyle='--',linewidth='1.0',color='red',label=lb,marker='o', markerfacecolor='none')
if argc == 4:
     x2 = data2_fltp['NT']
     y2 = data2_fltp['Rate_MB/s'] * 1.0e-3
     lb2 = data2_fltp['BN'].iloc[0]
     if lb2 == 'fj_zfill':
          lb2 = 'zfill,512-bits'
     else:
          lb2 = 'nozfill,512-bits'
     ax.plot(x2,y2,linestyle='--',linewidth='1.0',color='blue',label=lb2,marker='^', markerfacecolor='none')

ax.legend(fontsize='8.5',ncol=3)

ax.set_title('STREAM:Triad '+'[Fujitsu C Trad (fj4.12.1), FLIB_BARRIER=SOFT,\n' \
             +'Memory for arrays=2.3GB]' +' @ Fugaku (freq=2200, eco_state=2)',fontsize='9')

xminv = 0.3
xmaxv = 48.7
ax.set_xlim(left=xminv,right=xmaxv)

peakbw = 1024
ymaxv = peakbw * 1.3
ax.set_ylim(bottom=0,top=ymaxv)
ax.set_ylabel('Memory bandwidth (GB/s)',fontsize='11')
ax.set_xlabel('Number of threads',fontsize='11')
ax.axhline(y=peakbw,linestyle='-',linewidth=1.2,color='red')

ax.grid(which='major',axis='y',color='gray',linestyle='--',linewidth=0.8)

plt.text(xmaxv*0.3, ymaxv*0.05, 'OMP_PLACES=cores\n'\
     +'(# of thds)<=12: OMP_PROC_BIND=cores\n'\
     +'(# of thds)>12: OMP_PROC_BIND=spread\n'\
	+'XOS_MMM_L_PAGING_POLICY=demand:demand:prepage',\
	fontsize=7.5,bbox=dict(boxstyle='round',facecolor='wheat',alpha=0.5))

#ofn = sys.argv[1].rstrip('csv')
#ofn = ofn + sys.argv[2]+'.png'
ofn = 'stat.' + sys.argv[2] + '.png'
plt.savefig(ofn,format='png')
