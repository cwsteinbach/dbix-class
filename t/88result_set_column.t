use strict;
use warnings;  

use Test::More;
use lib qw(t/lib);
use DBICTest;

my $schema = DBICTest->init_schema();

plan tests => 14;

my $cd;
my $rs = $cd = $schema->resultset("CD")->search({});

my $rs_title = $rs->get_column('title');
my $rs_year = $rs->get_column('year');
my $max_year = $rs->get_column(\'MAX (year)');

is($rs_title->next, 'Spoonful of bees', "next okay");
is_deeply( [ sort $rs_year->func('DISTINCT') ], [ 1997, 1998, 1999, 2001 ],  "wantarray context okay");
ok ($max_year->next == $rs_year->max, q/get_column (\'FUNC') ok/);

my @all = $rs_title->all;
cmp_ok(scalar @all, '==', 5, "five titles returned");

cmp_ok($rs_year->max, '==', 2001, "max okay for year");
is($rs_title->min, 'Caterwaulin\' Blues', "min okay for title");

cmp_ok($rs_year->sum, '==', 9996, "three artists returned");

my $psrs = $schema->resultset('CD')->search({},
    {
        '+select'   => \'COUNT(*)',
        '+as'       => 'count'
    }
);
ok(defined($psrs->get_column('count')), '+select/+as count');

$psrs = $schema->resultset('CD')->search({},
    {
        '+select'   => [ \'COUNT(*)', 'title' ],
        '+as'       => [ 'count', 'addedtitle' ]
    }
);
ok(defined($psrs->get_column('count')), '+select/+as arrayref count');
ok(defined($psrs->get_column('addedtitle')), '+select/+as title');

{
  my $rs = $schema->resultset("CD")->search({}, { prefetch => 'artist' });
  my $rsc = $rs->get_column('year');
  is( $rsc->{_parent_resultset}->{attrs}->{prefetch}, undef, 'prefetch wiped' );
}

# test sum()
is ($schema->resultset('BooksInLibrary')->get_column ('price')->sum, 125, 'Sum of a resultset works correctly');

# test sum over search_related
my $owner = $schema->resultset('Owners')->find ({ name => 'Newton' });
ok ($owner->books->count > 1, 'Owner Newton has multiple books');
is ($owner->search_related ('books')->get_column ('price')->sum, 60, 'Correctly calculated price of all owned books');
