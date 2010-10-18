package Throwable::X::WithMessage;
use Moose::Role;
# ABSTRACT: a thing with a message method

=head1 DESCRIPTION

This is another extremely simple role.  A class that includes
Throwable::X::WithMessage is promising to provide a C<message> method that
returns a string describing the exception.  It does I<not> provide any actual
behavior.

=cut

use namespace::clean -except => 'meta';

requires 'message';

1;
