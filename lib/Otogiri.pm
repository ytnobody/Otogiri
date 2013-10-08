package Otogiri;
use 5.008005;
use strict;
use warnings;

our $VERSION = "0.01";

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

sub select {
    my $self = shift;
    my ($sql, @binds) = $self->maker->select(shift, ['*'], @_);
    $self->select_by_sql($sql, @binds);
}

sub search_by_sql {
    my ($self, $sql, @binds) = @_;
    my $rtn = $self->dbh->select_all($sql, @binds);
    $rtn ? @$rtn : ();
}

sub single {
    my $self = shift;
    my ($sql, @binds) = $self->maker->select(shift, ['*'], @_);
    $self->dbh->select_row($sql, @binds);
}

sub insert {
    my $self = shift;
    if ($self->fast_insert(@_)) {
        return $self->single(shift, @_);
    }
}

sub fast_insert {
    my $self = shift;
    my ($sql, @binds) = $self->maker->insert(@_);
    $self->dbh->query($sql, @binds);
}

sub delete {
    my $self = shift;
    my ($sql, @binds) = $self->maker->delete(@_);
    $self->dbh->query($sql, @binds);
}

sub update {
    my $self = shift;
    my ($sql, @binds) = $self->maker->update(@_);
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

1;
__END__

=encoding utf-8

=head1 NAME

Otogiri - It's new $module

=head1 SYNOPSIS

    use Otogiri;

=head1 DESCRIPTION

Otogiri is ...

=head1 LICENSE

Copyright (C) ytnobody.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

ytnobody E<lt>ytnobody@gmail.comE<gt>

=cut

