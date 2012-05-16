package OpsBot::Plugins::RT;

use strict;
use warnings;
require Exporter;
our @EXPORT_OK = qw(run);
use DateTimeX::Easy;
use RT::Client::REST;
sub initialize {
  my $conf = shift; 
  my @params = ( 'url', 'user', 'pass', 'rt_timezone', 'desired_timezone' );
  return my ( $url, $u, $p, $rt_tz, $desired_tz ) = map { $conf->{$_} } @params;
}


my $datemanip = sub {
  my ( $date, $rt_tz, $desired_tz ) = @_;
  $date = $date . " $rt_tz"; # append timezone for DateTimeX::Easy to do conversion 
  my $dt = DateTimeX::Easy->parse($date);
  $dt->set_time_zone("$desired_tz");
  return $dt->day_abbr . " " . $dt->month_abbr . " " . $dt->day . " " . $dt->hms;
};

sub run {
  my ( $msg_body, $config )  = @_;
  my ( $url, $u, $p, $rt_tz, $desired_tz ) = initialize($config);
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

