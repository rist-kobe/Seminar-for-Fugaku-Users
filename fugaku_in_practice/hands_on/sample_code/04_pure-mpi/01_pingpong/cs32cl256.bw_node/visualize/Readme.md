```shell
$ bash 01convert2csv.sh ../out.1.0
$ bash 01convert2csv.sh ../out-rendezvous.3.0
$ bash 01convert2csv.sh ../out-short.2.0
$ ls
out.1.0.csv  out-rendezvous.3.0.csv  out-short.2.0.csv  (...)
$ python3 02viz.py out.1.0.csv
$ ls
out.1.0.bw.png  out.1.0.lt.png (...)
$ python3 03viz-compare.py out.1.0.csv out-rendezvous.3.0.csv
$ ls
comp.bw.png  comp.lt.png  (...)
```
