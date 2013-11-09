package Otogiri;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.02";

use Class::Accessor::Lite (
    ro => [qw/connect_info/],
    rw => [qw/dbh maker/],
    new => 0,
);

use SQL::Maker;
use DBIx::Sunny;

sub new {
    my ($class, %opts) = @_;
    my $self = bless {%opts}, $class;
    ( $self->{dsn}{scheme},
      $self->{dsn}{driver},
      $self->{dsn}{attr_str},
      $self->{dsn}{attributes},
      $self->{dsn}{driver_dsn}
    ) = DBI->parse_dsn($self->{connect_info}[0]);
    $self->{dbh}   = DBIx::Sunny->connect(@{$self->{connect_info}});
    $self->{maker} = SQL::Maker->new(driver => $self->{dsn}{driver});
    return $self;
}

sub _deflate_param {
    my ($self, $table, $param) = @_;
    if ($self->{deflate}) {
        $param = $self->{deflate}->({%$param}, $table);
    }
    return $param;
}

sub _inflate_rows {
    my ($self, $table, @rows) = @_;
    @rows = $self->{inflate} ? map {$self->{inflate}->($_, $table)} @rows : @rows;
    wantarray ? @rows : $rows[0];
}

sub select {
    my ($self, $table, $param, @opts) = @_;
    $param = $self->_deflate_param($table, $param);
    my ($sql, @binds) = $self->maker->select($table, ['*'], $param, @opts);
    $self->search_by_sql($sql, @binds);
}

sub search_by_sql {
    my ($self, $sql, @binds) = @_;
    my $rtn = $self->dbh->select_all($sql, @binds);
    my @rows = $rtn ? $self->_inflate_rows(undef, @$rtn) : ();
}

sub single {
    my ($self, $table, $param, @opts) = @_;
    $param = $self->_deflate_param($table, $param);
    my ($sql, @binds) = $self->maker->select($table, ['*'], $param, @opts);
    my $row = $self->dbh->select_row($sql, @binds);
    $self->{inflate} ? $self->_inflate_rows($table, $row) : $row;
}

sub insert {
    my $self = shift;
    if ($self->fast_insert(@_)) {
        return $self->single(shift, @_);
    }
}

sub fast_insert {
    my ($self, $table, $param, @opts) = @_;
    $param = $self->_deflate_param($table, $param);
    my ($sql, @binds) = $self->maker->insert($table, $param, @opts);
    $self->dbh->query($sql, @binds);
}

sub delete {
    my ($self, $table, $param, @opts) = @_;
    $param = $self->_deflate_param($table, $param);
    my ($sql, @binds) = $self->maker->delete($table, $param, @opts);
    $self->dbh->query($sql, @binds);
}

sub update {
    my ($self, $table, $param, @opts) = @_;
    $param = $self->_deflate_param($table, $param);
    my ($sql, @binds) = $self->maker->update($table, $param, @opts);
    $self->dbh->query($sql, @binds);
}

sub do {
    my $self = shift;
    $self->dbh->query(@_);
}

sub txn_scope {
    my $self = shift;
    $self->dbh->txn_scope;
}

sub last_insert_id {
    my $self = shift;
    $self->dbh->last_insert_id(@_);
}

1;
__END__

=encoding utf-8

=head1 NAME

Otogiri - A lightweight medicine for using database

=head1 SYNOPSIS

    use Otogiri;
    my $db = Otogiri->new(connect_info => ['dbi:SQLite:...', '', '']);
    
    my $row = $db->insert(book => {title => 'mybook1', author => 'me', ...});
    print 'Title: '. $row->{title}. "\n";
    
    my @rows = $db->select(book => {price => {'>=' => 500}});
    for my $r (@rows) {
        printf "Title: %s \nPrice: %s yen\n", $r->{title}, $r->{price};
    }
    
    $db->update(book => [author => 'oreore'], {author => 'me'});
    
    $db->delete(book => {author => 'me'});
    
    ### insert without row-data in response
    $db->fast_insert(book => {title => 'someone', ...});
    
    ### using transaction
    do {
        my $txn = $db->txn_scope;
        $db->insert(book => ...);
        $db->insert(store => ...);
        $txn->commit;
    };

=head1 DESCRIPTION

Otogiri is one of ORM. A slogan is "Schema-less, Fat-less".

=head1 ATTRIBUTE

=head2 connect_info (required)

   connect_info => [$dsn, $dbuser, $dbpass],

You have to specify dsn, dbuser, and dbpass, to connect to database.

=head2 inflate (optional)

    use JSON;
    inflate => sub {
        my ($data, $tablename) = @_;
        if (defined $data->{json}) {
            $data->{json} = decode_json($data->{json});
        }
        $data->{table} = $tablename;
        $data;
    },

You may specify column inflation logic. 

Specified code is called internally when called select(), search_by_sql(), and single().

=head2 deflate (optional)

    use JSON;
    deflate => sub {
        my ($data, $tablename) = @_;
        if (defined $data->{json}) {
            $data->{json} = encode_json($data->{json});
        }
        delete $data->{table};
        $data;
    },

You may specify column deflation logic.

Specified code is called internally when called insert(), update(), and delete().

=head1 METHODS

=head2 new

    my $db = Otogiri->new( connect_info => [$dsn, $dbuser, $dbpass] );

Instantiate and connect to db.

Please see ATTRIBUTE section.

=head2 insert

    my $row = $db->insert($table_name => $columns_in_hashref);

Insert data. Then, returns row data.

=head2 fast_insert

    $db->fast_insert($table_name => $columns_in_hashref);

Insert data simply.

=head2 select

    my @rows = $db->select($table_name => $conditions_in_hashref [,@options]);

Select from specified table. Then, returns matched rows as array.

=head2 single

    my $row = $db->single($table_name => $conditions_in_hashref [,@options]);

Select from specified table. Then, returns first of matched rows.

=head2 search_by_sql

    my @rows = $db->search_by_sql($sql, @bind_vals);

Select by specified SQL. Then, returns matched rows as array.

=head2 update

    $db->update($table_name => [update_col_1 => $new_value_1, ...], $conditions_in_hashref);

Update rows that matched to $conditions_in_hashref.

=head2 delete

    $db->delete($table_name => $conditions_in_hashref);

Delete rows that matched to $conditions_in_hashref.

=head2 do

    $db->do($sql, @bind_vals);

Execute specified SQL.

=head2 txn_scope 

    my $txn = $db->txn_scope;

returns DBIx::TransactionManager::ScopeGuard's instance. See L<DBIx::TransactionManager> to more information.

=head2 last_insert_id 

    my $id = $db->last_insert_id([@args]);

returns last_insert_id. (mysql_insertid in MySQL or last_insert_rowid in SQLite)


=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=head1 SEE ALSO

L<DBIx::Sunny>

L<SQL::Maker>

=cut

