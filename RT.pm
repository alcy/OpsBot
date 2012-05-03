package OpsBot::RT;

use strict;
use warnings;
require Exporter;
our @EXPORT_OK = qw(process_rt);
use DateTimeX::Easy;
use RT::Client::REST;
use OpsBot::Config;
sub initialize {
  my $conf = $plugins{rt}; 
  my @params = ( 'url', 'user', 'pass', 'rt_timezone', 'desired_timezone' );
  return my ( $url, $u, $p, $rt_tz, $desired_tz ) = map { $conf->{$_} } @params;
}


my $datemanip = sub {
  my ( $date, $rt_tz, $desired_tz ) = @_;
  $date = $date . " $rt_tz"; # sysrt time is in UTC
  my $dt = DateTimeX::Easy->parse($date);
  $dt->set_time_zone("$desired_tz");
  return $dt->day_abbr . " " . $dt->month_abbr . " " . $dt->day . " " . $dt->hms;
};

sub process_rt {
  my $msg_body = shift;
  my ( $url, $u, $p, $rt_tz, $desired_tz ) = initialize();
  my $rt = RT::Client::REST->new(
    server => $url,
    timeout => 30
  );
  my ($id) = ( $msg_body =~ /(?:^\!rt) id=(\d+)/ );
  $rt->login(username => $u, password => $p);
  my $ticket = $rt->show(type => 'ticket', id => "$id");
  my ( $queue, $subject, $owner, $created, $lastupdated ) = ( $ticket->{Queue}, $ticket->{Subject}, $ticket->{Owner}, $ticket->{Created}, $ticket->{LastUpdated} );
  $created = $datemanip->($created, $rt_tz, $desired_tz);
  $lastupdated = $datemanip->($lastupdated, $rt_tz, $desired_tz);  
  return "Ticket \"$subject\" in queue $queue, was created on $created, last updated on $lastupdated, and is owned by $owner\n";
};

