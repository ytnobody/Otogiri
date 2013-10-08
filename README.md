# NAME

Otogiri - A lightweight medicine for using database

# SYNOPSIS

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

# DESCRIPTION

Otogiri is one of ORM. A slogan is "Schema-less, Fat-less".

# METHODS

## new

    my $db = Otogiri->new( connect_info => [$dsn, $dbuser, $dbpass] );

Instantiate and connect to db.

## insert

    my $row = $db->insert($table_name => $columns_in_hashref);

Insert data. Then, returns row data.

## fast\_insert

    $db->fast_insert($table_name => $columns_in_hashref);

Insert data simply.

## select

    my @rows = $db->select($table_name => $conditions_in_hashref [,@options]);

Select from specified table. Then, returns matched rows as array.

## single

    my $row = $db->single($table_name => $conditions_in_hashref [,@options]);

Select from specified table. Then, returns first of matched rows.

## search\_by\_sql

    my @rows = $db->search_by_sql($sql, @bind_vals);

Select by specified SQL. Then, returns matched rows as array.

## update

    $db->update($table_name => [update_col_1 => $new_value_1, ...], $conditions_in_hashref);

Update rows that matched to $conditions\_in\_hashref.

## delete

    $db->delete($table_name => $conditions_in_hashref);

Delete rows that matched to $conditions\_in\_hashref.

## do

    $db->do($sql, @bind_vals);

Execute specified SQL.

## txn\_scope 

    my $txn = $db->txn_scope;

returns DBIx::TransactionManager::ScopeGuard's instance. See [DBIx::TransactionManager](http://search.cpan.org/perldoc?DBIx::TransactionManager) to more information.

# LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

ytnobody <ytnobody@gmail.com>

# SEE ALSO

[DBIx::Sunny](http://search.cpan.org/perldoc?DBIx::Sunny)

[SQL::Maker](http://search.cpan.org/perldoc?SQL::Maker)
