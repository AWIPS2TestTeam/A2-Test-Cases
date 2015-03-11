#!/usr/bin/perl -w
#
# This script will automatically bounce EDEX as root on DX3 and DX4.
# The script stops EDEX on DX3 and then DX4. Then EDEX on DX3 is started.
# The /awips2/edex/logs/edex-request-$datestr.log is tailed to look for the
# "EDEX ESB is now operational" string that will trigger the restart of EDEX on DX4.
#
# William E. Smith, Fairfield Technologies, Inc.
# Revised: March 28, 2014 - Start and stop DX3 before bouncing DX4.
# Revised: September 23, 2014 - Now searches the request log for the trigger string.
#
# Set up variables
use strict;
use IO::Handle;
use Time::gmtime;

my $rc=0;
my $sleeptime=1;
my $logDat="";
my $flag=0;
my $trigger="EDEX ESB is now operational";

my $dum="";
my $year="";
my $mon="";
my $day="";
my $datestr="";

my $logname="";
my $server="";
#
# Check to see if user is root on DX3
#
$logname=$ENV{LOGNAME};
$server=$ENV{HOST_NAME};
if($logname !~ /root/ || $server !~ /dx3/){
     die "You must be logged on to DX3 as ROOT";
}
#
# Date string for log file
#
($dum,$dum,$dum,$day,$mon,$year,$dum,$dum,$dum)=localtime();
$datestr=sprintf("%4d%02d%02d",$year+1900,$mon+1,$day);
$logDat="/awips2/edex/logs/edex-request-$datestr.log";
#
#Stop EDEX on DX3
#
print "Stopping EDEX on DX3.\n";
$rc=system('service edex_camel stop');
print "Return code from dx3 edex stop: ",$rc,"\n";
if($rc){die "Stopping of EDEX on DX3 failed";}
#
# Restart EDEX on DX3 and wait for trigger before restarting on DX4
#
print "Restarting EDEX on DX3.\n";
#while(<LOGFILE>){
#   print $_,"\n";
#}
 
#LOGFILE->clearerr();
print "EDEX on DX3 is restarting. Waiting for ESB trigger to restart EDEX on DX4.\n";
$rc=system('service edex_camel start');
print "Return code from dx3 edex start: ",$rc,"\n";
if($rc){die "Restart of EDEX on DX3 failed";}

print "Moving pointer to end of log file.\n";
open(LOGFILE,$logDat) or die "Failed to open logfile $logDat: $!";
seek(LOGFILE, 0, 2);
sleep $sleeptime;
print "Looking for trigger.\n";
for(;;){
    while(<LOGFILE>){
        print $_;
        if($_ =~ /$trigger/){
            print "Found trigger on DX3\n";
            $flag=1;
            last;
        }
    }
    seek(LOGFILE, 0, 2);
    sleep $sleeptime;
    if($flag){last;}
}
#Stop EDEX on DX4
print "Stopping EDEX on DX4.\n";
$rc=system('ssh -q dx4 service edex_camel stop');
print "Return code from dx4 edex stop: ",$rc,"\n";
if($rc){die "Command to stop EDEX on DX4 failed!\n";}

#Restart EDEX on DX4
#
print "Restarting EDEX on DX4.\n";
$rc=system('ssh -q dx4 service edex_camel start');
print "Return code from dx4 edex start: ",$rc,"\n";
if($rc){die "Command to start EDEX on DX4 failed!\n";}
print "EDEX is restarting on DX4. Proceed.\n";
