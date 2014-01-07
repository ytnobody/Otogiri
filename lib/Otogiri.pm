package Otogiri;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.05";

use DBIx::Otogiri;

sub new {
    my ($class, %opts) = @_;
    DBIx::Otogiri->new(%opts);
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

Otogiri is a thing that like as ORM. A slogan is "Schema-less, Fat-less".

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

Instantiate and connect to db. Then, it returns L<DBIx::Otogiri> object.

Please see ATTRIBUTE section.

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=head1 SEE ALSO

L<DBIx::Otogiri>

L<DBIx::Sunny>

L<SQL::Maker>

=cut

