# $Id$
use strict;
use Test::More tests => 6;
use vars qw( $class );

BEGIN {
    $class = 'DateTime::Format::Builder';
    use_ok $class;
}

my $sample = 'SampleClassWithArgs1';

{
    my $parser = $class->parser( {
	    params => [ qw( year month day hour minute second ) ],
	    regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)$/,
	    postprocess => sub {
		my %p=(@_);
		$p{parsed}->{time_zone} = $p{args}->[0];
		1;
	    }
	} );

    my $dt = $parser->parse_datetime( "20030716T163245", 'Europe/Berlin' );
    is( $dt->time_zone->name, 'Europe/Berlin' );
}

{
    $class->create_class(
	class	 => $sample,
	parsers    => {
	    parse_datetime => [    
	    [
		preprocess => sub {
		    my %p=(@_);
		    $p{parsed}->{time_zone} = $p{args}->[0];
		    return $p{input};
		},
	    ],
	    {
		params => [ qw( year month day hour minute second ) ],
		regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)$/,
	    }
	    ],
	},
    );

    my $dt = $sample->parse_datetime( "20030716T163245", 'Asia/Singapore' );
    is( $dt->time_zone->name, 'Asia/Singapore' );
}

{
    $sample++;
    $class->create_class(
	class	 => $sample,
	parsers    => {
	    parse_datetime => [    
	    [
		preprocess =>  sub {
		    my %p = @_;
		    my %o = @{ $p{args} }; 
		    $p{parsed}->{time_zone} = $o{global} if $o{global};
		    return $p{input};
		},
	    ],
	    {
		params => [ qw( year month day hour minute second ) ],
		regex  => qr/^(\d\d\d\d)(\d\d)(\d\d)T(\d\d)(\d\d)(\d\d)$/,
		preprocess =>  sub {
		    my %p = @_;
		    my %o = @{ $p{args} }; 
		    $p{parsed}->{time_zone} = $o{pre} if $o{pre}; 
		    return $p{input};
		},
		postprocess => sub {
		    my %p = @_;
		    my %o = @{ $p{args} }; 
		    $p{parsed}->{time_zone} = $o{post} if $o{post}; 
		    return 1;
		},
	    },
	    ],
	}
    );

    my $dt = $sample->parse_datetime(
	"20030716T163245", 'global' => 'Africa/Cairo' );
    is( $dt->time_zone->name, 'Africa/Cairo' );

    $dt = $sample->parse_datetime(
	"20030716T163245", 'pre' => 'Europe/London' );
    is( $dt->time_zone->name, 'Europe/London' );

    $dt = $sample->parse_datetime(
	"20030716T163245", 'post' => 'Australia/Sydney' );
    is( $dt->time_zone->name, 'Australia/Sydney' );
}