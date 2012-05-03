package OpsBot::Jabber;

use strict;
use warnings;
require Exporter;
use AnyEvent::XMPP::Client;
use AnyEvent::XMPP::Ext::Disco;
use AnyEvent::XMPP::Ext::Version;
use AnyEvent::XMPP::Ext::MUC;
use OpsBot::Config;
use OpsBot::RT qw(&process_rt);
use OpsBot::Nagios qw(&nagios);

our $VERSION = 1.00;
our @ISA = qw(Exporter);
our @EXPORT = ();
our @EXPORT_OK = qw(jabber);
$| = 1;

my $client = AnyEvent::XMPP::Client->new();
my $disco   = AnyEvent::XMPP::Ext::Disco->new;
my $muc     = AnyEvent::XMPP::Ext::MUC->new (disco => $disco);
$client->add_extension($disco);
$client->add_extension($muc);
sub initialize { 
  my $jabber = $plugins{jabber};
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
  my $msg = shift;
  my $body = $msg->body;
  for my $plugin ( keys %plugins ) { 
    if ( $body =~ /^\!$plugin/ ) {
      return $plugins{$plugin}->{entrysub}->($body);
    }
  }
};

sub jabber {
    my ( $u, $p, $nick, $rooms ) = initialize();
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
          my $output = $parsemsg->($msg);
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


