use strict;
use warnings;

package Mixin::ExtraFields;

use Carp ();

=head1 NAME

Mixin::ExtraFields - add extra stashes of data to your objects

=head1 VERSION

version 0.001

 $Id$

=cut

our $VERSION = '0.001';

=head1 SYNOPSIS

If you use the ExtraFields mixin in your class:

  package Corporate::WorkOrder;

  use Mixin::ExtraFields -fields => {
    id      => 'workorder_id',
    moniker => 'note',
    driver  => { HashGuts => { hash_key => '_notes' } }
  };

...your objects will then have methods for manipulating their extra fields:

  my $workorder = Corporate::WorkOrder->retrieve(1234);

  if ($workorder->note_exists('debug_next')) {
    warn $workorder->note_get('debug_next');
    $workorder->note_delete('debug_next');
  }

  if ($workorder->note_get('time_bomb')) {
    $workorder->note_delete_all;
    $workorder->note_set(
      last_explosion  => time,
      explosion_cause => 'time bomb',
    );
  }

=head1 DESCRIPTION

Sometimes your well-defined object needs a way to tack on arbirary extra
fields.  This might be a set of session-specific ephemeral data, a stash of
settings that need to be easy to grow over time, or any sort of name-and-value
parameters.  Adding more and more methods can be cumbersome, and may not be
helpful if the names vary greatly.  Accessing an object's guts directly is
simple, but is difficult to control when subclassing, and can make altering
your object's structure difficult.

Mixin::ExtraFields provides a simple way to add an arbitrary number of stashes
for named data.  These data can be stored in the object, in a database, or
anywhere else.  The storage mechanism is abstracted away from the provided
interface, so one storage mechanism can be easily swapped for another.
Multiple ExtraFields stashes can be mixed into one class, using one or many
storage mechanisms.

=head1 MIXING IN

To create a stash of extra fields, just C<use> Mixin::ExtraFields and import
the C<fields> group like this:

  use Mixin::ExtraFields -fields => { driver => 'SomeDriver' };

The only argument required for the group is C<driver>, which names the driver
(storage mechanism) to use.  For more information, see L</Specifying a Driver>,
below.

Other valid arguments are:

  id - the name of the method to call on objects to get their unique identifier
       default: id

  moniker - the name to use in forming mixed-in method names
            default: extra

=head2 Specifying a Driver

The C<driver> argument can be given as either a driver identifier or a
reference to a hash of options.  If given as a hash reference, one of the
entries in the hash must be C<class>, giving the driver identifier for the
driver.

A driver identifier must be either:

=over

=item * a partial class name, to follow Mixin::ExtraFields::Driver::

=item * a full class name, prepended with +

=back

=head1 GENERATED METHODS

The default implementation of Mixin::ExtraFields provides a number of methods
for accessing the extras.  Wherever "extra" appears in the following method
names, the C<moniker> argument given to the C<fields> group will be used
instead.

=head2 exists_extra

  if ($obj->exists_extra($name)) { ... }

This method returns true if there is an entry in the extras for the given name.

=head2 get_extra

=head2 get_detailed_extra

  my $value = $obj->get_extra($name);

  my $value_hash = $obj->get_detailed_extra($name);

These methods return the entry for the given name.  If none exists, the method
returns undef.  The detailed version of this method will return a hashref
describing all information available about the entry.  While this information
is driver-specific, it is required to have an entry for the key C<entry>,
providing the value that would have been returned by C<get_extra>.

=head2 get_all_extra

=head2 get_all_detailed_extra

  my %extra = $obj->get_all_extra;

  my %extra_hash = $obj->get_all_detailed_extra;

These methods return a list of name/value pairs.  The values are in the same
form as those returned by the get-by-name methods, above.

=head2 get_all_extra_names

  my @names = $obj->get_all_extra_names;

This method returns the names of all existing extras.

=head2 set_extra

  $obj->set_extra($name => $value);

This method sets the given extra.  If no entry existed before, one is created.
If one existed for this name, it is replaced.

=head2 delete_extra

  $obj->delete_extra($name);

This method deletes the named entry.  After deletion, no entry will exist for
that name.

=head2 delete_all_extra

  $obj->delete_all_extra;

This method deletes all entries for the object.

=cut

