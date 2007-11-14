use strict;
use warnings;

use inc::Module::Install;

name      ('Mixin-ExtraFields');
author    ('Ricardo SIGNES <rjbs@cpan.org>');
license   ('perl');
all_from  ('lib/Mixin/ExtraFields.pm');

requires  ('Sub::Exporter' => '0.972'); # method name reference for generators
requires  ('Sub::Install'  => '0.000'); # any version will do, I think

WriteAll();
