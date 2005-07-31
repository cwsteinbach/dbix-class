package DBIx::Class::SQL;

use strict;
use warnings;

use base qw/Class::Data::Inheritable/;

use constant COLS => 0;
use constant FROM => 1;
use constant COND => 2;

=head1 NAME 

DBIx::Class::SQL -  SQL Specific methods for DBIx::Class

=head1 SYNOPSIS

=head1 DESCRIPTION

This class contains methods that generates SQL queries for
the rest of the L<DBIx::Class> hiarchy. It's also responsible
for executing these.

=cut

__PACKAGE__->mk_classdata('_sql_statements',
  {
    'select' =>
      sub { "SELECT ".join(', ', @{$_[COLS]})." FROM $_[FROM] WHERE $_[COND]"; },
    'update' =>
      sub { "UPDATE $_[FROM] SET ".join(', ', map { "$_ = ?" } @{$_[COLS]}).
              " WHERE $_[COND]"; },
    'insert' =>
      sub { "INSERT INTO $_[FROM] (".join(', ', @{$_[COLS]}).") VALUES (".
              join(', ', map { '?' } @{$_[COLS]}).")"; },
    'delete' =>
      sub { "DELETE FROM $_[FROM] WHERE $_[COND]"; },
  } );

sub _get_sql {
  my ($class, $name, $cols, $from, $cond) = @_;
  my $sql = $class->_sql_statements->{$name}->($cols, $from, $cond);
  #warn $sql;
  return $sql;
}

sub _sql_to_sth {
  my ($class, $sql) = @_;
  return $class->_get_dbh->prepare($sql);
}

sub _get_sth {
  my $class = shift;
  return $class->_sql_to_sth($class->_get_sql(@_));
}

1;

=head1 AUTHORS

Matt S. Trout <perl-stuff@trout.me.uk>

=head1 LICENSE

You may distribute this code under the same terms as Perl itself.

=cut
