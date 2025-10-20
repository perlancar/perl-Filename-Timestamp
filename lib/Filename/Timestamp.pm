package Filename::Timestamp;

use 5.010001;
use strict;
use warnings;

use Exporter 'import';
use Time::Local qw(timelocal_posix timegm_posix);

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

*Handling of timezone.* If timestmap contains timezone indication, e.g. `+0700`,
will return `tz_offset` key in the result hash as well as `epoch`. Otherwise,
will return `tz` key in the result hash with the value of `floating` and
`epoch_local` calculated using <pm:Time::Local>'s `timelocal_posix` as well as
`epoch_utc` calculated using `timegm_posix`.

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
    if ($filename =~ /(\d{4})[_.-](\d{2})[_.-](\d{2})      # 1 (year), 2 (mon), 3 (day)
                      (?:
                          [T-]
                          (\d{2})[_.-](\d{2})[_.-](\d{2})  # 4 (hour), 5 (minute), 6 (second)
                          (?:
                              ([+-])(\d{2})[_-]?(\d{2})    # 7 (timestamp sign), 8 (timestamp hour), 9 (timestamp minute)
                          )?
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
        if ($7) {
            $res->{tz_offset} = ($7 eq '+' ? 1:-1) * $8*3600 + $9*60;
        }
    } elsif ($filename =~ /(\d{4})(\d{2})(\d{2})                # 1 (year), 2 (mon), 3 (day)
                           (?:
                               [_-]
                               (\d{2})(\d{2})(\d{2})            # 4 (hour), 5 (min), 6 (second)
                               (?:
                                   ([+-])(\d{2})[_-]?(\d{2})    # 7 (timestamp sign), 8 (timestamp hour), 9 (timestamp minute)
                               )?
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
        if ($7) {
            $res->{tz_offset} = ($7 eq '+' ? 1:-1) * $8*3600 + $9*60;
        }
    } else {
        return 0;
    }

    if (defined $res->{tz_offset}) {
        $res->{epoch} = timegm_posix(
            $res->{second},
            $res->{minute},
            $res->{hour},
            $res->{day},
            $res->{month} - 1,
            $res->{year} - 1900,
        ) + $res->{tz_offset};
    } else {
        $res->{epoch_local} = $res->{epoch} = timelocal_posix(
            $res->{second},
            $res->{minute},
            $res->{hour},
            $res->{day},
            $res->{month} - 1,
            $res->{year} - 1900,
        );
        $res->{tz} = 'floating';
        $res->{epoch_utc} = timegm_posix(
            $res->{second},
            $res->{minute},
            $res->{hour},
            $res->{day},
            $res->{month} - 1,
            $res->{year} - 1900,
        );
    }

    $res;
}

1;
# ABSTRACT:

=head1 SYNOPSIS

 use Filename::Timestamp qw(extract_timestamp_from_filename);
 my $res = extract_timestamp_from_filename(filename => "foo.tar.gz");
 if ($res) {
     printf "Filename contains timestamp: %s\n", $res->{epoch};
 } else {
     print "Filename does not contain timestamp\n";
 }

=head1 DESCRIPTION


=head1 SEE ALSO

=cut
