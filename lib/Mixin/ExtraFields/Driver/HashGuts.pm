
use strict;
use warnings;

package Mixin::ExtraFields::Driver::HashGuts;
use base qw(Mixin::ExtraFields::Driver);

sub from_args {
  my ($class, $arg) = @_;

  my $self = {
    hash_key => $arg->{hash_key} || '__extras',
  };

  bless $self => $class;
}

sub hash_key {
  my ($self) = @_;
  return $self->{hash_key};
}

sub exists_extra {
  my ($self, $object, $id, $name) = @_;

  return exists $object->{ $self->hash_key }{ $name };
}

sub get_extra {
  my ($self, $object, $id, $name) = @_;

  return unless $self->exists_extra($object, $id, $name);
  return $object->{ $self->hash_key }{ $name };
}

sub set_extra {
  my ($self, $object, $id, $name, $value) = @_;

  return $object->{ $self->hash_key }{ $name } = $value;
}

sub delete_extra {
  my ($self, $object, $id, $name) = @_;

  delete $object->{ $self->hash_key }{ $name };
}

1;
