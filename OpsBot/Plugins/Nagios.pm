package OpsBot::Plugins::Nagios;

use strict;
use warnings;
require Exporter;
our @EXPORT_OK = qw(run);
use Monitoring::Livestatus;

sub run { 
  my ($msg_body, $config) = @_;
  my $output='';
  my $ml = Monitoring::Livestatus->new(
    server => "$config->{server}:$config->{port}"
  );
  my ($host) = ( $msg_body =~ /(?:^\!nagios) host=(\S+)/ );
  my %tmp=();
  my $services_with_info = $ml->selectcol_arrayref("GET hosts\nColumns: services_with_info\nFilter: host_name = $host");
  for my $serviceref ( @$services_with_info ) {
    foreach (@$serviceref) {
      my @serviceattrs = @$_;
      if ($serviceattrs[1] != 0 ) {
        $tmp{$serviceattrs[0]} = $serviceattrs[3]; # service description and service error code
      }
    }
  }
  for my $key ( keys %tmp ) {
    $output = $output . "$key ---> $tmp{$key}\n";
  }
  return $output;
}
1;
