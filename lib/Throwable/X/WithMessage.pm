package Throwable::X::WithMessage;
use Moose::Role;

use namespace::clean -except => 'meta';

requires 'message';

1;
