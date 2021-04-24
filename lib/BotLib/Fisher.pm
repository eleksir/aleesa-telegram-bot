package BotLib::Fisher;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw (:std :utf8);
use English qw ( -no_match_vars );
use Math::Random::Secure qw (irand);

use version; our $VERSION = qw (1.0);
use Exporter qw (import);
our @EXPORT_OK = qw (Fish);


sub Fish {
	my $name = shift;

	my @artifact = (
		'семикрылого чешуйчатого пятихуя',
		'разумного конденсатора',
		'сальмонеллу',
		'селёдку',
		'желтоперого тунца',
		'розовую сальмонеллу',
		'голавля',
		'барбуса',
		'окуня',
		'верхоплавку',
		'коричневую форель',
		'полярника',
		'плотву',
		'зубатку',
		'солнечную рыбу',
		'старую шину',
		'скользкую корягу',
		'лампу джина',
		'любовное послание в бутылке',
		'старое бревно',
		'резиновый сапог',
		'труп',
		'Лох-Несское чудовище',
		'старую рыбацкую приманку',
		'кусок Титаника',
		'обломок Атлантиды',
		'кита',
		'кальмара',
		'дельфина',
		'ската',
		'подводную лодку',
		'медузу',
		'морскую звезду',
		'электрического угря',
		'большую белую акулу',
		'аквалангиста',
		'монстра',
		'вируса',
		'сырую пачку сигарет',
		'водоросли',
		'якорь от лодки',
		'водяного',
		'русалку',
		'палтуса',
		'труп собаки по кличке Беня',
		'олигофрена Проню',
		'огеймера Фишкина',
	);

	my @location = (
		'в поток',
		'в озеро',
		'в реку',
		'в северный ледовитый океан',
		'в индийский океан',
		'в биде',
		'в детский плавательный бассейн',
		'в туалет',
		'в кучу рвоты',
		'в лужу мочи',
		'в раковину',
		'в слив ванной',
		'в лужу грязи',
		'в ведро воды',
		'в бутылку с водкой',
		'в ванную',
		'в бочку с дождевой водой',
		'в аквариум',
		'в сугроб',
		'в водопад',
		'в чашку кофе',
		'в стакан молока',
		'в черную дыру',
		'дно Удомельского реактора',
		'на Марс',
		'в соседнюю галактику',
		'к соседу на балкон',
		'далеко-далеко',
		'далеко и надолго',
		'на крышу дома',
	);

	my @material = (
		'бамбуковую',
		'фибергласовую',
		'карбоновую',
		'композитную',
	);

	my $find_probability = irand 100;
	my $success_probability = irand 100;
	my $weight = irand 7000;

	my $phrase = sprintf "Вы забрасываете %s удочку %s.\nВы чувствуете поклёвку и начинаете быстро тащить что-то.\n", $material[irand ($#material + 1)], $location[irand ($#location + 1)];

	if ($find_probability <= 20) {
		$phrase .= sprintf 'Черт, твоя рыбка сорвалась, %s! Не беда, может потом повезет?', $name;
		return $phrase;
	}

	$phrase .= sprintf "Поздравляю, %s! Вы только что поймали %s! аж на %d кило!\n\n", $name, $artifact[irand ($#artifact + 1)], $weight;

	if ($success_probability <= 25) {
		$phrase .= sprintf 'Ё-мое!!! А это ведь новый рекорд! Продолжай в том же духе, %s!', $name;
	} else {
		$phrase .= sprintf 'Извини, %s, но это не новый рекорд! Однако, хорошая попытка!', $name;
	}

	return $phrase;
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4: