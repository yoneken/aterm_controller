#!/usr/bin/perl

use strict;
use warnings;

use Time::Piece();
use Time::Seconds;
use HTTP::Request::Common;
use LWP::UserAgent;

our $user = "admin";
our $pass = "password";
our $router_url = "http://192.168.0.1";

if($ARGV[0] eq "start"){
	print "Start ECO mode 2 minutes later.\nWLAN will be closed.\n";
	&eco_mode("start");
}elsif($ARGV[0] eq "stop"){
	print "Stop ECO mode 2 minutes later.\nWLAN will be opened.\n";
	&eco_mode("stop");
}elsif($ARGV[0] eq "timer_off"){
	print "ECO timer off.\n";
	&eco_timer_off;
}

sub eco_mode{
	my ($start_time, $stop_time);
	if(shift eq "stop"){
		# Set ECO mode stop time 2 minutes later from now.
		$stop_time = Time::Piece::localtime() + ONE_MINUTE*2;
		$start_time = $stop_time + ONE_HOUR*12;
	}else{
		# Set ECO mode start time 2 minutes later from now.
		$start_time = Time::Piece::localtime() + ONE_MINUTE*2;
		$stop_time = $start_time + ONE_HOUR*12;
	}

	my $ua = LWP::UserAgent->new;

	my $request = POST(
		"$router_url/index.cgi/eco_main_set",
		[
			"TIMER"=>"0", 
			"ECO_START_MM" => sprintf("%02d", $start_time->minute), 
			"ECO_START_HH" => sprintf("%02d", $start_time->hour),
			"ECO_MODE_SELECT" => "normal",
			"ECO_FUNC" => "0",
			"ECO_END_MM" => sprintf("%02d", $stop_time->minute),
			"ECO_END_HH" => sprintf("%02d", $stop_time->hour),
			"DISABLED_CHECKBOX" => "",
			"CHECK_ACTION_MODE" => "0",
		]);

	$request->authorization_basic($user, $pass);
	my $res = $ua->request($request)->as_string;
	#print "Set ECO mode time range.\n";

	# Save editted data.
	$request = POST(
		"$router_url/index.cgi/eco_main",
		[
			"SAVE_CMD_ISSUE" => "YES",
			"CHECK_ACTIOIN_MODE" => "0",
		]);

	$request->authorization_basic($user, $pass);
	$res = $ua->request($request)->as_string;
	#print "Save ECO mode configuration.\n";
}

sub eco_timer_off{
	my $ua = LWP::UserAgent->new;

	my $request = POST(
		"$router_url/index.cgi/eco_main_set",
		[
			"ECO_MODE_SELECT" => "normal",
			"ECO_FUNC" => "0",
			"DISABLED_CHECKBOX" => "",
			"CHECK_ACTION_MODE" => "0",
		]);

	$request->authorization_basic($user, $pass);
	my $res = $ua->request($request)->as_string;
	#print "Set ECO mode timer off.\n";

	# Save editted data.
	$request = POST(
		"$router_url/index.cgi/eco_main",
		[
			"SAVE_CMD_ISSUE" => "YES",
			"CHECK_ACTIOIN_MODE" => "0",
		]);

	$request->authorization_basic($user, $pass);
	$res = $ua->request($request)->as_string;
	#print "Save ECO mode configuration.\n";
}

1;
