
use strict;
use warnings;

package Mixin::ExtraFields::Driver::HashGuts;
use base qw(Mixin::ExtraFields::Driver);

=head1 NAME

Mixin::ExtraFields::Driver::HashGuts - store extras in a hashy object's guts

=head1 VERSION

version 0.003

 $Id$

=cut

our $VERSION = '0.003';

=head1 SYNOPSIS

  package Your::HashBased::Class;

  use Mixin::ExtraFields -fields => { driver => 'HashGuts' };

=head1 DESCRIPTION

This driver class implements an extremely simple storage mechanism: extras are
stored on the object on which the mixed-in methods are called.  By default,
they are stored under the key returned by the C<L</default_has_key>> method,
but this can be changed by providing a C<hash_key> argument to the driver
configuration, like so:

  use Mixin::ExtraFields -fields => {
    driver => { class => 'HashGuts', hash_key => "\0Something\0Wicked\0" }
  };

=head1 METHODS

In addition to the methods required by Mixin::ExtraFields::Driver, the
following methods are provided:

=head2 hash_key

  my $key = $driver->hash_key;

This method returns the key where the driver will store its extras.

=cut

sub hash_key {
  my ($self) = @_;
  return $self->{hash_key};
}

=head2 default_hash_key

If no C<hash_key> argument is given for the driver, this method is called
during driver initialization.  It will return a unique string to be used as the
hash key.

=cut

my $i = 0;
sub default_hash_key {
  my ($self) = @_;
  return "$self" . '@' . $i++;
}

sub from_args {
  my ($class, $arg) = @_;

  my $self = bless {} => $class;

  $self->{hash_key} = $arg->{hash_key} || $self->default_hash_key;

  return $self;
}

sub exists_extra {
  my ($self, $object, $id, $name) = @_;

  return exists $object->{ $self->hash_key }{ $name };
}

sub get_extra {
  my ($self, $object, $id, $name) = @_;

  # avoid autovivifying entries on get.
  return unless $self->exists_extra($object, $id, $name);
  return $object->{ $self->hash_key }{ $name };
}

sub get_detailed_extra {
  my ($self, $object, $id, $name) = @_;

  # avoid autovivifying entries on get.
  return unless $self->exists_extra($object, $id, $name);
  return { value => $object->{ $self->hash_key }{ $name } };
}

sub get_all_detailed_extra {
  my ($self, $object, $id) = @_;

  return unless my $stash = $object->{ $self->hash_key };
  my @all_detailed = map { $_ => { value => $stash->{$_} } } keys %$stash;
}

sub get_all_extra {
  my ($self, $object, $id) = @_;

  return unless my $hash_ref = $object->{ $self->{hash_key} };
  return %$hash_ref;
}

sub set_extra {
  my ($self, $object, $id, $name, $value) = @_;

  return $object->{ $self->hash_key }{ $name } = $value;
}

sub delete_extra {
  my ($self, $object, $id, $name) = @_;

  delete $object->{ $self->hash_key }{ $name };
}

sub delete_all_extra {
  my ($self, $object, $id) = @_;
  $object->{ $self->hash_key } = undef;
}

=head1 AUTHOR

This code was written by Ricardo SIGNES.  His code in 2006 was sponsored by
Listbox.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, Ricardo SIGNES.  This code is free software, and is
available under the same terms as perl itself.

=cut

1;