=head1 SUBCLASSING

Mixin::ExtraFields can be subclassed to produce different methods, provide
different names, or behave differently in other ways.  Subclassing
Mixin::ExtraFields can produce many distinct and powerful tools.

None of the generated methods, above, are implemented in Mixin::ExtraFields.
The methods below are its actual methods, which work together to build and
export the methods that are mixed in.  These are the methods you should
override when subclassing Mixin::ExtraFields.

For information on writing drivers, see L<Mixin::ExtraFields::Driver>.

=cut

use Sub::Exporter -setup => {
  groups => [ fields => \'gen_fields_group', ]
};

=head2 default_moniker

This method returns the default moniker.  The default default moniker defaults
to the default "extra".

=cut

sub default_moniker { 'extra' }

=head2 methods

This method returns a list of base method names to construct and install.
These method names will be transformed into the installed method names via
C<L</method_name>>.

  my @methods = Mixin::ExtraFields->methods;

=cut

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

=head2 method_name

  my $method_name = Mixin::ExtraFields->method_name($method_base, $moniker);

This method returns the method name that will be installed into the importing
class.  Its default behavior is to join the method base (which comes from the
C<L</methods>> method) and the moniker with an underscore, more or less.

=cut

sub method_name {
  my ($self, $method, $moniker) = @_;

  return "get_all_$moniker\_names" if $method eq 'get_all_names';
  return "$method\_$moniker";
}

=head2 driver_method_name

This method returns the name of the driver method used to implement the given
method name.  This is primarily useful in the default implementation of
MixinExtraFields, where there is a one-to-one correspondence between installed
methods and driver methods.

=cut

sub driver_method_name {
  my ($self, $method) = @_;
  $self->method_name($method, 'extra');
}

=head2 gen_fields_group

  my $sub_href = Mixin::ExtraFields->gen_fields_group($name, \%arg, \%col);

This method is a group generator, as used by L<Sub::Exporter> and described in
its documentation.  It is the method you are least likely to subclass.

=cut

sub gen_fields_group {
  my ($class, $name, $arg, $col) = @_;
  
  $arg->{driver} ||= $class->default_driver_arg;
  my $driver = $class->build_driver($arg->{driver});

  my $id_method = $arg->{id} || 'id';
  my $moniker   = $arg->{moniker} || $class->default_moniker;

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

=head2 build_method

  my $code = Mixin::ExtraFields->build_method($method_name, \%arg);

This routine builds the requested method.  It is passed a method name in the
form returned by the C<methods> method and a hashref of the following data:

  id_method - the method to call on objects to get their unique id
  driver    - the storage driver

B<Note!>  The values for the above arguments are references to the values you'd
expect.  That is, if the id method is "foo" you will be given an reference to
the string foo.  (This reduces the copies of common values that will be enclosed
into generated code.)

=cut

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

=head2 default_driver_arg

  my $arg = Mixin::ExtraFields->default_driver_arg;

This method a default value for the C<driver> argument to the fields group
generator.  By default, this method will croak if called.

=cut

sub default_driver_arg {
  my ($class) = shift;
  Carp::croak "no driver supplied to $class";
}


=head2 build_driver

  my $driver = Mixin::ExtraFields->build_driver($arg);

This method constructs and returns the driver object to be used by the
generated methods.  It is passed the C<driver> argument given in the importing
code's C<use> statement.

=cut

sub build_driver {
  my ($self, $arg) = @_;
  
  my ($driver_class, $driver_args) = $self->_driver_class_and_args($arg);

  eval "require $driver_class" or Carp::croak $@;
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

  if (index($class, q{+}) == 0) {
    $class = substr $class, 1;
  } else {
    $class = "Mixin::ExtraFields::Driver::$class";
  }

  return ($class, $arg || {});
}

=head1 AUTHOR

This code was written by Ricardo SIGNES.  His work in 2006 was sponsored by
Listbox.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2006, Ricardo SIGNES.  This code is free software, and is
available under the same terms as perl itself.

=head1 TODO

=over

=item * handle invocants without ids (classes) and drivers that don't need ids

=item * a CGI->param-like subclass, to replace Mixin::Params, never released

=item * a Data::Hive-like subclass -- implemented, but too Listbox-specific

=back

=cut

1;
