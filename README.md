
RDS Oracle Tracefile Retriever
==============================

Provided two scripts for getting tracefiles from RDS.

* rds-tracefile-listing.pl
* tracefile-retriever.pl

The tracefile-retriever.pl script is generic and will work with any Oracle database,
while the rds-tracefile-listing script is RDS specific

## list the tracefiles

```text
$  ./rds-tracefile-listing.pl -database jks01  -username admin -password XXXX  -dumpdir BDUMP
FILENAME                                                            TYPE       SIZE MODTIME
alert_ORCL.log                                                      file       2744 2021-12-22 00:33:01
alert_ORCL.log.2021-12-09                                           file     156314 2021-12-09 23:58:25
alert_ORCL.log.2021-12-10                                           file     154704 2021-12-10 23:56:49
alert_ORCL.log.2021-12-11                                           file     113264 2021-12-11 23:54:39
alert_ORCL.log.2021-12-12                                           file     129297 2021-12-12 23:57:06
alert_ORCL.log.2021-12-13                                           file     113859 2021-12-13 23:57:19
alert_ORCL.log.2021-12-14                                           file     112845 2021-12-14 23:57:24
alert_ORCL.log.2021-12-15                                           file     114092 2021-12-15 23:57:01
alert_ORCL.log.2021-12-16                                           file     112326 2021-12-16 23:55:18
alert_ORCL.log.2021-12-17                                           file     112613 2021-12-17 23:54:30
alert_ORCL.log.2021-12-18                                           file     114667 2021-12-18 23:58:19
alert_ORCL.log.2021-12-19                                           file     113566 2021-12-19 23:57:35
alert_ORCL.log.2021-12-20                                           file     113409 2021-12-20 23:57:19
alert_ORCL.log.2021-12-21                                           file     112424 2021-12-21 23:57:26
bdump-file-listing                                                  file       5970 2021-12-22 00:37:40
dbtask-1639595523271-49.log                                         file      89322 2021-12-15 19:12:03
dbtask-1639595573791-49.log                                         file     735703 2021-12-15 19:12:55
dbtask-1639595590980-49.log                                         file       1140 2021-12-15 19:13:11
dbtask-1639595601687-49.log                                         file       1140 2021-12-15 19:13:21
fips-parameters                                                     file          0 2021-12-09 00:42:09
lsinventory-19.0.0.0.ru-2021-07.rur-2021-07.r1.txt                  file      67148 2021-08-16 01:31:09
lsinventory_detail-19.0.0.0.ru-2021-07.rur-2021-07.r1.txt           file    3064567 2021-08-16 01:31:41
ORCL_cjq0_6439.trc                                                  file       2856 2021-12-21 22:00:01
ORCL_cjq0_6439.trm                                                  file       1153 2021-12-21 22:00:01
ORCL_dbrm_6302.trc                                                  file     966418 2021-12-22 00:36:23
ORCL_dbrm_6302.trm                                                  file      88410 2021-12-22 00:36:23
ORCL_dia0_6314_base_1.trc                                           file       2080 2021-12-19 07:45:00
ORCL_dia0_6314_base_1.trm                                           file        865 2021-12-19 07:45:00
ORCL_j001_19842.trc                                                 file       1251 2021-12-16 22:00:04
ORCL_j001_19842.trm                                                 file        861 2021-12-16 22:00:04
ORCL_j001_20540.trc                                                 file       1251 2021-12-19 06:00:04
ORCL_j001_20540.trm                                                 file        861 2021-12-19 06:00:04
ORCL_j001_6275.trc                                                  file       1250 2021-12-17 22:00:05
ORCL_j001_6275.trm                                                  file        861 2021-12-17 22:00:05
ORCL_j002_12793.trc                                                 file       1252 2021-12-18 18:07:03
ORCL_j002_12793.trm                                                 file        862 2021-12-18 18:07:03
ORCL_j002_13258.trc                                                 file       1251 2021-12-19 22:07:54
ORCL_j002_13258.trm                                                 file        862 2021-12-19 22:07:54
ORCL_j002_17251.trc                                                 file       1252 2021-12-18 10:06:44
ORCL_j002_17251.trm                                                 file        862 2021-12-18 10:06:44
ORCL_j002_17707.trc                                                 file       1251 2021-12-19 14:07:39
ORCL_j002_17707.trm                                                 file        861 2021-12-19 14:07:39
ORCL_j002_26653.trc                                                 file       1251 2021-12-18 22:07:11
ORCL_j002_26653.trm                                                 file        862 2021-12-18 22:07:11
ORCL_j002_31210.trc                                                 file       1251 2021-12-18 14:06:53
ORCL_j002_31210.trm                                                 file        861 2021-12-18 14:06:53
ORCL_j002_31697.trc                                                 file       1252 2021-12-19 18:07:46
ORCL_j002_31697.trm                                                 file        862 2021-12-19 18:07:46
ORCL_j002_3795.trc                                                  file       1249 2021-12-19 10:07:33
ORCL_j002_3795.trm                                                  file        860 2021-12-19 10:07:33
ORCL_j003_1043.trc                                                  file       1249 2021-12-15 22:00:05
ORCL_j003_1043.trm                                                  file        861 2021-12-15 22:00:05
ORCL_j003_16900.trc                                                 file       1250 2021-12-21 22:00:03
ORCL_j003_16900.trm                                                 file        861 2021-12-21 22:00:03
ORCL_j003_1780.trc                                                  file       1248 2021-12-18 06:00:07
ORCL_j003_1780.trm                                                  file        861 2021-12-18 06:00:07
ORCL_j003_30420.trc                                                 file       1251 2021-12-20 22:00:04
ORCL_j003_30420.trm                                                 file        861 2021-12-20 22:00:04
ORCL_m000_7206.trc                                                  file       5209 2021-12-16 13:00:14
ORCL_m000_7206.trm                                                  file       2444 2021-12-16 13:00:14
ORCL_mz01_2255.trc                                                  file       9736 2021-12-16 03:41:11
ORCL_mz01_2255.trm                                                  file       4018 2021-12-16 03:41:11
ORCL_ora_10356.trc                                                  file       3355 2021-12-22 00:14:17
ORCL_ora_10356.trm                                                  file       1071 2021-12-22 00:14:17
ORCL_ora_12276.trc                                                  file       1171 2021-12-22 00:22:13
ORCL_ora_12276.trm                                                  file        872 2021-12-22 00:22:13
ORCL_ora_12291.trc                                                  file       1171 2021-12-22 00:22:21
ORCL_ora_12291.trm                                                  file        872 2021-12-22 00:22:21
ORCL_ora_12547.trc                                                  file       1171 2021-12-22 00:24:08
ORCL_ora_12547.trm                                                  file        872 2021-12-22 00:24:08
ORCL_ora_12589.trc                                                  file       1171 2021-12-22 00:24:27
ORCL_ora_12589.trm                                                  file        872 2021-12-22 00:24:27
ORCL_ora_12610.trc                                                  file       1170 2021-12-22 00:24:39
ORCL_ora_12610.trm                                                  file        872 2021-12-22 00:24:39
ORCL_ora_12633.trc                                                  file       1171 2021-12-22 00:24:47
ORCL_ora_12633.trm                                                  file        872 2021-12-22 00:24:47
ORCL_ora_13152.trc                                                  file       1171 2021-12-22 00:26:42
ORCL_ora_13152.trm                                                  file        872 2021-12-22 00:26:42
ORCL_ora_13166.trc                                                  file       1171 2021-12-22 00:26:49
ORCL_ora_13166.trm                                                  file        872 2021-12-22 00:26:49
ORCL_ora_13191.trc                                                  file       1171 2021-12-22 00:26:59
ORCL_ora_13191.trm                                                  file        872 2021-12-22 00:26:59
ORCL_ora_13259.trc                                                  file       1171 2021-12-22 00:27:15
ORCL_ora_13259.trm                                                  file        872 2021-12-22 00:27:15
ORCL_ora_13275.trc                                                  file       1171 2021-12-22 00:27:25
ORCL_ora_13275.trm                                                  file        872 2021-12-22 00:27:25
ORCL_ora_13305.trc                                                  file       1170 2021-12-22 00:27:37
ORCL_ora_13305.trm                                                  file        871 2021-12-22 00:27:37
ORCL_ora_13330.trc                                                  file       1171 2021-12-22 00:27:48
ORCL_ora_13330.trm                                                  file        872 2021-12-22 00:27:48
ORCL_ora_13404.trc                                                  file       1171 2021-12-22 00:28:09
ORCL_ora_13404.trm                                                  file        872 2021-12-22 00:28:09
ORCL_ora_13488.trc                                                  file       1171 2021-12-22 00:28:53
ORCL_ora_13488.trm                                                  file        872 2021-12-22 00:28:53
ORCL_ora_13554.trc                                                  file       1171 2021-12-22 00:29:07
ORCL_ora_13554.trm                                                  file        872 2021-12-22 00:29:07
ORCL_ora_13764.trc                                                  file       1305 2021-12-22 00:30:04
ORCL_ora_13764.trm                                                  file        881 2021-12-22 00:30:04
ORCL_ora_13999.trc                                                  file       1387 2021-12-22 00:30:42
ORCL_ora_13999.trm                                                  file        882 2021-12-22 00:30:42
ORCL_ora_14143.trc                                                  file       1037 2021-12-22 00:30:44
ORCL_ora_14143.trm                                                  file        862 2021-12-22 00:30:44
ORCL_ora_14290.trc                                                  file       1305 2021-12-22 00:30:55
ORCL_ora_14290.trm                                                  file        882 2021-12-22 00:30:55
ORCL_ora_14767.trc                                                  file       1176 2021-12-15 20:37:04
ORCL_ora_14767.trm                                                  file        884 2021-12-15 20:37:04
ORCL_ora_15966.trc                                                  file       1037 2021-12-22 00:37:40
ORCL_ora_15966.trm                                                  file        862 2021-12-22 00:37:40
ORCL_ora_23311.trc                                                  file     309742 2021-12-15 18:29:39
ORCL_ora_23311.trm                                                  file      52026 2021-12-15 18:29:39
ORCL_ora_24289.trc                                                  file    2478736 2021-12-15 20:28:32
ORCL_ora_24289.trm                                                  file     452720 2021-12-15 20:28:32
ORCL_ora_27056.trc                                                  file     128029 2021-12-15 18:50:09
ORCL_ora_27056.trm                                                  file      26107 2021-12-15 18:50:09
ORCL_ora_2706_test.trc                                              file      28467 2021-12-15 19:29:11
ORCL_ora_2706_test.trm                                              file       6892 2021-12-15 19:29:11
ORCL_ora_6064.trc                                                   file   39855122 2021-12-15 20:40:25
ORCL_ora_6064.trm                                                   file    5943108 2021-12-15 20:40:25
ORCL_ora_7604.trc                                                   file       1133 2021-12-21 23:59:40
ORCL_ora_7604.trm                                                   file        870 2021-12-21 23:59:40
ORCL_q005_6826.trc                                                  file      17509 2021-12-21 22:25:14
ORCL_q005_6826.trm                                                  file       3774 2021-12-21 22:25:14
ORCL_q006_11874.trc                                                 file       5436 2021-12-15 21:12:55
ORCL_q006_11874.trm                                                 file       1683 2021-12-15 21:12:55
ORCL_q007_13030.trc                                                 file       1686 2021-12-21 23:05:11
ORCL_q007_13030.trm                                                 file       1033 2021-12-21 23:05:11
ORCL_q008_6469.trc                                                  file       7234 2021-12-20 21:46:31
ORCL_q008_6469.trm                                                  file       1993 2021-12-20 21:46:31
ORCL_q00c_2636.trc                                                  file       2510 2021-12-22 00:25:07
ORCL_q00c_2636.trm                                                  file       1175 2021-12-22 00:25:07
ORCL_vkrm_6306.trc                                                  file     136961 2021-12-22 00:30:01
ORCL_vkrm_6306.trm                                                  file      19688 2021-12-22 00:30:01
ORCL_vktm_6272.trc                                                  file       1805 2021-12-15 21:15:01
ORCL_vktm_6272.trm                                                  file       1124 2021-12-15 21:15:01
sqlnet-parameters                                                   file         31 2021-12-09 00:42:09
trace/                                                         directory      32768 2021-12-22 00:37:40
```

