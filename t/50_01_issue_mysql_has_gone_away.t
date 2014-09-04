use strict;
use Test::More;
use Otogiri;
use Module::Load;

eval {load 'Test::mysqld'};
if ($@) {
    warn $@;
    plan skip_all => 'Could not load Test::mysql';
}

my $mysqld = Test::mysqld->new(
    my_cnf => {
        'skip-networking' => '',
        'wait_timeout' => 2,
    },
) or plan skip_all => $Test::mysqld::errstr;

my $db = Otogiri->new(connect_info => [$mysqld->dsn(dbname => 'test')]);

subtest 'mysql has gone away' => sub {

    # create dummy table
    $db->do('CREATE TABLE IF NOT EXISTS foo (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(12) NOT NULL)');
    $db->insert(foo => {name => 'ytnobody'});

    # "mysql has gone away" without DBIx::Connector
    sleep 4;

    my $row = $db->fetch(foo => {name => 'ytnobody'});
    isa_ok $row, 'HASH';
    is $row->{name}, 'ytnobody';

    # cleanup
    $db->do('DROP TABLE IF EXISTS foo'); 
};

done_testing;
