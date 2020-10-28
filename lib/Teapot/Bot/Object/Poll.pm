package Teapot::Bot::Object::Poll;
$Teapot::Bot::Object::Poll::VERSION = '0.021';
# ABSTRACT: The base class for Telegram 'Poll' type objects


use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::PollOption;


has 'id';
has 'question';
has 'options'; # Array of PollOption
has 'is_closed';

sub fields {
  return { scalar                              => [qw/id question is_closed/],
           'Teapot::Bot::Object::PollOption' => [qw/options /],

         };
}

sub arrays {
  qw/options/;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::Poll - The base class for Telegram 'Poll' type objects

=head1 VERSION

version 0.021

=head1 DESCRIPTION

See L<https://core.telegram.org/bots/api#poll> for details of the
attributes available for L<Teapot::Bot::Object::Poll> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
