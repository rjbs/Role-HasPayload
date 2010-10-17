use strict;
use warnings;

use Test::More;

{
  package Some::Exception;
  use Moose;

  extends 'Exception::Mine';

  has size => (
    is   => 'ro',
    isa  => 'Int',
    lazy => 1,
    traits  => [ 'Exception::Mine::Meta::Attribute::Payload' ],
    default => 36,
  );

  has private_thing => (
    is      => 'ro',
    isa     => 'Int',
    default => 13,
  );
}

my $ok = eval {
  Some::Exception->throw({
    ident   => 'pants too small',
    message => "can't fit into pants under %{size;inch}n",
  });
};

my $error = $@;
ok(!$ok, "->throw died");
isa_ok($error, 'Some::Exception', '...the thrown error');

is_deeply(
  $error->payload,
  {
    size => 36,
  },
  "...and the payload is correct",
);

is(
  $error->message,
  "can't fit into pants under 36 inches",
  "...and msg formats",
);

done_testing;
