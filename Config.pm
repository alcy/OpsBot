package OpsBot::Config;

use strict;
require Exporter;
our @EXPORT = qw(%plugins prepare);
our @ISA = qw(Exporter);

our %plugins;

sub prepare { 
  $plugins{nagios}->{entrysub} = \&OpsBot::Nagios::nagios;
  $plugins{rt}->{entrysub} = \&OpsBot::RT::process_rt;
}
1;
