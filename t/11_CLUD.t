use strict;
use warnings;
use Test::More;
use Otogiri;

use File::Spec;
use File::Basename 'dirname';

my $sqlfile = File::Spec->catfile(dirname(__FILE__), qw/fixture.sql/);
my $dbfile  = File::Spec->catfile(dirname(__FILE__), qw/testdb.sqlite3/);

### XXX I want more cool approach here ...
unlink $dbfile if -e $dbfile;
system("sqlite3 $dbfile < $sqlfile");

my $db = Otogiri->new( connect_info => ["dbi:SQLite:dbname=$dbfile", '', ''] );
isa_ok $db, 'Otogiri';
can_ok $db, qw/insert select single delete update txn_scope dbh maker/;

my $time = time;
my $param = {
    name       => 'ytnobody', 
    age        => 30,
    sex        => 'male',
    created_at => $time,
};

my $member = $db->insert(member => $param);

isa_ok $member, 'HASH';
for my $key (keys %$param) {
    is $member->{$key}, $param->{$key}, "$key is ". $param->{$key};
}

do {
    my $txn = $db->txn_scope;
    $db->insert(member => {name => 'oreore', sex => 'male', created_at => time});
    $db->update(member => [name => 'tonkichi', updated_at => time], {name => 'oreore'});
    $txn->commit;
};

my $oreore = $db->single(member => {name => 'tonkichi'});
isa_ok $oreore, 'HASH';
is $oreore->{name}, 'tonkichi';
ok $oreore->{updated_at};

done_testing;
