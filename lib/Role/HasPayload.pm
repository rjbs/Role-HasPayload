package Role::HasPayload;
use Moose::Role;
# ABSTRACT: something that carries a payload

=head1 OVERVIEW

Including Role::HasPayload in your class is a promise to provide a C<payload>
method that returns a hashref of data to be used for some purpose.  Some
implementations of pre-built payload behavior are bundled with Role-HasPayload:

=for :list
* L<Role::HasPayload::Auto> - automatically compute a payload from attribtues
* L<Role::HasPayload::Merged> - merge auto-payload with data from constructor

=cut

requires 'payload';

no Moose::Role;
1;
