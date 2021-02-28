# Aleesa-Telegram-bot - Telegram chatty bot

## About

It is based on Perl modules [Telegram::Bot][1] and [Hailo][2] as conversation
generator.

I have to fork [Telegram::Bot][1] and add some of new methods that are already
appear in [Telegram API][3], but author seems to abandon lib. Also, I decide to
rename it to avoid collision in the future, now it is Teapot::Bot and is bundled
with bot. When lib become mature enough, maybe I release it separately.

Bot config located in **data/config.json**, sample config provided as
**data/sample_config.json**.

Bot can be run via **bin/aleesa-telegram-bot** and acts as daemon.

## Installation

In order to run this application, you need to "bootstrap" it - download and build
all required dependencies and libraries.

You'll need "Development Tools" or similar group of packages, perl, perl-devel,
perl-local-lib, perl-app-cpanm, sqlite-devel, zlib-devel, openssl-devel,
libdb4-devel (Berkeley DB devel), make.

After installing required dependencies it is possible to run:

```bash
bash bootstrap.sh
```

and all libraries should be downloaded, built, tested and installed.

[1]: https://metacpan.org/pod/Telegram::Bot
[2]: https://metacpan.org/pod/Hailo
[3]: https://core.telegram.org/bots/api