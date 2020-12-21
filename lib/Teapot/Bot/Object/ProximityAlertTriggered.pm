package Teapot::Bot::Object::ProximityAlertTriggered;
# ABSTRACT: The base class for Telegram message 'ProximityAlertTriggered' type.

use Mojo::Base 'Teapot::Bot::Object::Base';

$Teapot::Bot::Object::ProximityAlertTriggered::VERSION = '0.022';

has 'traveler'; # User
has 'watcher'; # User
has 'distance';

sub fields {
  return {
    'Teapot::Bot::Object::User' => [qw/traveler watcher/],
    'scalar'                    => [qw/distance/],
  };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::ProximityAlertTriggered - The base class for Telegram message 'ProximityAlertTriggered' type

=head1 VERSION

version 0.022

=head1 DESCRIPTION
The base class for Telegram message 'ProximityAlertTriggered' type.

See L<https://core.telegram.org/bots/api#proximityalerttriggered> for details of the
attributes available for L<Teapot::Bot::Object::ProximityAlertTriggered> objects.

=head1 AUTHOR

Sergei Fedosov <eleksir@gmail.com>

=head1 LICENSE AND COPYRIGHT

This software is copyright (c) 2020 Sergei Fedosov <eleksir@gmail.com>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
