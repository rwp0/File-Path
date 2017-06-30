#! /usr/bin/env perl
# t/file-temp-compat.t

use strict;
use warnings;

use Test::More tests =>  41;
use File::Path qw( make_path rmtree );
use Fcntl ':mode';

note("File::Path version: $File::Path::VERSION");

my %ineligible_OSes = map { $_ => 1 } ( qw|
  VMS MacOS MSWin32 os2 amigaos dos epoc
|);

my %dupes;
SKIP: {
    my $skip_count = 41;
    skip "Testing inter-operability with File::Temp::tempdir()", $skip_count
        if $ineligible_OSes{$^O};

    require File::Temp;
    require Cwd;

    my $cwd = Cwd::cwd();

    my $tdir = File::Temp::tempdir( CLEANUP => 1 );
    chdir $tdir or die "Unable to chdir to $tdir: $!";

    my @perms   = map { '0' . $_ . '00' } (0..7);
    my %p2s     = map { $_ => join('_' => 'foo', $$, $_) } @perms;
    my @subdirs = sort values(%p2s);

    my @created;
    @created = make_path(@subdirs, { chmod => 0711 });
    is(scalar(@created), 8, "Created 8 subdirectories");
    for my $subdir (@subdirs) {
        my $p = File::Spec->catdir($tdir, $subdir);
        ok(-d $p, "Directory $p exists");
        my @perms = stat($p);
        my $mode = sprintf "%04o" => S_IMODE($perms[2]);
        cmp_ok($mode, 'eq', '0711', "Directory $p starts life as 0711");
        my $fname = File::Spec->catfile($p, 'a');
        open my $F, '>', $fname or die "Unable to open $fname for writing: $!";
        print $F "a\n";
        close $F or die "Unable to close $fname after writing: $!";
        ok(-f $fname, "Able to create file in $p");
    }

    for my $m (sort keys %p2s) {
        my $rv = chmod($m, $p2s{$m});
        is($rv, 1, "chmod $p2s{$m} to $m");
        my @perms = stat($p2s{$m});
        my $mode = sprintf "%04s" => S_IMODE($perms[2]);
        cmp_ok($mode, 'eq', $m, "Directory $p2s{$m} changed to $m");
    }
    while (my ($k,$v) = each %p2s) {
        $dupes{$k} = File::Spec->catdir($tdir, $v);
    }

    chdir $cwd or die "Unable to chdir to $cwd: $!";
}

