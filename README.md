# Aleesa-Telegram-bot - Simple Telegram chatty bot

## About

It is based on Perl modules [Telegram::Bot][1] and [Hailo][2] as conversation
generator.

Config located in **data/config.json**, sample config provided as
**data/sample_config.json**.

Bot can be run via **bin/aleesa-telegam-bot** and acts as daemon.

## Installation

In order to run this application, you need to "bootstrap" it - download all
dependencies and libraries.

You'll need "Development Tools" or similar group of packages, perl, perl-devel,
perl-local-lib, perl-app-cpanm, sqlite-devel, zlib-devel, openssl-devel,
libdb4-devel (Berkeley DB devel), make.

After installng required dependencies it is possible to run:

```bash
bash bootstrap.sh
```

and all libraries should be downloaded and built.

## N.B.

If bot is unable to post to channel due to limitated permissions, it will die.
It if possible to change this behavior by patching Telegram/Bot/Brain.pm:

```diff
--- Brain.pm	2019-07-01 04:04:17.000000000 +0300
+++ Brain.pm.new	2020-09-05 22:25:20.941373455 +0300
@@ -237,8 +237,9 @@
 
   my $res = $self->ua->post($url, form => $form_args)->result;
   if    ($res->is_success) { return $res->json->{result}; }
-  elsif ($res->is_error)   { die "Failed to post: " . $res->message; }
-  else                     { die "Not sure what went wrong"; }
+  elsif ($res->is_error)   { warn "Failed to post: " . $res->message; }
+  else                     { warn "Not sure what went wrong"; }
+  return "";
 }
```

[1]: https://metacpan.org/pod/Telegram::Bot
[2]: https://metacpan.org/pod/Hailo
