package Throwable::X;
use Moose::Role;
# ABSTRACT: useful eXtra behavior for Throwable exceptions

=head1 SYNOPSIS

Write an exception class:

  package X::BadValue;
  use Moose;

  with qw(Throwable::X StackTrace::Auto);

  use Throwable::X -all; # to get the Payload helper

  sub x_tags { qw(value) }

  # What bad value were we given?
  has given_value => (
    is => 'ro',
    required => 1,
    traits   => [ Payload ],
  );

  # What was the value supposed to be used for?
  has given_for => (
    is  => 'ro',
    isa => 'Str',
    traits => [ Payload ],
  );

Throw the exception when you need to:

  X::BadValue->throw({
    ident   => 'bad filename',
    tags    => [ qw(filename) ],
    public  => 1,
    message => "invalid filename %{given_value}s for %{given_for}s",
    given_value => $input,
    given_for   => 'user home directory',
  });

...and when catching:

  } catch {
    my $error = $_;

    if ($error->does('Throwable::X') and $error->is_public) {
      print $error->message, "\n\n", $error->stack_trace->as_string;
    }
  }

=head1 DESCRIPTION

Throwable::X is a collection of behavior for writing exceptions.  It's meant to
provide:

=for :list
* means by which exceptions can be identified without string parsing
* a structure that can be serialized and reconstituted in other environments
* maximum composability by dividing features into individual roles

=cut

use Throwable::X::Types;
use Throwable::X::Meta::Attribute::Payload;

use namespace::clean -except => 'meta';;

# Does this belong elsewhere? -- rjbs, 2010-10-18
use Sub::Exporter -setup => {
  exports => { Payload => \'__payload' },
};
sub __payload { sub { 'Throwable::X::Meta::Attribute::Payload' } }

with(
  'Throwable',
  'Throwable::X::AutoPayload',
  'Throwable::X::WithIdent',
  'Throwable::X::WithMessage::Errf',
  'Throwable::X::WithTags',

  'MooseX::OneArgNew' => {
    type     => 'Throwable::X::_VisibleStr',
    init_arg => 'ident',
  },
);

has is_public => (
  is  => 'ro',
  isa => 'Bool',
  init_arg => 'public',
  default  => 0,
);

1;
