package Teapot::Bot::Object::PollOption;
# ABSTRACT: The base class for Telegram 'PollOption' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::PollOption::VERSION = '0.021';

has 'text';
has 'voter_count';

sub fields {
  return { scalar  => [qw/text voter_count/] };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::PollOption - The base class for Telegram 'PollOption' type objects

=head1 VERSION

version 0.021

=head1 DESCRIPTION
The base class for Telegram 'PollOption' type objects.

See L<https://core.telegram.org/bots/api#polloption> for details of the
attributes available for L<Teapot::Bot::Object::PollOption> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
