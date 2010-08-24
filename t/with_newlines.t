use strict;
use warnings;
use Test::More;

use Test::Requires {
    'Test::Compile' => '0.01', # skip all if not installed
};

pm_file_ok('t/lib/WithNewline.pm', 'should not throw an "expected option name" error and segfault');

done_testing;
