package Filename::Timestamp;

use 5.010001;
use strict;
use warnings;

use Exporter 'import';

# AUTHORITY
# DATE
# DIST
# VERSION

our @EXPORT_OK = qw(extract_timestamp_from_filename);

$SPEC{extract_timestamp_from_filename} = {
    v => 1.1,
    summary => 'Extract date/timestamp from filename, if any',
    description => <<'MARKDOWN',


MARKDOWN
    args => {
        filename => {
            schema => 'str*',
            req => 1,
            pos => 0,
        },
        all => {
            schema => 'bool',
            summary => 'Find all timestamps instead of the first found only',
            description => <<'MARKDOWN',

Not yet implemented.

MARKDOWN
        },
    },
    result_naked => 1,
    result => {
        schema => ['any*', of=>['bool*', 'hash*']],
        description => <<'MARKDOWN',

Return false if no timestamp is detected. Otherwise return a hash of
information, which contains these keys: `epoch`, `year`, `month`, `day`, `hour`,
`minute`, `second`.

MARKDOWN
    },
    examples => [
        {
            args => {filename=>'2024-09-08T12_35_48+07_00.JPEG'},
        },
        {
            args => {filename=>'IMG_20240908_095444.jpg'},
        },
        {
            args => {filename=>'VID_20240908_092426.mp4'},
        },
        {
            args => {filename=>'Screenshot_2024-09-01-11-40-44-612_org.mozilla.firefox.jpg'},
        },
        {
            args => {filename=>'IMG-20241204-WA0001.jpg'},
        },
        {
            args => {filename=>'foo.txt'},
        },
    ],
};
sub extract_timestamp_from_filename {
    require Filename::Compressed;

    my %args = @_;

    my $filename = $args{filename};
    my $ci = $args{ignore_case} // 1;

    my @compressor_info;
    while (1) {
        my $res = Filename::Compressed::check_compressed_filename(
            filename => $filename, ci => $ci);
        if ($res) {
            push @compressor_info, $res;
            $filename = $res->{uncompressed_filename};
            next;
        } else {
            last;
        }
    }

    $filename =~ /(.+)(\.\w+)\z/ or return 0;
    my ($filename_without_suffix, $suffix) = ($1, $2);

    my $spec;
    if ($ci) {
        my $suffix_lc = lc($suffix);
        for (keys %SUFFIXES) {
            if (lc($_) eq $suffix_lc) {
                $spec = $SUFFIXES{$_};
                last;
            }
        }
    } else {
        $spec = $SUFFIXES{$suffix};
    }
    return 0 unless $spec;

    return {
        archive_name       => $spec->{name},
        archive_suffix     => $suffix,
        filename_without_suffix => $filename_without_suffix,
        (compressor_info    => \@compressor_info) x !!@compressor_info,
    };
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use Filename::Archive qw(check_archive_filename);
 my $res = check_archive_filename(filename => "foo.tar.gz");
 if ($res) {
     printf "File is an archive (type: %s, compressed: %s)\n",
         $res->{archive_name},
         $res->{compressor_info} ? "yes":"no";
 } else {
     print "File is not an archive\n";
 }

=head1 DESCRIPTION


=head1 SEE ALSO

L<Filename::Compressed>

=cut
