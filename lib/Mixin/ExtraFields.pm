use strict;
use warnings;

package Mixin::ExtraFields;

=head1 NAME

Mixin::ExtraFields - add extra stashes of data to your objects

=head1 VERSION

version 0.000

 $Id$

=cut

our $VERSION = '0.000';

=head1 SYNOPSIS

If you use the ExtraFields mixin in your class:

  package Corporate::WorkOrder;

  use Mixin::ExtraFields -fields => {
    id      => 'workorder_id',
    moniker => 'extra',
    driver  => { 'ClassDBI' => { table => 'workorder_extras' } }
  };

...your objects will then have methods for manipulating their extra fields:

  my $workorder = Corporate::WorkOrder->retrieve(1234);

  if ($workorder->extra_exists('debug_next')) {
    warn $workorder->extra_get('debug_next');
    $workorder->extra_delete('debug_next');
  }

  if ($workorder->extra_get('time_bomb')) {
    $workorder->extra_delete_all;
    $workorder->extra_set(
      last_explosion  => time,
      explosion_cause => 'time bomb',
    );
  }

=cut

use Sub::Exporter -setup => {
  groups => [ fields => \'gen_fields_group', ]
};

sub methods {
  qw(
    exists
    get_detailed get_all_detailed
    get          get_all
                 get_all_names
    set
    delete       delete_all
  )
}

sub driver_method_name {
  my ($self, $method) = @_;
  $self->method_name($method, 'extra');
}

sub method_name {
  my ($self, $method, $moniker) = @_;

  return "get_all_$moniker\_names" if $method eq 'get_all_names';
  return "$method\_$moniker";
}

sub gen_fields_group {
  my ($class, $name, $arg, $col) = @_;

  Carp::croak "no driver supplied to $class" unless $arg->{driver};
  my $driver = $class->build_driver($arg->{driver});

  my $id_method = $arg->{id} || 'id';
  my $moniker   = $arg->{moniker} || 'extra';

  my %method;
  for my $method_name ($class->methods) {
    my $install_method = $class->method_name($method_name, $moniker);

    $method{ $install_method } = $class->build_method(
      $method_name,
      {
        id_method => \$id_method,
        driver    => \$driver,
        moniker   => \$moniker, # So that things can refer to one another
      }
    );
  }

  return \%method;
}

sub build_method {
  my ($self, $method_name, $arg) = @_;

  # Remember that these are all passed in as references, to avoid unneeded
  # copying. -- rjbs, 2006-12-07
  my $id_method = $arg->{id_method};
  my $driver    = $arg->{driver};

  my $driver_method  = $self->driver_method_name($method_name);

  return sub {
    my $self = shift;
    my $id   = $self->$$id_method;
    Carp::confess "couldn't determine id for object" unless $id;
    $$driver->$driver_method($self, $id, @_);
  };
}

sub build_driver {
  my ($self, $arg) = @_;
  
  my ($driver_class, $driver_args) = $self->_driver_class_and_args($arg);

  eval "require $driver_class" or die $@;
  my $driver = $driver_class->from_args($driver_args);
}

sub _driver_class_and_args {
  my ($self, $arg) = @_;

  my $class;
  if (ref $arg) {
    $class = delete $arg->{class};
  } else {
    $class = $arg;
    $arg = {};
  }

  if (index($class, '+') == 0) {
    $class = substr $class, 1;
  } else {
    $class = "Mixin::ExtraFields::Driver::$class";
  }

  return ($class, $arg || {});
}

1;
