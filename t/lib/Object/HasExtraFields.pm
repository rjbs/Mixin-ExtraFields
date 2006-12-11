
use strict;
use warnings;

package Object::HasExtraFields;

use Carp ();

use Mixin::ExtraFields
  -fields => { driver => 'HashGuts' },
  -fields => {
    driver => { class => 'HashGuts', hash_key => '__misc' },
    moniker => 'misc',
  };

sub new {
  return bless {} => shift;
}

sub id {
  0 + $_[0];
}

1;
