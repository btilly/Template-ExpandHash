#!perl -T

use lib "../lib";

use warnings;
use strict;

use Storable qw(dclone);
use Test::More tests => 3;
use Template::ExpandHash qw(expand_hash);

my $original_config =  {
    user                => 'btilly',
    default_email       => '[% user %]@company.com',
    email_qa_email      => 'QA <[% default_email %]>',
    email_pager_email   => 'Pagers <[% default_email %]>',
    some_escaped_value  => '\[% user ]%',
    conflicting_sub     => 'outer',
    # etc
    email => {
      qa_email          => '[% email_qa_email %]',
      pager_email       => '[% email_pager_email %]',
      conflicting_sub   => 'inner',
      demo              => '[% conflicting_sub %]',
      # etc
    },
};

my $config = dclone($original_config);

my $expected_config = {
    user                => 'btilly',
    default_email       => 'btilly@company.com',
    email_qa_email      => 'QA <btilly@company.com>',
    email_pager_email   => 'Pagers <btilly@company.com>',
    some_escaped_value  => '[% user ]%',
    conflicting_sub     => 'outer',
    # etc
    email => {
        qa_email        => 'QA <btilly@company.com>',
        pager_email     => 'Pagers <btilly@company.com>',
        conflicting_sub => 'inner',
        demo            => 'inner',
        # etc
    },
};

my $expanded = expand_hash($config);
is_deeply($expected_config, $expanded, "Substitutions propagate properly");

my %expanded2 = expand_hash(%$config);
is_deeply($expected_config, \%expanded2, "Hash in gives hash out");

is_deeply($original_config, $config, "The original is not touched.");
