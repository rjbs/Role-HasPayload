package Throwable::X::WithMessage::Errf;
use MooseX::Role::Parameterized;
# ABSTRACT: an exception with a String::Errf-powered message

=head1 SYNOPSIS

In your class...

  package Errfy;
  use Moose;

  with 'Throwable::X::WithMessage::Errf';

  has payload => (
    is  => 'ro',
    isa => 'HashRef',
    required => 1,
  );

Then...

  my $thing = Errfy->new({
    message => "%{error_count;error}n encountered at %{when}t",
    payload => {
      error_count => 2,
      when        => time,
    },
  });

  # prints: 2 errors encountered at 2010-10-20 19:23:42
  print $thing->message;

=head1 DESCRIPTION

Throwable::X::WithMessage::Errf is an implementation of
L<Throwable::X::WithMessage> that uses L<String::Errf> to format
C<sprintf>-like message strings.  It adds a C<message_fmt> attribute,
initialized by the C<message> argument.  The value should be a String::Errf
format string.

When the provided C<message> method is called, it will fill in the format
string with the hashref returned by calling the C<payload> method, which I<must
be implemented by the including class>.

Throwable::X::WithMessage::Errf is a L<parameterized
role|MooseX::Role::Parameterized>.  The C<default> parameter lets you set a
default format string or callback.  The C<lazy> parameter sets whether or not
the C<message_fmt> attribute is lazy.  Setting it lazy will require that a
default is provided.

=cut

use String::Errf qw(errf);
use Try::Tiny;

use namespace::clean -except => 'meta';

parameter default => (
  isa => 'CodeRef|Str',
);

parameter lazy => (
  isa     => 'Bool',
  default => 0,
);

role {
  my $p = shift;

  with 'Throwable::X::WithMessage';

  requires 'payload';

  my $msg_default = $p->default;
  has message_fmt => (
    is   => 'ro',
    isa  => 'Throwable::X::_VisibleStr',
    lazy => $p->lazy,
    required => 1,
    init_arg => 'message',
    (defined $msg_default ? (default => $msg_default) : ()),
  );

  # The problem with putting this in a cached attribute is that we need to
  # clear it any time the payload changes.  We can do that by making the
  # Payload trait add a trigger to clear the message, but I haven't done so
  # yet. -- rjbs, 2010-10-16
  # has message => (
  #   is       => 'ro',
  #   lazy     => 1,
  #   init_arg => undef,
  #   default  => sub { __stringf($_[0]->message_fmt, $_[0]->data) },
  # );

  method message => sub {
    my ($self) = @_;
    return try {
      errf($self->message_fmt, $self->payload)
    } catch {
      sprintf '%s (error during formatting)', $self->message_fmt;
    }
  };
};

1;
