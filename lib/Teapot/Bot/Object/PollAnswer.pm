package Teapot::Bot::Object::PollOption;
# ABSTRACT: The base class for Telegram 'PollOption' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::PollOption::VERSION = '0.022';

has 'poll_id';
has 'user';
has 'option_ids';

sub fields {
  return {
    'scalar'                    => [qw/poll_id option_ids/],
    'Teapot::Bot::Object::User' => [qw/user/],
  };
}

sub arrays {
  return qw/option_ids/;
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::PollOption - The base class for Telegram 'PollOption' type objects

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram 'PollOption' type objects.

See L<https://core.telegram.org/bots/api#polloption> for details of the
attributes available for L<Teapot::Bot::Object::PollOption> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2020 Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
