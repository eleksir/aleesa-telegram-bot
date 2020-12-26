package archeologist;

use 5.018;
use strict;
use warnings;
use utf8;
use open qw(:std :utf8);
use English qw( -no_match_vars );

use vars qw/$VERSION/;
use Exporter qw(import);
our @EXPORT_OK = qw(dig);
$VERSION = '1.0';

sub dig {
	my $name = shift;

	my @artifact = (
		'амулет Мерлина',
		'библиотеку Ивана Грозного',
		'деревянную плошку',
		'диплока',
		'доски Ноева Ковчега',
		'древний презерватив из бараньей кишки',
		'икону',
		'инсталятор Windows 3.11',
		'истлевший гроб',
		'каменный топор',
		'клад со златом-серебром',
		'кривой нож',
		'ледяную глыбу',
		'лунный грунт',
		'мамонта',
		'мамонтенка',
		'метеорит',
		'мумию фараона Тутанхамона',
		'носки прапорщика (поставит в угол)',
		'обломки грузинской керамики',
		'птеродактиля',
		'рубль с Лениным',
		'рыцарские доспехи',
		'синий мох',
		'скелет',
		'скелет собаки по кличке Беня',
		'тиранозавтра',
		'тотем индейцев',
		'трубу с туркменским газом',
		'скорбь еврейского народа',
		'залежи активированного угля',
		'не очень новый завет',
		'мать леннарта поттеринга',
		'руководство "начинающему археологу"',
		'слово о полку игореве и дело о полку игореве, вместе с игорем',
		'телепрограмму канала A-one',
		'могилу искателя могил',
		'заплесневевший кусок хлеба',
		'преемник радиоприемника',
		'глушитель от ВАЗ-2106',
		'чувство удовлетворения',
		'крота',
		'воспоминания о былой любви',
		'грязистор',
		'египетское мумиё',
		'окаменелый камень',
		'кладку яиц рептилоида',
		'яму',
		'чеснок и стрелы',
		'доллар по 30',
		'несмазанные скрижали',
		'четырелобита',
		'чучело тролля',
		'целое ничего',
	);

	my @location = (
		'в архивах',
		'в гималаях',
		'в интернете',
		'в кармане',
		'в клумбе',
		'в лунном кратере',
		'во льдах арктики',
		'в морге',
		'в окрестностях погоста',
		'в песочнице',
		'в пустыне Гоби',
		'в пустыне Сахаре',
		'в русле высохшей реки',
		'в собственной памяти',
		'в старом сортире',
		'в углу',
		'в цветочном горшке',
		'на бабушкином огороде',
		'на винчестере',
		'на горе Арарат',
		'на горном плато',
		'на дне моря',
		'на необитаемом острове',
		'на первом слое сумрака',
		'на просторах Украины',
	);

	my $find_probability = int (rand 100);
	my $success_probability = int (rand 100);
	my $artifact_age = int (rand 15000);

	if ($find_probability <= 20) {
		return sprintf 'По уши закопавшись %s, %s, нифига вы не выкопали! Может повезет в другом месте?', $location[int (rand ($#location + 1))], $name;
	}

	my $phrase = sprintf "Вы начали раскопки %s и усиленно роете лопатами, экскаватором...\n", $location[int (rand ($#location + 1))];
	$phrase .= "Вам кажется что ваш совочек ударился обо что-то твердое. Может, это клад?!\n\n";

	if ($success_probability <= 20) {
		$phrase .= sprintf '%s стал лучшим археологом, выкопав %s! возраст артефакта - %s лет!', $name, $artifact[int (rand ($#artifact + 1))], $artifact_age;
	} else {
		$phrase .= sprintf "Поздравляю, %s! Вы только что выкопали %s, возраст - %s лет!\n", $name, $artifact[int (rand ($#artifact + 1))], $artifact_age;
		$phrase .= sprintf 'Извини %s, но на артефакт это не тянет! Однако, попытка хорошая!', $name;
	}

	return $phrase;
}

1;

# vim: set ft=perl noet ai ts=4 sw=4 sts=4:
