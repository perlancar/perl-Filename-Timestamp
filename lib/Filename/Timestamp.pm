package Filename::Timestamp;

use 5.010001;
use strict;
use warnings;

use Exporter 'import';
use Time::Local qw(timelocal_posix);

# AUTHORITY
# DATE
# DIST
# VERSION

our @EXPORT_OK = qw(extract_timestamp_from_filename);

our %SPEC;

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
    my %args = @_;

    my $filename = $args{filename};

    my $res = {};
    if ($filename =~ /(\d{4})[_.-](\d{2})[_.-](\d{2})
                      (?:
                          [T-]
                          (\d{2})[_.-](\d{2})[_.-](\d{2})
                      )?
                     /x) {
        $res->{year} = $1+0;
        $res->{month} = $2+0;
        $res->{day} = $3+0;
        if (defined $4) {
            $res->{hour} = $4+0;
            $res->{minute} = $5+0;
            $res->{second} = $6+0;
        } else {
            $res->{hour} = 0;
            $res->{minute} = 0;
            $res->{second} = 0;
        }
    } elsif ($filename =~ /(\d{4})(\d{2})(\d{2})
                           (?:
                               [_-]
                               (\d{2})(\d{2})(\d{2})
                           )?
                          /x) {
        $res->{year} = $1+0;
        $res->{month} = $2+0;
        $res->{day} = $3+0;
        if (defined $4) {
            $res->{hour} = $4+0;
            $res->{minute} = $5+0;
            $res->{second} = $6+0;
        } else {
            $res->{hour} = 0;
            $res->{minute} = 0;
            $res->{second} = 0;
        }
    } else {
        return 0;
    }

    $res->{epoch} = timelocal_posix(
        $res->{second},
        $res->{minute},
        $res->{hour},
        $res->{day},
        $res->{month} - 1,
        $res->{year} - 1900,
    );

    $res;
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
