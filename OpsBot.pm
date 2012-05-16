package OpsBot;

use strict;
require Exporter;
our @EXPORT = ();
our @EXPORT_OK = qw(startBot);
our @ISA = qw(Exporter);
use OpsBot::Plugins::Jabber qw(run);
use OpsBot::Packages qw(getPackage);

sub startBot { 
  my $plugins = shift;
  my $communication_plugins = $plugins->{communication};
  my $infra = $plugins->{infra};
  my %comm = %$communication_plugins;
  foreach ( keys %comm ) {
    my $config = $comm{$_};
    my $runplugin = getPackage($_) . "::run";
    my $runref = \&$runplugin;
    $runref->($config, $infra);
  }
}
1;
