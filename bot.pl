#!/usr/bin/env perl
use strict;
use warnings;
use lib '../';
use OpsBot::Config;
use OpsBot::Jabber qw(jabber);


%plugins = (
  rt => {
    url => 'https://rt.example.com',
    user => 'foo',
    pass => 'pass',
    rt_timezone => 'UTC',
    desired_timezone => 'Asia/Kolkata',
  },
 
  nagios => { 
    server => 'nagios.example.com',
    port => '6557' # live status port
  },

  jabber => { 
    user => 'bot@localhost',
    pass => 'botpass',
    nick => 'botnick',
    rooms => ['test1@conference.localhost', 'test2@conference.localhost'],
  },
);

prepare(); # required for setting entry subroutines for different plugins, see Config.pm
jabber(); # starts the ( jabber ) bot


  
