package Throwable::X::AutoPayload;
use Moose::Role;

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
