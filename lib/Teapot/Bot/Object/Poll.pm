package Teapot::Bot::Object::Poll;
# ABSTRACT: The base class for Telegram 'Poll' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';
use Teapot::Bot::Object::PollOption;

$Teapot::Bot::Object::Poll::VERSION = '0.022';

has 'id';
has 'question';
has 'options'; # Array of PollOption
has 'total_voter_count';
has 'is_closed';
has 'is_anonymous';
has 'type';
has 'allows_multiple_answers';
has 'correct_option_id';
has 'explanation';
has 'explanation_entities';
has 'open_period';
has 'close_date';

sub fields {
  return {
           scalar                            => [qw/id question total_voter_count is_closed is_anonymous type
                                                    allows_multiple_answers correct_option_id explanation
                                                    explanation_entities open_period close_date/],
           'Teapot::Bot::Object::PollOption' => [qw/options/],
         };
}

sub arrays {
  return qw/options explanation_entities/;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::Poll - The base class for Telegram 'Poll' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'Poll' type objects

See L<https://core.telegram.org/bots/api#poll> for details of the
attributes available for L<Teapot::Bot::Object::Poll> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
