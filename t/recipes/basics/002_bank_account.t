use strict;
use warnings;

use Test::More tests => 23;
use Test::Fatal;

use MooseX::Declare;

class BankAccount {
    has 'balance' => ( isa => 'Num', is => 'rw', default => 0 );

    method deposit (Num $amount) {
        $self->balance( $self->balance + $amount );
    }

    method withdraw (Num $amount) {
        my $current_balance = $self->balance();
        ( $current_balance >= $amount )
            || confess "Account overdrawn";
        $self->balance( $current_balance - $amount );
    }
}

class CheckingAccount extends BankAccount {
    has 'overdraft_account' => ( isa => 'BankAccount', is => 'rw' );

    before withdraw (Num $amount) {
        my $overdraft_amount = $amount - $self->balance();
        if ( $self->overdraft_account && $overdraft_amount > 0 ) {
            $self->overdraft_account->withdraw($overdraft_amount);
            $self->deposit($overdraft_amount);
        }
    }
}

my $savings_account = BankAccount->new(balance => 250);
isa_ok($savings_account, 'BankAccount');

is($savings_account->balance, 250, '... got the right savings balance');
is( exception {
    $savings_account->withdraw(50);
}, undef, '... withdrew from savings successfully');
is($savings_account->balance, 200, '... got the right savings balance after withdrawl');

$savings_account->deposit(150);
is($savings_account->balance, 350, '... got the right savings balance after deposit');

{
    my $checking_account = CheckingAccount->new(
                                balance => 100,
                                overdraft_account => $savings_account
                            );
    isa_ok($checking_account, 'CheckingAccount');
    isa_ok($checking_account, 'BankAccount');

    is($checking_account->overdraft_account, $savings_account, '... got the right overdraft account');

    is($checking_account->balance, 100, '... got the right checkings balance');

    is( exception {
        $checking_account->withdraw(50);
    }, undef, '... withdrew from checking successfully');
    is($checking_account->balance, 50, '... got the right checkings balance after withdrawl');
    is($savings_account->balance, 350, '... got the right savings balance after checking withdrawl (no overdraft)');

    is( exception {
        $checking_account->withdraw(200);
    }, undef, '... withdrew from checking successfully');
    is($checking_account->balance, 0, '... got the right checkings balance after withdrawl');
    is($savings_account->balance, 200, '... got the right savings balance after overdraft withdrawl');
}

{
    my $checking_account = CheckingAccount->new(
                                balance => 100
                                # no overdraft account
                            );
    isa_ok($checking_account, 'CheckingAccount');
    isa_ok($checking_account, 'BankAccount');

    is($checking_account->overdraft_account, undef, '... no overdraft account');

    is($checking_account->balance, 100, '... got the right checkings balance');

    is( exception {
        $checking_account->withdraw(50);
    }, undef, '... withdrew from checking successfully');
    is($checking_account->balance, 50, '... got the right checkings balance after withdrawl');

    isnt( exception {
        $checking_account->withdraw(200);
    }, undef, '... withdrawl failed due to attempted overdraft');
    is($checking_account->balance, 50, '... got the right checkings balance after withdrawl failure');
}


