#!/usr/bin/perl
# 
# $Id: Null.pm,v 1.3 1999/11/01 23:10:23 sguelich Exp $
# 
# This code is copyright 1999 by Scott Guelich <scott@scripted.com>
# and is distributed according to the same conditions as Perl itself
# Please visit http://www.scripted.com/wddx/ for more information

#

package WDDX::Null;

use strict;
use Carp;

require WDDX;

1;


#/-----------------------------------------------------------------------
# Public Methods
# 

sub new {
    return bless { value => undef }, shift;
}


sub type {
    return "null";
}


sub as_packet {
    my( $self ) = @_;
    my $output = $WDDX::PACKET_HEADER . $self->_serialize . $WDDX::PACKET_FOOTER;
}


sub as_scalar {
    my( $self ) = @_;
    return $self->_deserialize;
}


sub as_javascript {
    my( $self, $js_var ) = @_;
    return "$js_var=null;";
}


#/-----------------------------------------------------------------------
# Private Methods
# 

sub is_parser {
    return 0;
}


sub _serialize {
    return "<null/>";
}


sub _deserialize {
    return undef;
}


#/-----------------------------------------------------------------------
# Parsing Code
# 

package WDDX::Null::Parser;


sub new {
    return bless { value => undef }, shift;
}


sub start_tag {
    my( $self, $element, $attribs ) = @_;
    
    die "<$element> not allowed within <null> element\n" unless $element eq "null";
    return $self;
}


sub end_tag {
    my( $self, $element ) = @_;
    
    if ( $element eq "null" ) {
        $self = new WDDX::Null();
    }
    else {
        die "</$element> not allowed within <null> element\n";
    }
    return $self;
}


sub append_data {
    die "No data is allowed between <null> tags\n";
}


sub is_parser {
    return 1;
}

