package Teapot::Bot::Object::MessageAutoDeleteTimerChanged;
# ABSTRACT: The base class for Telegram 'MessageAutoDeleteTimerChanged' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::MessageAutoDeleteTimerChanged::VERSION = '0.022';

has 'message_auto_delete_time';

sub fields {
  return {
           'scalar'                    => [qw/message_auto_delete_time/],
         };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::MessageAutoDeleteTimerChanged - The base class for Telegram 'MessageAutoDeleteTimerChanged' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'MessageAutoDeleteTimerChanged' type objects.

See L<https://core.telegram.org/bots/api#messageautodeletetimerchanged> for details of the
attributes available for L<Teapot::Bot::Object::MessageAutoDeleteTimerChanged> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2021 by Sergei Fedosov <eleksir@gmail.com>

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
