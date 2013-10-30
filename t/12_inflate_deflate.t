use strict;
use warnings;
use utf8;
use Test::More;

use Otogiri;
use JSON;

my $json = JSON->new->utf8(1);
my $dbfile  = ':memory:';

my $db = Otogiri->new( 
    connect_info => ["dbi:SQLite:dbname=$dbfile", '', ''],
    inflate => sub {
        my $row = shift;
        $row->{data} = $json->decode($row->{data}) if defined $row->{data};
        $row;
    },
    deflate => sub {
        my $row = shift;
        $row->{data} = $json->encode($row->{data}) if defined $row->{data};
        $row;
    }
);

my $sql = <<'EOF';
CREATE TABLE free_data (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    data       TEXT
);
EOF
$db->do($sql);

my $row = $db->insert(free_data => {
    data => {
        name     => 'ytnobody', 
        age      => 32,
        favolite => [qw/Soba Zohni Akadashi/],
    },
});

is $row->{data}{name}, 'ytnobody';
is $row->{data}{age}, 32;
is_deeply $row->{data}{favolite}, [qw/Soba Zohni Akadashi/];

done_testing;
