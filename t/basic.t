use strict;
use warnings;

use Test::More tests => 16;

BEGIN { require_ok('Mixin::ExtraFields'); }

use lib 't/lib';

my $test_class;

BEGIN {
  $test_class = 'Object::HasExtraFields';
  use_ok($test_class);
}

my $object = $test_class->new;

isa_ok($object, $test_class);

can_ok(
  $object,
  map { "$_\_extra" } qw(get get_all set exists delete delete_all),
);

ok( ! $object->exists_extra('datum'), "there exists no extra 'datum' yet");
is($object->get_extra('datum'), undef, "extra 'datum' shows undef value");
ok( ! $object->exists_extra('datum'), "getting 'datum' value doesn't autoviv");

$object->set_extra(datum => 10);

ok($object->exists_extra('datum'), "extra 'datum' exists now");
is($object->get_extra('datum'), 10, "extra/datum has the value we supplied");

ok( ! $object->exists_misc('datum'), "there exists no misc 'datum' yet");
is($object->get_misc('datum'), undef, "misc/datum has the value we supplied");

$object->set_misc(datum => 20);

ok($object->exists_misc('datum'), "there now exists misc 'datum'");
is($object->get_misc('datum'), 20, "misc/datum has the value we supplied");

is($object->get_extra('datum'), 10, "extra/datum has the value we supplied");

$object->delete_extra('datum');

ok( ! $object->exists_extra('datum'), "there exists no extra 'datum' again");
is($object->get_extra('datum'), undef, "extra 'datum' shows undef value");
