use strict;
use warnings;
use Test::More;
use Test::Exception;
use Otogiri;

my $dbfile  = ':memory:';

my $db = Otogiri->new( connect_info => ["dbi:SQLite:dbname=$dbfile", '', ''] );

my $sql = <<'EOF';
CREATE TABLE member (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    name       TEXT    NOT NULL,
    age        INTEGER NOT NULL DEFAULT 20,
    sex        TEXT    NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER
);
EOF
$db->do($sql);

my $time = time;
my $param = {
    name       => 'ytnobody', 
    age        => 30,
    sex        => 'male',
    created_at => $time,
};
my $member = $db->insert(member => $param);
    
subtest broken_query => sub {
    dies_ok {    
        $db->search_by_sql(
            'SELECT * FROM membre WHERE id = ?', 
            [ $member->{id} ], 
            'member'
        );
    } 'select query to non exists table';
    my $filename = __FILE__;
    like $@, qr|$filename|, 'check filename that contains into comment in SQL';
};

done_testing;

