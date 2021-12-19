# Aleesa-Telegram-bot - Telegram chatty bot

## Disclaimer

This version - 3 (something) - considered stable. It means that further
development of new features kind of frosen. Most effort will be targeted to
future 4-th version development. If you have some ideas or fixes to this version
feel free PR them, they will be merged as soon as being reviewed.

## About

It is based on Perl modules [Telegram::Bot][1] and [Hailo][2] as conversation
generator.

I have to fork [Telegram::Bot][1] and update it according to features appeared
in [Telegram Bot API v5][3]. Also, I decide to rename it to avoid collision in
the future, now it is Teapot::Bot and is bundled with bot. When lib becomes
mature enough, maybe I release it separately.

Bot config located in **data/config.json**, sample config provided as
**data/sample_config.json**.

Bot can be run via **bin/aleesa-telegram-bot** and acts as daemon (double fork()
and detaches stdio).

## Installation

In order to run this application, you need to "bootstrap" it - download and build
all required dependencies and libraries.

You'll need perl-5.18 or newer, "Development Tools" or similar group of
packages, perl, perl-devel, perl-local-lib, perl-app-cpanm, sqlite-devel,
zlib-devel, openssl-devel, libdb4-devel (Berkeley DB devel), make.

After installing required dependencies it is possible to run:

```bash

bash bootstrap.sh

```

and all libraries should be downloaded, built, tested and installed.

## Running

This bot does not [ultilize][4] webhooks, so in order to run it only well
internet connection is required, no public-available ip address is needed.

### Additional Settings to be performed in order to run bot as it designed

There are some "plugins" that requires registration on third party services
and API keys and secrets in order to work.

#### OpenWeatherMap

You should [register][5], [login][6] and [create][7] api key. Free plan have
all required features to run this "plugin".

Once key is created you should put it in **config.json** under openweathermap
section as appid. Thats it.

It is still impossible to disable this plugin, but "I'm working on it".

#### Imgur

This plugin "just exists" and is actually used nowhere around the code.
Anyway, to make use of it besides registering appropriate handler in code, you
should sign in imgur and get access token.

Actually at this time this "plugin" can be stub-ed with default config values.

Anyway, to fetch access token you should [login][8] and perform [registration][9]
of your app. Then you should authorize your app according to [this][10] manual. Or
[this][11] one.

#### Flickr

This "plugin" is really used to implement random picture link retrival plugins.

There is helper script in **bin/flickr_init.pl** that helps to get all required keys
and secrets from flickr api.

Before using it bot must be bootstrapped via **`bootstrap.sh`**.

[Login][11] and create an [app][12] in your flickr account. Then *logout* flickr account.
(It is required in order to properly get "verifier" parameter later).

Put your [app key and secret][13] to **config.json**. Ensure that "verifier" parameter
in Flickr-related part of config either absent or commented out.

Run **bin/flickr_init.pl** first time and follow on screen instructions - copy and
paste given link to browser login to flickr account and you'll be redirected to
example.com. Check address bar in browser to get so-called "verifier", put it in
**config.json**. Then run **bin/flickr_init.pl** again to store API access token in db
under data/image directory (in default config). You're done.

[1]: https://metacpan.org/pod/Telegram::Bot
[2]: https://metacpan.org/pod/Hailo
[3]: https://core.telegram.org/bots/api
[4]: https://core.telegram.org/bots/api#getting-updates
[5]: https://home.openweathermap.org/users/sign_up
[6]: https://home.openweathermap.org/users/sign_in
[7]: https://home.openweathermap.org/api_keys
[8]: https://imgur.com/signin
[9]: https://api.imgur.com/oauth2/addclient
[10]: https://apidocs.imgur.com/#authorization-and-oauth
[11]: https://identity.flickr.com/login
[12]: https://www.flickr.com/services/apps/create/apply/
[13]: https://www.flickr.com/services/api/keys/
