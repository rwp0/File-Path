use strict;

use Test::More qw( no_plan );

BEGIN {
    use_ok('File::Path', qw(rmtree mkpath make_path remove_tree));
    use_ok('File::Spec::Functions');
}

my ($error, $list, $file, $message);
my $tmp_base = catdir(
    curdir(),
    sprintf( 'test-%x-%x-%x', time, $$, rand(99999) ),
);

my ($dir, $dir_stem, @created, $owner, $group);
$dir_stem = catdir($tmp_base, 'owned-by');
$dir = catdir($dir_stem, 'aaa');
{
    local $@;
    $owner = 'foo';
    eval { @created = make_path($dir, { owner => $owner, error => \$error }); };
    if ($@) { chomp $@; print STDERR "dollar-@: <$@>\n"; }
    is(scalar(@{$error}), 1, "1 error condition logged");
    foreach my $e (@{$error}) {
        my ($file, $message) = each %{$e};
        print STDERR "file:     <$file>\n";
        print STDERR "message:  <$message>\n";
    }
}

{
    local $@;
    $group = 'foo';
    eval { @created = make_path($dir, { group => $group, error => \$error }); };
    if ($@) { chomp $@; print STDERR "dollar-@: <$@>\n"; }
    is(scalar(@{$error}), 1, "1 error condition logged");
    foreach my $e (@{$error}) {
        my ($file, $message) = each %{$e};
        print STDERR "file:     <$file>\n";
        print STDERR "message:  <$message>\n";
    }
}

