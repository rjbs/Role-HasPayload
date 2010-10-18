package Throwable::X;
use Moose::Role;
# ABSTRACT: useful eXtra behavior for Throwable exceptions

=head1 SYNOPSIS

Write an exception class:

  package X::Bad

=cut

use namespace::autoclean;

use Moose::Util::TypeConstraints -default => { -prefix => 'tc_' };
use Throwable::X::Meta::Attribute::Payload;
use Try::Tiny;

use String::Errf qw(errf);

tc_subtype 'Throwable::X::_VisibleStr',
  tc_as 'Str',
  tc_where { length };

# We don't want vertical whitespace, but we also don't want it to be a format
# string, in case we default to it.  Rather than being really cagey and
# demanding we use %% and then we s/%%/% in the ident, we just forbid it.
# Let's not be too clever, just yet. -- rjbs, 2010-10-17
tc_subtype 'Throwable::X::_Ident',
  tc_as 'Throwable::X::_VisibleStr',
  tc_where { /\S/ && ! /[%\v]/ };

# Another idea is to mark both lazy and then have a before BUILDALL (or
# something) that ensures that at least one is set and allows % in the ident as
# long as an explicit message_fmt was given.  I think this is probably better.
# -- rjbs, 2010-10-17

with(
  'Throwable',
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

has ident => (
  is  => 'ro',
  isa => 'Throwable::X::_Ident',
  required => 1,
);

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

tc_subtype 'Throwable::X::_Tag',
  tc_as 'Str',
  tc_where { /\A[-a-z0-9]+\z/ };

sub has_tag {
  my ($self, $tag) = @_;

  $_ eq $tag && return 1 for $self->tags;

  return;
}

sub tags {
  my ($self) = @_;

  # Poor man's uniq:
  my %tags = map {; $_ => 1 }
             (@{ $self->_default_tags }, @{ $self->_instance_tags });

  return wantarray ? keys %tags : (keys %tags)[0];
}

has instance_tags => (
  is     => 'ro',
  isa    => 'ArrayRef[Throwable::X::_Tag]',
  reader => '_instance_tags',
  init_arg => 'tags',
  default  => sub { [] },
);

has _default_tags => (
  is      => 'ro',
  builder => '_build_default_tags',
);

sub _build_default_tags {
  # This code stolen happily from Moose::Object::BUILDALL -- rjbs, 2010-10-18

  # NOTE: we ask Perl if we even need to do this first, to avoid extra meta
  # level calls
  return [] unless $_[0]->can('x_tags');

  my @tags;

  my ($self, $params) = @_;
  foreach my $method (
    reverse Class::MOP::class_of($self)->find_all_methods_by_name('x_tags')
  ) {
    push @tags, $method->{code}->execute($self, $params);
  }

  return \@tags;
}

sub payload {
  my ($self) = @_;

  my @attrs = grep { $_->does('Throwable::X::Meta::Attribute::Payload') }
              $self->meta->get_all_attributes;

  my %payload = map {;
    my $method = $_->get_read_method;
    ($_->name => $self->$method)
  } @attrs;

  return \%payload;
}

1;
