package Throwable::X::WithIdent;
use Moose::Role;

use Throwable::X::Types;

use namespace::clean -except => 'meta';

has ident => (
  is  => 'ro',
  isa => 'Throwable::X::_Ident',
  required => 1,
);

1;
