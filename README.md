# perf_report
Run a report for avg CPU/Mem/Load from Nagios perf data

Use this as a rough draft if you need somehting similar.  It runs against all perf data and uses very poor methods to validate if it is Windows or Linux.  For other items, like switches or whatever that also have Load, it may false report as linux and other items may false report as Windows.  This does what we need it to do though, shows us the heavy hitters with high averages over the past month
