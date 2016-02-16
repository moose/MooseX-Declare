use Test::More 0.88;
use MooseX::Declare;

class Foo {
    has bar => (
        is      => 'ro',
        default => method { ref $self },
    );
}

is(Foo->new->bar,'Foo','yay');

done_testing;
