package Throwable::X::WithMessage::Errf;
use Moose::Role;

use String::Errf qw(errf);
use Try::Tiny;

use namespace::clean -except => 'meta';

with 'Throwable::X::WithMessage';

requires 'payload';

has message_fmt => (
  is   => 'ro',
  isa  => 'Throwable::X::_VisibleStr',
  lazy => 1,
  default  => sub { $_[0]->ident },
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
    sprintf '%s (error during formatting)', $self->message_fmt;
  }
}

1;
