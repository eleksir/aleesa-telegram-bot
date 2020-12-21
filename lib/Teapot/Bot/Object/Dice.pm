package Teapot::Bot::Object::Dice;
# ABSTRACT: The base class for Telegram message 'Dice' type.

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::Dice::VERSION = '0.022';

has 'emoji';
has 'value';

sub fields {
  return { scalar => [qw/emoji value/] };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::Dice - The base class for Telegram message 'Dice' type

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram message 'Dice' type.

See L<https://core.telegram.org/bots/api#dice> for details of the
attributes available for L<Teapot::Bot::Object::dice> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
