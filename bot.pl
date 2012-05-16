#!/usr/bin/env perl
use strict;
use warnings;
use OpsBot qw(startBot);

my %plugins = (
  infra => { 
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
  },

  communication => { 
    jabber => { 
      user => 'bot@localhost',
      pass => 'botpass',
      nick => 'botnick',
      rooms => ['test1@conference.localhost', 'test2@conference.localhost'],
    },
  }
);

startBot(\%plugins);


  
