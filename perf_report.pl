#! /usr/bin/perl -w
############## disk_perf.pl #########################
# Author  : IT Convergence
# Licence : GPL - http://www.fsf.org/licenses/gpl.txt
# Contrib : 
# ToDo    : N/A
#######################################################
#
use strict;
use warnings;
use Carp;
use Getopt::Long;
use lib "/usr/local/nagios/libexec";
use utils qw(%ERRORS $TIMEOUT);

#### Nagios specific ####
my $output_msg = "";
my $status = 0;
my $Version = "0.5";

# Standard options
my $o_check  = undef;
my $o_email  = undef;
my $o_help  = undef;

# functions
sub print_usage {
    print "Usage: $0 -e <your email address> -h\n";
}

sub help {
   print "\nReport of 1 month perf data averages - Version ",$Version,"\n";
   print "GPL licence, (c)2013-2016 ITC\n\n";
   print_usage();
   print <<EOT;
-h, --help
   print this help message
-e, --email
   Email address to send report
EOT
}

sub check_options { #### Check Options
    Getopt::Long::Configure ("bundling");
	GetOptions(
	'h'     => \$o_help,            'help'          => \$o_help,
        'c:s'   => \$o_check,	'check:s'	=> \$o_check,
        'e:s'   => \$o_email,	'email:s'	=> \$o_email
    );
    if (defined($o_help)) { help(); exit $ERRORS{"UNKNOWN"}};
    if ( !defined($o_email) ) { print_usage(); exit $ERRORS{"UNKNOWN"}};
#    if ( !defined($o_check) ) { print_usage(); exit $ERRORS{"UNKNOWN"}};
}

############################################
##############   MAIN   ####################
############################################
check_options();
chdir "/usr/local/nagios/share/perfdata";
my $command = "ls -ldm1 *";
my @folders = `$command`;
my $filesnix = "/tmp/perf-report.csv";
# check if the file exists
if (-f $filesnix) {
	unlink $filesnix
	or croak "Cannot delete $filesnix: $!";
}
# use a variable for the file handle
my $OUTFILE;
open $OUTFILE, '>>', $filesnix;
        print { $OUTFILE } "server,os,cpu,cpu user,cpu system,cpu idle,cpu iowait,load1,load5,load15,memory used percent\n";