## Tracefile Retriever

mrskew was used to verify the tracefile is complete.

```text
$  time ./tracefile-retriever.pl -username admin -password XXXX -database jks01 -dumpdir BDUMP -tracefile ORCL_ora_6064.trc > test.trc

real    1m26.295s
user    0m0.756s
sys     0m0.412s

$  ls -l test.trc
-rw-rw-r-- 1 jkstill dba 39855122 Dec 21 17:43 test.trc

$  mrskew test.trc
input files:
        'test.trc'

where expression:
        ((1) and ($dep==$depmin)) and ($nam=~/.+/i)

group expression:
        $nam

matched input files:
        'test.trc'

matched call names:
        'CLOSE'
        'Disk file operations I/O'
        'EXEC'
        'FETCH'
        'PARSE'
        'PGA memory operation'
        'SQL*Net message from client'
        'SQL*Net message to client'
        'XCTEND'
        'buffer busy waits'
        'db file parallel read'
        'db file scattered read'
        'db file sequential read'
        'direct path read'
        'enq: KO - fast object checkpoint'
        'latch: In memory undo latch'
        'latch: enqueue hash chains'
        'latch: redo allocation'
        'log file sync'
        'reliable message'

CALL-NAME                      DURATION       %    CALLS      MEAN       MIN       MAX
---------------------------  ----------  ------  -------  --------  --------  --------
SQL*Net message from client  827.762658   96.7%   41,859  0.019775  0.014027  0.575505
db file sequential read        9.476320    1.1%   13,210  0.000717  0.000240  0.141593
EXEC                           6.457169    0.8%   38,117  0.000169  0.000000  0.041244
FETCH                          6.278640    0.7%   30,240  0.000208  0.000000  0.253826
log file sync                  4.146784    0.5%    3,739  0.001109  0.000552  0.063785
PARSE                          0.527491    0.1%   38,117  0.000014  0.000000  0.006133
db file parallel read          0.312037    0.0%      456  0.000684  0.000408  0.003753
CLOSE                          0.217897    0.0%   38,117  0.000006  0.000000  0.009952
SQL*Net message to client      0.206395    0.0%   41,859  0.000005  0.000001  0.020415
direct path read               0.155816    0.0%      149  0.001046  0.000011  0.007415
10 others                      0.115250    0.0%    4,827  0.000024  0.000000  0.047877
---------------------------  ----------  ------  -------  --------  --------  --------
TOTAL (20)                   855.656457  100.0%  250,690  0.003413  0.000000  0.575505
(base) jkstill@poirot  ~/aws/rds/trace-file-retriever $

```

