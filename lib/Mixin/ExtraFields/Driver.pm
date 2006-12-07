
use strict;
use warnings;

use base qw(Mixin::ExtraFields::Driver);

# The most important getter to implement is get_all_extra_detailed.

sub get_extra {
  my ($self, $object, $id, $name) = @_;
  
  my $extra = $self->get_extra_detailed($object, $id, $name);
  return $extra ? $extra->{value} : ();
}

sub get_all_extra {
  my ($self, $object, $id) = @_;
  
  my %extra  = $self->get_all_extra_detailed($object, $id);
  my @simple = map { $_ => $extra{$_}{value} } keys %extra;
}

sub get_extra_detailed {
  my ($self, $object, $id, $name) = @_;

  my %extra = $self->get_all_extra_detailed($object, $id);
  return exists $extra{$name} ? $extra{$name} : ();
}

1;
