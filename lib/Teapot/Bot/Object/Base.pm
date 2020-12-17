package Teapot::Bot::Object::Base;
# ABSTRACT: The base class for all Teapot::Bot::Object objects.

use Mojo::Base -base;
use List::Util qw/any/;
use Carp qw/croak cluck/;
use Data::Dumper;

$Teapot::Bot::Object::Base::VERSION = '0.022';

has '_brain'; # a reference to our brain


sub arrays { return qw// }  # override if needed
sub _field_is_array {
  my $self = shift;
  my $field = shift;

  unless (defined $field) {
    return;
  }

  if (any { /^$field$/ } $self->arrays) {
    return 1;
  }
  return;
}


sub array_of_arrays {  return qw// } #override if needed
sub _field_is_array_of_arrays {
  my $self = shift;
  my $field = shift;

  unless (defined $field) {
    return;
  }

  if (any { /^$field$/ } $self->array_of_arrays) {
    return 1;
  }
  return;
}


# create an object from a hash. Needs to deal with the nested types, and
# arrays
sub create_from_hash {
  my $class = shift;
  my $hash  = shift;
  my $brain = shift || croak 'No brain supplied to create_from_hash()';
  my $obj   = $class->new(_brain => $brain);

  unless (defined $hash) {
    cluck "Hash is undef";
    return $obj;
  }

  unless (ref ($hash) eq 'HASH') {
    cluck "Not a hash " . Dumper ($hash);
    return $obj;
  }

  # deal with each type of field
  foreach my $type (keys %{ $class->fields }) {
    my @fields_of_this_type = @{ $class->fields->{$type} };

    foreach my $field (@fields_of_this_type) {
      # ignore undefined fields (sic!)
      next if (! defined $field);

      # ignore fields for which we have no value in the hash
      next if (! defined $hash->{$field} );

      # warn "type: $type field $field\n";
      if ($type eq 'scalar') {
        if ($obj->_field_is_array($field)) {
          # simple scalar array ref, so just copy it
          my $val = $hash->{$field};
          # deal with boolean stuff so we don't pollute our object
          # with JSON
          if (ref($val) eq 'JSON::PP::Boolean') {
            $val = !!$val;
          }
          $obj->$field($val);
        }
        elsif ($obj->_field_is_array_of_arrays) {
          croak 'Not yet implemented for scalars';
        }
        else {
          my $val = $hash->{$field};
          if (ref($val) eq 'JSON::PP::Boolean') {
            $val = 0+$val;

          }
          $obj->$field($val);
        }
      }

      else {
        if ($obj->_field_is_array($field)) {
          my @sub_array;
          foreach my $data ( @{ $hash->{$field} } ) {
            push @sub_array, $type->create_from_hash($data, $brain);
          }
          $obj->$field(\@sub_array);
        }
        elsif ($obj->_field_is_array_of_arrays) {
          croak 'Not yet implemented for scalars';
        }
        else {
          $obj->$field($type->create_from_hash($hash->{$field}, $brain));
        }

      }
    }
  }

  return $obj;
}


sub as_hashref {
  my $self = shift;
  my $hash = {};
  # add the simple scalar values
  foreach my $type ( keys %{ $self->fields }) {
    my @fields = @{ $self->fields->{$type} };
    foreach my $field (@fields) {
      if ($type eq 'scalar') {
        $hash->{$field} = $self->$field;
      }
      else {
        # non array types
        $hash->{$field} = $self->$field->as_hashref
          if (ref($self->$field) ne 'ARRAY' && defined $self->$field);
        # array types
        $hash->{$field} = [
          map { $_->as_hashref } @{ $self->$field }
        ] if (ref($self->$field) eq 'ARRAY');
      }
    }
  }
  return $hash;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::Base - The base class for all Telegram::Bot::Object objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION

The base class for all Telegram::Bot::Object objects.

This class should not be instantiated itself. Instead, instantiate a sub-class.

You should generally not need to instantiate objects of sub-classes of L<Teapot::Bot::Object::Base>,
instead the appropriate objects will be created from an incoming request via
L<Teapot::Bot::Brain>.

You can then use the methods referenced below on those objects.

=head1 METHODS

=head2 arrays

Should be overridden by subclasses, returning an array listing of which fields
for the object are arrays.

=head2 array_of_arrays

Should be overridden by subclasses, returning an array listing od which fields
for the object are arrays of arrays.

=head2 create_from_hash

Create an object of the appropriate class, including any sub-objects of
other types, as needed.

=head2 as_hashref

Return this object as a hashref.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
