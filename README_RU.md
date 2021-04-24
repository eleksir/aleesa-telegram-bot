# Aleesa-Telegram-bot - Болтливый бот для Telegram

## Что это такое

Это бот основанный на перловых модулях [Telegram::Bot][1] для работы в
мессенджере Telegram и [Hailo][2] для генерации "умной" беседы.

Для корректной работы пришлось форкнуть [Telegram::Bot][1] чтобы обновить
интерфейс API до [Telegram Bot API v5][3]. Для избежания неоднозначностей модуль
пришлось переименовать и теперь он идёт в составе бота. Возможно, когда модуль
отлежится и будет похож на стабильный, он стнет самостоятельным и поселится на
metacpan.org

Конфиг бота должен лежать в **data/config.json**, пример конфига расположен в
**data/sample_config.json**.

Бота можно запустить через **bin/aleesa-telegram-bot** и он взлетит как юниксовый
демон (сделает двойной fork() и отцепится от stdio).

## Установка

Чтобы запустить приложение, его надо "забурстрапить" - загрузить и собрать все
необходимые зависимости.

Понадобится perl-5.18 а желательно новее, "Development Tools" или подобная
группа пакетов , perl, perl-devel, perl-local-lib, perl-app-cpanm, sqlite-devel,
zlib-devel, openssl-devel, libdb4-devel (Berkeley DB devel), make.

После установки этих пакетов можно будет запустить:

```bash

bash bootstrap.sh

```

и по идее всё что нужно будет выкачено, собрано и разложено куда надо.

## Запуск и работа

Бот не использует [вебхуки][4], поэтому ничего дополнительного, кроме хорошего
подключения к интернету ему не нужно.

### Дополнительные настройки

Некоторые "плагины" требуют регистрации в сторонних сервисах (API keys, secrets
итд), чтобы бот не сыпал ошибками в логи (возможно, в дальнейшем возможно будет
отключить эти плагины).

#### OpenWeatherMap

Для работы погодного плагина надо [заргистрироваться][5], [залогиниться][6] и
[создать][7] api key. Free plan предлагает всё необхдимое для работы "плагина".

Когда api key будет создан, его нужно вписать в **config.json** "секцию"
openweathermap в качестве appid. На этом всё.

#### Imgur

Этот плагин "просто есть" и его на самом деле ничто и никто не использует. И в
этой связи все настройки плагина можно оставить "как есть" в примере конфига.

Тем не менее, если есть большое желание, то можно [залогиниться][8] и
[зарегистрировать][9] бота как приложение, а потом разрешить приложению
пользоваться API-шкой, как описано в [этом][10] или [этом][11] мануале.

#### Flickr

Этот "плагин" действительно используется для добычи ссылок на картинки в разных
"картиночных" командах бота.

Есть скрипт, который поможет с регистрацией приложения в api Flickr -
**bin/flickr_init.pl** он достанет все нужные ключи и секреты к ним.

До запуска этого скрипта, бот должен быть забутстраплен через **`bootstrap.sh`**.

[Залогиньтесь][11] и создайте [app][12] in своём Flicker-овском аккаунте. Далее,
*разлогиньтесь*, это нужно, чтобы потом проще было достать параметр verifier.

Запишите [app key и secret][13] в **config.json**. Удостоверьтесь, что параметр
"verifier" в конфиге либо закоменчен либо отсутствует.

Запустите **bin/flickr_init.pl** и следуте предлагаемым инструкциям - в итоге
будет дана ссылка, которую надо скопипастить в браузер и через один-два
редиректа вы попадёте на example.com. Из адресной строки браузера надо
скопировать параметр "verifier" и вписать его в **config.json**.

Чтобы сохранить в бд плагина API access token для нормальной работы "плагина",
второй раз запустите **bin/flickr_init.pl**. На этом всё.

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