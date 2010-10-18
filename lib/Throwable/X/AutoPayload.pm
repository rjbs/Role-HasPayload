package Throwable::X::AutoPayload;
use Moose::Role;
# ABSTRACT: a thing that automatically computes its payload based on attributes

=head1 SYNOPSIS

  package X::Example;
  use Moose;

  with qw(Throwable::X::AutoPayload);

  sub Payload { 'Throwable::X::Meta::Attribute::Payload' }

  has height => (
    is => 'ro',
    traits   => [ Payload ],
  );

  has width => (
    is => 'ro',
    traits   => [ Payload ],
  );

  has color => (
    is => 'ro',
  );

...then...

  my $example = X::Example->new({
    height => 10,
    width  => 20,
    color  => 'blue',
  });

  $example->payload; # { height => 10, width => 20 }

=head1 DESCRIPTION

Throwable::X::AutoPayload only provides one method, C<payload>, which returns a
hashref of the name and value of every attribute on the object with the
Throwable::X::Meta::Attribute::Payload trait.  (The attribute value is gotten
with the the method returned by the attribute's C<get_read_method> method.)

This role is especially useful when combined with
L<Throwable::X::WithMessage::Errf>.

=cut

use Throwable::X::Meta::Attribute::Payload;

use namespace::clean -except => 'meta';

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
