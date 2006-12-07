
use strict;
use warnings;

package Mixin::ExtraFields::Driver;

# The most important getter to implement is get_all_detailed_extra.
# Subclasses must implement:
#   get_all_detailed_extra
#   delete_extra
#   set

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

sub delete_all_extra {
  my ($self, $object, $id) = @_;

  for my $name ($self->get_all_extra_names($object, $id)) {
    $self->delete_extra($object, $id);
  }
}

sub mutate {
  my ($self, $object, $id, $name) = @_;
  
  if (@_) {
    return $self->set_extra($object, $id, $name, shift @_);
  } else {
    return $self->get_extra($object, $id, $name);
  };
}

1;
