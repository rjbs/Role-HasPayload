package Exception::Mine;
use Moose::Role;
with (
  'Throwable',
  'StackTrace::Auto',
);

use namespace::autoclean;

use Moose::Util::TypeConstraints -default => { -prefix => 'tc_' };
use Exception::Mine::Meta::Attribute::Payload;
use Try::Tiny;

use String::Errf qw(errf);

has is_public => (
  is  => 'ro',
  isa => 'Bool',
  init_arg => 'public',
  default  => 0,
);

tc_subtype 'Exception::Mine::NonEmptyStr', tc_as 'Str', tc_where { length };

has ident => (
  is  => 'ro',
  isa => 'Exception::Mine::NonEmptyStr',
  required => 1
);

has message_fmt => (
  is  => 'ro',
  isa => 'Str',
  required => 1,
  init_arg => 'message',
);

# The problem with putting this in a cached attribute is that we need to clear
# it any time the payload changes.  We can do that by making the Payload trait
# add a trigger to clear the message, but I haven't done so yet.
# -- rjbs, 2010-10-16
# has message => (
#   is       => 'ro',
#   lazy     => 1,
#   init_arg => undef,
#   default  => sub { __stringf($_[0]->message_fmt, $_[0]->data) },
# );

sub message {
  my ($self) = @_;
  return try {
    errf($self->message_fmt, $self->payload)
  } catch {
    warn $_;
    sprintf '%s (error during formatting)', $self->message_fmt;
  }
}

has tags => (
  is  => 'ro',
  isa => 'ArrayRef',
  default => sub { [] },
);

sub payload {
  my ($self) = @_;

  my @attrs = grep { $_->does('Exception::Mine::Meta::Attribute::Payload') }
              $self->meta->get_all_attributes;

  my %payload = map {;
    my $method = $_->get_read_method;
    ($_->name => $self->$method)
  } @attrs;

  return \%payload;
}

1;
