package OpsBot::Plugins::Jabber;

use strict;
use warnings;
require Exporter;
use AnyEvent::XMPP::Client;
use AnyEvent::XMPP::Ext::Disco;
use AnyEvent::XMPP::Ext::Version;
use AnyEvent::XMPP::Ext::MUC;
use lib '../';
use OpsBot::Packages qw(getPackage);
use Module::Load;

our $VERSION = 1.00;
our @ISA = qw(Exporter);
our @EXPORT = ();
our @EXPORT_OK = qw(run);
$| = 1;

my $client = AnyEvent::XMPP::Client->new();
my $disco   = AnyEvent::XMPP::Ext::Disco->new;
my $muc     = AnyEvent::XMPP::Ext::MUC->new (disco => $disco);
$client->add_extension($disco);
$client->add_extension($muc);
sub initialize { 
  my $jabber = shift;  
  my @params = ( 'user', 'pass', 'nick', 'rooms');
  return my ( $u, $p, $nick, $rooms ) = map { $jabber->{$_} } @params;
}
my $j = AnyEvent->condvar;

my $sendreply = sub { 
  my ( $msg, $output_from_plugin ) = @_;
  my $reply = $msg->make_reply;
  $reply->add_body($output_from_plugin);
  $reply->send;
};

my $parsemsg = sub { 
  my ( $msg, $infra )  = @_;
  my $body = $msg->body;
  my %infra_plugins = %$infra;

  for my $plugin ( keys %infra_plugins ) { 
    if ( $body =~ /^\!$plugin/ ) {
      my $module = getPackage($plugin);
      load $module, ':run';
      my $pluginrun = $module . "::run";
      my $runref = \&$pluginrun;
      return $runref->($body, $infra->{$plugin});
    }
  }
};

sub run {
    my ($config, $infra) = @_;
    my ( $u, $p, $nick, $rooms ) = initialize($config);
    $client->add_account($u, $p);
    $client->reg_cb(
    session_ready => sub {
      my ( $cl, $acc ) = @_;
      for my $room ( @$rooms ) {
        $muc->join_room($acc->connection, $room, $nick, { history => { chars => 0 } });
      }
      $muc->reg_cb(
        message => sub {
          my ( $cl, $acc, $msg, $is_echo ) =  @_;
          return if $is_echo;
          return if $msg->is_delayed;
          my $output = $parsemsg->($msg, $infra);
          if ( !$output ) { 
            return;
          } else { 
            $sendreply->($msg, $output);
          }
            
        }
      );
    }
  );
    $client->start;
    $j->wait;
}

1;


