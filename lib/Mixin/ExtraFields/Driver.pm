
use strict;
use warnings;

package Mixin::ExtraFields::Driver;

# The most important getter to implement is get_all_detailed_extra.

sub get_extra {
  my ($self, $object, $id, $name) = @_;
  
  my $extra = $self->get_extra_detailed($object, $id, $name);
  return $extra ? $extra->{value} : ();
}

sub get_all_extra {
  my ($self, $object, $id) = @_;
  
  my %extra  = $self->get_all_detailed_extra($object, $id);
  my @simple = map { $_ => $extra{$_}{value} } keys %extra;
}

sub get_extra_detailed {
  my ($self, $object, $id, $name) = @_;

  my %extra = $self->get_all_detailed_extra($object, $id);
  return exists $extra{$name} ? $extra{$name} : ();
}

sub get_all_extra_names {
  my ($self, $object, $id) = @_;
  my %extra = $self->get_all_detailed_extra($object, $id);
  return keys %extra;
}

sub exists_extra {
  my ($self, $object, $id, $name) = @_;
  my %extra = $self->get_all_detailed_extra($object, $id);

  return exists $extra{ $name };
}

1;
