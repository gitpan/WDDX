#!/usr/bin/perl
# 
# $Id: Binary.pm,v 1.4 1999/11/02 07:23:48 sguelich Exp $
# 
# This code is copyright 1999 by Scott Guelich <scott@scripted.com>
# and is distributed according to the same conditions as Perl itself
# Please visit http://www.scripted.com/wddx/ for more information

#

package WDDX::Binary;

use strict;
use Carp;
use MIME::Base64;

require WDDX;

1;


#/-----------------------------------------------------------------------
# Public Methods
# 

sub new {
    my( $class, $value ) = @_;
    
    croak "You must supply a value when creating a new $class object\n"
        unless defined $value;
    
    my $self = {
        value   => $value,
    };
    
    bless $self, $class;
    return $self;
}


sub type {
    return "binary";
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
    my( $self ) = @_;
    croak "JavaScript support is not implemented for binary objects.";
}


#/-----------------------------------------------------------------------
# Private Methods
# 

sub is_parser {
    return 0;
}


sub _serialize {
    my( $self ) = @_;
    my $length = length $self->{value};
    my $val = $self->encode;
    my $output = "<binary length='$length'>$val</binary>";
    
    return $output;
}


sub _deserialize {
    my( $self ) = @_;
    return $self->{value};
}


# This is a separate sub to facilitate adding other encodings in the future
sub decode {
    my( $self ) = @_;
    return decode_base64( $self->{value} );
}

# This is a separate sub to facilitate adding other encodings in the future
sub encode {
    my( $self ) = @_;
    return encode_base64( $self->{value} );
}


#/-----------------------------------------------------------------------
# Parsing Code
# 

package WDDX::Binary::Parser;

use MIME::Base64;


sub new {
    return bless { value => "" }, shift;
}


sub start_tag {
    my( $self, $element, $attribs ) = @_;
    
    if ( $element eq "binary" ) {
        $self->{'length'} = 
            defined( $attribs->{'length'} ) ? $attribs->{'length'} : undef;
    }
    else {
        die "<$element> not allowed within <binary> element\n";
    }
    
    return $self;
}


sub end_tag {
    my( $self, $element ) = @_;
    
    if ( $element eq "binary" ) {
        $self = new WDDX::Binary( $self->decode );
    }
    else {
        die "</$element> not allowed within <binary> element\n";
    }
    return $self;
}


sub append_data {
    my( $self, $data ) = @_;
    $self->{value} .= $data;
}


sub is_parser {
    return 1;
}


# This is a separate sub to facilitate adding other encodings in the future
sub decode {
    my( $self ) = @_;
    
    my $decoded = decode_base64( $self->{value} );
    
    if ( defined $self->{'length'} ) {
        my $declared = $self->{'length'};
        my $read = length $decoded;
        if ( $declared != length $read ) {
## Temporary comment... my Mac version of MIME::Base64 is munged so it's always wrong
#            die "Declared length of <binary> element ($declared) does not " .
#                "match length read ($read)\n";
        }
    }
    
    return $decoded;
}
