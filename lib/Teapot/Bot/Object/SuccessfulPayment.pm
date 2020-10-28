package Teapot::Bot::Object::SuccessfulPayment;
# ABSTRACT: The base class for Telegram 'SuccessfulPayment' type objects

use Mojo::Base 'Teapot::Bot::Object::Base';
# use Teapot::Bot::Object::OrderInfo;

$Teapot::Bot::Object::SuccessfulPayment::VERSION = '0.021';

has 'currency';
has 'total_amount';
has 'invoice_payload';
has 'shipping_option_id';
# has 'order_info'; #OrderInfo XXX
has 'telegram_payment_charge_id';
has 'provider_payment_charge_id';

sub fields {
  return { scalar => [qw/currency total_amount invoice_payload shipping_option_id
                         telegram_payment_charge_id provider_payment_charge_id/],
       # 'Teapot::Bot::Object::OrderInfo' => [qw/order_info/],

         };
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

Teapot::Bot::Object::SuccessfulPayment - The base class for Telegram 'SuccessfulPayment' type objects

=head1 VERSION

version 0.021

=head1 DESCRIPTION

See L<https://core.telegram.org/bots/api#successfulpayment> for details of the
attributes available for L<Teapot::Bot::Object::SuccessfulPayment> objects.

=head1 AUTHOR

Justin Hawkins <justin@eatmorecode.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2019 by Justin Hawkins.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
