package OpsBot::Packages;

use strict;
require Exporter;
our @EXPORT = ();
our @EXPORT_OK = qw(getPackage);
our @ISA = qw(Exporter);
my %pluginpackages = ( 
  jabber => "OpsBot::Plugins::Jabber",
  nagios => "OpsBot::Plugins::Nagios",
  rt => "OpsBot::Plugins::RT",
);

sub getPackage { 
  my $plugin = shift;
  return $pluginpackages{$plugin};
}
1;