foreach (@folders){
	my $folder = $_;
	chomp $folder;
	$folder =~ s/^\s+|\s+$//g;
	my $file = $folder."/Load.xml";
	my $file2 = $folder."/CPU.xml";
	my $file3 = $folder."/Memory.xml";
	my $cpuuser2='';
        my $cpusystem2='';
        my $cpuidle2='';
        my $cpuiowait2='';
        my $load12='';
        my $load52='';
        my $load152='';
        my $memtotal2='';
        my $memused2='';
	if (-f $file){ #Linux
	if ( 1 > -M $file and (localtime((stat _)[9]))[3] == (localtime)[3] ) {
		if (-f $file2){
		if ( 1 > -M $file2 and (localtime((stat _)[9]))[3] == (localtime)[3] ) {
			my $cpuuser= "rrdtool graph dummy -s -1month -e start+1month DEF:test=/usr/local/nagios/share/perfdata/$folder/CPU.rrd:1:AVERAGE PRINT:test:AVERAGE:'%.0lf'|sed -n 2p";
			my $cpusystem= "rrdtool graph dummy -s -1month -e start+1month DEF:test=/usr/local/nagios/share/perfdata/$folder/CPU.rrd:2:AVERAGE PRINT:test:AVERAGE:'%.0lf'|sed -n 2p";
			my $cpuidle= "rrdtool graph dummy -s -1month -e start+1month DEF:test=/usr/local/nagios/share/perfdata/$folder/CPU.rrd:4:AVERAGE PRINT:test:AVERAGE:'%.0lf'|sed -n 2p";
			my $cpuiowait= "rrdtool graph dummy -s -1month -e start+1month DEF:test=/usr/local/nagios/share/perfdata/$folder/CPU.rrd:3:AVERAGE PRINT:test:AVERAGE:'%.0lf'|sed -n 2p";
	                $cpuuser2= `$cpuuser`;
	                $cpusystem2= `$cpusystem`;
	                $cpuidle2= `$cpuidle`;
	                $cpuiowait2= `$cpuiowait`;
	                chomp $cpuuser2;
	                chomp $cpusystem2;
	                chomp $cpuidle2;
	                chomp $cpuiowait2;
		}
		}
			my $load1= "rrdtool graph dummy -s -1month -e start+1month DEF:test=/usr/local/nagios/share/perfdata/$folder/Load.rrd:1:AVERAGE PRINT:test:AVERAGE:'%.0lf'|sed -n 2p";
			my $load5= "rrdtool graph dummy -s -1month -e start+1month DEF:test=/usr/local/nagios/share/perfdata/$folder/Load.rrd:2:AVERAGE PRINT:test:AVERAGE:'%.0lf'|sed -n 2p";
			my $load15= "rrdtool graph dummy -s -1month -e start+1month DEF:test=/usr/local/nagios/share/perfdata/$folder/Load.rrd:3:AVERAGE PRINT:test:AVERAGE:'%.0lf'|sed -n 2p";
		my $memtotal= "rrdtool graph dummy -s -1month -e start+1month DEF:test=/usr/local/nagios/share/perfdata/$folder/Memory.rrd:1:AVERAGE PRINT:test:AVERAGE:'%.0lf'|sed -n 2p";
		my $memused= "rrdtool graph dummy -s -1month -e start+1month DEF:test=/usr/local/nagios/share/perfdata/$folder/Memory.rrd:2:AVERAGE PRINT:test:AVERAGE:'%.0lf'|sed -n 2p";
                $load12= `$load1`;
                $load52= `$load5`;
                $load152= `$load15`;
                $memtotal2= `$memtotal`;
                $memused2= `$memused`;
		chomp $load12;
		chomp $load52;
		chomp $load152;
		chomp $memtotal2;
		chomp $memused2;
		my $memused3=undef;
		if ($memused2 > 0) {
			$memused3= int(($memused2/$memtotal2)*100);
		} else {
			$memused3= "n/a";
		}
		my $output="$folder,Linux,,$cpuuser2,$cpusystem2,$cpuidle2,$cpuiowait2,$load12,$load52,$load152,$memused3\n";
		#if ($output ne "$folder,Linux,,,,,,,,,\n") {
			print { $OUTFILE } "$output";
		#}
		}
	} elsif ((-f $file2) && (-f $file3)) { #Windows
	if ( 1 > -M $file2 and (localtime((stat _)[9]))[3] == (localtime)[3] ) {
                my $cpu= "rrdtool graph dummy -s -1month -e start+1month DEF:test=/usr/local/nagios/share/perfdata/$folder/CPU.rrd:1:AVERAGE PRINT:test:AVERAGE:'%.0lf'|sed -n 2p";
                my $memused= "rrdtool graph dummy -s -1month -e start+1month DEF:test=/usr/local/nagios/share/perfdata/$folder/Memory.rrd:1:AVERAGE PRINT:test:AVERAGE:'%.0lf'|sed -n 2p";
		my $cpu2= `$cpu`;
                my $memused2= `$memused`;
		chomp $cpu2;
                chomp $memused2;
                print { $OUTFILE } "$folder,Windows,$cpu2,,,,,,,,$memused2\n";
	}
	}
}
########################################################################################
#
# Close file and email
#
close $OUTFILE;
system("mail -a /tmp/perf-report.csv -s \"Perf Report for: CPU/MEM/LOAD\" $o_email < /usr/local/nagios/libexec/scripts/perfreport/perf_report_body.txt");
exit $status;
