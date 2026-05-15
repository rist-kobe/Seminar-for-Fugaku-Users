#!/usr/bin/env python3
# Copyright 2025 Research Organization for Information Science and Technology 
import sys
import textwrap
import numpy as np
import matplotlib 
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pandas as pd

## command-line option
argc = len(sys.argv)

if argc != 3:
     usage_msg = '''
     [usage] viz-compare.py (arg1) (arg2)
     (arg1): input file (char; csv)
     (arg1): input file for comparison (char; csv)
     '''
     print(textwrap.dedent(usage_msg).strip())
     sys.exit(0)

data = pd.read_csv(sys.argv[1],sep=',',header=0)
fltp = ( data['bytes'] != 0 )
data_fltp = data[fltp]

data2 = pd.read_csv(sys.argv[2],sep=',',header=0)
fltp2 = ( data2['bytes'] != 0 )
data2_fltp = data2[fltp2]

## plot latency
plt.clf()
plt.rc('figure',figsize=(5.4,4.1)) # figsize=(6.4,4.8)
plt.rc('figure',dpi=150)
fig,ax = plt.subplots()

ax.set_xscale("log")
ax.set_yscale("log")

yminv = data_fltp['t[usec]'].min()
yminv = yminv*0.35
ymaxv = data_fltp['t[usec]'].max() 
ymaxv = ymaxv*2.3
ax.set_ylim(bottom=yminv,top=ymaxv)

xvar = data_fltp['bytes']
yvar = data_fltp['t[usec]']
ax.plot(xvar,yvar,linestyle='--',linewidth='1.2',marker='^',color='#dc143c',\
        label='default',markerfacecolor='none')
xvar = data2_fltp['bytes']
yvar = data2_fltp['t[usec]']
ax.plot(xvar,yvar,linestyle='--',linewidth='1.2',marker='o',color='#1e90ff',\
        label='Rendezvous(>256B)',markerfacecolor='none')

ax.legend()
ax.set_xlabel('Message length (bytes)')
ax.set_ylabel('Elapsed time ($\\mu$s)')
ax.set_title('IMB-1:Pingpong b/w 2 nodes in Fugaku (fj4.12.1)',fontsize=9)
ax.grid(which='both',axis='y',color='gray',linestyle='--',linewidth=0.6)
ax.grid(which='major',axis='x',color='gray',linestyle='--',linewidth=0.6)
ax.vlines(4096,yminv,ymaxv,colors='gray',linestyles='solid',linewidth=1.3)
ax.vlines(65536,yminv,ymaxv,colors='gray',linestyles='solid',linewidth=1.3)
ax.vlines(1048526,yminv,ymaxv,colors='gray',linestyles='solid',linewidth=1.3)

plt.text(4.0e+3, yminv*2, \
         'Cache-size=32MB, Cache-line=256B',\
         fontsize=7.5,bbox=dict(boxstyle='round',facecolor='wheat',alpha=0.5))

ofn = 'comp'
ofn = ofn + '.lt' +'.png'
plt.savefig(ofn,format='png')

## plot bandwidth 
plt.clf()
plt.rc('figure',figsize=(5.4,4.1)) # figsize=(6.4,4.8)
plt.rc('figure',dpi=150)
fig,ax = plt.subplots()

ax.set_xscale("log")
ax.set_yscale("log")

yminv = data_fltp['Mbytes/sec'].min()
yminv = yminv*0.35
ymaxv = data_fltp['Mbytes/sec'].max() 
ymaxv = ymaxv*2.3
ax.set_ylim(bottom=yminv,top=ymaxv)

xvar = data_fltp['bytes']
yvar = data_fltp['Mbytes/sec']
ax.plot(xvar,yvar,linestyle='--',linewidth='1.2',marker='^',color='#dc143c',\
        label='default',markerfacecolor='none')
xvar = data2_fltp['bytes']
yvar = data2_fltp['Mbytes/sec']
ax.plot(xvar,yvar,linestyle='--',linewidth='1.2',marker='o',color='#1e90ff',\
        label='Rendezvous(>256B)',markerfacecolor='none')

ax.legend()
ax.set_xlabel('Message length (bytes)')
ax.set_ylabel('Bandwidth (MB/s)')
ax.set_title('IMB-1:Pingpong b/w 2 nodes in Fugaku (fj4.12.1)', fontsize=9)
ax.grid(which='both',axis='y',color='gray',linestyle='--',linewidth=0.6)
ax.grid(which='major',axis='x',color='gray',linestyle='--',linewidth=0.6)
ax.vlines(4096,yminv,ymaxv,colors='gray',linestyles='solid',linewidth=1.3)
ax.vlines(65536,yminv,ymaxv,colors='gray',linestyles='solid',linewidth=1.3)
ax.vlines(1048526,yminv,ymaxv,colors='gray',linestyles='solid',linewidth=1.3)

plt.text(4.0e+3, yminv*2, \
         'Cache-size=32MB, Cache-line=256B',\
         fontsize=7.5,bbox=dict(boxstyle='round',facecolor='wheat',alpha=0.5))

ofn = 'comp'
ofn = ofn + '.bw' +'.png'
plt.savefig(ofn,format='png')
