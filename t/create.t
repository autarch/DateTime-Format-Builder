use strict;
use lib 'inc';
use Test::More tests => 41;
use vars qw( $class );

BEGIN {
    $class = 'DateTime::Format::Builder';
    use_ok $class;
}

my $should_fail;

my @parsers = (
    {
	params => [ qw( year month day hour minute second ) ],
	regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)$/,
	on_fail => sub { ok( $should_fail, "on_fail called for $_[0]" ) },
	on_match => sub { ok( !$should_fail, "on_match called for $_[0]" ) },
    },
    {
	length => 8,
	params => [ qw( year month day ) ],
	regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)$/,
	on_fail => sub { ok( $should_fail, "on_fail called for $_[0]" ) },
	on_match => sub { ok( !$should_fail, "on_match called for $_[0]" ) },
    },
    {
	length => 13,
	params => [ qw( year month day hour minute ) ],
	regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)$/,
	on_fail => sub { ok( $should_fail, "on_fail called for $_[0]" ) },
	on_match => sub { ok( !$should_fail, "on_match called for $_[0]" ) },
    },
    {
	length => 11,
	params => [ qw( year month day hour ) ],
	regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)T(\d\d)$/,
	on_fail => sub { ok( $should_fail, "on_fail called for $_[0]" ) },
	on_match => sub { ok( !$should_fail, "on_match called for $_[0]" ) },
    },
);

{
    my $parser = $class->parser( %{ $parsers[0] } );
    isa_ok( $parser => $class );
    {
	$should_fail = 0;
	my $dt = $parser->parse_datetime( "20030716T163245" );

	isa_ok( $dt => "DateTime" );

	my %methods = qw( hour 16 minute 32 second 45 year 2003 month 7 day 16 );
	while (my ($method, $expected) = each %methods)
	{
	    is( $dt->$method() => $expected, "\$dt->$method() == $expected" );
	}
    }
    {
	$should_fail = 1;
	my $dt = eval { $parser->parse_datetime( "20030716T1632456" ) };
	ok($@, "Shouldn't've passed or rescued." );
    }
}

{
    my $parser = $class->parser( @parsers );
    isa_ok( $parser => $class );
    my %times = (
        '20030716T163245' => {qw(
		hour 16 minute 32 second 45 year 2003 month 7 day 16 )},
        '20030716T1632' => {qw( hour 16 minute 32 year 2003 month 7 day 16 )},
        '20030716T16' => {qw( hour 16 year 2003 month 7 day 16 )},
        '20030716' => {qw( year 2003 month 7 day 16 )},
    );
    for my $time (sort keys %times)
    {
	$should_fail = 0;
	my $dt = $parser->parse_datetime( $time );

	isa_ok( $dt => "DateTime" );

	while (my ($method, $expected) = each %{ $times{$time} })
	{
	    is( $dt->$method() => $expected, "\$dt->$method() == $expected" );
	}
    }
}

{
    sub ClassHasNew::new { return 'new' }

    eval q[
	package ClassHasNew;
	use DateTime::Format::Builder
	    parsers => {
		parse_datetime => [
		{
		    regex => qr/^(\d{4})(\d\d)(d\d)(\d\d)(\d\d)(\d\d)$/,
		    params => [qw( year month day hour minute second )],
		},
		{
		    regex => qr/^(\d{4})(\d\d)(\d\d)$/,
		    params => [qw( year month day )],
		},
		],
	    };
    ];
    ok( !$@, "No errors when creating the class." );
    is( ClassHasNew->new, 'new', "Don't overwrite existing new() method" );
}
