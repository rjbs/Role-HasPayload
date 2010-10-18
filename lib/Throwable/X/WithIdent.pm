package Throwable::X::WithIdent;
use Moose::Role;
# ABSTRACT: a thing with an ident attribute

=head1 DESCRIPTION

This is an incredibly simple role.  It adds a required C<ident> attribute that
stores a simple string, meant to identify exceptions.

=cut

use Throwable::X::Types;

use namespace::clean -except => 'meta';

has ident => (
  is  => 'ro',
  isa => 'Throwable::X::_Ident',
  required => 1,
);

1;
