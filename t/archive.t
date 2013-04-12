#!perl
use Test::More;
use File::Temp ();
use File::Spec::Functions qw(catfile catdir);
plan(tests => 35);

BEGIN {
    use_ok('TAP::Harness::Archive');
}

# do we have Archive::Extract installed?
eval { require Archive::Extract };
my $HAVE_ARCHIVE_EXTRACT = $@ ? 0 : 1;

# test creation
eval { TAP::Harness::Archive->new() };
like($@, qr/You must provide the name of the archive to create!/);
eval { TAP::Harness::Archive->new({archive => 'foo.bar'}) };
like($@, qr/Archive is not a known format type!/);

# a temp directory to put everything in
my $temp_dir = File::Temp->tempdir('tap-archive-XXXXXXXX', CLEANUP => 0);
my @testfiles = (catfile('t', 'pod.t'), catfile('t', 'pod-coverage.t'));

# first a .zip file
my $file = catfile($temp_dir, 'archive.zip');
my $harness = TAP::Harness::Archive->new({archive => $file});
$harness->runtests(@testfiles);
ok(-e $file, 'archive.zip created');
check_archive($file);

# now a .tar file
$file = catfile($temp_dir, 'archive.tar');
$harness = TAP::Harness::Archive->new({archive => $file});
$harness->runtests(@testfiles);
ok(-e $file, 'archive.tar created');
check_archive($file);

# now a .tar.gz
$file = catfile($temp_dir, 'archive.tar.gz');
$harness = TAP::Harness::Archive->new({archive => $file});
$harness->runtests(@testfiles);
ok(-e $file, 'archive.tar.gz created');
check_archive($file);

sub check_archive {
  SKIP: {
        skip("Don't have Archive::Extract installed", 9) unless $HAVE_ARCHIVE_EXTRACT;
        my $archive_file = shift;
        my %tap_files;
        my $aggregator = TAP::Harness::Archive->aggregator_from_archive(
            {
                archive              => $archive_file,
                made_parser_callback => sub {
                    my ($parser, $filename) = @_;
                    isa_ok($parser, 'TAP::Parser');
                    $tap_files{$filename} = 1;
                },
                meta_yaml_callback => sub {
                    my $yaml = shift;
                    $yaml = $yaml->[0];
                    ok(exists $yaml->{start_time}, 'meta.yml: start_time exists');
                    ok(exists $yaml->{stop_time},  'meta.yml: stop_time exists');
                    ok(exists $yaml->{file_order}, 'meta.yml: file_order exists');
                },
            }
        );

        isa_ok($aggregator, 'TAP::Parser::Aggregator');
        cmp_ok($aggregator->total, '==', 2, "aggregator has correct total");
        cmp_ok(scalar keys %tap_files, '==', 2, "correct number of files in archive $archive_file");
        foreach my $f (@testfiles) {
            ok($tap_files{$f}, "file $f in archive $archive_file");
        }
    }
}

