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

subtest insert => sub {
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
};

subtest transaction_and_update => sub {
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
};

subtest rollback => sub {
    do {
        my $txn = $db->txn_scope;
        $db->update(member => [name => 'tonny', updated_at => time], {name => 'tonkichi'});
        $txn->rollback;
    };

    my $oreore = $db->single(member => {name => 'tonny'});
    is $oreore, undef;
    $oreore = $db->single(member => {name => 'tonkichi'});
    isa_ok $oreore, 'HASH';
    is $oreore->{name}, 'tonkichi';
};

subtest fast_insert_and_search_by_sql => sub {
    $db->fast_insert(member => {name => 'airwife', sex => 'female', created_at => time});
    my @rows = $db->search_by_sql('SELECT * FROM member WHERE sex=? ORDER BY id', 'male');
    is scalar(@rows), 2;
    is $rows[0]->{name}, 'ytnobody';
    is $rows[0]->{sex}, 'male';
    @rows = $db->search_by_sql('SELECT * FROM member WHERE sex=?', 'female');
    is scalar(@rows), 1;
    is $rows[0]->{name}, 'airwife';
    is $rows[0]->{sex}, 'female';
};

subtest delete => sub {
    my $tonkichi = $db->single(member => {name => 'tonkichi'});
    $db->delete(member => {name => 'tonkichi'});
    my $row = $db->single(member => {id => $tonkichi->{id}});
    is $row, undef;
};


done_testing;
