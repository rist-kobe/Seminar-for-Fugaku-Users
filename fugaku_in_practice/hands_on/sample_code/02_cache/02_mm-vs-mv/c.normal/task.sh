#!/bin/bash
#PJM --gname [project_name]
# #PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=1"
#PJM --rsc-list "elapse=00:10:00"
#PJM --rsc-list "node-mem=23Gi"
#PJM --rsc-list "freq=2000, eco_state=0"
#PJM -x PJM_LLIO_GFSCACHE=/vol0006
#PJM -N "mm"
#PJM -o  "%n.%j.out"
#PJM -e  "%n.%j.err"
#PJM -s


EXE=../run.x

NS=20
${EXE} ${NS} > outfile.${NS}

NS=40
${EXE} ${NS} > outfile.${NS}

NS=80
${EXE} ${NS} > outfile.${NS}

NS=100
${EXE} ${NS} > outfile.${NS}

NS=200
${EXE} ${NS} > outfile.${NS}

NS=400
${EXE} ${NS} > outfile.${NS}

NS=600
${EXE} ${NS} > outfile.${NS}

NS=800
${EXE} ${NS} > outfile.${NS}

NS=1000
${EXE} ${NS} > outfile.${NS}

NS=1200
${EXE} ${NS} > outfile.${NS}

NS=1400
${EXE} ${NS} > outfile.${NS}

#NS=1800
#${EXE} ${NS} > outfile.${NS}

#NS=2000
#${EXE} ${NS} > outfile.${NS}

#NS=4000
#${EXE} ${NS} > outfile.${NS}
