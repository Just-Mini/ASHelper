script_name('AS Helper')
script_description('Удобный помощник для Автошколы.')
script_author('JustMini')
script_version_number(44)
script_version('2.7')
script_dependencies('imgui; samp events; lfs')

require 'moonloader'
local dlstatus					= require 'moonloader'.download_status
local inicfg					= require 'inicfg'
local vkeys						= require 'vkeys'
local imguicheck, imgui			= pcall(require, 'imgui')
local sampevcheck, sampev		= pcall(require, 'lib.samp.events')
local encodingcheck, encoding	= pcall(require, 'encoding')
local lfscheck, lfs 			= pcall(require, 'lfs')

local ScreenX, ScreenY 			= getScreenResolution()

local lections 					= {}
local questions					= {}
local ruless					= {}
local dephistory				= {}

local default_questions = {
	active = { redact = false },
	questions = {
		{bname = 'Рабочее время в будние дни',bq = 'Назовите время дневной смены в будние дни.',bhint = '09:00 - 19:00'},
		{bname = 'Рабочее время в выходные дни',bq = 'Назовите время дневной смены в выходные дни.',bhint = '10:00 - 18:00'},
		{bname = 'Кнопка вызова полиции без причины',bq = 'Какое наказание получает сотрудник за ложное нажатие кнопки вызова полиции?',bhint = 'выговор'},
		{bname = 'Использование транспорта',bq = 'С какой должности разрешено брать автомобили, мотоциклы и вертолёт?',bhint = '(3+) Лицензёр - мото, (4+) Мл.Инструктор - авто, (8+) Зам. директора - вертолёт'},
		{bname = 'Должность для отпуска',bq = 'Скажите, с какой должности разрешено брать отпуск?',bhint = '(5+) Инструктор'},
		{bname = 'Время сна вне раздвелки',bq = 'Максимально допустимое время сна вне раздевалки?',bhint = '5 минут максимально, за этим последует выговор.'},
		{bname = 'Что такое субординация',bq = 'Что по вашему мнению означает слово \'Субординация\'?',bhint = 'cубординация - это правила общения между сотрудниками, разными по должности.'},
		{bname = 'Обращения к другим сотрудникам',bq = 'Такой вопрос, какие обращения допускаются к другим сотрудникам автошколы?',bhint = 'Подсказка: по должности, по имени, \'Сэр\' и \'Коллега\'.'},
	}
}

local default_lect = {
	active = { bool = false, name = nil, handle = nil },
	data = {
		{
			name = 'Правила дорожного движения',
			text = {
				'Дорогие сотрудники, сейчас я проведу лекцию на тему Правил Дорожного Движения.',
				'Водитель должен пропускать пешеходов в специальных местах для перехода.',
				'Водителю запрещается нарушать правила дорожного движения предписанные на офф.портале.',
				'Сотрудники нарушившие ПДД будут наказаны в виде выговора, в худшем случае - увольнение.',
				'Все мы хотим вернуться после работы домой здоровыми и невредимыми...',
				'Спасибо за внимание, лекция окончена.'
			}
		},
		{
			name = 'Субординация в Автошколе',
			text = {
				'Дорогие сотрудники! Минуточку внимания.',
				'Прошу Вас соблюдать Субординацию в Автошколе...',
				'К старшим по должности необходимо обращаться на \'Вы\'.',
				'Также , запрещено нецензурно выражаться , и оскорблять сотрудников...',
				'За такие поступки , будут выдаваться выговоры.',
				'Благодарю за внимание!',
				'Прошу не нарушать Субординацию.'
			}
		},
		{
			name = 'Запреты в рацию',
			text = {
				'Сейчас я расскажу вам лекцию на тему \'Запреты в рацию\'.',
				'Хочу напомнить Вам о том, что в рацию запрещено...',
				'торговать домами, автомобилями, бизнесами и т.п.',
				'Так же в рацию нельзя материться и выяснять отношения между собой.',
				'За данные нарушения у Вас отберут рацию. При повторном нарушении Вы будете уволены.',
				'Спасибо за внимание. Можете продолжать работать.'
			}
		},
		{
			name = 'Основные правила Автошколы',
			text = {
				'Cейчас я проведу лекцию на тему \'Основные правила Автошколы\'.',
				'Сотрудникам автошколы запрещено прогуливать рабочий день.',
				'Сотрудникам автошколы запрещено в рабочее время посещать мероприятия.',
				'Сотрудникам автошколы запрещено в рабочее время посещать казино.',
				'Сотрудникам автошколы запрещено в рабочее время посещать любые подработки.',
				'Сотрудникам автошколы запрещено носить при себе огнестрельное оружие.',
				'Сотрудникам автошколы запрещено курить в здании автошколы.',
				'Сотрудникам автошколы запрещено употреблять алкогольные напитки в рабочее время.',
				'На этом у меня всё, спасибо за внимание.'
			}
		},
		{
			name = 'Рабочий день',
			text = {
				'Уважаемые сотрудники, минуточку внимания!',
				'Сейчас я проведу лекцию на тему Рабочий день.',
				'Сотрудники в рабочее время обязаны находиться в офисе автошколы в форме.',
				'За прогул рабочего дня сотрудник получит выговор или увольнение.',
				'С понедельника по пятницу рабочий день с 9:00 до 19:00.',
				'В субботу и воскресенье рабочий день с 10:00 до 18:00.',
				'В не рабочее время или в обед сотрудник может покинуть офис Автошколы.',
				'Но перед этим обязательно нужно снять форму.',
				'Обед идёт с 13:00 до 14:00.',
				'На этом у меня всё, спасибо за внимание.'
			}
		}
	}
}

local default_rules = {
	{
		name = 'Правила гос. структур',
		text = {
			'{FF0000}Кадровая система',
			'[1 - 4 Ранги] - {00FF00}[Отсутствует]',
			'[5 Ранг] - {FF9900}[3 Суток]',
			'[6 Ранг] - {FF9900}[4 Суток]',
			'[7 Ранг] - {FF5500}[6 Дней]',
			'[8 Ранг] - {FF5500}[8 Дней]',
			'[9 Ранг] - {FF1100}[15 Дней]',
			'{FF1100}Если человек не отстоял исполнительный срок и был уволен/ушел ПСЖ - Занесение в ЧС красной степени.',
			' ',
			'{FF0000}Норма АФК',
			'Норма АФК для Министра/Лидера/Заместителя составляет 10 минут [600 секунд] | Наказание: устное/строгое',
			'предупреждение и кик.',
			'Норма АФК для Ст.состава [5-8 ранг] составляет 15 минут [900 секунд] | Наказание: Выговор в личное дело/кик.',
			'Норма АФК для Мл.состава [1-4 ранг] составляет 30 минут [1800 секунд] | Наказание: Увольнение.',
			' ',
			'{FF0000}Ограничение по рангам',
			'9 ранг - 3 человека',
			'8 ранг - 4 человека',
			' ',
			'{FF0000}Тэги в /d чат и /gov',
			'Центральный Банк г. Лос-Сантос - [Банк]',
			'Правительство Штата - [Правительство]',
			'Государственная АвтоШкола г. Сан-Фиерро - [Автошкола]',
			' ',
			'Федеральное Бюро Расследований - [ФБР]',
			'Полиция г. Лос-Сантос - [Полиция ЛС]',
			'Полиция г. Сан-Фиерро - [Полиция СФ]',
			'Полиция округа Ред Каунти - [Областная Полиция]',
			'Полиция г. Лас-Вентурас - [Полиция ЛВ]',
			' ',
			'Армия г. Лос-Сантос - [Армия ЛС]',
			'Армия г. Сан-Фиерро - [ВМС]',
			' ',
			'Тюрьма Строгого Режима',
			'Тюрьма Строгого Режима г.Las-Venturas - [Тюрьма ЛВ]',
			'',
			'Больница г. Лос-Сантос - [Больница ЛС]',
			'Больница г. Сан-Фиерро - [Больница СФ]',
			'Больница г. Лас-Вентурас - [Больница ЛВ]',
			' ',
			'Страховая компания - [СК]',
			' ',
			'{FF0000}Система переводов',
			'Переводы внутри Центрального Аппарата происходят со всех фракций данного Министерства.',
			'Можно перевестись из Правительства в Автошколу и обратно, из Автошколы в Центральный Банк и обратно,',
			'из Центрального Банка в Правительство и обратно.',
			' ',
			'Переводы осуществляются по системе:',
			'Перевод из Автошколы и Центрального банка в Правительство -2 ранга от нынешнего.',
			'Перевод из Правительства в Автошколу и Центральный банк -1 ранг от нынешнего.',
			'Переводы из Автошколы в Центральный банк и наоборот -1 ранг от нынешнего.',
			' ',
			'Перевестись в Центральный Аппарат из других министерств и из него в другие министерства - нельзя.'
		}
	},
	{
		name = 'Устав автошколы',
		text = {
		'Глава I. Общее положение.',
		'1.1. Данный документ обязан знать и соблюдать каждый сотрудник Автошколы.',
		'1.2. За нарушения одного из пунктов данного документа последует наказание.',
		'1.3. Незнание устава не освобождает от ответственности.',
		'1.4. Сотрудники старшего состава [5-9] должны следить за порядком и дисциплиной в Автошколе.',
		'1.5. Каждый сотрудник должен знать свои рабочие обязанности на каждой должности.',
		'1.6.Каждый сотрудник обязан соблюдать субординацию.',
		'1.7. Решение Управляющего является окончательным и обжалованию не подлежит.',
		'1.8. Устав может исправляться/дополняться Управляющим автошколы.',
		'1.9 Сотрудники Автошколы обязаны отвечать на задаваемые посетителями вопросы.',
		'1.10 Курирующим составом являются Управляющий и Директора.',
		'1.11 Если сотрудник уходит с должности \'Стажер [1]\', он получат ЧС АШ.',
		'1.12 Сотруднк который уходит [ПСЖ] с любой должностью , имеющий 1 или более выговоров заносится в [ЧС] Авто-Школы',
		' ',
		'Глава II. Этикет и субординация.',
		' ',
		'2.1 Правила этикета - это свод правил поведения, принятых в определенных социальных кругах.',
		'2.2 Субординация - это правила общения между сотрудниками, разными по должности.',
		'2.3 Все сотрудники должны уважительно относиться ко всем окружающим их людям.',
		'2.4 Сотрудник обязан уважать людей, которые ниже его по должности.',
		'2.5 Допускаются обращение по должности, имени, \'сэр\', \'коллега\'.',
		'2.6 Каждый работник автошколы обязан представиться перед клиентом.',
		'2.7 Любой сотрудник автошколы обязан быть вежливым несмотря на поведение клиента.',
		' ',
		'Глава III. Правила пользования т/с Автошколы.',
		' ',
		'3.1 Правила пользования т/с должны соблюдать все сотрудники Автошколы.',
		'3.2 Т/с разрешено брать по следующему принципу:',
		'а) Лицензер[3] - мотоцикл;',
		'б) 4-7 ранги - автомобиль;',
		'в) Зам. Директора и выше - вертолет.',
		'3.3 Запрещено использовать служебный транспорт в своих целях.',
		'3.4 Запрещено использовать служебный транспорт вне рабочего дня, исключение: можно использовать для тренировок и т.п.',
		'3.5 Запрещено использовать служебный транспорт, не предупредив об этом руководство.',
		' ',
		'Глава IV. Рабочий график.',
		' ',
		'4.1 Рабочее время (Понедельник-Пятница):',
		'4.1.1 Дневная смена с 09:00 до 19:00',
		'4.1.2 Перерыв на обед - с 13:00 до 14:00',
		'4.1.3 Ночная смена с 20:00 до 8:00',
		'4.1.4 Рабочее время (Суббота-Воскресенье):',
		'4.1.5 Дневная смена с 10:00 до 18:00',
		'4.1.6 Перерыв на обед - с 13:00 до 14:00',
		'4.1.7 Ночная смена с 19:00 до 9:00',
		'4.2 Каждый сотрудник Автошколы должен находиться в Автошколе во время рабочего времени.',
		'4.3 Покидать здание разрешено только с разрешением старших. ( если их нет в штате - доложить по рации и сделать*screenshot + /time* )',
		'4.4 За прогулы в рабочее время сотрудник получит выговор, либо же будет уволен.',
		'4.5 По окончанию дневной смены все сотрудники должны сдать форму кроме тех, кто остается на ночную смену.',
		'4.6 Посещение ночной смены не является обязательным, но оно будет поощряться.',
		' ',
		'Глава V. Обязанности сотрудников Автошколы.',
		' ',
		'5.1 Каждый сотрудник обязан соблюдать и знать устав Автошколы.',
		'5.2 Каждый сотрудник должен соблюдать субординацию в общении.',
		'5.3 Каждый сотрудник обязан слушаться своего непосредственного руководителя.',
		'5.4 Каждый сотрудник должен знать руководящий состав в лицо и по имени.',
		'5.5 Директора и их заместители обязаны отчитываются о своей недельной работе при желании Управляющего.',
		'5.6 Каждый сотрудник обязан соблюдать законодательство Штата.',
		'5.7 Каждый сотрудник АвтоШколы обязан качественно выполнять свою поставленную работу.',
		'5.8 Сотрудники обязаны подчиниться сотрудникам правоохранительной власти, при теракте или ограблении.',
		'5.9 Сотрудники должны содействовать органам правоохранительной власти.',
		'5.10 Сотрудники АвтоШкола, начиная с должности \'Консультант\'[2] обязаны иметь спец. рацию \'Discord\'.',
		'5.11 Сотрудники старшего состава обязаны обучать и помогать сотрудникам, младше их по должности.',
		'5.12 Сотрудники старшего состава должны посещать еженедельные собрания, неявка карается выговором.',
		' ',
		'Глава VI. Отпуск и неактив.',
		' ',
		'6.1 Отпуск разрешено брать с должности \'Инструктор[5]\'.',
		'6.2 Сотрудник имеет право подать заявку на получение отпуска за проделанные отчёты за неделю.',
		'6.3 Отпуск возможно взять максимум на 5 календарных дней.',
		'6.4 Если сотрудник не вернулся с отпуска в назначенное время, он будет уволен, без права восстановления не зависимо от занимаемой должности.',
		'6.5 Во время неактива разрешено не заходить в игру.',
		'6.6 Неактив можно брать максимум на 5 дней ( для заместителей 3 дня ).',
		'6.7 Дни неактива не будут браться в учет в рассмотрении отчета.',
		'6.8 Неактив можно взять два раза за срок Управляющего.',
		'6.9 Несвоевременный выход из неактива без предупреждения может караться выговором и увольнением.',
		' ',
		'Глава VII. Запреты и права для сотрудников Автошколы.',
		' ',
		'7.1 Сотрудник не имеет право нарушать устав и законодательство Штата.',
		'7.2 Сотрудникам запрещено во время раб. дня носить яркие акксесуары // закрывающие лицо ( маски, шлемы, банданы , амулет ).',
		'7.3 Запрещено спать вне раздевалки более 5-и минут. ( Искл.: 10 минут для Зама / Директора )',
		'7.4 Запрещено спать за стойкой более 2-х минут - выговор.',
		'7.5 Сотрудники не имеют право уходить на обед, пока не обслужат людей, которые стоят в очереди.',
		'7.6 Сотрудники не имеют право во время рабочего дня носить одежду не по дресс-коду.',
		'7.7 Сотрудникам запрещено курить, пить, есть во время рабочего дня.',
		'7.8 Запрещено неадекватное поведение в здании автошколы.',
		'7.9 Сотруднику категорически запрещено хранить/употреблять/переносить психотропные вещества.',
		'7.10 Сотрудникам запрещено ловить дома в рабочее время.',
		'7.11 Сотруднику автошколы запрещено намекать/выпрашивать повышение.',
		'7.12 Сотрудникам старшего состава запрещено проводить тренировки и лекции чаще, чем раз в 30 минут.',
		'7.13 Запрещено подкидывать диалоги выдачи лицензий клиентам. - Увольнение',
		'7.14 Носить огнестрельное оружие на территории автошколы - выговор.',
		'7.15 Запрещено иметь связи с нелегальными организациями - увольнение.',
		' ',
		'Примечание: Управляющий и его Директора могут выдавать наказание на свое усмотрение, от устного предупреждения до Черного Списка Автошколы.',
		' ',
		'Глава VIII. Прочие правила.',
		' ',
		'8.1 Выговоры снимаются только за выполнение заданий, а так же за штрафную выплату на счет организации.',
		'8.2 Халатное оформление лицензий - наказуемо.',
		'8.3 Нажатие на кнопку вызова полиции без особой причины - выговор.',
		'8.4 Если сотрудника Автошколы нет в штате более 5 дней, то он будет уволен без дальнейшего восстановления.',
		' ',
		'Глава IX. Обязанности и права директора.',
		'9.1 Директор является официальной правой рукой Управляющего.',
		'9.2 Директор имеет право выступать на мероприятиях от имени Управляющего.',
		'9.3 Директор - главное руководящее лицо в Авто-Школу пока Управляющего нету в Штате.',
		'9.4 Директор является куратором всех отделов, то есть имеет полное право снимать глав отделов и назначать новых.',
		'9.5 Директор имеет право на выдачу выговоров Заместителям Директора.',
		'9.6 Директор имеет право выдвинуть Директора на процедуру снятия со своей должности. Окончательное решение принимает Управляющий.',
		'9.7 Директор обязан подчиняться только указам Управляющего и Сенаторов Штата, а так же ФБР и Губернатору.',
		' ',
		'Глава X. OOC (Out Of Character).',
		' ',
		'10.1 Запрещено нарушать действующие правила сервера.',
		'10.2 Сотрудник автошколы обязан соблюдать RolePlay режим, в зависимости от ситуации.',
		'10.3 Запрещено стоять AFK без Esc на сердечке около кулера.',
		'10.4 Запрещена NonRP работа с клиентами.',
		'10.5 Запрещен flood, offtop, MG, DM.',
		'10.6 Запрещены оскорбления в NonRP чатах'}
	}
}

local configuration = inicfg.load({
	main_settings = {
		myrankint = 1,
		gender = 0,
		style = 0,
		rule_align = 1,
		lection_delay = 10,
		myname = '',
		myaccent = '',
		astag = 'Автошкола',
		expelreason = 'Н.П.А.',
		useservername = true,
		useaccent = false,
		createmarker = false,
		dorponcmd = true,
		replacechat = true,
		dofastscreen = true,
		noscrollbar = true,
		playdubinka = true,
		changelog = true,
		usefastmenu = 'E',
		fastscreen = 'F4',
		avtoprice = 5000,
		motoprice = 10000,
		ribaprice = 30000,
		lodkaprice = 30000,
		gunaprice = 50000,
		huntprice = 100000,
		kladprice = 200000,
		taxiprice = 250000,
		RChatColor = 4282626093,
		DChatColor = 4294940723,
		ASChatColor = 4281558783
	},
	imgui_pos = {
		posX = 100,
		posY = 300
	},
	my_stats = {
		avto = 0,
		moto = 0,
		riba = 0,
		lodka = 0,
		guns = 0,
		hunt = 0,
		klad = 0,
		taxi = 0
	},
	RankNames = {
		'Стажёр',
		'Консультант',
		'Лицензёр',
		'Мл.Инструктор',
		'Инструктор',
		'Менеджер',
		'Ст. Менеджер',
		'Помощник директора',
		'Директор',
		'Управляющий',
	},
	BindsName = {},
	BindsDelay = {},
	BindsType = {},
	BindsAction = {},
	BindsCmd = {},
	BindsKeys = {}
}, 'AS Helper')

-- fAwesome5
	local fa = {
		['ICON_FA_USER_COG'] = '\xef\x93\xbe',
		['ICON_FA_FILE_ALT'] = '\xef\x85\x9c',
		['ICON_FA_KEYBOARD'] = '\xef\x84\x9c',
		['ICON_FA_PALETTE'] = '\xef\x94\xbf',
		['ICON_FA_BOOK_OPEN'] = '\xef\x94\x98',
		['ICON_FA_INFO_CIRCLE'] = '\xef\x81\x9a',
		['ICON_FA_SEARCH'] = '\xef\x80\x82',
		['ICON_FA_ALIGN_LEFT'] = '\xef\x80\xb6',
		['ICON_FA_ALIGN_CENTER'] = '\xef\x80\xb7',
		['ICON_FA_ALIGN_RIGHT'] = '\xef\x80\xb8',
		['ICON_FA_TRASH'] = '\xef\x87\xb8',
		['ICON_FA_REDO_ALT'] = '\xef\x8b\xb9',
		['ICON_FA_LOCK'] = '\xef\x80\xa3',
		['ICON_FA_COMMENT_ALT'] = '\xef\x89\xba',
		['ICON_FA_HAND_PAPER'] = '\xef\x89\x96',
		['ICON_FA_FILE_SIGNATURE'] = '\xef\x95\xb3',
		['ICON_FA_REPLY'] = '\xef\x8f\xa5',
		['ICON_FA_USER_PLUS'] = '\xef\x88\xb4',
		['ICON_FA_USER_MINUS'] = '\xef\x94\x83',
		['ICON_FA_EXCHANGE_ALT'] = '\xef\x8d\xa2',
		['ICON_FA_USER_SLASH'] = '\xef\x94\x86',
		['ICON_FA_USER'] = '\xef\x80\x87',
		['ICON_FA_FROWN'] = '\xef\x84\x99',
		['ICON_FA_SMILE'] = '\xef\x84\x98',
		['ICON_FA_VOLUME_MUTE'] = '\xef\x9a\xa9',
		['ICON_FA_VOLUME_UP'] = '\xef\x80\xa8',
		['ICON_FA_STAMP'] = '\xef\x96\xbf',
		['ICON_FA_ELLIPSIS_V'] = '\xef\x85\x82',
		['ICON_FA_ARROW_UP'] = '\xef\x81\xa2',
		['ICON_FA_ARROW_DOWN'] = '\xef\x81\xa3',
		['ICON_FA_ARROW_RIGHT'] = '\xef\x81\xa1',
		['ICON_FA_SPINNER'] = '\xef\x84\x90',
		['ICON_FA_TERMINAL'] = '\xef\x84\xa0',
		['ICON_FA_CLOUD_DOWNLOAD_ALT'] = '\xef\x8e\x81',
		['ICON_FA_LAYER_GROUP'] = '\xef\x97\xbd',
		['ICON_FA_LINK'] = '\xef\x83\x81',
		['ICON_FA_CAR'] = '\xef\x86\xb9',
		['ICON_FA_MOTORCYCLE'] = '\xef\x88\x9c',
		['ICON_FA_FISH'] = '\xef\x95\xb8',
		['ICON_FA_SHIP'] = '\xef\x88\x9a',
		['ICON_FA_CROSSHAIRS'] = '\xef\x81\x9b',
		['ICON_FA_SKULL_CROSSBONES'] = '\xef\x9c\x94',
		['ICON_FA_ARCHIVE'] = '\xef\x86\x87',
		['ICON_FA_PLUS_CIRCLE'] = '\xef\x81\x95',
		['ICON_FA_PAUSE'] = '\xef\x81\x8c',
		['ICON_FA_PEN'] = '\xef\x8c\x84',
		['ICON_FA_TIMES'] = '\xef\x80\x8d',
		['ICON_FA_QUESTION_CIRCLE'] = '\xef\x81\x99',
		['ICON_FA_MINUS_SQUARE'] = '\xef\x85\x86',
		['ICON_FA_CLOCK'] = '\xef\x80\x97',
		['ICON_FA_COG'] = '\xef\x80\x93',
		['ICON_FA_TAXI'] = '\xef\x86\xba',
	}
	
	setmetatable(fa, {
		__call = function(t, v)
			if (type(v) == 'string') then
				return t['ICON_' .. v:upper()] or '?'
			elseif (type(v) == 'number' and v >= 0xf000 and v <= 0xf83e) then
				local t, h = {}, 128
				while v >= h do
					t[#t + 1] = 128 + v % 64
					v = math.floor(v / 64)
					h = h > 32 and 32 or h / 2
				end
				t[#t + 1] = 256 - 2 * h + v
				return string.char(unpack(t)):reverse()
			end
			return '?'
		end,
	
		__index = function(t, i)
			if type(i) == 'string' then
				if i == 'min_range' then
					return 0xf000
				elseif i == 'max_range' then
					return 0xf83e
				end
			end
		
			return t[i]
		end
	})
-- fAwesome5

-- rkeys
	function keybindactivation(numb)
		local temp = 0
		local temp2 = 0
		for _ in tostring(configuration.BindsAction[numb]):gmatch('[^~]+') do
			temp = temp + 1
		end
		inprocess = true
		for bp in tostring(configuration.BindsAction[numb]):gmatch('[^~]+') do
			temp2 = temp2 + 1
			if not bp:find('%{delay_(%d+)%}') then
				sampSendChat(tostring(bp))
				if temp2 ~= temp then
					wait(configuration.BindsDelay[numb])
				end
			else
				local delay = bp:match('%{delay_(%d+)%}')
				wait(delay)
			end
		end
		inprocess = false
	end
--rkeys

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(1000) end

	local checking = checkbibl()
	while not checking do
		wait(200)
	end
	if not checkServer(select(1, sampGetCurrentServerAddress())) then
		ASHelperMessage('Скрипт работает только на серверах Arizona RP. Скрипт выгружен.')
		NoErrors = true
		thisScript():unload()
	end
	if not doesFileExist('moonloader/config/AS Helper.ini') then
		if inicfg.save(configuration, 'AS Helper.ini') then
		end
	end
	--while not sampIsLocalPlayerSpawned() do
	--	wait(2000)
	--end
	getmyrank = true
	sampSendChat('/stats')
	ASHelperMessage(('AS Helper %s успешно загружен. Автор: JustMini'):format(thisScript().version))
	ASHelperMessage('Введите /ash чтобы открыть настройки.')
	checkstyle()
	imgui.Process = false
	if configuration.main_settings.changelog then
		windows.imgui_changelog.v = true
		configuration.main_settings.changelog = false
		inicfg.save(configuration, 'AS Helper.ini')
	end
	sampRegisterChatCommand('ash', function()
		windows.imgui_fm.v = false
		windows.imgui_sobes.v = false
		windows.imgui_settings.v = not windows.imgui_settings.v
		settingswindow = 0
	end)
	sampRegisterChatCommand('ashbind', function()
		choosedslot = nil
		windows.imgui_binder.v = not windows.imgui_binder.v
	end)
	sampRegisterChatCommand('ashstats', function()
		windows.imgui_stats.v = not windows.imgui_stats.v
		if windows.imgui_stats.v then
			ASHelperMessage('Двойной клик по окну сохранит его местоположение.')		
		end
	end)
	sampRegisterChatCommand('ashlect', function()
		if configuration.main_settings.myrankint >= 5 then
			windows.imgui_lect.v = not windows.imgui_lect.v
			return
		end
		ASHelperMessage('Данная функция доступна с 5-го ранга.')
		return
	end)
	sampRegisterChatCommand('ashdep', function()
		if configuration.main_settings.myrankint >= 5 then
			windows.imgui_depart.v = not windows.imgui_depart.v
			return
		end
		ASHelperMessage('Данная функция доступна с 5-го ранга.')
		return
	end)
	sampRegisterChatCommand('uninvite', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 9 then
				if not inprocess then
					local uvalid = param:match('(%d+)')
					local reason = select(2, param:match('(%d+) (.+),')) or select(2, param:match('(%d+) (.+)'))
					local withbl = select(2, param:match('(.+), (.+)'))
					local uvalid = tonumber(uvalid)
					if uvalid ~= nil and uvalid ~= '' and reason ~= nil and reason ~= '' then
						if uvalid ~= select(2,sampGetPlayerIdByCharHandle(playerPed)) then
							lua_thread.create(function()
								inprocess = true
								sampSendChat('/time')
								sampSendChat('/me {gender:достал|достала} КПК из кармана')
								wait(2000)
								sampSendChat('/me {gender:перешёл|перешла} в раздел \'Увольнение\'')
								wait(2000)
								sampSendChat('/do Раздел открыт.')
								wait(2000)
								sampSendChat('/me {gender:внёс|внесла} человека в раздел \'Увольнение\'')
								wait(2000)
								if withbl then
									sampSendChat('/me {gender:перешёл|перешла} в раздел \'Чёрный список\'')
									wait(2000)
									sampSendChat('/me {gender:занёс|занесла} сотрудника в раздел, после чего {gender:подтвердил|подтвердила} изменения')
									wait(2000)
									sampSendChat('/do Изменения были сохранены.')
									wait(2000)
									sampSendChat(string.format('/uninvite %s %s',uvalid,reason))
									wait(2000)
									sampSendChat(string.format('/blacklist %s %s',uvalid,withbl))
								else
									sampSendChat('/me {gender:подтведрдил|подтвердила} изменения, затем {gender:выключил|выключила} КПК и {gender:положил|положила} его обратно в карман')
									wait(2000)
									sampSendChat(string.format('/uninvite %s %s',uvalid,reason))
								end
								sampSendChat('/time')
								inprocess = false
							end)
							return
						end
						ASHelperMessage('Вы не можете увольнять из организации самого себя.')
						return
					end
					ASHelperMessage('/uninvite [id] [причина], [причина чс] (не обязательно)')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/uninvite %s',param))
		return
	end)
	sampRegisterChatCommand('invite', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 9 then
				if not inprocess then
					local id = param:match('(%d+)')
					local id = tonumber(id)
					if id ~= nil then
						if id ~= select(2,sampGetPlayerIdByCharHandle(playerPed)) then
							lua_thread.create(function()
								inprocess = true
								sampSendChat('/do Ключи от шкафчика в кармане.')
								wait(2000)
								sampSendChat('/me всунув руку в карман брюк, {gender:достал|достала} оттуда ключ от шкафчика')
								wait(2000)
								sampSendChat('/me {gender:передал|передала} ключ человеку напротив')
								wait(2000)
								sampSendChat('Добро пожаловать! Раздевалка за дверью.')
								wait(2000)
								sampSendChat('Со всей информацией Вы можете ознакомиться на оф. портале.')
								wait(2000)								
								sampSendChat(string.format('/invite %s',id))
								inprocess = false
							end)
							return
						end
						ASHelperMessage('Вы не можете приглашать в организацию самого себя.')
						return
					end
					ASHelperMessage('/invite [id]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/invite %s',param))
		return
	end)
	sampRegisterChatCommand('giverank', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 9 then
				if not inprocess then
					local id,rank = param:match('(%d+) (%d)')
					local id = tonumber(id)
					local rank = tonumber(rank)
					if id ~= nil and id ~= '' and rank ~= nil and rank ~= '' then
						if id ~= select(2,sampGetPlayerIdByCharHandle(playerPed)) then
							lua_thread.create(function()
								inprocess = true
								sampSendChat('/me {gender:включил|включила} КПК')
								wait(2000)
								sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\'')
								wait(2000)
								sampSendChat('/me {gender:выбрал|выбрала} в разделе нужного сотрудника')
								wait(2000)
								sampSendChat('/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтведрдил|подтвердила} изменения')
								wait(2000)
								sampSendChat('/do Информация о сотруднике была изменена.')
								wait(2000)
								sampSendChat('Поздравляю с повышением. Новый бейджик Вы можете взять в раздевалке.')
								wait(2000)								
								sampSendChat(string.format('/giverank %s %s',id,rank))
								inprocess = false
							end)
							return
						end
						ASHelperMessage('Вы не можете менять ранг самому себе.')
						return
					end
					ASHelperMessage('/giverank [id] [ранг]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/giverank %s',param))
		return
	end)
	sampRegisterChatCommand('blacklist', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 9 then
				if not inprocess then
					local id,reason = param:match('(%d+) (.+)')
					local id = tonumber(id)
					if id ~= nil and id ~= '' and reason ~= nil and reason ~= '' then
						lua_thread.create(function()
							inprocess = true
							sampSendChat('/time')
							sampSendChat('/me {gender:достал|достала} КПК из кармана')
							wait(2000)
							sampSendChat('/me {gender:перешёл|перешла} в раздел \'Чёрный список\'')
							wait(2000)
							sampSendChat('/me {gender:ввёл|ввела} имя нарушителя')
							wait(2000)
							sampSendChat('/me {gender:внёс|внесла} нарушителя в раздел \'Чёрный список\'')
							wait(2000)
							sampSendChat('/me {gender:подтведрдил|подтвердила} изменения')
							wait(2000)
							sampSendChat('/do Изменения были сохранены.')
							wait(2000)								
							sampSendChat(string.format('/blacklist %s %s',id,reason))
							sampSendChat('/time')
							inprocess = false
						end)
						return
					end
					ASHelperMessage('/blacklist [id] [причина]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/blacklist %s',param))
		return
	end)
	sampRegisterChatCommand('unblacklist', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 9 then
				if not inprocess then
					local id = param:match('(%d+)')
					local id = tonumber(id)
					if id ~= nil and id ~= '' then	
						lua_thread.create(function()
							inprocess = true
							sampSendChat('/me {gender:достал|достала} КПК из кармана')
							wait(2000)
							sampSendChat('/me {gender:перешёл|перешла} в раздел \'Чёрный список\'')
							wait(2000)
							sampSendChat('/me {gender:ввёл|ввела} имя гражданина в поиск')
							wait(2000)
							sampSendChat('/me {gender:убрал|убрала} гражданина из раздела \'Чёрный список\'')
							wait(2000)
							sampSendChat('/me {gender:подтведрдил|подтвердила} изменения')
							wait(2000)
							sampSendChat('/do Изменения были сохранены.')
							wait(2000)								
							sampSendChat(string.format('/unblacklist %s',id))
							inprocess = false
						end)
						return
					end
					ASHelperMessage('/unblacklist [id]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/unblacklist %s',param))
		return
	end)
	sampRegisterChatCommand('fwarn', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 9 then
				if not inprocess then
					local id,reason = param:match('(%d+) (.+)')
					if id ~= nil and id ~= '' and reason ~= nil and reason ~= '' then
						lua_thread.create(function()
							inprocess = true
							sampSendChat('/me {gender:достал|достала} КПК из кармана')
							wait(2000)
							sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\'')
							wait(2000)
							sampSendChat('/me {gender:зашёл|зашла} в раздел \'Выговоры\'')
							wait(2000)
							sampSendChat('/me найдя в разделе нужного сотрудника, {gender:добавил|добавила} в его личное дело выговор')
							wait(2000)
							sampSendChat('/do Выговор был добавлен в личное дело сотрудника.')
							wait(2000)
							sampSendChat(string.format('/fwarn %s %s',id,reason))
							inprocess = false
						end)
						return
					end
					ASHelperMessage('/fwarn [id] [причина]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/fwarn %s',param))
		return
	end)
	sampRegisterChatCommand('unfwarn', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 9 then
				if not inprocess then
					local id = param:match('(%d+)')
					local id = tonumber(id)
					if id ~= nil and id ~= '' then
						lua_thread.create(function()
							inprocess = true
							sampSendChat('/me {gender:достал|достала} КПК из кармана')
							wait(2000)
							sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\'')
							wait(2000)
							sampSendChat('/me {gender:зашёл|зашла} в раздел \'Выговоры\'')
							wait(2000)
							sampSendChat('/me найдя в разделе нужного сотрудника, {gender:убрал|убрала} из его личного дела один выговор')
							wait(2000)
							sampSendChat('/do Выговор был убран из личного дела сотрудника.')
							wait(2000)								
							sampSendChat(string.format('/unfwarn %s',id))
							inprocess = false
						end)
						return
					end
					ASHelperMessage('/unfwarn [id]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/unfwarn %s',param))
		return
	end)
	sampRegisterChatCommand('fmute', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 9 then
				if not inprocess then
					local id,mutetime,reason = param:match('(%d+) (%d+) (.+)')
					local id = tonumber(id)
					local mutetime = tonumber(mutetime)	
					if id ~= nil and id ~= '' and reason ~= nil and reason ~= '' then
						lua_thread.create(function()
							inprocess = true
							sampSendChat('/me {gender:достал|достала} КПК из кармана')
							wait(2000)
							sampSendChat('/me {gender:включил|включила} КПК')
							wait(2000)
							sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками Автошколы\'')
							wait(2000)
							sampSendChat('/me {gender:выбрал|выбрала} нужного сотрудника')
							wait(2000)
							sampSendChat('/me {gender:выбрал|выбрала} пункт \'Отключить рацию сотрудника\'')
							wait(2000)
							sampSendChat('/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\'')
							wait(2000)							
							sampSendChat(string.format('/fmute %s %s %s',id,mutetime,reason))
							inprocess = false
						end)
						return
					end
					ASHelperMessage('/fmute [id] [время] [причина]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/fmute %s',param))
		return
	end)
	sampRegisterChatCommand('funmute', function(param)
		if configuration.main_settings.dorponcmd then		
			if configuration.main_settings.myrankint >= 9 then
				if not inprocess then
					local id = param:match('(%d+)')
					local id = tonumber(id)
					if id ~= nil and id ~= '' then
						lua_thread.create(function()
							inprocess = true
							sampSendChat('/me {gender:достал|достала} КПК из кармана')
							wait(2000)
							sampSendChat('/me {gender:включил|включила} КПК')
							wait(2000)
							sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками Автошколы\'')
							wait(2000)
							sampSendChat('/me {gender:выбрал|выбрала} нужного сотрудника')
							wait(2000)
							sampSendChat('/me {gender:выбрал|выбрала} пункт \'Включить рацию сотрудника\'')
							wait(2000)
							sampSendChat('/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\'')
							wait(2000)							
							sampSendChat(string.format('/funmute %s',id))
							inprocess = false
						end)
						return
					end
					ASHelperMessage('/funmute [id]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 9-го ранга.')
			return
		end
		sampSendChat(string.format('/funmute %s',param))
		return
	end)
	sampRegisterChatCommand('expel', function(param)
		if configuration.main_settings.dorponcmd then
			if configuration.main_settings.myrankint >= 2 then
				if not inprocess then
					local id,reason = param:match('(%d+) (.+)')
					local id = tonumber(id)
					if id ~= nil and id ~= '' and reason ~= nil and reason ~= '' then
						if not sampIsPlayerPaused(id) then
							lua_thread.create(function()
								inprocess = true
								sampSendChat('/do Рация свисает на поясе.')
								wait(2000)
								sampSendChat('/me сняв рацию с пояса, {gender:вызвал|вызвала} охрану по ней')
								wait(2000)
								sampSendChat('/do Охрана выводит нарушителя из холла.')
								wait(2000)									
								sampSendChat(string.format('/expel %s %s',id,reason))
								inprocess = false
							end)
							return
						end
						ASHelperMessage('Игрок находится в АФК!')
						return
					end
					ASHelperMessage('/expel [id] [причина]')
					return
				end
				ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
				return
			end
			ASHelperMessage('Данная команда доступна с 2-го ранга.')
			return
		end
		sampSendChat(string.format('/expel %s',param))
		return
	end)
	updatechatcommands()
	local bindkeysthread = lua_thread.create_suspended(keybindactivation)

	-- меню быстрого доступа
	while true do
		if getCharPlayerIsTargeting() then
			if configuration.main_settings.createmarker then
				local targettingped = select(2,getCharPlayerIsTargeting())
				if sampGetPlayerIdByCharHandle(targettingped) then
					if marker ~= nil and oldtargettingped ~= targettingped then
						removeBlip(marker)
						marker = nil
						marker = addBlipForChar(targettingped)
					elseif marker == nil and oldtargettingped ~= targettingped then
						marker = addBlipForChar(targettingped)
					end
				end
				oldtargettingped = targettingped
			end
			if wasKeyPressed(vkeys.name_to_id(configuration.main_settings.usefastmenu,true)) then
				if not sampIsChatInputActive() then
					if sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())) then
						setVirtualKeyDown(0x02,false)
						fastmenuID = select(2,sampGetPlayerIdByCharHandle(select(2,getCharPlayerIsTargeting())))
						local r, g, b, a = imgui.ImColor(configuration.main_settings.ASChatColor):GetRGBA()
						ASHelperMessage(string.format('Вы использовали меню быстрого доступа на: %s [%s]',string.gsub(sampGetPlayerNickname(fastmenuID), '_', ' '),fastmenuID))
						ASHelperMessage('Зажмите {MC}ALT{WC} для того, чтобы скрыть курсор. {MC}ESC{WC} для того, чтобы закрыть меню.')
						wait(0)
						windowtype = 0
						windows.imgui_fm.v = true
					end
				end
			end
		end
		-- быстрый скрин
		if wasKeyPressed(vkeys.name_to_id(configuration.main_settings.fastscreen,true)) and not getscreenkey and configuration.main_settings.dofastscreen then
			sampSendChat('/time')
			wait(500)
			setVirtualKeyDown(0x77, true)
			wait(0)
			setVirtualKeyDown(0x77, false)
		end
		--отыгровка дубинки
		if configuration.main_settings.playdubinka then
			local weapon = getCurrentCharWeapon(playerPed)
			if weapon == 3 and not rp_check then 
				sampSendChat('/me сняв дубинку с пояса {gender:взял|взяла} в правую руку')
				rp_check = true
			elseif weapon ~= 3 and rp_check then
				sampSendChat('/me {gender:повесил|повесила} дубинку на пояс')
				rp_check = false
			end
		end
		-- всё, что связано с imgui
		if windows.imgui_settings.v or windows.imgui_fm.v or windows.imgui_binder.v or windows.imgui_sobes.v or windows.imgui_lect.v or windows.imgui_depart.v or windows.imgui_changelog.v then
			if isKeyDown(0x12) and not setbinderkey then
				imgui.ShowCursor = false
			else
				imgui.ShowCursor = true
			end
			imgui.Process = true
		elseif windows.imgui_stats.v then
			imgui.Process = true
			imgui.ShowCursor = false
		else
			imgui.ShowCursor = false
			imgui.Process = false
		end
		-- кнопки биндера
		for key, value in pairs(configuration.BindsName) do
			if tostring(value) == tostring(configuration.BindsName[key]) then
				if configuration.BindsKeys[key] ~= '' then
					if tostring(configuration.BindsKeys[key]):match('(.+) %p (.+)') then
						local fkey = tostring(configuration.BindsKeys[key]):match('(.+) %p')
						local skey = tostring(configuration.BindsKeys[key]):match('%p (.+)')
						if isKeyDown(vkeys.name_to_id(fkey)) and wasKeyPressed(vkeys.name_to_id(skey)) and not sampIsChatInputActive() then
							if not inprocess then
								bindkeysthread:run(key)
							else
								ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
							end
						end
					elseif tostring(configuration.BindsKeys[key]):match('(.+)') then
						local fkey = tostring(configuration.BindsKeys[key]):match('(.+)')
						if wasKeyPressed(vkeys.name_to_id(fkey)) and not sampIsChatInputActive() then
							if not inprocess then
								bindkeysthread:run(key)
							else
								ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
							end
						end
					end
				end
			end
		end
		wait(0)
	end
end

function updatechatcommands()
	for key, value in pairs(configuration.BindsName) do
		if tostring(value) == tostring(configuration.BindsName[key]) then
			if configuration.BindsCmd[key] ~= '' then
				sampUnregisterChatCommand(configuration.BindsCmd[key])
				sampRegisterChatCommand(configuration.BindsCmd[key], function()
					if not inprocess then
						local temp = 0
						local temp2 = 0
						for bp in tostring(configuration.BindsAction[key]):gmatch('[^~]+') do
							temp = temp + 1
						end
						lua_thread.create(function()
							inprocess = true
							for bp in tostring(configuration.BindsAction[key]):gmatch('[^~]+') do
								temp2 = temp2 + 1
								if not bp:find('%{delay_(%d+)%}') then
									sampSendChat(tostring(bp))
									if temp2 ~= temp then
										wait(configuration.BindsDelay[key])
									end
								else
									local delay = bp:match('%{delay_(%d+)%}')
									wait(delay)
								end
							end
							inprocess = false
						end)
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end)
			end
		end
	end
end

if sampevcheck then
	function sampev.onCreatePickup(id, model, pickupType, position)
		if model == 19132 and getCharActiveInterior(playerPed) == 14 then
			return {id, 1272, pickupType, position}
		end
	end

	function sampev.onShowDialog(dialogId, style, title, button1, button2, text)
		if dialogId == 6 and givelic then
			if lictype == 'авто' then
				sampSendDialogResponse(6, 1, 0, nil)
			elseif lictype == 'мото' then
				sampSendDialogResponse(6, 1, 1, nil)
			elseif lictype == 'рыболовство' then
				sampSendDialogResponse(6, 1, 3, nil)
			elseif lictype == 'плавание' then
				sampSendDialogResponse(6, 1, 4, nil)
			elseif lictype == 'оружие' then
				sampSendDialogResponse(6, 1, 5, nil)
			elseif lictype == 'охоту' then
				sampSendDialogResponse(6, 1, 6, nil)
			elseif lictype == 'раскопки' then
				sampSendDialogResponse(6, 1, 7, nil)
			elseif lictype == 'такси' then
				sampSendDialogResponse(6, 1, 8, nil)
			end
			lua_thread.create(function()
				wait(1000)
				if givelic then
					sampProcessChatInput(string.format('/givelicense %s',sellto))
				end
			end)
			return false

		elseif dialogId == 235 and getmyrank then
			if text:find('Инструкторы') then
				for DialogLine in text:gmatch('[^\r\n]+') do
					local nameRankStats, getStatsRank = DialogLine:match('Должность: {B83434}(.+)%p(%d+)%p')
					if tonumber(getStatsRank) then
						local rangint = tonumber(getStatsRank)
						local rang = nameRankStats
						if rangint ~= configuration.main_settings.myrankint then
							ASHelperMessage(string.format('Ваш ранг был обновлён на %s (%s)',rang,rangint))
						end
						configuration.main_settings.myrankint = rangint
						inicfg.save(configuration,'AS Helper')
					end
				end
			else
				ASHelperMessage('Вы не работаете в автошколе, скрипт выгружен!')
				NoErrors = true
				thisScript():unload()
			end
			sampSendDialogResponse(235, 0, 0, nil)
			getmyrank = false
			return false

		elseif dialogId == 1234 then
			if text:find('Срок действия') then
				if mcvalue then
					if text:find('Имя: '..sampGetPlayerNickname(fastmenuID)) then
						for DialogLine in text:gmatch('[^\r\n]+') do
							if text:find('Полностью здоровый') then
							local statusint = DialogLine:match('{CEAD2A}Наркозависимость: (%d+)')
								if tonumber(statusint) then
									if tonumber(statusint) <= 5 then
										mcvalue = false
										mcverdict = ('в порядке')
									else
										mcvalue = false
										mcverdict = ('наркозависимость')
									end
								end
							else
								mcvalue = false
								mcverdict = ('не полностью здоровый')
							end
						end
					end
				end
				if skiporcancel then
					if text:find('Имя: '..sampGetPlayerNickname(tempid)) then
						if text:find('Полностью здоровый') then
							lua_thread.create(function()
								while inprocess do
									wait(0)
								end
								skiporcancel = false
								inprocess = true
								sampSendChat('/me взяв мед.карту в руки начал её проверять')
								wait(2000)
								sampSendChat('/do Мед.карта в норме.')
								wait(2000)
								sampSendChat('/todo Всё в порядке* отдавая мед.карту обратно')
								wait(2000)
								sampSendChat('/me {gender:взял|взяла} со стола бланк и {gender:заполнил|заполнила} ручкой бланк на получение лицензии на оружие')
								wait(2000)
								sampSendChat('/do Спустя некоторое время бланк на получение лицензии был заполнен.')
								wait(2000)
								sampSendChat('/me распечатав лицензию на оружие {gender:передал|передала} её человеку напротив')
								wait(1000)
								givelic = true
								lictype = 'оружие'
								sampProcessChatInput(('/givelicense %s'):format(tempid))
								inprocess = false
							end)
						else
							lua_thread.create(function()
								while inprocess do
									wait(0)
								end
								skiporcancel = false
								inprocess = true
								ASHelperMessage('Человек не полностью здоровый, требуется поменять мед.карту!')
								sampSendChat('/me взяв мед.карту в руки начал её проверять')
								wait(2000)
								sampSendChat('/do Мед.карта не в норме.')
								wait(2000)
								sampSendChat('/todo К сожалению, в мед.карте написано, что у вас есть отклонения.* отдавая мед.карту обратно')
								wait(2000)
								sampSendChat('Обновите её и приходите снова!')
								inprocess = false
							end)
						end
						sampSendDialogResponse(1234, 1, 1, nil)
						return false
					end
				end
			elseif text:find('Серия') then
				if passvalue then
					if text:find('Имя: {FFD700}'..sampGetPlayerNickname(fastmenuID)) then
						if not text:find('{FFFFFF}Организация:') then
							for DialogLine in text:gmatch('[^\r\n]+') do
								local passstatusint = DialogLine:match('{FFFFFF}Лет в штате: {FFD700}(%d+)')
								if tonumber(passstatusint) then
									if tonumber(passstatusint) >= 3 then
										for DialogLine in text:gmatch('[^\r\n]+') do
											local zakonstatusint = DialogLine:match('{FFFFFF}Законопослушность: {FFD700}(%d+)')
											if tonumber(zakonstatusint) then
												if tonumber(zakonstatusint) >= 35 then
													if not text:find('Лечился в Психиатрической больнице') then
														if not text:find('Состоит в ЧС{FF6200} Инструкторы') then
															if not text:find('Warns') then
																passvalue = false
																passverdict = ('в порядке')
															else
																passvalue = false
																passverdict = ('есть варны')
															end
														else
															passvalue = false
															passverdict = ('в чс автошколы')
														end
													else
														passvalue = false
														passverdict = ('был в деморгане')
													end
												else
													passvalue = false
													passverdict = ('не законопослушный')
												end
											end
										end
									else
										passvalue = false
										passverdict = ('меньше 3 лет в штате')
									end
								end
							end
						else
							passvalue = false
							passverdict = ('игрок в организации')
						end
					end
				end
			end
		end
		if dialogId == 2015 then 
			for line in text:gmatch('[^\r\n]+') do
				local name, rank = line:match('^{%x+}[A-z0-9_]+%([0-9]+%)\t(.+)%(([0-9]+)%)\t%d+\t%d+')
				if name and rank then
					name, rank = tostring(name), tonumber(rank)
					if configuration.RankNames[rank] ~= nil and configuration.RankNames[rank] ~= name then
						ASHelperMessage(string.format('Название {MC}%s{WC} ранга изменено с {MC}%s{WC} на {MC}%s{WC}', rank, configuration.RankNames[rank], name))
						configuration.RankNames[rank] = name
					end
				end
			end
		end
	end
	
	function sampev.onServerMessage(color, message)
		if configuration.main_settings.replacechat then
			if message:find('Используйте: /jobprogress %[ ID игрока %]') then
				ASHelperMessage('Вы просмотрели свою рабочую успеваемость.')
				return false
			end
			if message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' переодевается в гражданскую одежду') then
				ASHelperMessage('Вы закончили рабочий день, удачного отдыха!')
				return false
			end
			if message:find(sampGetPlayerNickname(select(2, sampGetPlayerIdByCharHandle(playerPed)))..' переодевается в рабочую одежду') then
				ASHelperMessage('Вы начали рабочий день, удачной работы!')
				return false
			end
			if message:find('%[Информация%] {FFFFFF}Вы покинули пост!') then
				ASHelperMessage('Вы покинули пост.')
				return false
			end
		end
		if message:find('%[Информация%] {FFFFFF}Вы предложили (.+) купить лицензию (.+)') and givelic then
			givelic = false
		end
		if message == ('Используйте: /jobprogress(Без параметра)') and color == -1104335361 then
			sampSendChat('/jobprogress')
			return false
		end
		if message:find('%[R%]') and not message:find('%[Объявление%]') and color == 766526463 then
			local r, g, b, a = imgui.ImColor(configuration.main_settings.RChatColor):GetRGBA()
			return { join_argb(r, g, b, a), message}
		end
		if message:find('%[D%]') and color == 865730559 or color == 865665023 then
			if message:find(u8:decode(departsettings.myorgname.v)) then
				local tmsg = message:gsub('%[D%] ','')
				table.insert(dephistory,tmsg)
			end
			local r, g, b, a = imgui.ImColor(configuration.main_settings.DChatColor):GetRGBA()
			return { join_argb(r, g, b, a), message }
		end
		if message:find('повысил до') then
			getmyrank = true
			sampSendChat('/stats')
		end
		if message:find('%[Информация%] {FFFFFF}Вы успешно продали лицензию') then
			local typeddd, toddd = message:match('%[Информация%] {FFFFFF}Вы успешно продали лицензию (.+) игроку (.+).')
			if typeddd == 'на авто' then
				configuration.my_stats.avto = configuration.my_stats.avto + 1
			elseif typeddd == 'на мото' then
				configuration.my_stats.moto = configuration.my_stats.moto + 1
			elseif typeddd == 'на рыбалку' then
				configuration.my_stats.riba = configuration.my_stats.riba + 1
			elseif typeddd == 'на плавание' then
				configuration.my_stats.lodka = configuration.my_stats.lodka + 1
			elseif typeddd == 'на оружие' then
				configuration.my_stats.guns = configuration.my_stats.guns + 1
			elseif typeddd == 'на охоту' then
				configuration.my_stats.hunt = configuration.my_stats.hunt + 1
			elseif typeddd == 'на раскопки' then
				configuration.my_stats.klad = configuration.my_stats.klad + 1
			elseif typeddd == 'таксиста' then
				configuration.my_stats.taxi = configuration.my_stats.taxi + 1
			else
				if configuration.main_settings.replacechat then
					ASHelperMessage(string.format('Вы успешно продали лицензию на %s игроку %s.',typeddd,toddd:gsub('_',' ')))
					return false
				end
			end
			if inicfg.save(configuration,'AS Helper') then
				if configuration.main_settings.replacechat then
					ASHelperMessage(string.format('Вы успешно продали лицензию на %s игроку %s. Она была засчитана в вашу статистику.',typeddd,toddd:gsub('_',' ')))
					return false
				end
			end
		end
		if message:find('Приветствуем нового члена нашей организации (.+), которого пригласил: (.+)') then
			local invited,inviting = message:match('Приветствуем нового члена нашей организации (.+), которого пригласил: (.+)%[')
			if inviting == sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))) then
				if invited == sampGetPlayerNickname(waitingaccept) then
					sampSendChat(string.format('/giverank %s 2',waitingaccept))
					waitingaccept = false
				end
			end
			return {color,message}
		end
	end

	function sampev.onSendChat(message)
		if message:find('{my_id}') then
			sampSendChat(message:gsub('{my_id}', select(2, sampGetPlayerIdByCharHandle(playerPed))))
			return false
		end
		if message:find('{my_name}') then
			sampSendChat(message:gsub('{my_name}', (configuration.main_settings.useservername and string.gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname))))
			return false
		end
		if message:find('{my_rank}') then
			sampSendChat(message:gsub('{my_rank}', configuration.RankNames[configuration.main_settings.myrankint]))
			return false
		end
		if message:find('{my_score}') then
			sampSendChat(message:gsub('{my_score}', sampGetPlayerScore(select(2,sampGetPlayerIdByCharHandle(playerPed)))))
			return false
		end
		if message:find('{H}') then
			sampSendChat(message:gsub('{H}', os.date('%H', os.time())))
			return false
		end
		if message:find('{HM}') then
			sampSendChat(message:gsub('{HM}', os.date('%H:%M', os.time())))
			return false
		end
		if message:find('{HMS}') then
			sampSendChat(message:gsub('{HMS}', os.date('%H:%M:%S', os.time())))
			return false
		end
		if message:find('{close_id}') then
			if select(1,getClosestPlayerId()) then
				sampSendChat(message:gsub('{close_id}', select(2,getClosestPlayerId())))
				return false
			end
			ASHelperMessage('В зоне стрима не найдено ни одного игрока')
			return false
		end
		if message:find('@{%d+}') then
			local id = message:match('@{(%d+)}')
			if id and sampIsPlayerConnected(id) then
				sampSendChat(message:gsub('@{%d+}', sampGetPlayerNickname(id)))
				return false
			end
			ASHelperMessage('Такого игрока нет на сервере.')
			return false
		end
		if message:find('{gender:%A+|%A+}') then
			local male, female = message:match('{gender:(%A+)|(%A+)}')
			if configuration.main_settings.gender == 0 then
				local gendermsg = message:gsub('{gender:%A+|%A+}', male, 1)
				sampSendChat(tostring(gendermsg))
				return false
			else
				local gendermsg = message:gsub('{gender:%A+|%A+}', female, 1)
				sampSendChat(tostring(gendermsg))
				return false
			end
		end
		--на основе https://www.blast.hk/threads/43610/
		if configuration.main_settings.useaccent and configuration.main_settings.myaccent ~= '' and configuration.main_settings.myaccent ~= ' ' then
			if message == ')' or message == '(' or message ==  '))' or message == '((' or message == 'xD' or message == ':D' or message == 'q' or message == ';)' then
				return{message}
			end
			if string.find(u8:decode(configuration.main_settings.myaccent), 'акцент') or string.find(u8:decode(configuration.main_settings.myaccent), 'Акцент') then
				return{('[%s]: %s'):format(u8:decode(configuration.main_settings.myaccent),message)}
			else
				return{('[%s акцент]: %s'):format(u8:decode(configuration.main_settings.myaccent),message)}
			end
		end
	end
	
	function sampev.onSendCommand(cmd)
		print(cmd)
		if cmd:find('{my_id}') then
			sampSendChat(cmd:gsub('{my_id}', select(2, sampGetPlayerIdByCharHandle(playerPed))))
			return  false
		end
		if cmd:find('{my_name}') then
			sampSendChat(cmd:gsub('{my_name}', (configuration.main_settings.useservername and string.gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname))))
			return false
		end
		if cmd:find('{my_rank}') then
			sampSendChat(cmd:gsub('{my_rank}', configuration.RankNames[configuration.main_settings.myrankint]))
			return false
		end
		if cmd:find('{my_score}') then
			sampSendChat(cmd:gsub('{my_score}', sampGetPlayerScore(select(2,sampGetPlayerIdByCharHandle(playerPed)))))
			return false
		end
		if cmd:find('{H}') then
			sampSendChat(cmd:gsub('{H}', os.date('%H', os.time())))
			return false
		end
		if cmd:find('{HM}') then
			sampSendChat(cmd:gsub('{HM}', os.date('%H:%M', os.time())))
			return false
		end
		if cmd:find('{HMS}') then
			sampSendChat(cmd:gsub('{HMS}', os.date('%H:%M:%S', os.time())))
			return false
		end
		if cmd:find('{close_id}') then
			if select(1,getClosestPlayerId()) then
				sampSendChat(cmd:gsub('{close_id}', select(2,getClosestPlayerId())))
				return false
			end
			ASHelperMessage('В зоне стрима не найдено ни одного игрока')
			return false
		end
		if cmd:find('@{%d+}') then
			local id = cmd:match('@{(%d+)}')
			if id and sampIsPlayerConnected(id) then
				sampSendChat(cmd:gsub('@{%d+}', sampGetPlayerNickname(id)))
				return false
			end
			ASHelperMessage('Такого игрока нет на сервере.')
			return false
		end
		if cmd:find('{gender:%A+|%A+}') then
			local male, female = cmd:match('{gender:(%A+)|(%A+)}')
			if configuration.main_settings.gender == 0 then
				local gendermsg = cmd:gsub('{gender:%A+|%A+}', male, 1)
				sampSendChat(tostring(gendermsg))
				return false
			else
				local gendermsg = cmd:gsub('{gender:%A+|%A+}', female, 1)
				sampSendChat(tostring(gendermsg))
				return false
			end
		end
	end
end

function checkServer(ip)
	for k, v in pairs({
		'185.169.134.3',
		'185.169.134.4',
		'185.169.134.43',
		'185.169.134.44', 
		'185.169.134.45',
		'185.169.134.5',
		'185.169.134.59',
		'185.169.134.61',
		'185.169.134.107',
		'185.169.134.109',
		'185.169.134.166',
		'185.169.134.171',
		'185.169.134.172',
		'185.169.134.173',
		'185.169.134.174',
		'80.66.82.191',
		'80.66.82.190'}) do
		if v == ip then 
			return true
		end
	end
	return false
end

function ASHelperMessage(text)
	if imguicheck then
		local r, g, b, a = imgui.ImColor(configuration.main_settings.ASChatColor):GetRGBA()
		text = text:gsub('{WC}', '{EBEBEB}')
		text = text:gsub('{MC}', ('{%06X}'):format(join_rgb(r, g, b)))
		sampAddChatMessage(('[ASHelper]{EBEBEB} %s'):format(text),join_rgb(r, g, b))
	else
		sampAddChatMessage(('[ASHelper]{EBEBEB} %s'):format(text),0xff6633)
	end
end

if imguicheck then
	function onWindowMessage(msg, wparam, lparam)
		if wparam == 0x1B and not isPauseMenuActive() then
			if windows.imgui_settings.v or windows.imgui_fm.v or windows.imgui_binder.v or windows.imgui_sobes.v or windows.imgui_lect.v or windows.imgui_depart.v or windows.imgui_changelog.v then
				consumeWindowMessage(true, false)
				if(msg == 0x101)then
					windows.imgui_settings.v = false
					windows.imgui_fm.v = false
					windows.imgui_sobes.v = false
					windows.imgui_lect.v = false
					windows.imgui_binder.v = false
					windows.imgui_depart.v = false
					windows.imgui_changelog.v = false
					imgui.ShowCursor = false
				end
			end
		end
	end
end

function join_argb(a, r, g, b)
	local argb = b
	argb = bit.bor(argb, bit.lshift(g, 8)) 
	argb = bit.bor(argb, bit.lshift(r, 16))
	argb = bit.bor(argb, bit.lshift(a, 24))
	return argb
end

function join_rgb(rr, gg, bb)
	return bit.bor(bit.bor(bb, bit.lshift(gg, 8)), bit.lshift(rr, 16))
end

function onQuitGame()
	inicfg.save(configuration, 'AS Helper.ini')
end

function onScriptTerminate(script, quitGame)
	if script == thisScript() then
		if not sampIsDialogActive() then
			showCursor(false, false)
		end
		if marker ~= nil then
			removeBlip(marker)
		end
		inicfg.save(configuration, 'AS Helper.ini')
		if NoErrors then
			return false
		end
		sampShowDialog(1313, '{ff6633}[AS Helper]{ffffff} Скрипт был выгружен сам по себе.', [[
{ffffff}																			 Что делать в таких случаях?{f51111}
Если вы самостоятельно перезагрузили скрипт, то можете закрыть это диалоговое окно.
В ином случае, для начала попытайтесь восстановить работу скрипта сочетанием клавиш CTRL + R.
Если же это не помогло, то читайте следующие пункты.{ff6633}
1. Возможно у вас установлены другие LUA файлы и хелперы, попытайтесь удалить их.
2. Возможно вы не доустановили некоторые дополнения, а именно:
 - SAMPFUNCS
 - CLEO 4.1+
 - MoonLoader 0.26
3. Если данной ошибки не было ранее, попытайтесь сделать следующие действия:
- В папке moonloader > config > Удаляем файл AS Helper.ini
- В папке moonloader > Удаляем папку AS Helper
4. Если ничего из вышеперечисленного не исправило ошибку, то следует установить скрипт на другую сборку.
5. Если у вас скрипт вылетает по нажатию на какую-то кнопку, то можете отправить (JustMini#3885) эту ошибку.]], 'ОК', nil, 0)
	end
end

--Отдельное спасибо Bank Helper от Cosmo. Оттуда взял несколько интересных идей.
if imguicheck and encodingcheck then
	u8 									= encoding.UTF8
	encoding.default 					= 'CP1251'
	
	local Licenses_select 				= imgui.ImInt(0)
	local Licenses_Arr 					= {u8'Авто',u8'Мото',u8'Рыболовство',u8'Плавание',u8'Оружие',u8'Охоту',u8'Раскопки',u8'Такси'}

	local StyleBox_select				= imgui.ImInt(configuration.main_settings.style)
	local StyleBox_arr					= {u8'Тёмно-оранжевая (transp.)',u8'Тёмно-красная (not transp.)',u8'Светло-синяя (not transp.)',u8'Фиолетовая (not transp.)',u8'Тёмно-зеленая (not transp.)'}

	local Ranks_select 					= imgui.ImInt(0)
	
	local sobesdecline_select 			= imgui.ImInt(0)
	local sobesdecline_arr 				= {u8'Плохое РП',u8'Не было РП',u8'Плохая грамматика',u8'Ничего не показал',u8'Другое'}
		
	local uninvitebuf 					= imgui.ImBuffer(256)
	local blacklistbuf 					= imgui.ImBuffer(256)
	local uninvitebox 					= imgui.ImBool(false)
	
	local blacklistbuff 				= imgui.ImBuffer(256)

	local fwarnbuff 					= imgui.ImBuffer(256)
	
	local fmutebuff 					= imgui.ImBuffer(256)
	local fmuteint 						= imgui.ImInt(0)

	local buttons 						= {fa.ICON_FA_USER_COG..u8' Настройки пользователя',fa.ICON_FA_FILE_ALT..u8' Ценовая политика',fa.ICON_FA_KEYBOARD..u8' Горячие клавиши',fa.ICON_FA_PALETTE..u8' Настройки цветов',fa.ICON_FA_BOOK_OPEN..u8' Правила автошколы',fa.ICON_FA_INFO_CIRCLE..u8' Информация о скрипте'}

	local search_rule				 	= imgui.ImBuffer(256)
	local rule_align					= imgui.ImInt(configuration.main_settings.rule_align)
	
	local lastq = false

	windows = {
		imgui_settings 					= imgui.ImBool(false),
		imgui_fm 						= imgui.ImBool(false),
		imgui_sobes						= imgui.ImBool(false),
		imgui_binder 					= imgui.ImBool(false),
		imgui_stats						= imgui.ImBool(false),
		imgui_lect						= imgui.ImBool(false),
		imgui_depart					= imgui.ImBool(false),
		imgui_changelog					= imgui.ImBool(configuration.main_settings.changelog)
	}
	
	local bindersettings = {
		binderbuff 						= imgui.ImBuffer(4096),
		bindername 						= imgui.ImBuffer(40),
		binderdelay 					= imgui.ImBuffer(7),
		bindertype 						= imgui.ImInt(0),
		bindercmd 						= imgui.ImBuffer(15)
	}
	
	local chatcolors = {
		RChatColor 						= imgui.ImFloat4(imgui.ImColor(configuration.main_settings.RChatColor):GetFloat4()),
		DChatColor 						= imgui.ImFloat4(imgui.ImColor(configuration.main_settings.DChatColor):GetFloat4()),
		ASChatColor 					= imgui.ImFloat4(imgui.ImColor(configuration.main_settings.ASChatColor):GetFloat4())
	}
	
	local usersettings = {
		useaccent 						= imgui.ImBool(configuration.main_settings.useaccent),
		createmarker 					= imgui.ImBool(configuration.main_settings.createmarker),
		useservername 					= imgui.ImBool(configuration.main_settings.useservername),
		dorponcmd						= imgui.ImBool(configuration.main_settings.dorponcmd),
		replacechat						= imgui.ImBool(configuration.main_settings.replacechat),
		dofastscreen					= imgui.ImBool(configuration.main_settings.dofastscreen),
		noscrollbar						= imgui.ImBool(configuration.main_settings.noscrollbar),
		playdubinka						= imgui.ImBool(configuration.main_settings.playdubinka),
		myname 							= imgui.ImBuffer(configuration.main_settings.myname, 256),
		myaccent 						= imgui.ImBuffer(configuration.main_settings.myaccent, 256),
		gender 							= imgui.ImInt(configuration.main_settings.gender),
		expelreason						= imgui.ImBuffer(u8(configuration.main_settings.expelreason), 256),
	}
	
	local pricelist = {
		avtoprice 						= imgui.ImBuffer(tostring(configuration.main_settings.avtoprice), 7),
		motoprice 						= imgui.ImBuffer(tostring(configuration.main_settings.motoprice), 7),
		ribaprice 						= imgui.ImBuffer(tostring(configuration.main_settings.ribaprice), 7),
		lodkaprice 						= imgui.ImBuffer(tostring(configuration.main_settings.lodkaprice), 7),
		gunaprice 						= imgui.ImBuffer(tostring(configuration.main_settings.gunaprice), 7),
		huntprice 						= imgui.ImBuffer(tostring(configuration.main_settings.huntprice), 7),
		kladprice						= imgui.ImBuffer(tostring(configuration.main_settings.kladprice), 7),
		taxiprice						= imgui.ImBuffer(tostring(configuration.main_settings.taxiprice), 7)
	}
	
	local lectionsettings = {
		lection_type					= imgui.ImInt(1),
		lection_delay					= imgui.ImInt(configuration.main_settings.lection_delay),
		lection_name					= imgui.ImBuffer(256),
		lection_text					= imgui.ImBuffer(65536)
	}

	departsettings = {
		myorgname						= imgui.ImBuffer(u8(configuration.main_settings.astag),50),
		toorgname						= imgui.ImBuffer(50),
		frequency						= imgui.ImBuffer(7),
		myorgtext						= imgui.ImBuffer(256),
	}

	local questionsettings = {
		questionname					= imgui.ImBuffer(256),
		questionhint					= imgui.ImBuffer(256),
		questionques					= imgui.ImBuffer(256)
	}
	
	local whiteashelper					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\AS Helper\\Images\\settingswhite.png')
	local blackashelper					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\AS Helper\\Images\\settingsblack.png')
	local whitebinder					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\AS Helper\\Images\\binderwhite.png')
	local blackbinder					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\AS Helper\\Images\\binderblack.png')
	local whitelection					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\AS Helper\\Images\\lectionwhite.png')
	local blacklection					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\AS Helper\\Images\\lectionblack.png')
	local whitedepart					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\AS Helper\\Images\\departamenwhite.png')
	local blackdepart					= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\AS Helper\\Images\\departamentblack.png')
	local whitechangelog				= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\AS Helper\\Images\\changelogwhite.png')
	local blackchangelog				= imgui.CreateTextureFromFile(getGameDirectory() .. '\\moonloader\\AS Helper\\Images\\changelogblack.png')
	
	local tagbuttons = {
		{name = '{my_id}',text = 'Пишет Ваш ID.',hint = '/n /showpass {my_id}\n(( /showpass \'Ваш ID\' ))'},
		{name = '{my_name}',text = 'Пишет Ваш ник из настроек.',hint = 'Здравствуйте, я {my_name}\n- Здравствуйте, я '..u8:decode(configuration.main_settings.myname)..'.'},
		{name = '{my_rank}',text = 'Пишет Ваш ранг из настроек.',hint = '/do На груди бейджик {my_rank}\nНа груди бейджик '..configuration.RankNames[configuration.main_settings.myrankint]},
		{name = '{my_score}',text = 'Пишет Ваш уровень.',hint = 'Я проживаю в штате уже {my_score} лет!\n- Я проживаю в штате уже \'Ваш уровень\' лет!'},
		{name = '{H}',text = 'Пишет системное время в часы.',hint = 'Давай встретимся завтра тут же в {H} \n- Давай встретимся завтра тут же в чч'},
		{name = '{HM}',text = 'Пишет системное время в часы:минуты.',hint = 'Сегодня в {HM} будет концерт!\n- Сегодня в чч:мм будет концерт!'},
		{name = '{HMS}',text = 'Пишет системное время в часы:минуты:секунды.',hint = 'У меня на часах {HMS}\n- У меня на часах \'чч:мм:сс\''},
		{name = '{gender:Текст1|Текст2}',text = 'Пишет сообщение в зависимости от вашего пола.',hint = 'Я вчера {gender:был|была} в банке\n- Если мужской пол: был в банке\n- Если женский пол: была в банке'},
		{name = '@{ID}',text = 'Узнаёт имя игрока по ID.',hint = 'Ты не видел где сейчас @{43}?\n- Ты не видел где сейчас \'Имя 43 ида\''},
		{name = '{close_id}',text = 'Узнаёт ID ближайшего к вам игрока',hint = 'О, а вот и @{{close_id}}?\nО, а вот и \'Имя ближайшего ида\''},
		{name = '{delay_*}',text = 'Добавляет задержку между сообщениями',hint = 'Добрый день, я сотрудник Автошколы г. Сан-Фиерро, чем могу вам помочь?\n{delay_2000}\n/do На груди висит бейджик с надписью Лицензёр Автошколы.\n\n[10:54:29] Добрый день, я сотрудник Автошколы г. Сан-Фиерро, чем могу вам помочь?\n[10:54:31] На груди висит бейджик с надписью Лицензёр Автошколы.'},
	}

	local fa_glyph_ranges	= imgui.ImGlyphRanges({ fa.min_range, fa.max_range })
	function imgui.BeforeDrawFrame()
		if fa_font == nil then
			local font_config = imgui.ImFontConfig()
			font_config.MergeMode = true
			fa_font = imgui.GetIO().Fonts:AddFontFromFileTTF('moonloader/resource/fonts/fa-solid-900.ttf', 13.0, font_config, fa_glyph_ranges)
		end
		if fontsize16 == nil then fontsize16 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\trebucbd.ttf', 16.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) end
		if fontsize25 == nil then fontsize25 = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\trebucbd.ttf', 25.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) end
	end

	function checkstyle()
		imgui.SwitchContext()
		local style 							= imgui.GetStyle()
		local colors 							= style.Colors
		local clr 								= imgui.Col
		local ImVec4 							= imgui.ImVec4
		local ImVec2 							= imgui.ImVec2

		style.WindowTitleAlign 					= ImVec2(0.5, 0.5)
		style.WindowPadding 					= ImVec2(15, 15)
		style.WindowRounding 					= 6.0
		style.FramePadding 						= ImVec2(5, 5)
		style.FrameRounding 					= 5.0
		style.ItemSpacing						= ImVec2(12, 8)
		style.ItemInnerSpacing 					= ImVec2(8, 6)
		style.IndentSpacing 					= 25.0
		style.ScrollbarSize 					= 15
		style.ScrollbarRounding 				= 9.0
		style.GrabMinSize 						= 5.0
		style.GrabRounding 						= 3.0
		style.ChildWindowRounding 				= 5.0
		if configuration.main_settings.style == 0 or configuration.main_settings.style == nil then -- на основе https://www.blast.hk/threads/25442/post-310168
			colors[clr.Text] 					= ImVec4(0.80, 0.80, 0.83, 1.00)
			colors[clr.TextDisabled] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
			colors[clr.WindowBg] 				= ImVec4(0.06, 0.05, 0.07, 0.95)
			colors[clr.ChildWindowBg] 			= ImVec4(0.10, 0.09, 0.12, 0.50)
			colors[clr.PopupBg] 				= ImVec4(0.07, 0.07, 0.09, 1.00)
			colors[clr.Border] 					= ImVec4(0.40, 0.40, 0.53, 0.18)
			colors[clr.BorderShadow] 			= ImVec4(0.92, 0.91, 0.88, 0.00)
			colors[clr.FrameBg] 				= ImVec4(0.15, 0.14, 0.16, 0.50)
			colors[clr.FrameBgHovered] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
			colors[clr.FrameBgActive] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
			colors[clr.TitleBg] 				= ImVec4(0.76, 0.31, 0.00, 1.00)
			colors[clr.TitleBgCollapsed] 		= ImVec4(1.00, 0.98, 0.95, 0.75)
			colors[clr.TitleBgActive] 			= ImVec4(0.80, 0.33, 0.00, 1.00)
			colors[clr.MenuBarBg] 				= ImVec4(0.10, 0.09, 0.12, 1.00)
			colors[clr.ScrollbarBg] 			= ImVec4(0.10, 0.09, 0.12, 1.00)
			colors[clr.ScrollbarGrab] 			= ImVec4(0.80, 0.80, 0.83, 0.31)
			colors[clr.ScrollbarGrabHovered] 	= ImVec4(0.56, 0.56, 0.58, 1.00)
			colors[clr.ScrollbarGrabActive] 	= ImVec4(0.06, 0.05, 0.07, 1.00)
			colors[clr.ComboBg] 				= ImVec4(0.19, 0.18, 0.21, 1.00)
			colors[clr.CheckMark] 				= ImVec4(1.00, 0.42, 0.00, 0.53)
			colors[clr.SliderGrab] 				= ImVec4(1.00, 0.42, 0.00, 0.53)
			colors[clr.SliderGrabActive] 		= ImVec4(1.00, 0.42, 0.00, 1.00)
			colors[clr.Button] 					= ImVec4(0.15, 0.14, 0.21, 0.60)
			colors[clr.ButtonHovered] 			= ImVec4(0.24, 0.23, 0.29, 1.00)
			colors[clr.ButtonActive] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
			colors[clr.Header] 					= ImVec4(0.10, 0.09, 0.12, 1.00)
			colors[clr.HeaderHovered] 			= ImVec4(0.56, 0.56, 0.58, 1.00)
			colors[clr.HeaderActive] 			= ImVec4(0.06, 0.05, 0.07, 1.00)
			colors[clr.ResizeGrip] 				= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.ResizeGripHovered] 		= ImVec4(0.56, 0.56, 0.58, 1.00)
			colors[clr.ResizeGripActive] 		= ImVec4(0.06, 0.05, 0.07, 1.00)
			colors[clr.CloseButton] 			= ImVec4(0.91, 0.44, 0.00, 1.00)
			colors[clr.CloseButtonHovered] 		= ImVec4(0.40, 0.39, 0.38, 0.39)
			colors[clr.CloseButtonActive] 		= ImVec4(0.40, 0.39, 0.38, 1.00)
			colors[clr.PlotLines] 				= ImVec4(0.40, 0.39, 0.38, 0.63)
			colors[clr.PlotLinesHovered]		= ImVec4(0.25, 1.00, 0.00, 1.00)
			colors[clr.PlotHistogram] 			= ImVec4(0.40, 0.39, 0.38, 0.63)
			colors[clr.PlotHistogramHovered] 	= ImVec4(0.25, 1.00, 0.00, 1.00)
			colors[clr.TextSelectedBg] 			= ImVec4(0.25, 1.00, 0.00, 0.43)
			colors[clr.ModalWindowDarkening] 	= ImVec4(0.00, 0.00, 0.00, 0.30)
			--textcolorinhex						= '{ccccd4}'
		elseif configuration.main_settings.style == 1 then -- из Bank Helper
			colors[clr.Text]				   	= ImVec4(0.95, 0.96, 0.98, 1.00)
			colors[clr.TextDisabled]		   	= ImVec4(0.29, 0.29, 0.29, 1.00)
			colors[clr.WindowBg]			   	= ImVec4(0.14, 0.14, 0.14, 1.00)
			colors[clr.ChildWindowBg]		  	= ImVec4(0.14, 0.14, 0.14, 1.00)
			colors[clr.PopupBg]					= ImVec4(0.14, 0.14, 0.14, 1.00)
			colors[clr.Border]				 	= ImVec4(1.00, 0.28, 0.28, 0.50)
			colors[clr.BorderShadow]		   	= ImVec4(1.00, 1.00, 1.00, 0.00)
			colors[clr.FrameBg]					= ImVec4(0.22, 0.22, 0.22, 1.00)
			colors[clr.FrameBgHovered]		 	= ImVec4(0.18, 0.18, 0.18, 1.00)
			colors[clr.FrameBgActive]		  	= ImVec4(0.09, 0.12, 0.14, 1.00)
			colors[clr.TitleBg]					= ImVec4(1.00, 0.30, 0.30, 1.00)
			colors[clr.TitleBgActive]		  	= ImVec4(1.00, 0.30, 0.30, 1.00)
			colors[clr.TitleBgCollapsed]	   	= ImVec4(1.00, 0.30, 0.30, 1.00)
			colors[clr.MenuBarBg]			  	= ImVec4(0.20, 0.20, 0.20, 1.00)
			colors[clr.ScrollbarBg]				= ImVec4(0.02, 0.02, 0.02, 0.39)
			colors[clr.ScrollbarGrab]		  	= ImVec4(0.36, 0.36, 0.36, 1.00)
			colors[clr.ScrollbarGrabHovered]   	= ImVec4(0.18, 0.22, 0.25, 1.00)
			colors[clr.ScrollbarGrabActive]		= ImVec4(0.24, 0.24, 0.24, 1.00)
			colors[clr.ComboBg]					= ImVec4(0.24, 0.24, 0.24, 1.00)
			colors[clr.CheckMark]			  	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.SliderGrab]			 	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.SliderGrabActive]	   	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.Button]				 	= ImVec4(1.00, 0.30, 0.30, 1.00)
			colors[clr.ButtonHovered]		  	= ImVec4(1.00, 0.25, 0.25, 1.00)
			colors[clr.ButtonActive]		   	= ImVec4(1.00, 0.20, 0.20, 1.00)
			colors[clr.Header]				 	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.HeaderHovered]		  	= ImVec4(1.00, 0.39, 0.39, 1.00)
			colors[clr.HeaderActive]		   	= ImVec4(1.00, 0.21, 0.21, 1.00)
			colors[clr.ResizeGrip]			 	= ImVec4(1.00, 0.28, 0.28, 1.00)
			colors[clr.ResizeGripHovered]	  	= ImVec4(1.00, 0.39, 0.39, 1.00)
			colors[clr.ResizeGripActive]	   	= ImVec4(1.00, 0.19, 0.19, 1.00)
			colors[clr.CloseButton]				= ImVec4(1.00, 0.00, 0.00, 0.50)
			colors[clr.CloseButtonHovered]	 	= ImVec4(1.00, 0.00, 0.00, 0.60)
			colors[clr.CloseButtonActive]	  	= ImVec4(1.00, 0.00, 0.00, 0.70)
			colors[clr.PlotLines]			  	= ImVec4(0.61, 0.61, 0.61, 1.00)
			colors[clr.PlotLinesHovered]	   	= ImVec4(1.00, 0.43, 0.35, 1.00)
			colors[clr.PlotHistogram]		  	= ImVec4(1.00, 0.21, 0.21, 1.00)
			colors[clr.PlotHistogramHovered]   	= ImVec4(1.00, 0.18, 0.18, 1.00)
			colors[clr.TextSelectedBg]		 	= ImVec4(1.00, 0.25, 0.25, 1.00)
			colors[clr.ModalWindowDarkening]   	= ImVec4(0.00, 0.00, 0.00, 0.30)
			--textcolorinhex						= '{f2f5fa}'
		elseif configuration.main_settings.style == 2 then -- https://www.blast.hk/threads/25442/post-262906
			colors[clr.Text]					= ImVec4(0.00, 0.00, 0.00, 0.51)
			colors[clr.TextDisabled]   			= ImVec4(0.24, 0.24, 0.24, 1.00)
			colors[clr.WindowBg]				= ImVec4(1.00, 1.00, 1.00, 1.00)
			colors[clr.ChildWindowBg]			= ImVec4(0.96, 0.96, 0.96, 1.00)
			colors[clr.PopupBg]			  	= ImVec4(0.92, 0.92, 0.92, 1.00)
			colors[clr.Border]			   	= ImVec4(0.00, 0.49, 1.00, 0.78)
			colors[clr.BorderShadow]		 	= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.FrameBg]			  	= ImVec4(0.68, 0.68, 0.68, 0.50)
			colors[clr.FrameBgHovered]	   	= ImVec4(0.82, 0.82, 0.82, 1.00)
			colors[clr.FrameBgActive]			= ImVec4(0.76, 0.76, 0.76, 1.00)
			colors[clr.TitleBg]			  	= ImVec4(0.00, 0.45, 1.00, 0.82)
			colors[clr.TitleBgCollapsed]	 	= ImVec4(0.00, 0.45, 1.00, 0.82)
			colors[clr.TitleBgActive]			= ImVec4(0.00, 0.45, 1.00, 0.82)
			colors[clr.MenuBarBg]				= ImVec4(0.00, 0.37, 0.78, 1.00)
			colors[clr.ScrollbarBg]		  	= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.ScrollbarGrab]			= ImVec4(0.00, 0.35, 1.00, 0.78)
			colors[clr.ScrollbarGrabHovered] 	= ImVec4(0.00, 0.33, 1.00, 0.84)
			colors[clr.ScrollbarGrabActive]  	= ImVec4(0.00, 0.31, 1.00, 0.88)
			colors[clr.ComboBg]			  	= ImVec4(0.92, 0.92, 0.92, 1.00)
			colors[clr.CheckMark]				= ImVec4(0.00, 0.49, 1.00, 0.59)
			colors[clr.SliderGrab]		   	= ImVec4(0.00, 0.49, 1.00, 0.59)
			colors[clr.SliderGrabActive]	 	= ImVec4(0.00, 0.39, 1.00, 0.71)
			colors[clr.Button]			   	= ImVec4(0.00, 0.49, 1.00, 0.59)
			colors[clr.ButtonHovered]			= ImVec4(0.00, 0.49, 1.00, 0.71)
			colors[clr.ButtonActive]		 	= ImVec4(0.00, 0.49, 1.00, 0.78)
			colors[clr.Header]			   	= ImVec4(0.00, 0.49, 1.00, 0.78)
			colors[clr.HeaderHovered]			= ImVec4(0.00, 0.49, 1.00, 0.71)
			colors[clr.HeaderActive]		 	= ImVec4(0.00, 0.49, 1.00, 0.78)
			colors[clr.Separator]			  	= ImVec4(0.00, 0.00, 0.00, 0.51)
			colors[clr.SeparatorHovered]	   	= ImVec4(0.00, 0.00, 0.00, 0.51)
			colors[clr.SeparatorActive]			= ImVec4(0.00, 0.00, 0.00, 0.51)
			colors[clr.ResizeGrip]		   	= ImVec4(0.00, 0.39, 1.00, 0.59)
			colors[clr.ResizeGripHovered]		= ImVec4(0.00, 0.27, 1.00, 0.59)
			colors[clr.ResizeGripActive]	 	= ImVec4(0.00, 0.25, 1.00, 0.63)
			colors[clr.CloseButton]		  	= ImVec4(0.00, 0.35, 0.96, 0.71)
			colors[clr.CloseButtonHovered]   	= ImVec4(0.00, 0.31, 0.88, 0.69)
			colors[clr.CloseButtonActive]		= ImVec4(0.00, 0.25, 0.88, 0.67)
			colors[clr.PlotLines]				= ImVec4(0.00, 0.39, 1.00, 0.75)
			colors[clr.PlotLinesHovered]	 	= ImVec4(0.00, 0.39, 1.00, 0.75)
			colors[clr.PlotHistogram]			= ImVec4(0.00, 0.39, 1.00, 0.75)
			colors[clr.PlotHistogramHovered] 	= ImVec4(0.00, 0.35, 0.92, 0.78)
			colors[clr.TextSelectedBg]	   	= ImVec4(0.00, 0.47, 1.00, 0.59)
			colors[clr.ModalWindowDarkening] 	= ImVec4(0.20, 0.20, 0.20, 0.35)
			--textcolorinhex						= '{7d7d7d}'
		elseif configuration.main_settings.style == 3 then -- из Bank Helper
			colors[clr.Text]					= ImVec4(1.00, 1.00, 1.00, 1.00)
			colors[clr.WindowBg]			  	= ImVec4(0.14, 0.12, 0.16, 1.00)
			colors[clr.ChildWindowBg]		 	= ImVec4(0.30, 0.20, 0.39, 0.00)
			colors[clr.PopupBg]			   	= ImVec4(0.05, 0.05, 0.10, 0.90)
			colors[clr.Border]					= ImVec4(0.89, 0.85, 0.92, 0.30)
			colors[clr.BorderShadow]		  	= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.FrameBg]			   	= ImVec4(0.30, 0.20, 0.39, 1.00)
			colors[clr.FrameBgHovered]			= ImVec4(0.41, 0.19, 0.63, 0.68)
			colors[clr.FrameBgActive]		 	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.TitleBg]			   	= ImVec4(0.41, 0.19, 0.63, 0.45)
			colors[clr.TitleBgCollapsed]	  	= ImVec4(0.41, 0.19, 0.63, 0.35)
			colors[clr.TitleBgActive]		 	= ImVec4(0.41, 0.19, 0.63, 0.78)
			colors[clr.MenuBarBg]			 	= ImVec4(0.30, 0.20, 0.39, 0.57)
			colors[clr.ScrollbarBg]		   	= ImVec4(0.30, 0.20, 0.39, 1.00)
			colors[clr.ScrollbarGrab]		 	= ImVec4(0.41, 0.19, 0.63, 0.31)
			colors[clr.ScrollbarGrabHovered]  	= ImVec4(0.41, 0.19, 0.63, 0.78)
			colors[clr.ScrollbarGrabActive]   	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.ComboBg]			   	= ImVec4(0.30, 0.20, 0.39, 1.00)
			colors[clr.CheckMark]			 	= ImVec4(0.56, 0.61, 1.00, 1.00)
			colors[clr.SliderGrab]				= ImVec4(0.41, 0.19, 0.63, 0.24)
			colors[clr.SliderGrabActive]	  	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.Button]					= ImVec4(0.41, 0.19, 0.63, 0.44)
			colors[clr.ButtonHovered]		 	= ImVec4(0.41, 0.19, 0.63, 0.86)
			colors[clr.ButtonActive]		  	= ImVec4(0.64, 0.33, 0.94, 1.00)
			colors[clr.Header]					= ImVec4(0.41, 0.19, 0.63, 0.76)
			colors[clr.HeaderHovered]		 	= ImVec4(0.41, 0.19, 0.63, 0.86)
			colors[clr.HeaderActive]		  	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.ResizeGrip]				= ImVec4(0.41, 0.19, 0.63, 0.20)
			colors[clr.ResizeGripHovered]	 	= ImVec4(0.41, 0.19, 0.63, 0.78)
			colors[clr.ResizeGripActive]	  	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.CloseButton]		   	= ImVec4(1.00, 1.00, 1.00, 0.75)
			colors[clr.CloseButtonHovered]		= ImVec4(0.88, 0.74, 1.00, 0.59)
			colors[clr.CloseButtonActive]	 	= ImVec4(0.88, 0.85, 0.92, 1.00)
			colors[clr.PlotLines]			 	= ImVec4(0.89, 0.85, 0.92, 0.63)
			colors[clr.PlotLinesHovered]	  	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.PlotHistogram]		 	= ImVec4(0.89, 0.85, 0.92, 0.63)
			colors[clr.PlotHistogramHovered]  	= ImVec4(0.41, 0.19, 0.63, 1.00)
			colors[clr.TextSelectedBg]			= ImVec4(0.41, 0.19, 0.63, 0.43)
			colors[clr.ModalWindowDarkening]  	= ImVec4(0.20, 0.20, 0.20, 0.35)
			--textcolorinhex						= '{ffffff}'
		elseif configuration.main_settings.style == 4 then -- https://www.blast.hk/threads/25442/post-555626
			colors[clr.Text]				   	= ImVec4(0.90, 0.90, 0.90, 1.00)
			colors[clr.TextDisabled]		   	= ImVec4(0.60, 0.60, 0.60, 1.00)
			colors[clr.WindowBg]			   	= ImVec4(0.08, 0.08, 0.08, 1.00)
			colors[clr.ChildWindowBg]		  	= ImVec4(0.10, 0.10, 0.10, 1.00)
			colors[clr.PopupBg]					= ImVec4(0.08, 0.08, 0.08, 1.00)
			colors[clr.Border]				 	= ImVec4(0.70, 0.70, 0.70, 0.40)
			colors[clr.BorderShadow]		   	= ImVec4(0.00, 0.00, 0.00, 0.00)
			colors[clr.FrameBg]					= ImVec4(0.15, 0.15, 0.15, 1.00)
			colors[clr.FrameBgHovered]		 	= ImVec4(0.19, 0.19, 0.19, 0.71)
			colors[clr.FrameBgActive]		  	= ImVec4(0.34, 0.34, 0.34, 0.79)
			colors[clr.TitleBg]					= ImVec4(0.00, 0.69, 0.33, 0.80)
			colors[clr.TitleBgActive]		  	= ImVec4(0.00, 0.74, 0.36, 1.00)
			colors[clr.TitleBgCollapsed]	   	= ImVec4(0.00, 0.69, 0.33, 0.50)
			colors[clr.MenuBarBg]			  	= ImVec4(0.00, 0.80, 0.38, 1.00)
			colors[clr.ScrollbarBg]				= ImVec4(0.16, 0.16, 0.16, 1.00)
			colors[clr.ScrollbarGrab]		  	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.ScrollbarGrabHovered]   	= ImVec4(0.00, 0.82, 0.39, 1.00)
			colors[clr.ScrollbarGrabActive]		= ImVec4(0.00, 1.00, 0.48, 1.00)
			colors[clr.ComboBg]					= ImVec4(0.20, 0.20, 0.20, 0.99)
			colors[clr.CheckMark]			  	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.SliderGrab]			 	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.SliderGrabActive]	   	= ImVec4(0.00, 0.77, 0.37, 1.00)
			colors[clr.Button]				 	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.ButtonHovered]		  	= ImVec4(0.00, 0.82, 0.39, 1.00)
			colors[clr.ButtonActive]		   	= ImVec4(0.00, 0.87, 0.42, 1.00)
			colors[clr.Header]				 	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.HeaderHovered]		  	= ImVec4(0.00, 0.76, 0.37, 0.57)
			colors[clr.HeaderActive]		   	= ImVec4(0.00, 0.88, 0.42, 0.89)
			colors[clr.Separator]			  	= ImVec4(1.00, 1.00, 1.00, 0.40)
			colors[clr.SeparatorHovered]	   	= ImVec4(1.00, 1.00, 1.00, 0.60)
			colors[clr.SeparatorActive]			= ImVec4(1.00, 1.00, 1.00, 0.80)
			colors[clr.ResizeGrip]			 	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.ResizeGripHovered]	  	= ImVec4(0.00, 0.76, 0.37, 1.00)
			colors[clr.ResizeGripActive]	   	= ImVec4(0.00, 0.86, 0.41, 1.00)
			colors[clr.CloseButton]				= ImVec4(0.00, 0.82, 0.39, 1.00)
			colors[clr.CloseButtonHovered]	 	= ImVec4(0.00, 0.88, 0.42, 1.00)
			colors[clr.CloseButtonActive]	  	= ImVec4(0.00, 1.00, 0.48, 1.00)
			colors[clr.PlotLines]			  	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.PlotLinesHovered]	   	= ImVec4(0.00, 0.74, 0.36, 1.00)
			colors[clr.PlotHistogram]		  	= ImVec4(0.00, 0.69, 0.33, 1.00)
			colors[clr.PlotHistogramHovered]   	= ImVec4(0.00, 0.80, 0.38, 1.00)
			colors[clr.TextSelectedBg]		 	= ImVec4(0.00, 0.69, 0.33, 0.72)
			colors[clr.ModalWindowDarkening]   	= ImVec4(0.17, 0.17, 0.17, 0.48)
			--textcolorinhex						= '{e5e5e5}'
		else
			configuration.main_settings.style = 0
			checkstyle()
		end
	end

	function string.split(inputstr, sep)
		if sep == nil then
				sep = '%s'
		end
		local t={} ; i=1
		for str in string.gmatch(inputstr, '([^'..sep..']+)') do
				t[i] = str
				i = i + 1
		end
		return t
	end

	--Разделение на точки: https://www.blast.hk/threads/13380/post-220949
	function string.separate(a)
		local b, e = ('%d'):format(a):gsub('^%-', '')
		local c = b:reverse():gsub('%d%d%d', '%1.')
		local d = c:reverse():gsub('^%.', '')
		return (e == 1 and '-' or '')..d
	end

	function string.rlower(s)
		local russian_characters = {
			[155] = '[', [168] = 'Ё', [184] = 'ё', [192] = 'А', [193] = 'Б', [194] = 'В', [195] = 'Г', [196] = 'Д', [197] = 'Е', [198] = 'Ж', [199] = 'З', [200] = 'И', [201] = 'Й', [202] = 'К', [203] = 'Л', [204] = 'М', [205] = 'Н', [206] = 'О', [207] = 'П', [208] = 'Р', [209] = 'С', [210] = 'Т', [211] = 'У', [212] = 'Ф', [213] = 'Х', [214] = 'Ц', [215] = 'Ч', [216] = 'Ш', [217] = 'Щ', [218] = 'Ъ', [219] = 'Ы', [220] = 'Ь', [221] = 'Э', [222] = 'Ю', [223] = 'Я', [224] = 'а', [225] = 'б', [226] = 'в', [227] = 'г', [228] = 'д', [229] = 'е', [230] = 'ж', [231] = 'з', [232] = 'и', [233] = 'й', [234] = 'к', [235] = 'л', [236] = 'м', [237] = 'н', [238] = 'о', [239] = 'п', [240] = 'р', [241] = 'с', [242] = 'т', [243] = 'у', [244] = 'ф', [245] = 'х', [246] = 'ц', [247] = 'ч', [248] = 'ш', [249] = 'щ', [250] = 'ъ', [251] = 'ы', [252] = 'ь', [253] = 'э', [254] = 'ю', [255] = 'я',
		}
		s = s:lower()
		local strlen = s:len()
		if strlen == 0 then return s end
		s = s:lower()
		local output = ''
		for i = 1, strlen do
			local ch = s:byte(i)
			if ch >= 192 and ch <= 223 then output = output .. russian_characters[ch + 32]
			elseif ch == 168 then output = output .. russian_characters[184]
			else output = output .. string.char(ch)
			end
		end
		return output
	end

	function GetMyGender() -- bhelper
		local skins = {
			[0] = {0, 1, 2, 3, 4, 5, 6, 7, 8, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 57, 58, 59, 60, 61, 62, 66, 67, 68, 70, 71, 72, 73, 78, 79, 80, 81, 82, 83, 84, 86, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 132, 133, 134, 135, 136, 137, 142, 143, 144, 146, 147, 149, 153, 154, 155, 156, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 170, 171, 173, 174, 175, 176, 177, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 200, 202, 203, 204, 206, 208, 209, 210, 212, 213, 217, 220, 221, 222, 223, 227, 228, 229, 230, 234, 235, 236, 239, 240, 241, 242, 247, 248, 249, 250, 252, 253, 254, 255, 258, 259, 260, 261, 262, 264, 265, 266, 267, 268, 269, 270, 271, 272, 273, 274, 275, 276, 277, 278, 279, 280, 281, 282, 283, 284, 285, 286, 287, 288, 289, 290, 291, 292, 293, 294, 295, 296, 297, 299, 300, 301, 302, 303, 304, 305, 310, 311}, 
			[1] = {9, 10, 11, 12, 13, 31, 38, 39, 40, 41, 53, 54, 55, 56, 63, 64, 65, 69, 75, 76, 77, 85, 87, 88, 89, 90, 91, 92, 93, 129, 130, 131, 138, 139, 140, 141, 145, 148, 150, 151, 152, 157, 169, 172, 178, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 201, 205, 207, 211, 214, 215, 216, 218, 219, 224, 225, 226, 231, 232, 233, 237, 238, 243, 244, 245, 246, 251, 256, 257, 263, 298, 306, 307, 308, 309}
		}
		for k, v in pairs(skins) do
			for _, skin in pairs(v) do
				if skin == getCharModel(playerPed) then
					usersettings.gender.v = k
					configuration.main_settings.gender = k
					if inicfg.save(configuration,'AS Helper') then
						local r, g, b, a = imgui.ImColor(configuration.main_settings.ASChatColor):GetRGBA()
						ASHelperMessage(string.format('Пол был выбран: {MC}%s', usersettings.gender.v and 'Мужской' or 'Женский'))
					end
					return k
				end
			end
		end
		return nil
	end

	function imgui.GetKeys(bool,maxkeys)
		if bool then
			local function getDownKeys()
				local curkeys = ''
				local bool = false
				for k, v in pairs(vkeys) do
					if isKeyDown(v) and (v == VK_MENU or v == VK_CONTROL or v == VK_SHIFT or v == VK_LMENU or v == VK_RMENU or v == VK_RCONTROL or v == VK_LCONTROL or v == VK_LSHIFT or v == VK_RSHIFT) then
						if v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT then
							curkeys = v
						end
					end
				end
				for k, v in pairs(vkeys) do
					if isKeyDown(v) and (v ~= VK_MENU and v ~= VK_CONTROL and v ~= VK_SHIFT and v ~= VK_LMENU and v ~= VK_RMENU and v ~= VK_RCONTROL and v ~= VK_LCONTROL and v ~= VK_LSHIFT and v ~= VK_RSHIFT) then
						if tostring(curkeys):len() == 0 then
							curkeys = v
						else
							curkeys = curkeys .. ' ' .. v
						end
						bool = true
					end
				end
				return curkeys, bool
			end
			
			local tKeys = string.split(getDownKeys(), ' ')
			if #tKeys ~= 0 then
				for i = 1, #tKeys do
					if maxkeys > 1 then
						if #tKeys == 1 then
							str = vkeys.id_to_name(tonumber(tKeys[i]))
							return true,'ЛКМ - сохранение '..str
						elseif #tKeys == maxkeys then
							if str and not str:find(vkeys.id_to_name(tonumber(tKeys[i]))) then
								str = str .. ' + ' .. vkeys.id_to_name(tonumber(tKeys[i]))
								return false,str
							end
						else
							return true,'None'
						end
					else
						str = vkeys.id_to_name(tonumber(tKeys[i]))
						return false, str
					end
				end
			else
				return true,'None'
			end
		end
	end

	function imgui.SmoothButton(bool, name, wide) -- на основе https://www.blast.hk/threads/49782/
		local animTime = 0.25
		local drawList = imgui.GetWindowDrawList()
		local p1 = imgui.GetCursorScreenPos()
		local p2 = imgui.GetCursorPos()
		local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetRGBA()
		local hex = string.format('%06X', bit.band(join_argb(a, b, g, r), 0xFFFFFF))
		local button = imgui.InvisibleButton(name, imgui.ImVec2(wide, 30))
		if button and not bool then navigateLast = os.clock() end
		local pressed = imgui.IsItemActive()
		drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 220, p1.y + 30), ('0x20%s'):format(hex))
		if bool then
			if navigateLast and (os.clock() - navigateLast) < animTime then
				local wide = (os.clock() - navigateLast) * (wide / animTime)
				drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + wide, p1.y + 30), ('0x80%s'):format(hex))
				drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + 5, p1.y + 30), ('0xFF%s'):format(hex))
			else
				drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + wide, p1.y + 30), ('0x80%s'):format(hex))
				drawList:AddRectFilled(imgui.ImVec2(p1.x, (pressed and p1.y or p1.y)), imgui.ImVec2(p1.x + 5, (pressed and p1.y + 30 or p1.y + 30)), ('0xFF%s'):format(hex))
			end
		else
			if imgui.IsItemHovered() then
				drawList:AddRectFilled(imgui.ImVec2(p1.x, p1.y), imgui.ImVec2(p1.x + wide, p1.y + 30), ('0x10%s'):format(hex))
				drawList:AddRectFilled(imgui.ImVec2(p1.x, (pressed and p1.y or p1.y)), imgui.ImVec2(p1.x + 5, (pressed and p1.y + 30 or p1.y + 30)), ('0x70%s'):format(hex))
			end
		end
		imgui.SameLine(10)
		imgui.SetCursorPos(imgui.ImVec2((wide - imgui.CalcTextSize(name).x) / 2, p2.y + 8))
		imgui.Text(name)
		imgui.SetCursorPosY(p2.y + 36.7)
		return button
	end

	function imgui.BoolButton(bool, name) -- из https://www.blast.hk/threads/59761/
		if type(bool) ~= 'boolean' then return end
		if bool then
			local button = imgui.Button(name)
			return button
		else
			local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetFloat4()
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, a/1))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, a/1))
			imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
			local button = imgui.Button(name)
			imgui.PopStyleColor(4)
			return button
		end
	end

	function imgui.LockedButton(text, size)
		local r, g, b, a = imgui.ImColor(imgui.GetStyle().Colors[imgui.Col.Button]):GetFloat4()
		imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(r, g, b, a/2) )
		imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(r, g, b, a/2))
		imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(r, g, b, a/2))
		imgui.PushStyleColor(imgui.Col.Text, imgui.GetStyle().Colors[imgui.Col.TextDisabled])
		local button = imgui.Button(text, size)
		imgui.PopStyleColor(4)
		return button
	end

	function imgui.TextColoredRGB(text,align)
		local width = imgui.GetWindowWidth()
		local style = imgui.GetStyle()
		local colors = style.Colors
		local ImVec4 = imgui.ImVec4
	
		local explode_argb = function(argb)
			local a = bit.band(bit.rshift(argb, 24), 0xFF)
			local r = bit.band(bit.rshift(argb, 16), 0xFF)
			local g = bit.band(bit.rshift(argb, 8), 0xFF)
			local b = bit.band(argb, 0xFF)
			return a, r, g, b
		end
	
		local getcolor = function(color)
			if color:sub(1, 6):upper() == 'SSSSSS' then
				local r, g, b = colors[1].x, colors[1].y, colors[1].z
				local a = tonumber(color:sub(7, 8), 16) or colors[1].w * 255
				return ImVec4(r, g, b, a / 255)
			end
			local color = type(color) == 'string' and tonumber(color, 16) or color
			if type(color) ~= 'number' then return end
			local r, g, b, a = explode_argb(color)
			return imgui.ImColor(r, g, b, a):GetVec4()
		end
	
		local render_text = function(text_)
			for w in text_:gmatch('[^\r\n]+') do
				local textsize = w:gsub('{.-}', '')
				local text_width = imgui.CalcTextSize(u8(textsize))
				if align == 1 then imgui.SetCursorPosX( width / 2 - text_width .x / 2 )
				elseif align == 2 then imgui.SetCursorPosX(imgui.GetCursorPosX() + width - text_width.x - imgui.GetScrollX() - 2 * imgui.GetStyle().ItemSpacing.x - imgui.GetStyle().ScrollbarSize)
				end
				local text, colors_, m = {}, {}, 1
				w = w:gsub('{(......)}', '{%1FF}')
				while w:find('{........}') do
					local n, k = w:find('{........}')
					local color = getcolor(w:sub(n + 1, k - 1))
					if color then
						text[#text], text[#text + 1] = w:sub(m, n - 1), w:sub(k + 1, #w)
						colors_[#colors_ + 1] = color
						m = n
					end
					w = w:sub(1, n - 1) .. w:sub(k + 1, #w)
				end
				if text[0] then
					for i = 0, #text do
						imgui.TextColored(colors_[i] or colors[1], u8(text[i]))
						imgui.SameLine(nil, 0)
					end
					imgui.NewLine()
				else imgui.Text(u8(w)) end
			end
		end
		render_text(text)
	end

	function imgui.Hint(text, delay, action)
		if imgui.IsItemHovered() then
			if hintanim == nil then hintanim = os.clock() + (delay and delay or 0.0) end
			local alpha = (os.clock() - hintanim) * 5
			if os.clock() >= hintanim then
				imgui.PushStyleVar(imgui.StyleVar.WindowPadding, imgui.ImVec2(10, 10))
				imgui.PushStyleVar(imgui.StyleVar.Alpha, (alpha <= 1.0 and alpha or 1.0))
					imgui.PushStyleColor(imgui.Col.PopupBg, imgui.ImVec4(0.11, 0.11, 0.11, 0.80))
						imgui.BeginTooltip()
						imgui.PushTextWrapPos(450)
						imgui.SetCursorPosX( imgui.GetWindowWidth() / 2 - imgui.CalcTextSize(fa.ICON_FA_INFO_CIRCLE..u8' Подсказка:').x / 2 )
						imgui.TextColored(imgui.ImVec4(1.00, 1.00, 1.00, 1.00), fa.ICON_FA_INFO_CIRCLE..u8' Подсказка')
						imgui.TextColoredRGB(('{FFFFFF}%s'):format(text),1)
						if action ~= nil then imgui.Text(('\n %s'):format(action)) end
						if not imgui.IsItemVisible() and imgui.GetStyle().Alpha == 1.0 then hintanim = nil end
						imgui.PopTextWrapPos()
						imgui.EndTooltip()
					imgui.PopStyleColor()
				imgui.PopStyleVar(2)
			end
		end
	end

	function Rule()
		if imgui.BeginPopupModal(u8('Правила'), nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
			imgui.TextColoredRGB(ruless[RuleSelect].name,1)
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
			imgui.PushItemWidth(200)
			imgui.InputText('##search_rule', search_rule, imgui.InputTextFlags.EnterReturnsTrue) -- bank helper
			if not imgui.IsItemActive() and #search_rule.v == 0 then
				imgui.SameLine((imgui.GetWindowWidth() - imgui.CalcTextSize(fa.ICON_FA_SEARCH..u8(' Искать')).x) / 2)
				imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), fa.ICON_FA_SEARCH..u8(' Искать'))
			end
			imgui.SameLine(928)
			if imgui.BoolButton(rule_align.v == 1,fa.ICON_FA_ALIGN_LEFT, imgui.ImVec2(40, 20)) then
				rule_align.v = 1
				configuration.main_settings.rule_align = rule_align.v
				inicfg.save(configuration,'AS Helper.ini')
			end
			imgui.SameLine()
			if imgui.BoolButton(rule_align.v == 2,fa.ICON_FA_ALIGN_CENTER, imgui.ImVec2(40, 20)) then
				rule_align.v = 2
				configuration.main_settings.rule_align = rule_align.v
				inicfg.save(configuration,'AS Helper.ini')
			end
			imgui.SameLine()
			if imgui.BoolButton(rule_align.v == 3,fa.ICON_FA_ALIGN_RIGHT, imgui.ImVec2(40, 20)) then
				rule_align.v = 3
				configuration.main_settings.rule_align = rule_align.v
				inicfg.save(configuration,'AS Helper.ini')
			end
			imgui.BeginChild('##Правила', imgui.ImVec2(1000, 500), true)
			for _,line in ipairs(ruless[RuleSelect].text) do
				if #search_rule.v < 1 then
					imgui.TextColoredRGB(line,rule_align.v-1)
					imgui.Hint('Двойной клик перенесёт строку в чат.', 2)
					if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
						sampSetChatInputEnabled(true)
						sampSetChatInputText(line:gsub('%{.+%}',''))
					end
				else
					if string.rlower(line):find(string.rlower(u8:decode(search_rule.v)):gsub('(%p)','(%%p)')) then
						imgui.TextColoredRGB(line,rule_align.v-1)
						imgui.Hint('Двойной клик перенесёт строку в чат.', 2)
						if imgui.IsItemHovered() and imgui.IsMouseDoubleClicked(0) then
							sampSetChatInputEnabled(true)
							sampSetChatInputText(line:gsub('%{.+%}',''))
						end
					end
				end	
			end
			imgui.EndChild()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 200) / 2)
			if imgui.Button(u8'Закрыть',imgui.ImVec2(200,25)) then imgui.CloseCurrentPopup() end
			imgui.EndPopup()
		end
	end

	function otheractions()
		if imgui.BeginPopup(u8'Остальное', nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			if imgui.Button(u8'Сбросить конфиг '..(fa.ICON_FA_TRASH), imgui.ImVec2(160,25)) then
				windows.imgui_settings.v = false
				windows.imgui_fm.v = false
				windows.imgui_sobes.v = false
				windows.imgui_lect.v = false
				windows.imgui_binder.v = false
				windows.imgui_depart.v = false
				windows.imgui_changelog.v = false
				imgui.ShowCursor = false
				os.remove('moonloader/config/AS Helper.ini')
				configuration = {}
				NoErrors = true
				thisScript():reload()
				imgui.CloseCurrentPopup()
			end
			imgui.Hint('{CC0000}После нажатия все ваши бинды, настройки\n{CC0000} и цены на лицензии будут сброшены.')
			if imgui.Button(u8'Перезагрузить скрипт '..(fa.ICON_FA_REDO_ALT), imgui.ImVec2(160,25)) then
				NoErrors = true
				thisScript():reload()
			end
			if imgui.Button(u8'Выгрузить скрипт '..(fa.ICON_FA_LOCK), imgui.ImVec2(160,25)) then
				NoErrors = true
				thisScript():unload()
			end
			if imgui.Button(u8'Очистить чат '..(fa.ICON_FA_COMMENT_ALT), imgui.ImVec2(160,25)) then
				local memory = require 'memory'
				memory.fill(sampGetChatInfoPtr() + 306, 0x0, 25200)
				memory.write(sampGetChatInfoPtr() + 306, 25562, 4, 0x0)
				memory.write(sampGetChatInfoPtr() + 0x63DA, 1, 1)
			end
			imgui.EndPopup()
		end
	end

	function communicate()
		if imgui.BeginPopup(u8'Связь', nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.23, 0.49, 0.96, 0.8))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.23, 0.49, 0.96, 0.9))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.23, 0.49, 0.96, 1))
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 1))
			if imgui.Button(u8'ВКонтакте', imgui.ImVec2(90, 25)) then
				ASHelperMessage('Ссылка была скопирована')
				setClipboardText('https://vk.com/id468019660')
			end
			imgui.PopStyleColor(4)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.46, 0.51, 0.85, 0.8))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.46, 0.51, 0.85, 0.9))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.46, 0.51, 0.85, 1))
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 1))
			if imgui.Button(u8'Discord', imgui.ImVec2(90, 25)) then
				ASHelperMessage('Ник был скопирован')
				setClipboardText('JustMini#3885')
			end
			imgui.PopStyleColor(4)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.19, 0.22, 0.26, 0.8))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.19, 0.22, 0.26, 0.9))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.19, 0.22, 0.26, 1))
			imgui.PushStyleColor(imgui.Col.Text, imgui.ImVec4(1, 1, 1, 1))
			if imgui.Button(u8'BlastHack', imgui.ImVec2(90, 25)) then
				ASHelperMessage('Ссылка была скопирована')
				setClipboardText('https://www.blast.hk/threads/87533/')
			end
			imgui.PopStyleColor(4)
			imgui.EndPopup()
		end
	end

	function editquestion()
		if imgui.BeginPopup(u8'Редактор вопросов', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.Text(u8'Название кнопки:')
			imgui.SameLine()
			imgui.SetCursorPosX(125)
			imgui.InputText('##questeditorname', questionsettings.questionname)
			imgui.Text(u8'Вопрос: ')
			imgui.SameLine()
			imgui.SetCursorPosX(125)
			imgui.InputText('##questeditorques', questionsettings.questionques)
			imgui.Text(u8'Подсказка: ')
			imgui.SameLine()
			imgui.SetCursorPosX(125)
			imgui.InputText('##questeditorhint', questionsettings.questionhint)
			imgui.SetCursorPosX( (imgui.GetWindowWidth() - 300 - imgui.GetStyle().ItemSpacing.x) / 2 )
			if #questionsettings.questionhint.v > 0 and #questionsettings.questionques.v > 0 and #questionsettings.questionname.v > 0 then
				if imgui.Button(u8'Сохранить####questeditor', imgui.ImVec2(150, 25)) then
					if question_number == nil then 
						table.insert(questions.questions, {
							bname = u8:decode(tostring(questionsettings.questionname.v)),
							bq = u8:decode(tostring(questionsettings.questionques.v)),
							bhint = u8:decode(tostring(questionsettings.questionhint.v)),
						})
					else
						questions.questions[question_number].bname = u8:decode(tostring(questionsettings.questionname.v))
						questions.questions[question_number].bq = u8:decode(tostring(questionsettings.questionques.v))
						questions.questions[question_number].bhint = u8:decode(tostring(questionsettings.questionhint.v))
					end
					local file = io.open(getWorkingDirectory()..'\\AS Helper\\Questions.json', 'w')
					file:write(encodeJson(questions))
					file:close()
					imgui.CloseCurrentPopup()
				end
			else
				imgui.LockedButton(u8'Сохранить####questeditor', imgui.ImVec2(150, 25))
				imgui.Hint('Вы ввели не все параметры. Переповерьте всё.')
			end
			imgui.SameLine()
			if imgui.Button(u8'Отменить##questeditor', imgui.ImVec2(150, 25)) then imgui.CloseCurrentPopup() end
			imgui.EndPopup()
		end
	end

	function editlection()
		if imgui.BeginPopupModal(u8'Редактор лекций', _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize) then
			imgui.Text(u8'Название лекции:')
			imgui.SameLine()
			imgui.SetCursorPosY(35)
			imgui.InputText('##lecteditor', lectionsettings.lection_name)
			imgui.Text(u8'Текст лекции: ')
			imgui.InputTextMultiline('##lecteditortext', lectionsettings.lection_text, imgui.ImVec2(700, 300))
			imgui.SetCursorPosX( (imgui.GetWindowWidth() - 300 - imgui.GetStyle().ItemSpacing.x) / 2 )
			if #lectionsettings.lection_name.v > 0 and #lectionsettings.lection_text.v > 0 then
				if imgui.Button(u8'Сохранить##lecteditor', imgui.ImVec2(150, 25)) then
					local pack = function(text, match)
						local array = {}
						for line in text:gmatch('[^'..match..']+') do
							array[#array + 1] = line
						end
						return array
					end
					if lection_number == nil then 
						table.insert(lections.data, {
							name = u8:decode(tostring(lectionsettings.lection_name.v)),
							text = pack(u8:decode(tostring(lectionsettings.lection_text.v)), '\n')
						})
					else
						lections.data[lection_number].name = u8:decode(tostring(lectionsettings.lection_name.v))
						lections.data[lection_number].text = pack(u8:decode(tostring(lectionsettings.lection_text.v)), '\n')
					end
					local file = io.open(getWorkingDirectory()..'\\AS Helper\\Lections.json', 'w')
					file:write(encodeJson(lections))
					file:close()
					imgui.CloseCurrentPopup()
				end
			else
				imgui.LockedButton(u8'Сохранить##lecteditor', imgui.ImVec2(150, 25))
				imgui.Hint('Вы ввели не все параметры. Переповерьте всё.')
			end
			imgui.SameLine()
			if imgui.Button(u8'Отменить##lecteditor', imgui.ImVec2(150, 25)) then imgui.CloseCurrentPopup() end
			imgui.EndPopup()
		end
	end

	function bindertags()
		if imgui.BeginPopup(u8'Тэги', nil, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoTitleBar) then
			for k,v in pairs(tagbuttons) do
				if imgui.Button(u8(tagbuttons[k].name),imgui.ImVec2(150,25)) then
					bindersettings.binderbuff.v = bindersettings.binderbuff.v..''..u8(tagbuttons[k].name)
					ASHelperMessage('Тэг был скопирован.')
				end
				imgui.SameLine()
				if imgui.IsItemHovered() then
					imgui.BeginTooltip()
					imgui.Text(u8(tagbuttons[k].hint))
					imgui.EndTooltip()
				end
				imgui.Text(u8(tagbuttons[k].text))
			end
			imgui.EndPopup()
		end
	end

	function imgui.OnDrawFrame()
		if windows.imgui_fm.v then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Меню быстрого доступа', _, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse + (configuration.main_settings.noscrollbar and imgui.WindowFlags.NoScrollbar or imgui.WindowFlags.NoBringToFrontOnFocus))
			if windowtype == 0 then
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_HAND_PAPER..u8' Поприветствовать игрока', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 1 then
							getmyrank = true
							sampSendChat('/stats')
							lua_thread.create(function()
								inprocess = true
								if tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 4 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 13 then
									sampSendChat('Доброе утро, я {gender:сотрудник|сотрудница} Автошколы г. Сан-Фиерро, чем могу вам помочь?')
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 12 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 17 then
									sampSendChat('Добрый день, я {gender:сотрудник|сотрудница} Автошколы г. Сан-Фиерро, чем могу вам помочь?')
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) > 16 and tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 24 then
									sampSendChat('Добрый вечер, я {gender:сотрудник|сотрудница} Автошколы г. Сан-Фиерро, чем могу вам помочь?')
								elseif tonumber(os.date('%H', os.time(os.date('!*t')) + 2 * 60 * 60)) < 5 then
									sampSendChat('Доброй ночи, я {gender:сотрудник|сотрудница} Автошколы г. Сан-Фиерро, чем могу вам помочь?')
								end
								wait(2000)
								sampSendChat(('/do На груди висит бейджик с надписью %s %s.'):format(configuration.RankNames[configuration.main_settings.myrankint],(configuration.main_settings.useservername and string.gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname))))
								inprocess = false
							end)
						else
							ASHelperMessage('Данная команда доступна с 1-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_FILE_ALT..u8' Озвучить прайс лист', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 1  then
							lua_thread.create(function()
								inprocess = true
								sampSendChat('/do В кармане брюк лежит прайс лист на лицензии.')
								wait(2000)
								sampSendChat('/me {gender:достал|достала} прайс лист из кармана брюк и передал его клиенту')
								wait(2000)
								sampSendChat('/do В прайс листе написано:')
								wait(2000)
								sampSendChat(('/do Лицензия на вождение автомобилей - %s$.'):format(string.separate(configuration.main_settings.avtoprice)))
								wait(2000)
								sampSendChat(('/do Лицензия на вождение мотоциклов - %s$.'):format(string.separate(configuration.main_settings.motoprice)))
								wait(2000)
								sampSendChat(('/do Лицензия на рыболовство - %s$.'):format(string.separate(configuration.main_settings.ribaprice)))
								wait(2000)
								sampSendChat(('/do Лицензия на водный транспорт - %s$.'):format(string.separate(configuration.main_settings.lodkaprice)))
								wait(2000)
								sampSendChat(('/do Лицензия на оружие - %s$.'):format(string.separate(configuration.main_settings.gunaprice)))
								wait(2000)
								sampSendChat(('/do Лицензия на охоту - %s$.'):format(string.separate(configuration.main_settings.huntprice)))
								wait(2000)
								sampSendChat(('/do Лицензия на раскопки - %s$.'):format(string.separate(configuration.main_settings.kladprice)))
								wait(2000)
								sampSendChat(('/do Лицензия на работу таксиста - %s$.'):format(string.separate(configuration.main_settings.taxiprice)))
								inprocess = false
							end)
						else
							ASHelperMessage('Данная команда доступна с 1-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_FILE_SIGNATURE..u8' Продать лицензию игроку', imgui.ImVec2(285,30)) then
					if configuration.main_settings.myrankint >= 3 then
						imgui.SetScrollY(0)
						Licenses_select.v = 0
						windowtype = 1
					else
						ASHelperMessage('Данная команда доступна с 3-го ранга.')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_REPLY..u8' Выгнать из автошколы', imgui.ImVec2(285,30))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if imgui.IsMouseReleased(0) then
							if configuration.main_settings.myrankint >= 2 then
								if not inprocess then
									if not sampIsPlayerPaused(fastmenuID) then
										windows.imgui_fm.v = false
										lua_thread.create(function()
											local expelid = fastmenuID
											inprocess = true
											sampSendChat('/do Рация свисает на поясе.')
											wait(2000)
											sampSendChat('/me сняв рацию с пояса, {gender:вызвал|вызвала} охрану по ней')
											wait(2000)
											sampSendChat('/do Охрана выводит нарушителя из холла.')
											wait(2000)
											sampSendChat(('/expel %s %s'):format(expelid,configuration.main_settings.expelreason))
											inprocess = false
										end)
									else
										ASHelperMessage('Игрок находится в АФК!')
									end
								else
									ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
								end
							else
								ASHelperMessage('Данная команда доступна с 2-го ранга.')
							end
						end
						if imgui.IsMouseReleased(1) then
							imgui.OpenPopup('##changeexpelreason')
						end
					end
				end
				imgui.Hint('ЛКМ для того, чтобы выгнать человека\n{FFFFFF}ПКМ для того, чтобы настроить причину',0)
				if imgui.BeginPopup('##changeexpelreason') then
					imgui.Text(u8'Причина /expel:')
					if imgui.InputText('##expelreasonbuff',usersettings.expelreason) then
						configuration.main_settings.expelreason = u8:decode(usersettings.expelreason.v)
						inicfg.save(configuration,'AS Helper')
					end
					imgui.EndPopup()
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.Button(fa.ICON_FA_USER_PLUS..u8' Принять в организацию', imgui.ImVec2(285,30))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if not inprocess then
							if configuration.main_settings.myrankint >= 9 then
								if imgui.IsMouseReleased(0) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local inviteid = fastmenuID
										inprocess = true
										sampSendChat('/do Ключи от шкафчика в кармане.')
										wait(2000)
										sampSendChat('/me всунув руку в карман брюк, {gender:достал|достала} оттуда ключ от шкафчика')
										wait(2000)
										sampSendChat('/me {gender:передал|передала} ключ человеку напротив')
										wait(2000)
										sampSendChat('Добро пожаловать! Раздевалка за дверью.')
										wait(2000)
										sampSendChat('Со всей информацией Вы можете ознакомиться на оф. портале.')
										wait(2000)
										sampSendChat(('/invite %s'):format(inviteid))
										inprocess = false
									end)
								end
								if imgui.IsMouseReleased(1) then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local inviteid = fastmenuID
										inprocess = true
										sampSendChat('/do Ключи от шкафчика в кармане.')
										wait(2000)
										sampSendChat('/me всунув руку в карман брюк, {gender:достал|достала} оттуда ключ от шкафчика')
										wait(2000)
										sampSendChat('/me {gender:передал|передала} ключ человеку напротив')
										wait(2000)
										sampSendChat('Добро пожаловать! Раздевалка за дверью.')
										wait(2000)
										sampSendChat('Со всей информацией Вы можете ознакомиться на оф. портале.')
										wait(2000)
										sampSendChat(('/invite %s'):format(inviteid))
										waitingaccept = inviteid
										inprocess = false
									end)
								end
							else
								ASHelperMessage('Данная команда доступна с 9-го ранга.')
							end
						else
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						end
					end
				end
				imgui.Hint('ЛКМ для принятия человека в организацию\n{FFFFFF}ПКМ для принятия на должность Консультанта',0)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER_MINUS..u8' Уволить из организации', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							windowtype = 3
							uninvitebuf.v = ''
							blacklistbuf.v = ''
							uninvitebox.v = false
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_EXCHANGE_ALT..u8' Изменить должность', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							Ranks_select.v = 0
							windowtype = 4
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER_SLASH..u8' Занести в чёрный список', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							windowtype = 5
							blacklistbuff.v = ''
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_USER..u8' Убрать из чёрного списка', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							windows.imgui_fm.v = false
							lua_thread.create(function()
								local unblacklistid = fastmenuID
								inprocess = true
								sampSendChat('/me {gender:достал|достала} КПК из кармана')
								wait(2000)
								sampSendChat('/me {gender:перешёл|перешла} в раздел \'Чёрный список\'')
								wait(2000)
								sampSendChat('/me {gender:ввёл|ввела} имя гражданина в поиск')
								wait(2000)
								sampSendChat('/me {gender:убрал|убрала} гражданина из раздела \'Чёрный список\'')
								wait(2000)
								sampSendChat('/me {gender:подтведрдил|подтвердила} изменения')
								wait(2000)
								sampSendChat('/do Изменения были сохранены.')
								wait(2000)
								sampSendChat(('/unblacklist %s'):format(unblacklistid))
								inprocess = false
							end)
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_FROWN..u8' Выдать выговор сотруднику', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							fwarnbuff.v = ''
							windowtype = 6
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_SMILE..u8' Снять выговор сотруднику', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							windows.imgui_fm.v = false
							lua_thread.create(function()
								local unfwarnid = fastmenuID
								inprocess = true
								sampSendChat('/me {gender:достал|достала} КПК из кармана')
								wait(2000)
								sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\'')
								wait(2000)
								sampSendChat('/me {gender:зашёл|зашла} в раздел \'Выговоры\'')
								wait(2000)
								sampSendChat('/me найдя в разделе нужного сотрудника, {gender:убрал|убрала} из его личного дела один выговор')
								wait(2000)
								sampSendChat('/do Выговор был убран из личного дела сотрудника.')
									wait(2000)
								sampSendChat(('/unfwarn %s'):format(unfwarnid))
								inprocess = false
							end)
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_VOLUME_MUTE..u8' Выдать мут сотруднику', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							imgui.SetScrollY(0)
							fmutebuff.v = ''
							fmuteint.v = 0
							windowtype = 7
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(fa.ICON_FA_VOLUME_UP..u8' Снять мут сотруднику', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							windows.imgui_fm.v = false
							lua_thread.create(function()
								local funmuteid = fastmenuID
								inprocess = true
								sampSendChat('/me {gender:достал|достала} КПК из кармана')
								wait(2000)
								sampSendChat('/me {gender:включил|включила} КПК')
								wait(2000)
								sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками Автошколы\'')
								wait(2000)
								sampSendChat('/me {gender:выбрал|выбрала} нужного сотрудника')
								wait(2000)
								sampSendChat('/me {gender:выбрал|выбрала} пункт \'Включить рацию сотрудника\'')
								wait(2000)
								sampSendChat('/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\'')
								wait(2000)
								sampSendChat(('/funmute %s'):format(funmuteid))
								inprocess = false
							end)
						else
							ASHelperMessage('Данная команда доступна с 9-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Проверка устава '..fa.ICON_FA_STAMP, imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 5 then
							imgui.SetScrollY(0)
							lastq = false
							windowtype = 8
						else
							ASHelperMessage('Данное действие доступно с 5-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Собеседование '..fa.ICON_FA_ELLIPSIS_V, imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 5 then
							imgui.SetScrollY(0)
							passvalue = true
							mcvalue = true
							passverdict = ''
							mcverdict = ''
							sobesetap = 0
							sobesdecline_select.v = 0
							windows.imgui_fm.v = false
							windows.imgui_sobes.v = true
						else
							ASHelperMessage('Данное действие доступно с 5-го ранга.')
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
			end
	
			if windowtype == 1 then
				imgui.Text(u8'Лицензия: ', imgui.ImVec2(75,30))
				imgui.SameLine()
				imgui.Combo(' ', Licenses_select, Licenses_Arr, #Licenses_Arr)
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Продать лицензию на '..u8(string.rlower(u8:decode(Licenses_Arr[Licenses_select.v+1]))), imgui.ImVec2(285,30)) then
					if not inprocess then
						local selllic = function(param)
							sellto, lictype = param:match('(.+) (.+)')
							lictype = string.rlower(u8:decode(lictype))
							local sellto = tonumber(sellto)
							if lictype ~= nil and sellto ~= nil then
								if inprocess ~= true then
									if lictype == 'оружие' then
										sampSendChat('Хорошо, для покупки лицензии на оружие покажите мне свою мед.карту')
										sampSendChat(('/n /showmc %s'):format(select(2,sampGetPlayerIdByCharHandle(playerPed))))
										ASHelperMessage('Началось ожидание показа мед.карты.')
										skiporcancel = true
										tempid = fastmenuID
									else
										lua_thread.create(function()
											inprocess = true
											sampSendChat('/me {gender:взял|взяла} со стола бланк и {gender:заполнил|заполнила} ручкой бланк на получение лицензии на '..lictype)
											wait(2000)
											sampSendChat('/do Спустя некоторое время бланк на получение лицензии был заполнен.')
											wait(2000)
											sampSendChat(('/me распечатав лицензию на %s {gender:передал|передала} её человеку напротив'):format(lictype))
											wait(1000)
											givelic = true
											sampProcessChatInput(('/givelicense %s'):format(sellto))
											inprocess = false
										end)
									end
								else
									ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
								end
							end
						end
						selllic(tostring(('%s %s'):format(fastmenuID,Licenses_Arr[Licenses_select.v+1])))
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Лицензия на полёты', imgui.ImVec2(285,30)) then
					if not inprocess then
						sampSendChat('Получить лицензию на полёты Вы можете в авиашколе г. Лас-Вентурас')
						sampSendChat('/n /gps -> Важные места -> Следующая страница -> [LV] Авиашкола (9)')
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype = 0
				end
			end
	
			if windowtype == 3 then
				imgui.TextColoredRGB('Причина увольнения:',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'').x) / 5.7)
				imgui.InputText(u8'	', uninvitebuf)
				if uninvitebox.v then
					imgui.TextColoredRGB('Причина ЧС:',1)
					imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8' ').x) / 5.7)
					imgui.InputText(u8' ', blacklistbuf)
				end
				imgui.Checkbox(u8'Уволить с ЧС', uninvitebox)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Уволить '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
					if configuration.main_settings.myrankint >= 9 then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							if uninvitebuf.v == nil or uninvitebuf.v == '' then
								ASHelperMessage('Введите причину увольнения!')
							else
								if uninvitebox.v then
									if blacklistbuf.v == nil or blacklistbuf.v == '' then
										ASHelperMessage('Введите причину занесения в ЧС!')
									else
										windows.imgui_fm.v = false
										lua_thread.create(function()
											local uninviteid = fastmenuID
											inprocess = true
											sampSendChat('/time')
											sampSendChat('/me {gender:достал|достала} КПК из кармана')
											wait(2000)
											sampSendChat('/me {gender:перешёл|перешла} в раздел \'Увольнение\'')
											wait(2000)
											sampSendChat('/do Раздел открыт.')
											wait(2000)
											sampSendChat('/me {gender:внёс|внесла} человека в раздел \'Увольнение\'')
											wait(2000)
											sampSendChat('/me {gender:перешёл|перешла} в раздел \'Чёрный список\'')
											wait(2000)
											sampSendChat('/me {gender:занёс|занесла} сотрудника в раздел, после чего {gender:подтвердил|подтвердила} изменения')
											wait(2000)
											sampSendChat('/do Изменения были сохранены.')
											wait(2000)
											sampSendChat(('/uninvite %s %s'):format(uninviteid,u8:decode(uninvitebuf.v)))
											wait(2000)
											sampSendChat(('/blacklist %s %s'):format(uninviteid,u8:decode(blacklistbuf.v)))
											sampSendChat('/time')
											inprocess = false
										end)
									end
								else
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local uninviteid = fastmenuID
										inprocess = true
										sampSendChat('/time')
										sampSendChat('/me {gender:достал|достала} КПК из кармана')
										wait(2000)
										sampSendChat('/me {gender:перешёл|перешла} в раздел \'Увольнение\'')
										wait(2000)
										sampSendChat('/do Раздел открыт.')
										wait(2000)
										sampSendChat('/me {gender:внёс|внесла} человека в раздел \'Увольнение\'')
										wait(2000)
										sampSendChat('/me {gender:подтведрдил|подтвердила} изменения, затем {gender:выключил|выключила} КПК и {gender:положил|положила} его обратно в карман')
										wait(2000)
										sampSendChat(('/uninvite %s %s'):format(uninviteid,u8:decode(uninvitebuf.v)))
										sampSendChat('/time')
										inprocess = false
									end)
								end
							end
						end
					else
						ASHelperMessage('Данная команда доступна с 9-го ранга.')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype = 0
				end
			end
	
			if windowtype == 4 then
				imgui.PushItemWidth(270)
				imgui.Combo(' ', Ranks_select, {u8('[1] '..configuration.RankNames[1]), u8('[2] '..configuration.RankNames[2]),u8('[3] '..configuration.RankNames[3]),u8('[4] '..configuration.RankNames[4]),u8('[5] '..configuration.RankNames[5]),u8('[6] '..configuration.RankNames[6]),u8('[7] '..configuration.RankNames[7]),u8('[8] '..configuration.RankNames[8]),u8('[9] '..configuration.RankNames[9])}, #configuration.RankNames)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 270) / 2)
				imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.15, 0.42, 0.0, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.25, 0.52, 0.0, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.35, 0.62, 0.7, 1.00))
				if imgui.Button(u8'Повысить сотрудника '..fa.ICON_FA_ARROW_UP, imgui.ImVec2(270,40)) then
					if configuration.main_settings.myrankint >= 9 then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							windows.imgui_fm.v = false
							lua_thread.create(function()
								local changerankid = fastmenuID
								inprocess = true
								sampSendChat('/me {gender:включил|включила} КПК')
								wait(2000)
								sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\'')
								wait(2000)
								sampSendChat('/me {gender:выбрал|выбрала} в разделе нужного сотрудника')
								wait(2000)
								sampSendChat('/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтведрдил|подтвердила} изменения')
								wait(2000)
								sampSendChat('/do Информация о сотруднике была изменена.')
								wait(2000)
								sampSendChat('Поздравляю с повышением. Новый бейджик Вы можете взять в раздевалке.')
								wait(2000)
								sampSendChat(('/giverank %s %s'):format(changerankid,Ranks_select.v+1))
								inprocess = false
							end)
						end
					else
						ASHelperMessage('Данная команда доступна с 9-го ранга.')
					end
				end
				imgui.PopStyleColor(3)
				if imgui.Button(u8'Понизить сотрудника '..fa.ICON_FA_ARROW_DOWN, imgui.ImVec2(270,30)) then
					if configuration.main_settings.myrankint >= 9 then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							windows.imgui_fm.v = false
							lua_thread.create(function()
								local changerankid = fastmenuID
								inprocess = true
								sampSendChat('/me {gender:включил|включила} КПК')
								wait(2000)
								sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\'')
								wait(2000)
								sampSendChat('/me {gender:выбрал|выбрала} в разделе нужного сотрудника')
								wait(2000)
								sampSendChat('/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтведрдил|подтвердила} изменения')
								wait(2000)
								sampSendChat('/do Информация о сотруднике была изменена.')
								wait(2000)
								sampSendChat(('/giverank %s %s'):format(changerankid,Ranks_select.v+1))
								inprocess = false
							end)
						end
					else
						ASHelperMessage('Данная команда доступна с 9-го ранга.')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype = 0
				end
			end
	
			if windowtype == 5 then
				imgui.TextColoredRGB('Причина занесения в ЧС:',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'').x) / 5.7)
				imgui.InputText(u8'				   ', blacklistbuff)
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Занести в ЧС '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
					if configuration.main_settings.myrankint >= 9 then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							if blacklistbuff.v == nil or blacklistbuff.v == '' then
								ASHelperMessage('Введите причину занесения в ЧС!')
							else
								windows.imgui_fm.v = false
								lua_thread.create(function()
									local blacklistid = fastmenuID
									inprocess = true
									sampSendChat('/time')
									sampSendChat('/me {gender:достал|достала} КПК из кармана')
									wait(2000)
									sampSendChat('/me {gender:перешёл|перешла} в раздел \'Чёрный список\'')
									wait(2000)
									sampSendChat('/me {gender:ввёл|ввела} имя нарушителя')
									wait(2000)
									sampSendChat('/me {gender:внёс|внесла} нарушителя в раздел \'Чёрный список\'')
									wait(2000)
									sampSendChat('/me {gender:подтведрдил|подтвердила} изменения')
									wait(2000)
									sampSendChat('/do Изменения были сохранены.')
									wait(2000)
									sampSendChat(('/blacklist %s %s'):format(blacklistid,u8:decode(blacklistbuff.v)))
									sampSendChat('/time')
									inprocess = false
								end)
							end
						end
					else
						ASHelperMessage('Данная команда доступна с 9-го ранга.')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype = 0
				end
			end
	
			if windowtype == 6 then
				imgui.TextColoredRGB('Причина выговора:',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'   ').x) / 5.7)
				imgui.InputText(u8'   ', fwarnbuff)
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Выдать выговор '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(285,30)) then
					if fwarnbuff.v == nil or fwarnbuff.v == '' then
						ASHelperMessage('Введите причину выдачи выговора!')
					else
						windows.imgui_fm.v = false
						lua_thread.create(function()
							local fwarnid = fastmenuID
							inprocess = true
							sampSendChat('/me {gender:достал|достала} КПК из кармана')
							wait(2000)
							sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\'')
							wait(2000)
							sampSendChat('/me {gender:зашёл|зашла} в раздел \'Выговоры\'')
							wait(2000)
							sampSendChat('/me найдя в разделе нужного сотрудника, {gender:добавил|добавила} в его личное дело выговор')
							wait(2000)
							sampSendChat('/do Выговор был добавлен в личное дело сотрудника.')
							wait(2000)
							sampSendChat(('/fwarn %s %s'):format(fwarnid,u8:decode(fwarnbuff.v)))
							inprocess = false
						end)
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype = 0
				end
			end
	
			if windowtype == 7 then
				imgui.TextColoredRGB('Причина мута:',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'').x) / 5.7)
				imgui.InputText(u8'		 ', fmutebuff)
				imgui.TextColoredRGB('Время мута:',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8' ').x) / 5.7)
				imgui.InputInt(u8' ', fmuteint)
				imgui.NewLine()
				if imgui.Button(u8'Выдать мут '..sampGetPlayerNickname(fastmenuID)..'['..fastmenuID..']', imgui.ImVec2(270,30)) then
					if configuration.main_settings.myrankint >= 9 then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							if fmutebuff.v == nil or fmutebuff.v == '' then
								ASHelperMessage('Введите причину выдачи мута!')
							else
								if fmuteint.v == nil or fmuteint.v == '' or fmuteint.v == 0 or tostring(fmuteint.v):find('-') then
									ASHelperMessage('Введите корректное время мута!')
								else
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local fmuteid = fastmenuID
										inprocess = true
										sampSendChat('/me {gender:достал|достала} КПК из кармана')
										wait(2000)
										sampSendChat('/me {gender:включил|включила} КПК')
										wait(2000)
										sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками Автошколы\'')
										wait(2000)
										sampSendChat('/me {gender:выбрал|выбрала} нужного сотрудника')
										wait(2000)
										sampSendChat('/me {gender:выбрал|выбрала} пункт \'Отключить рацию сотрудника\'')
										wait(2000)
										sampSendChat('/me {gender:нажал|нажала} на кнопку \'Сохранить изменения\'')
										wait(2000)
										sampSendChat(('/fmute %s %s %s'):format(fmuteid,u8:decode(fmuteint.v),u8:decode(fmutebuff.v)))
										inprocess = false
									end)
								end
							end
						end
					else
						ASHelperMessage('Данная команда доступна с 9-го ранга.')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype = 0
				end
			end
			if windowtype == 8 then
				if #questions.questions ~= 0 then
					if questions.active.redact then
						for k,v in pairs(questions.questions) do
							imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
							if imgui.Button(u8(v.bname..'##'..k), imgui.ImVec2(200,30)) then
								if not inprocess then
									if string.rlower(v.bhint):find('подсказка') then
										ASHelperMessage(v.bhint)
									else
										ASHelperMessage('Подсказка: '..v.bhint)
									end
									sampSendChat(v.bq)
									lastq = os.clock() - 1
								else
									ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
								end
							end
							imgui.SameLine()
							if imgui.Button(fa.ICON_FA_PEN..'##'..k, imgui.ImVec2(30,30)) then
								question_number = k
								questionsettings.questionname.v = u8(v.bname)
								questionsettings.questionhint.v = u8(v.bhint)
								questionsettings.questionques.v = u8(v.bq)
								imgui.OpenPopup(u8('Редактор вопросов'))
							end
							imgui.SameLine()
							if imgui.Button(fa.ICON_FA_TRASH..'##'..k, imgui.ImVec2(30,30)) then
								table.remove(questions.questions,k)
								local file = io.open(getWorkingDirectory()..'\\AS Helper\\Questions.json', 'w')
								file:write(encodeJson(questions))
								file:close()
							end
						end
					else
						for k,v in pairs(questions.questions) do
							imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
							if imgui.Button(u8(v.bname), imgui.ImVec2(285,30)) then
								if not inprocess then
									if string.rlower(v.bhint):find('подсказка') then
										ASHelperMessage(v.bhint)
									else
										ASHelperMessage('Подсказка: '..v.bhint)
									end
									sampSendChat(v.bq)
									lastq = os.clock() - 1
								else
									ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
								end
							end
						end
					end
				else
					imgui.TextColoredRGB('Восстановить все вопросы',1)
					if imgui.IsItemHovered() and imgui.IsMouseReleased(0) then
						local function copy(obj, seen)
							if type(obj) ~= 'table' then return obj end
							if seen and seen[obj] then return seen[obj] end
							local s = seen or {}
							local res = setmetatable({}, getmetatable(obj))
							s[obj] = res
							for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
							return res
						end
						questions = copy(default_questions)
						local file = io.open(getWorkingDirectory()..'\\AS Helper\\Questions.json', 'w')
						file:write(encodeJson(questions))
						file:close()
					end
				end
				imgui.NewLine()
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
				imgui.Button(u8'Одобрить', imgui.ImVec2(137,35))
				if imgui.IsMouseReleased(0) or imgui.IsMouseReleased(1) then
					if imgui.IsItemHovered() then
						if not inprocess then
							if imgui.IsMouseReleased(0) then
								windows.imgui_fm.v = false
								sampSendChat(('Поздравляю, %s, вы сдали устав!'):format(string.gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
								sampSendChat(('/r %s успешно сдал устав!'):format(string.gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
							end
							if imgui.IsMouseReleased(1) then
								if configuration.main_settings.myrankint >= 9 then
									windows.imgui_fm.v = false
									lua_thread.create(function()
										local changerankid = fastmenuID
										inprocess = true
										sampSendChat(('Поздравляю, %s , вы сдали устав!'):format(string.gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
										sampSendChat('/me {gender:включил|включила} КПК')
										wait(2000)
										sampSendChat('/me {gender:перешёл|перешла} в раздел \'Управление сотрудниками\'')
										wait(2000)
										sampSendChat('/me {gender:выбрал|выбрала} в разделе нужного сотрудника')
										wait(2000)
										sampSendChat('/me {gender:изменил|изменила} информацию о должности сотрудника, после чего {gender:подтведрдил|подтвердила} изменения')
										wait(2000)
										sampSendChat('/do Информация о сотруднике была изменена.')
										wait(2000)
										sampSendChat('Поздравляю с повышением. Новый бейджик Вы можете взять в раздевалке.')
										sampSendChat(('/giverank %s 2'):format(changerankid))
										inprocess = false
									end)
								else
									ASHelperMessage('Данная команда доступна с 9-го ранга.')
								end
							end
						else
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						end
					end
				end
				imgui.Hint('ЛКМ для информирования о сдаче устава\n{FFFFFF}ПКМ для повышения до Консультанта',0)
				imgui.PopStyleColor(2)
				imgui.SameLine()
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Отказать', imgui.ImVec2(137,35)) then
					if not inprocess then
						sampSendChat(('Очень жаль, %s, но вы не смогли сдать устав. Подучите и приходите в следующий раз.'):format(string.gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
						windows.imgui_fm.v = false
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.PopStyleColor(2)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 605) / 2)
				imgui.Text(fa.ICON_FA_CLOCK..' '..(lastq == false and u8'0 с. назад' or math.floor(os.clock()-lastq)..u8' с. назад'))
				imgui.Hint('Прошедшее время с последнего вопроса.')
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
				if imgui.Button(u8'Назад', imgui.ImVec2(142.5,30)) then
					windowtype = 0
				end
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 660) / 2)
				if not questions.active.redact then
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.80, 0.25, 0.25, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.70, 0.25, 0.25, 1.00))
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.90, 0.25, 0.25, 1.00))
				else
					if #questions.questions <= 7 then
						imgui.SetCursorPosX(imgui.GetWindowWidth() - 95)
						if imgui.Button(fa.ICON_FA_PLUS_CIRCLE,imgui.ImVec2(50,25)) then
							question_number = nil
							questionsettings.questionname.v = u8('')
							questionsettings.questionhint.v = u8('')
							questionsettings.questionques.v = u8('')
							imgui.OpenPopup(u8('Редактор вопросов'))
						end
						imgui.SameLine()
					end
					imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(0.00, 0.70, 0.00, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.60, 0.00, 1.00))
					imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.50, 0.00, 1.00))
				end
				imgui.SetCursorPosX(imgui.GetWindowWidth() - 35)
				if imgui.Button(fa.ICON_FA_COG, imgui.ImVec2(25,25)) then
					questions.active.redact = not questions.active.redact
				end
				imgui.PopStyleColor(3)
				editquestion()
			end
			-- if not sampIsPlayerConnected(fastmenuID) then
				-- windows.imgui_fm.v = false
				-- windows.imgui_sobes.v = false
				-- ASHelperMessage('Игрок с которым вы взаимодействовали вышел из игры!')
			-- end
			imgui.End()
		end

		if windows.imgui_sobes.v then
			imgui.SetNextWindowSize(imgui.ImVec2(300, 517), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Меню быстрого доступа', _, imgui.WindowFlags.NoResize + (configuration.main_settings.noscrollbar and imgui.WindowFlags.NoScrollbar or imgui.WindowFlags.NoBringToFrontOnFocus) + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoCollapse)
			if sobesetap == 0 then
				imgui.TextColoredRGB('Собеседование: Этап 1',1)
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Поприветствовать', imgui.ImVec2(285,30)) then
					if not inprocess then
						lua_thread.create(function()
							inprocess = true
							sampSendChat(('Здравствуйте, я %s Автошколы, вы пришли на собеседование?'):format(configuration.RankNames[configuration.main_settings.myrankint]))
							wait(2000)
							sampSendChat(('/do На груди висит бейджик с надписью %s %s.'):format(configuration.RankNames[configuration.main_settings.myrankint],configuration.main_settings.useservername and string.gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ') or u8:decode(configuration.main_settings.myname)))
							inprocess = false
						end)
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Попросить документы '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
					if not inprocess then
						lua_thread.create(function()
							inprocess = true
							sampSendChat('Хорошо, для этого покажите мне ваши документы, а именно: паспорт и мед.карту')
							sampSendChat('/n Обязательно по рп!')
							wait(50)
							sobesetap = 1
							inprocess = false
						end)
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
			end

			if sobesetap == 1 then
				imgui.TextColoredRGB('Собеседование: Этап 2',1)
				imgui.Separator()
				if mcvalue then
					imgui.TextColoredRGB('Мед.карта - не показана',1)
				else
					imgui.TextColoredRGB('Мед.карта - показана ('..mcverdict..')',1)
				end
				if passvalue then
					imgui.TextColoredRGB('Паспорт - не показан',1)
				else
					imgui.TextColoredRGB('Паспорт - показан ('..passverdict..')',1)
				end
				if not mcvalue and mcverdict == ('в порядке') and not passvalue and passverdict == ('в порядке') then
					imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
					if imgui.Button(u8'Продолжить '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
						if not inprocess then
							lua_thread.create(function()
								inprocess = true
								wait(50)
								sobesetap = 2
								sampSendChat('/me взяв документы из рук человека напротив {gender:начал|начала} их проверять')
								wait(2000)
								sampSendChat('/todo Хорошо...* отдавая документы обратно')
								wait(2000)
								sampSendChat('Сейчас я задам вам несколько вопросов, вы готовы на них отвечать?')
								inprocess = false
							end)
						else
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						end
					end
				end
			end

			if sobesetap == 2 then
				imgui.TextColoredRGB('Собеседование: Этап 3',1)
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Расскажите немного о себе.', imgui.ImVec2(285,30)) then
					if not inprocess then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							inprocess = true
							sampSendChat('Расскажите немного о себе.')
							inprocess = false
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Почему выбрали именно нас?', imgui.ImVec2(285,30)) then
					if not inprocess then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							inprocess = true
							sampSendChat('Почему вы выбрали именно нас?')
							inprocess = false
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Работали вы уже в организациях ЦА? '..fa.ICON_FA_ARROW_RIGHT, imgui.ImVec2(285,30)) then
					if not inprocess then
						if inprocess then
							ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
						else
							inprocess = true
							sampSendChat('Работали вы уже в организациях ЦА? Если да, то расскажите подробнее')
							sampSendChat('/n ЦА - Центральный аппарат [Автошкола, Правительство, Банк]')
							lua_thread.create(function()
								wait(50)
								sobesetap = 3
							end)
							inprocess = false
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
			end

			if sobesetap == 3 then
				imgui.TextColoredRGB('Собеседование: Решение',1)
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.00, 0.40, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.00, 0.30, 0.00, 1.00))
				if imgui.Button(u8'Принять', imgui.ImVec2(285,30)) then
					if not inprocess then
						if configuration.main_settings.myrankint >= 9 then
							lua_thread.create(function()
								local inviteid = fastmenuID
								inprocess = true
								sampSendChat('Отлично, я думаю вы нам подходите!')
								wait(2000)
								sampSendChat('/do Ключи от шкафчика в кармане.')
								wait(2000)
								sampSendChat('/me всунув руку в карман брюк, {gender:достал|достала} оттуда ключ от шкафчика')
								wait(2000)
								sampSendChat('/me {gender:передал|передала} ключ человеку напротив')
								wait(2000)
								sampSendChat('Добро пожаловать! Раздевалка за дверью.')
								wait(2000)
								sampSendChat('Со всей информацией Вы можете ознакомиться на оф. портале.')
								wait(2000)
								sampSendChat(('/invite %s'):format(inviteid))
								inprocess = false
							end)
						else
							lua_thread.create(function()
								inprocess = true
								sampSendChat('Отлично, я думаю вы нам подходите!')
								wait(2000)
								sampSendChat(('/r %s успешно прошёл собеседование! Он ждёт старших около стойки чтобы вы его приняли.'):format(string.gsub(sampGetPlayerNickname(fastmenuID), '_', ' ')))
								wait(2000)
								sampSendChat(('/rb %s id'):format(fastmenuID))
								inprocess = false
							end)
						end
						sobesetap = 0
						windows.imgui_sobes.v = false
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.PopStyleColor(2)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Отклонить', imgui.ImVec2(285,30)) then
					if not inprocess then
						lastsobesetap = sobesetap
						sobesetap = 7
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.PopStyleColor(2)
			end

			if sobesetap == 7 then
				imgui.TextColoredRGB('Собеседование: Отклонение',1)
				imgui.Separator()
				imgui.PushItemWidth(270)
				imgui.Combo(' ',sobesdecline_select,sobesdecline_arr , #sobesdecline_arr)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 270) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Отклонить', imgui.ImVec2(270,30)) then
					if not inprocess then
						sobesetap = 0
						if sobesdecline_select.v == 0 then
							sampSendChat('К сожалению я не могу принять вас из-за того, что вы проф. непригодны.')
							sampSendChat('/b Очень плохое РП')
						elseif sobesdecline_select.v == 1 then
							sampSendChat('К сожалению я не могу принять вас из-за того, что вы проф. непригодны.')
							sampSendChat('/b Не было РП')
						elseif sobesdecline_select.v == 2 then
							sampSendChat('К сожалению я не могу принять вас из-за того, что вы проф. непригодны.')
							sampSendChat('/b Плохая грамматика')
						elseif sobesdecline_select.v == 3 then
							sampSendChat('К сожалению я не могу принять вас из-за того, что вы проф. непригодны.')
							sampSendChat('/b Ничего не показал')
						elseif sobesdecline_select.v == 4 then
							sampSendChat('К сожалению я не могу принять вас из-за того, что вы проф. непригодны.')
						end
						windows.imgui_sobes.v = false
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.PopStyleColor(2)
			end

			if sobesetap ~= 3 and sobesetap ~= 7  then
				imgui.Separator()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(0.40, 0.00, 0.00, 1.00))
				imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(0.30, 0.00, 0.00, 1.00))
				if imgui.Button(u8'Отклонить', imgui.ImVec2(285,30)) then
					if not inprocess then
						if not mcvalue or not passvalue then
							if mcverdict == ('наркозависимость') or mcverdict == ('не полностью здоровый') or passverdict == ('меньше 3 лет в штате') or passverdict == ('не законопослушный') or passverdict == ('игрок в организации') or passverdict == ('был в деморгане') or passverdict == ('в чс автошколы') or passverdict == ('есть варны') then
								windows.imgui_sobes.v = false
								if mcverdict == ('наркозависимость') then
									sampSendChat('К сожалению я не могу продолжить собеседование. Вы слишком наркозависимый.')
								elseif mcverdict == ('не полностью здоровый') then
									sampSendChat('К сожалению я не могу продолжить собеседование. Вы не полностью здоровый.')
								elseif passverdict == ('меньше 3 лет в штате') then
									sampSendChat('К сожалению я не могу продолжить собеседование. Вы не проживаете в штате 3 года.')
								elseif passverdict == ('не законопослушный') then
									sampSendChat('К сожалению я не могу продолжить собеседование. Вы недостаточно законопослушный.')
								elseif passverdict == ('игрок в организации') then
									sampSendChat('К сожалению я не могу продолжить собеседование. Вы уже работаете в другой организации.')
								elseif passverdict == ('был в деморгане') then
									sampSendChat('К сожалению я не могу продолжить собеседование. Вы лечились в псих. больнице.')
									sampSendChat('/n поменяй мед. карту')
								elseif passverdict == ('в чс автошколы') then
									sampSendChat('К сожалению я не могу продолжить собеседование. Вы находитесь в ЧС АШ.')
								elseif passverdict == ('есть варны') then
									sampSendChat('К сожалению я не могу продолжить собеседование. Вы проф. непригодны.')
									sampSendChat('/n есть варны')
								end							
							else
								lastsobesetap = sobesetap
								sobesetap = 7
							end
						else
							lastsobesetap = sobesetap
							sobesetap = 7
						end
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
				imgui.PopStyleColor(2)
			end
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() + 655) / 2)
			if imgui.Button(u8'Назад', imgui.ImVec2(137,30)) then
				if sobesetap == 7 then sobesetap = lastsobesetap
				elseif sobesetap ~= 0 then sobesetap = sobesetap - 1
				else
					windows.imgui_sobes.v = false
					windows.imgui_fm.v = true
					windowtype = 0
				end
			end
			imgui.SameLine()
			if sobesetap ~= 3 and sobesetap ~= 7 then
				if imgui.Button(u8'Пропустить этап', imgui.ImVec2(137,30)) then
					if not inprocess then
						sobesetap = sobesetap + 1
					else
						ASHelperMessage('Не торопитесь, вы уже отыгрываете что-то!')
					end
				end
			end
			if not sampIsPlayerConnected(fastmenuID) then
				windows.imgui_fm.v = false
				windows.imgui_sobes.v = false
				ASHelperMessage('Игрок с которым вы взаимодействовали вышел из игры!')
			end
			imgui.End()
		end

		if windows.imgui_settings.v then
			imgui.SetNextWindowSize(imgui.ImVec2(600, 300), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'#settings', windows.imgui_settings, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
			imgui.Image(configuration.main_settings.style ~= 2 and whiteashelper or blackashelper,imgui.ImVec2(198,25))
			imgui.SameLine(560)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
			if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
				windows.imgui_settings.v = false
			end
			imgui.PopStyleColor(3)
			imgui.SetCursorPos(imgui.ImVec2(217, 22))
			imgui.TextColoredRGB('{808080}'..thisScript().version)
			imgui.Hint('Обновление от 02.11.2021')
			imgui.BeginChild('##Buttons',imgui.ImVec2(230,240),true,imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.AlwaysAutoResize + imgui.WindowFlags.NoScrollWithMouse)
			for number, button in pairs(buttons) do
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 220) / 2)
				if imgui.SmoothButton(settingswindow == number, button, 220) then
					settingswindow = number
				end
			end
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild('##Settings',imgui.ImVec2(325,240),true,imgui.WindowFlags.AlwaysAutoResize)
			if settingswindow == 0 then

				imgui.PushFont(fontsize25)
				imgui.TextColoredRGB('Что я умею?',1)
				imgui.PopFont()
				imgui.TextWrapped(u8([[
	• Меню быстрого доступа: Прицелившись на игрока с помощью ПКМ и нажав кнопку E (по умолчанию), откроется меню быстрого доступа. В данном меню есть все нужные функции, а именно: приветствие, озвучивание прайс листа, продажа лицензий, возможность выгнать человека из автошколы, приглашение в организацию, увольнение из организации, изменение должности, занесение в ЧС, удаление из ЧС, выдача выговоров, удаление выговоров, выдача организационного мута, удаление организационного мута, автоматизированное проведение собеседования со всеми нужными отыгровками.
	
	• Команды сервера с отыгровками: /invite, /uninvite, /giverank, /blacklist, /unblacklist, /fwarn, /unfwarn, /fmute, /funmute, /expel. Введя любую из этих команд начнётся РП отыгровка, лишь после неё будет активирована сама команда.
	
	• Команды: /ash - настройки хелпера, /ashbind - биндер хелпера, /ashstats - статистика проданных лицензий, /ashlect - меню лекций.
	
	• Настройки: Введя команду /ash откроются настройки в которых можно изменять никнейм в приветствии, акцент, создание маркера при выделении, пол, цены на лицензии, горячую клавишу быстрого меню и узнать информацию о скрипте.
	
	• Биндер: Введя команду /ashbind откроется полностью работоспособный биндер, в котором вы можете создать абсолютно любой бинд.
	
	• Меню лекций: Введя команду /ashlect откроется меню лекций, в котором вы сможете озвучить/добавить/удалить лекции.]]
	))
			end

			if settingswindow == 1 then

				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8'Использовать мой ник из таба',usersettings.useservername) then
					if configuration.main_settings.myname == '' then
						usersettings.myname.v = string.gsub(sampGetPlayerNickname(select(2,sampGetPlayerIdByCharHandle(playerPed))), '_', ' ')
						configuration.main_settings.myname = usersettings.myname.v
					end
					configuration.main_settings.useservername = usersettings.useservername.v
					inicfg.save(configuration,'AS Helper')
				end
				if not usersettings.useservername.v then
					imgui.SetCursorPosX(10)
					if imgui.InputText(u8' ', usersettings.myname) then
						configuration.main_settings.myname = usersettings.myname.v
						inicfg.save(configuration,'AS Helper')
					end
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8'Использовать акцент',usersettings.useaccent) then
					configuration.main_settings.useaccent = usersettings.useaccent.v
					inicfg.save(configuration,'AS Helper')
				end
				if usersettings.useaccent.v then
					imgui.PushItemWidth(150)
					imgui.SetCursorPosX(20)
					if imgui.InputText(u8'   ', usersettings.myaccent) then
						configuration.main_settings.myaccent = usersettings.myaccent.v
						inicfg.save(configuration,'AS Helper')
					end
					imgui.PopItemWidth()
					imgui.SameLine()
					imgui.SetCursorPosX(10)
					imgui.Text('[')
					imgui.SameLine()
					imgui.SetCursorPosX(175)
					imgui.Text(']')
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8'Создавать маркер при выделении',usersettings.createmarker) then
					if marker ~= nil then
						removeBlip(marker)
					end
					marker = nil
					oldtargettingped = 0
					configuration.main_settings.createmarker = usersettings.createmarker.v
					inicfg.save(configuration,'AS Helper')
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8'Начинать отыгровки после команд', usersettings.dorponcmd) then
					configuration.main_settings.dorponcmd = usersettings.dorponcmd.v
					inicfg.save(configuration,'AS Helper')
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8'Заменять серверные сообщения', usersettings.replacechat) then
					configuration.main_settings.replacechat = usersettings.replacechat.v
					inicfg.save(configuration,'AS Helper')
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8'Быстрый скрин на '..configuration.main_settings.fastscreen, usersettings.dofastscreen) then
					configuration.main_settings.dofastscreen = usersettings.dofastscreen.v
					inicfg.save(configuration,'AS Helper')
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8'Убирать полосу прокрутки', usersettings.noscrollbar) then
					configuration.main_settings.noscrollbar = usersettings.noscrollbar.v
					inicfg.save(configuration,'AS Helper')
					checkstyle()
				end
				imgui.SetCursorPosX(10)
				if imgui.Checkbox(u8'Автоотыгровка дубинки', usersettings.playdubinka) then
					configuration.main_settings.playdubinka = usersettings.playdubinka.v
					inicfg.save(configuration,'AS Helper')
				end
				imgui.SetCursorPosX(10)
				if imgui.Button(u8'Обновить', imgui.ImVec2(85,25)) then
					getmyrank = true
					sampSendChat('/stats')
				end
				imgui.SameLine()
				imgui.Text(u8'Ваш ранг: '..u8(configuration.RankNames[configuration.main_settings.myrankint])..' ('..u8(configuration.main_settings.myrankint)..')')
				imgui.PushItemWidth(85)
				imgui.SetCursorPosX(10)
				if imgui.Combo(u8'',usersettings.gender, {u8'Мужской',u8'Женский'}, 2) then
					configuration.main_settings.gender = usersettings.gender.v
					inicfg.save(configuration,'AS Helper')
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.TextColoredRGB('Пол выбран {808080}(?)')
				if imgui.IsMouseReleased(0) and imgui.IsItemHovered() then
					GetMyGender()
				end
				imgui.Hint('ЛКМ для автоматического определения.')
				imgui.PushItemWidth(85)
				imgui.SetCursorPosX(10)
				if imgui.InputText(u8'##expelreasonbuff',usersettings.expelreason) then
					configuration.main_settings.expelreason = u8:decode(usersettings.expelreason.v)
					inicfg.save(configuration,'AS Helper')
				end
				imgui.PopItemWidth()
				imgui.SameLine('')
				imgui.Text(u8'Причина /expel')
			end

			if settingswindow == 2 then
				imgui.TextColoredRGB('Ценовая политика {808080}(?)',1)
				imgui.Hint('Эти цены будут использоваться при озвучивании прайс листа')
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8'Авто', pricelist.avtoprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.avtoprice = pricelist.avtoprice.v
					inicfg.save(configuration,'AS Helper')
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() + 29) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8'Мото', pricelist.motoprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.motoprice = pricelist.motoprice.v
					inicfg.save(configuration,'AS Helper')
				end
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8'Рыбалка', pricelist.ribaprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.ribaprice = pricelist.ribaprice.v
					inicfg.save(configuration,'AS Helper')
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.PushItemWidth(62)
				if imgui.InputText(u8'Плавание', pricelist.lodkaprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.lodkaprice = pricelist.lodkaprice.v
					inicfg.save(configuration,'AS Helper')
				end
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8'Оружие', pricelist.gunaprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.gunaprice = pricelist.gunaprice.v
					inicfg.save(configuration,'AS Helper')
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() + 31) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8'Охота', pricelist.huntprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.huntprice = pricelist.huntprice.v
					inicfg.save(configuration,'AS Helper')
				end
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 230) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8'Раскопки', pricelist.kladprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.kladprice = pricelist.kladprice.v
					inicfg.save(configuration,'AS Helper')
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() + 31) / 2)
				imgui.PushItemWidth(62)
				if imgui.InputText(u8'Такси', pricelist.taxiprice, imgui.InputTextFlags.CharsDecimal) then
					configuration.main_settings.taxiprice = pricelist.taxiprice.v
					inicfg.save(configuration,'AS Helper')
				end
				imgui.PopItemWidth()
			end

			if settingswindow == 3 then
				if imgui.Button(u8'Изменить кнопку быстрого меню', imgui.ImVec2(-1,35.9)) then
					getbindkey = not getbindkey
				end
				if getbindkey then
					imgui.Hint('Нажмите любую клавишу')
					getbindkey,configuration.main_settings.usefastmenu = imgui.GetKeys(getbindkey,1)
				else
					imgui.Hint('ПКМ + '..configuration.main_settings.usefastmenu)
				end
				if imgui.Button(u8'Изменить кнопку быстрого скрина', imgui.ImVec2(-1,35.9)) then
					getscreenkey = not getscreenkey
				end
				if getscreenkey then
					imgui.Hint('Нажмите любую клавишу')
					getscreenkey,configuration.main_settings.fastscreen = imgui.GetKeys(getscreenkey,1)
				else
					imgui.Hint(configuration.main_settings.fastscreen)
				end
				if imgui.Button(u8(windows.imgui_binder.v and 'Закрыть' or 'Открыть')..u8' биндер', imgui.ImVec2(-1,35.9)) then
					choosedslot = nil
					windows.imgui_binder.v = not windows.imgui_binder.v
				end
				if imgui.Button(u8(windows.imgui_lect.v and 'Закрыть' or 'Открыть')..u8' меню лекций', imgui.ImVec2(-1,35.9)) then
					if configuration.main_settings.myrankint >= 5 then
						windows.imgui_lect.v = not windows.imgui_lect.v
					else
						ASHelperMessage('Данная функция доступна с 5-го ранга.')
					end
				end
				if imgui.Button(u8(windows.imgui_depart.v and 'Закрыть' or 'Открыть')..u8' рацию департамента', imgui.ImVec2(-1,35.9)) then
					if configuration.main_settings.myrankint >= 5 then
						windows.imgui_depart.v = not windows.imgui_depart.v
					else
						ASHelperMessage('Данная функция доступна с 5-го ранга.')
					end
				end
				imgui.SameLine()
			end

			if settingswindow == 4 then
				imgui.PushItemWidth(200)
				if imgui.Combo(u8'Выбор темы', StyleBox_select, StyleBox_arr, #StyleBox_arr) then
					configuration.main_settings.style = StyleBox_select.v
					if inicfg.save(configuration,'AS Helper') then
						checkstyle()
					end
				end
				imgui.PopItemWidth()
				if imgui.ColorEdit4(u8'Цвет чата организации##RSet', chatcolors.RChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
					local clr = imgui.ImColor.FromFloat4(chatcolors.RChatColor.v[1], chatcolors.RChatColor.v[2], chatcolors.RChatColor.v[3], chatcolors.RChatColor.v[4]):GetU32()
					configuration.main_settings.RChatColor = clr
					inicfg.save(configuration, 'AS Helper.ini')
				end
				imgui.SameLine(imgui.GetWindowWidth() - 75)
				if imgui.Button(u8'Сбросить##RCol',imgui.ImVec2(65,25)) then
					configuration.main_settings.RChatColor = 4282626093
					if inicfg.save(configuration, 'AS Helper.ini') then
						chatcolors.RChatColor = imgui.ImFloat4(imgui.ImColor(configuration.main_settings.RChatColor):GetFloat4())
					end
				end
				imgui.SameLine(imgui.GetWindowWidth() - 130)
				if imgui.Button(u8'Тест##RTest',imgui.ImVec2(50,25)) then
					local result, myid = sampGetPlayerIdByCharHandle(playerPed)
					local r, g, b, a = imgui.ImColor(configuration.main_settings.RChatColor):GetRGBA()
					sampAddChatMessage('[R] '..configuration.RankNames[configuration.main_settings.myrankint]..' '..sampGetPlayerNickname(tonumber(myid))..'['..myid..']:(( Это сообщение видите только вы! ))', join_rgb(r, g, b))
				end
				if imgui.ColorEdit4(u8'Цвет чата департамента##DSet', chatcolors.DChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
					local clr = imgui.ImColor.FromFloat4(chatcolors.DChatColor.v[1], chatcolors.DChatColor.v[2], chatcolors.DChatColor.v[3], chatcolors.DChatColor.v[4]):GetU32()
					configuration.main_settings.DChatColor = clr
					inicfg.save(configuration, 'AS Helper.ini')
				end
				imgui.SameLine(imgui.GetWindowWidth() - 75)
				if imgui.Button(u8'Сбросить##DCol',imgui.ImVec2(65,25)) then
					configuration.main_settings.DChatColor = 4294940723
					if inicfg.save(configuration, 'AS Helper.ini') then
						chatcolors.DChatColor = imgui.ImFloat4(imgui.ImColor(configuration.main_settings.DChatColor):GetFloat4())
					end
				end
				imgui.SameLine(imgui.GetWindowWidth() - 130)
				if imgui.Button(u8'Тест##DTest',imgui.ImVec2(50,25)) then
					local result, myid = sampGetPlayerIdByCharHandle(playerPed)
					local r, g, b, a = imgui.ImColor(configuration.main_settings.DChatColor):GetRGBA()
					sampAddChatMessage('[D] '..configuration.RankNames[configuration.main_settings.myrankint]..' '..sampGetPlayerNickname(tonumber(myid))..'['..myid..']: Это сообщение видите только вы!', join_rgb(r, g, b))
				end
				if imgui.ColorEdit4(u8'Цвет AS Helper в чате##SSet', chatcolors.ASChatColor, imgui.ColorEditFlags.NoInputs + imgui.ColorEditFlags.NoAlpha) then
					local clr = imgui.ImColor.FromFloat4(chatcolors.ASChatColor.v[1], chatcolors.ASChatColor.v[2], chatcolors.ASChatColor.v[3], chatcolors.ASChatColor.v[4]):GetU32()
					configuration.main_settings.ASChatColor = clr
					inicfg.save(configuration, 'AS Helper.ini')
				end
				imgui.SameLine(imgui.GetWindowWidth() - 75)
				if imgui.Button(u8'Сбросить##SCol',imgui.ImVec2(65,25)) then
					configuration.main_settings.ASChatColor = 4281558783
					if inicfg.save(configuration, 'AS Helper.ini') then
						chatcolors.ASChatColor = imgui.ImFloat4(imgui.ImColor(configuration.main_settings.ASChatColor):GetFloat4())
					end
				end
				imgui.SameLine(imgui.GetWindowWidth() - 130)
				if imgui.Button(u8'Тест##ASTest',imgui.ImVec2(50,25)) then
					ASHelperMessage('Это сообщение видите только вы!')
				end
			end

			if settingswindow == 5 then
				imgui.TextColoredRGB('Вы можете добавлять свои правила!{808080} (?)',1)
				imgui.Hint('Вы должны создать .txt файл с кодировкой ANSI\nЛКМ для открытия папки с правилами')
				if imgui.IsMouseReleased(0) and imgui.IsItemHovered() then
					createDirectory(getWorkingDirectory()..'\\AS Helper\\Rules')
					os.execute('explorer '..getWorkingDirectory()..'\\AS Helper\\Rules')
				end
				for i, block in ipairs(ruless) do
					if imgui.Button(u8(block.name), imgui.ImVec2(-1,35)) then
						search_rule.v = ''
						RuleSelect = i
						imgui.OpenPopup(u8('Правила'))
					end
				end
				Rule()
				if imgui.Button(fa.ICON_FA_SPINNER,imgui.ImVec2(25,25)) then
					checkrules()
				end
				imgui.Hint('Нажмите для обновления всех правил')
			end

			if settingswindow == 6 then
				imgui.TextColoredRGB('Автор: {ff6633}JustMini',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 285) / 2)
				if imgui.Button(u8'Change Log '..(fa.ICON_FA_TERMINAL), imgui.ImVec2(137,30)) then
					windows.imgui_changelog.v = true
				end
				imgui.SameLine()
				if imgui.Button(u8'Check Updates '..(fa.ICON_FA_CLOUD_DOWNLOAD_ALT), imgui.ImVec2(137,30)) then
					lua_thread.create(function ()
						checkbibl()
					end)
				end
				imgui.SetCursorPos(imgui.ImVec2(185.5,200))
				if imgui.Button(u8'Дополнительно '..(fa.ICON_FA_LAYER_GROUP), imgui.ImVec2(120,25)) then
					imgui.OpenPopup(u8('Остальное'))
				end
				otheractions()
				imgui.SameLine(20)
				if imgui.Button(fa.ICON_FA_LINK..u8' Связь со мной', imgui.ImVec2(120,25)) then
					imgui.OpenPopup(u8('Связь'))
				end
				imgui.Hint('Если вы нашли баг/ошибку в скрипте,\n{FFFFFF} то можете отправить мне её.')
				communicate()
			end
			imgui.EndChild()
			imgui.End()
		end

		if windows.imgui_binder.v then
			imgui.SetNextWindowSize(imgui.ImVec2(650, 370), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Биндер', windows.imgui_binder, imgui.WindowFlags.NoScrollWithMouse + imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoScrollbar + imgui.WindowFlags.NoCollapse)
			imgui.Image(configuration.main_settings.style ~= 2 and whitebinder or blackbinder,imgui.ImVec2(202,25))
			imgui.SameLine(583)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
			if choosedslot then
				if imgui.Button(fa.ICON_FA_QUESTION_CIRCLE,imgui.ImVec2(23,23)) then
					imgui.OpenPopup(u8'Тэги')
				end
			end
			imgui.SameLine(606)
			if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
				windows.imgui_binder.v = false
			end
			imgui.PopStyleColor(3)
			bindertags()
			imgui.BeginChild('ChildWindow',imgui.ImVec2(175,270),true, (configuration.main_settings.noscrollbar and imgui.WindowFlags.NoScrollbar or imgui.WindowFlags.NoBringToFrontOnFocus))
			imgui.SetCursorPosY((imgui.GetWindowWidth() - 160) / 2)
			for key, value in pairs(configuration.BindsName) do
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 160) / 2)
				if imgui.Button(u8(configuration.BindsName[key]),imgui.ImVec2(160,30)) then
					choosedslot = key
					bindersettings.binderbuff.v = u8(configuration.BindsAction[key]):gsub('~', '\n')
					bindersettings.bindername.v = u8(configuration.BindsName[key])
					bindersettings.bindertype.v = u8(configuration.BindsType[key])
					bindersettings.bindercmd.v = u8(configuration.BindsCmd[key])
					binderkeystatus = u8(configuration.BindsKeys[key])
					bindersettings.binderdelay.v = u8(configuration.BindsDelay[key])
				end
			end
			imgui.EndChild()
			if choosedslot ~= nil and choosedslot <= 50 then
				imgui.SameLine()
				imgui.BeginChild('ChildWindow2',imgui.ImVec2(435,200),false)
				imgui.InputTextMultiline(u8'',bindersettings.binderbuff, imgui.ImVec2(435,200))
				imgui.EndChild()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Название бинда:').x - 145) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Название бинда:').y - 115) / 2)
				imgui.Text(u8'Название бинда:'); imgui.SameLine()
				imgui.PushItemWidth(150)
				if choosedslot ~= 50 then imgui.InputText('##bindersettings.bindername', bindersettings.bindername,imgui.InputTextFlags.ReadOnly)
				else imgui.InputText('##bindersettings.bindername', bindersettings.bindername)
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				imgui.PushItemWidth(162)
				imgui.Combo(' ',bindersettings.bindertype, u8'Использовать команду\0Использовать клавиши\0\0', 2)
				imgui.PopItemWidth()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Название бинда:').x - 145) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() - imgui.CalcTextSize(u8'Задержка между строками (ms):').y - 50) / 2)
				imgui.TextColoredRGB('Задержка между строками {808080}(ms):'); imgui.SameLine()
				imgui.Hint('Указывайте значение в миллисекундах\n{FFFFFF}1 секунда = 1.000 миллисекунд')
				imgui.PushItemWidth(58)
				imgui.InputText('##bindersettings.binderdelay', bindersettings.binderdelay, imgui.InputTextFlags.CharsDecimal)
				if tonumber(bindersettings.binderdelay.v) and tonumber(bindersettings.binderdelay.v) > 60000 then
					bindersettings.binderdelay.v = '60000'
				elseif tonumber(bindersettings.binderdelay.v) and tonumber(bindersettings.binderdelay.v) < 1 then
					bindersettings.binderdelay.v = '1'
				end
				imgui.PopItemWidth()
				imgui.SameLine()
				if bindersettings.bindertype.v == 0 then
					imgui.Text('/')
					imgui.SameLine()
					imgui.PushItemWidth(147)
					imgui.InputText('##bindersettings.bindercmd',bindersettings.bindercmd,imgui.InputTextFlags.CharsNoBlank)
					imgui.PopItemWidth()
				elseif bindersettings.bindertype.v == 1 then
					if setbinderkey then
						setbinderkey,binderkeystatus = imgui.GetKeys(setbinderkey,2)
					end
					if imgui.Button(binderkeystatus and u8(binderkeystatus) or u8'Нажмите чтобы поменять',imgui.ImVec2(162,24)) then
						if binderkeystatus then
							str = nil
							if binderkeystatus:find('ЛКМ %- сохранение') then
								binderkeystatus = binderkeystatus:match('ЛКМ %- сохранение (.+)')
								setbinderkey = false
							else
								binderkeystatus = nil
								setbinderkey = false
							end
						else
							setbinderkey = true
						end
					end
				end
				imgui.NewLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() + 429) / 2)
				imgui.SetCursorPosY((imgui.GetWindowWidth() + 10) / 2)
				local kei
				local doreplace = false
				if bindersettings.binderbuff.v ~= '' and bindersettings.bindername.v ~= '' and bindersettings.binderdelay.v ~= '' and bindersettings.bindertype.v ~= nil then
					if imgui.Button(u8'Сохранить',imgui.ImVec2(100,30)) then
						if not inprocess then
							if bindersettings.bindertype.v == 0 then
								if bindersettings.bindercmd.v ~= '' and bindersettings.bindercmd.v ~= nil then
									for key, value in pairs(configuration.BindsName) do
										if tostring(u8:decode(bindersettings.bindername.v)) == tostring(value) then
											sampUnregisterChatCommand(configuration.BindsCmd[key])
											doreplace = true
											kei = key
										end
									end
									if doreplace then
										local refresh_text = u8:decode(bindersettings.binderbuff.v):gsub('\n', '~')
										configuration.BindsName[kei] = u8:decode(bindersettings.bindername.v)
										configuration.BindsAction[kei] = refresh_text
										configuration.BindsDelay[kei] = u8:decode(bindersettings.binderdelay.v)
										configuration.BindsType[kei]= u8:decode(bindersettings.bindertype.v)
										configuration.BindsCmd[kei] = u8:decode(bindersettings.bindercmd.v)
										configuration.BindsKeys[kei] = ''
										if inicfg.save(configuration, 'AS Helper') then
											ASHelperMessage('Бинд успешно сохранён!')
											setbinderkey = false
											keyname = nil
											keyname2 = nil
											bindersettings.bindercmd.v = ''
											bindersettings.binderbuff.v = ''
											bindersettings.bindername.v = ''
											bindersettings.bindertype.v = 0
											bindersettings.binderdelay.v = ''
											bindersettings.bindercmd.v = ''
											binderkeystatus = nil
											choosedslot = nil
										end
									else
										local refresh_text = u8:decode(bindersettings.binderbuff.v):gsub('\n', '~')
										table.insert(configuration.BindsName, u8:decode(bindersettings.bindername.v))
										table.insert(configuration.BindsAction, refresh_text)
										table.insert(configuration.BindsDelay, u8:decode(bindersettings.binderdelay.v))
										table.insert(configuration.BindsType, u8:decode(bindersettings.bindertype.v))
										table.insert(configuration.BindsCmd, u8:decode(bindersettings.bindercmd.v))
										table.insert(configuration.BindsKeys, '')
										if inicfg.save(configuration, 'AS Helper') then
											ASHelperMessage('Бинд успешно создан!')
											setbinderkey = false
											keyname = nil
											keyname2 = nil
											bindersettings.bindercmd.v = ''
											bindersettings.binderbuff.v = ''
											bindersettings.bindername.v = ''
											bindersettings.bindertype.v = 0
											bindersettings.binderdelay.v = ''
											bindersettings.bindercmd.v = ''
											binderkeystatus = nil
											choosedslot = nil
										end
									end
								else
									ASHelperMessage('Вы неправильно указали команду бинда!')
								end
							elseif bindersettings.bindertype.v == 1 then
								if binderkeystatus ~= nil and (u8:decode(binderkeystatus)) ~= 'Нажмите чтобы поменять' and not string.find((u8:decode(binderkeystatus)), 'ЛКМ для сохранения ') and (u8:decode(binderkeystatus)) ~= 'None' then
									for key, value in pairs(configuration.BindsName) do
										if tostring(u8:decode(bindersettings.bindername.v)) == tostring(value) then
											sampUnregisterChatCommand(configuration.BindsCmd[key])
											doreplace = true
											kei = key
										end
									end
									if doreplace then
										local refresh_text = u8:decode(bindersettings.binderbuff.v):gsub('\n', '~')
										configuration.BindsName[kei] = u8:decode(bindersettings.bindername.v)
										configuration.BindsAction[kei] = refresh_text
										configuration.BindsDelay[kei] = u8:decode(bindersettings.binderdelay.v)
										configuration.BindsType[kei]= u8:decode(bindersettings.bindertype.v)
										configuration.BindsCmd[kei] = ''
										configuration.BindsKeys[kei] = u8(binderkeystatus)
										if inicfg.save(configuration, 'AS Helper') then
											ASHelperMessage('Бинд успешно сохранён!')
											setbinderkey = false
											keyname = nil
											keyname2 = nil
											bindersettings.bindercmd.v = ''
											bindersettings.binderbuff.v = ''
											bindersettings.bindername.v = ''
											bindersettings.bindertype.v = 0
											bindersettings.binderdelay.v = ''
											bindersettings.bindercmd.v = ''
											binderkeystatus = nil
											choosedslot = nil
										end
									else
										local refresh_text = u8:decode(bindersettings.binderbuff.v):gsub('\n', '~')
										table.insert(configuration.BindsName, u8:decode(bindersettings.bindername.v))
										table.insert(configuration.BindsAction, refresh_text)
										table.insert(configuration.BindsDelay, u8:decode(bindersettings.binderdelay.v))
										table.insert(configuration.BindsType, u8:decode(bindersettings.bindertype.v))
										table.insert(configuration.BindsKeys, u8(binderkeystatus))
										table.insert(configuration.BindsCmd, '')
										if inicfg.save(configuration, 'AS Helper') then
											ASHelperMessage('Бинд успешно создан!')
											setbinderkey = false
											keyname = nil
											keyname2 = nil
											bindersettings.bindercmd.v = ''
											bindersettings.binderbuff.v = ''
											bindersettings.bindername.v = ''
											bindersettings.bindertype.v = 0
											bindersettings.binderdelay.v = ''
											bindersettings.bindercmd.v = ''
											binderkeystatus = nil
											choosedslot = nil
										end
									end
								else
									ASHelperMessage('Вы неправильно указали клавишу бинда!')
								end
							end
							updatechatcommands()
						else
							ASHelperMessage('Вы не можете взаимодействовать с биндером во время любой отыгровки!')
						end	
					end
				else
					imgui.LockedButton(u8'Сохранить',imgui.ImVec2(100,30))
					imgui.Hint('Вы ввели не все параметры. Перепроверьте всё.')
				end
				imgui.SameLine()
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 247) / 2)
				if imgui.Button(u8'Отменить',imgui.ImVec2(100,30)) then
					setbinderkey = false
					keyname = nil
					keyname2 = nil
					bindersettings.bindercmd.v = ''
					bindersettings.binderbuff.v = ''
					bindersettings.bindername.v = ''
					bindersettings.bindertype.v = 0
					bindersettings.binderdelay.v = ''
					bindersettings.bindercmd.v = ''
					binderkeystatus = nil
					updatechatcommands()
					choosedslot = nil
				end
			else
				imgui.SetCursorPos(imgui.ImVec2(230,180))
				imgui.Text(u8'Откройте бинд или создайте новый для меню редактирования.')
			end
			imgui.NewLine()
			imgui.SetCursorPosX((imgui.GetWindowWidth() - 621) / 2)
			imgui.SetCursorPosY((imgui.GetWindowWidth() + 10) / 2)
			if imgui.Button(u8'Добавить',imgui.ImVec2(82,30)) then
				choosedslot = 50
				bindersettings.binderbuff.v = ''
				bindersettings.bindername.v = ''
				bindersettings.bindertype.v = 0
				bindersettings.bindercmd.v = ''
				binderkeystatus = nil
				bindersettings.binderdelay.v = ''
				updatechatcommands()
			end
			imgui.SameLine()
			if choosedslot ~= nil and choosedslot ~= 50 then
				if imgui.Button(u8'Удалить',imgui.ImVec2(82,30)) then
					if not inprocess then
						for key, value in pairs(configuration.BindsName) do
							local value = tostring(value)
							if u8:decode(bindersettings.bindername.v) == tostring(configuration.BindsName[key]) then
								sampUnregisterChatCommand(configuration.BindsCmd[key])
								table.remove(configuration.BindsName,key)
								table.remove(configuration.BindsKeys,key)
								table.remove(configuration.BindsAction,key)
								table.remove(configuration.BindsCmd,key)
								table.remove(configuration.BindsDelay,key)
								table.remove(configuration.BindsType,key)
								if inicfg.save(configuration,'AS Helper') then
									setbinderkey = false
									keyname = nil
									keyname2 = nil
									bindersettings.bindercmd.v = ''
									bindersettings.binderbuff.v = ''
									bindersettings.bindername.v = ''
									bindersettings.bindertype.v = 0
									bindersettings.binderdelay.v = ''
									bindersettings.bindercmd.v = ''
									binderkeystatus = nil
									choosedslot = nil
									ASHelperMessage('Бинд успешно удалён!')
								end
							end
						end
					updatechatcommands()
					else
						ASHelperMessage('Вы не можете удалять бинд во время любой отыгровки!')
					end
				end
			else
				imgui.LockedButton(u8'Удалить',imgui.ImVec2(82,30))
				imgui.Hint('Выберите бинд который хотите удалить',0)
			end
			imgui.End()
		end

		if windows.imgui_lect.v then -- на основе лекций из Bank Helper
			imgui.SetNextWindowSize(imgui.ImVec2(435, 300), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'Лекции', windows.imgui_lect, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + (configuration.main_settings.noscrollbar and imgui.WindowFlags.NoScrollbar or imgui.WindowFlags.NoBringToFrontOnFocus))
			imgui.Image(configuration.main_settings.style ~= 2 and whitelection or blacklection,imgui.ImVec2(199,25))
			imgui.SameLine(401)
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
			if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
				windows.imgui_lect.v = false
			end
			imgui.PopStyleColor(3)
			imgui.Separator()
			imgui.RadioButton(u8('Чат'), lectionsettings.lection_type, 1)
			imgui.SameLine()
			imgui.RadioButton(u8('/s'), lectionsettings.lection_type, 4)
			imgui.SameLine()
			imgui.RadioButton(u8('/r'), lectionsettings.lection_type, 2)
			imgui.SameLine()
			imgui.RadioButton(u8('/rb'), lectionsettings.lection_type, 3)
			imgui.SameLine()
			imgui.SetCursorPosX(245)
			imgui.PushItemWidth(50)
			if imgui.DragInt('##lectionsettings.lection_delay', lectionsettings.lection_delay, 1, 1, 30, u8('%0.0f с.')) then
				if lectionsettings.lection_delay.v < 1 then lectionsettings.lection_delay.v = 1 end
				if lectionsettings.lection_delay.v > 30 then lectionsettings.lection_delay.v = 30 end
				configuration.main_settings.lection_delay = lectionsettings.lection_delay.v
				inicfg.save(configuration,'AS Helper')
				end
			imgui.Hint('Задержка между сообщениями')
			imgui.PopItemWidth()
			imgui.SameLine()
			imgui.SetCursorPosX(307)
			if imgui.Button(u8'Создать новую '..fa.ICON_FA_PLUS_CIRCLE, imgui.ImVec2(112, 24)) then
				lection_number = nil
				lectionsettings.lection_name.v = u8('')
				lectionsettings.lection_text.v = u8('')
				imgui.OpenPopup(u8('Редактор лекций'))
			end
			imgui.Separator()
			if #lections.data == 0 then
				imgui.SetCursorPosY(120)
				imgui.TextColoredRGB('У вас нет ни одной лекции.',1)
				imgui.SetCursorPosX((imgui.GetWindowWidth() - 250) / 2)
				if imgui.Button(u8'Восстановить изначальные лекции', imgui.ImVec2(250, 25)) then
					local function copy(obj, seen)
						if type(obj) ~= 'table' then return obj end
						if seen and seen[obj] then return seen[obj] end
						local s = seen or {}
						local res = setmetatable({}, getmetatable(obj))
						s[obj] = res
						for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
						return res
					end
					lections = copy(default_lect)
					local file = io.open(getWorkingDirectory()..'\\AS Helper\\Lections.json', 'w')
					file:write(encodeJson(lections))
					file:close()
				end
			else
				for i, block in ipairs(lections.data) do
					if lections.active.bool == true then
						if block.name == lections.active.name then
							if imgui.Button(fa.ICON_FA_PAUSE..'##'..u8(block.name), imgui.ImVec2(280, 25)) then
								inprocess = false
								lections.active.bool = false
								lections.active.name = nil
								lections.active.handle:terminate()
								lections.active.handle = nil
							end
						else
							imgui.LockedButton(u8(block.name), imgui.ImVec2(280, 25))
						end
						imgui.SameLine()
						imgui.LockedButton(fa.ICON_FA_PEN..'##'..u8(block.name), imgui.ImVec2(50, 25))
						imgui.SameLine()
						imgui.LockedButton(fa.ICON_FA_TRASH..'##'..u8(block.name), imgui.ImVec2(50, 25))
					else
						if imgui.Button(u8(block.name), imgui.ImVec2(280, 25)) then
							lections.active.bool = true
							lections.active.name = block.name
							lections.active.handle = lua_thread.create(function()
								inprocess = true
								for i, line in ipairs(block.text) do
									if lectionsettings.lection_type.v == 2 then
										sampSendChat(('/r %s'):format(line))
									elseif lectionsettings.lection_type.v == 3 then
										sampSendChat(('/rb %s'):format(line))
									elseif lectionsettings.lection_type.v == 4 then
										sampSendChat(('/s %s'):format(line))
									else
										sampSendChat(line)
									end
									if i ~= #block.text then
										wait(lectionsettings.lection_delay.v * 1000)
									end
								end
								inprocess = false
								lections.active.bool = false
								lections.active.name = nil
								lections.active.handle = nil
							end)
						end
						imgui.SameLine()
						if imgui.Button(fa.ICON_FA_PEN..'##'..u8(block.name), imgui.ImVec2(50, 25)) then
							lection_number = i
							lectionsettings.lection_name.v = u8(tostring(block.name))
							lectionsettings.lection_text.v = u8(tostring(table.concat(block.text, '\n')))
							imgui.OpenPopup(u8'Редактор лекций')
						end
						imgui.SameLine()
						if imgui.Button(fa.ICON_FA_TRASH..'##'..u8(block.name), imgui.ImVec2(50, 25)) then
							lection_number = i
							imgui.OpenPopup('##delete')
						end
					end
				end
			end
			if imgui.BeginPopup('##delete') then
				imgui.TextColoredRGB('Вы уверены, что хотите удалить лекцию \n\''..(lections.data[lection_number].name)..'\'',1)
				imgui.SetCursorPosX( (imgui.GetWindowWidth() - 100 - imgui.GetStyle().ItemSpacing.x) / 2 )
				if imgui.Button(u8'Да',imgui.ImVec2(50,25)) then
					imgui.CloseCurrentPopup()
					table.remove(lections.data, lection_number)
					local file = io.open(getWorkingDirectory()..'\\AS Helper\\Lections.json', 'w')
					file:write(encodeJson(lections))
					file:close()
				end
				imgui.SameLine()
				if imgui.Button(u8'Нет',imgui.ImVec2(50,25)) then
					imgui.CloseCurrentPopup()
				end
				imgui.EndPopup()
			end
			editlection()
			imgui.End()
		end

		if windows.imgui_depart.v then -- идея https://www.blast.hk/threads/86025/ (удалено :()
			imgui.SetNextWindowSize(imgui.ImVec2(700, 365), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'#depart', windows.imgui_depart, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
			imgui.Image(configuration.main_settings.style ~= 2 and whitedepart or blackdepart,imgui.ImVec2(266,25))
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
			imgui.SameLine(645)
			if imgui.Button(fa.ICON_FA_MINUS_SQUARE,imgui.ImVec2(23,23)) then
				if #dephistory ~= 0 then
					dephistory = {}
					ASHelperMessage('История сообщений успешно очищена.')
				end
			end
			imgui.Hint('Очистить историю сообщений')
			imgui.SameLine(668)
			if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
				windows.imgui_depart.v = false
			end
			imgui.PopStyleColor(3)
			imgui.BeginChild('##depbuttons',imgui.ImVec2(180,300),true)
			imgui.PushItemWidth(150)
			imgui.TextColoredRGB('Тэг вашей организации',1)
			if imgui.InputText('##myorgnamedep',departsettings.myorgname) then
				configuration.main_settings.astag = u8:decode(departsettings.myorgname.v)
			end
			if not imgui.IsItemActive() and #departsettings.myorgname.v == 0 then
				imgui.SameLine(20.7)
				imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), u8('Автошкола'))
			end
			imgui.TextColoredRGB('Тэг с кем связываетесь',1)
			imgui.InputText('##toorgnamedep',departsettings.toorgname)
			if not imgui.IsItemActive() and #departsettings.toorgname.v == 0 then
				imgui.SameLine(20.7)
				imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), u8('Банк'))
			end
			imgui.TextColoredRGB('Частота соеденения',1)
			imgui.InputText('##frequencydep',departsettings.frequency)
			if not imgui.IsItemActive() and #departsettings.frequency.v == 0 then
				imgui.SameLine(20.7)
				imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), '100,3')
			end
			imgui.PopItemWidth()
			imgui.NewLine()
			if imgui.Button(u8'Перейти на частоту',imgui.ImVec2(150,25)) then
				if u8:decode(departsettings.frequency.v) ~= '' and u8:decode(departsettings.myorgname.v) ~= '' then
					lua_thread.create(function()
						sampSendChat('/r Перехожу на частоту '..u8:decode(departsettings.frequency.v):gsub('%.',','))
						wait(2000)
						sampSendChat(('/d [%s] - [Информация] Перешёл на частоту %s'):format(u8:decode(departsettings.myorgname.v),u8:decode(departsettings.frequency.v):gsub('%.',',')))
					end)
				else
					ASHelperMessage('У вас что-то не указано.')
				end
			end
			imgui.Hint(('/r Перехожу на частоту %s\n{FFFFFF}/d [%s] - [Информация] Перешёл на частоту %s'):format(u8:decode(departsettings.frequency.v):gsub('%.',','),u8:decode(departsettings.myorgname.v),u8:decode(departsettings.frequency.v):gsub('%.',',')))
			if imgui.Button(u8'Покинуть частоту',imgui.ImVec2(150,25)) then
				if u8:decode(departsettings.frequency.v) ~= '' and u8:decode(departsettings.myorgname.v) ~= '' then
					sampSendChat('/d ['..u8:decode(departsettings.myorgname.v)..'] - [Информация] Покидаю частоту '..u8:decode(departsettings.frequency.v):gsub('%.',','))
				else
					ASHelperMessage('У вас что-то не указано.')
				end
			end
			imgui.Hint('/d ['..u8:decode(departsettings.myorgname.v)..'] - [Информация] Покидаю частоту '..u8:decode(departsettings.frequency.v):gsub('%.',','))
			if imgui.Button(u8'Тех. Неполадки',imgui.ImVec2(150,25)) then
				if u8:decode(departsettings.myorgname.v) ~= '' then
					sampSendChat('/d ['..u8:decode(departsettings.myorgname.v)..'] - [Информация] Тех. Неполадки')
				else
					ASHelperMessage('У вас что-то не указано.')
				end
			end
			imgui.Hint('/d ['..u8:decode(departsettings.myorgname.v)..'] - [Информация] Тех. Неполадки')
			imgui.EndChild()
			imgui.SameLine()
			imgui.BeginChild('##deptext',imgui.ImVec2(480,265),true,imgui.WindowFlags.NoScrollbar)
			imgui.SetScrollY(imgui.GetScrollMaxY())
			imgui.TextColoredRGB('История сообщений департамента {808080}(?)',1)
			imgui.Hint('Если в чате департамента будет тэг \''..u8:decode(departsettings.myorgname.v)..'\'\n{FFFFFF}в этот список добавится это сообщение')
			imgui.Separator()
			for k,v in pairs(dephistory) do
				imgui.TextWrapped(u8(v))
			end
			imgui.EndChild()
			imgui.SetCursorPos(imgui.ImVec2(207,323))
			imgui.PushItemWidth(368)
			imgui.InputText('##myorgtextdep',departsettings.myorgtext)
			imgui.PopItemWidth()
			imgui.SameLine()
			if imgui.Button(u8'Отправить',imgui.ImVec2(100,24)) then
				if u8:decode(departsettings.myorgname.v) ~= '' and u8:decode(departsettings.toorgname.v) ~= '' and u8:decode(departsettings.myorgtext.v) ~= '' then
					if u8:decode(departsettings.frequency.v) == '' then
						sampSendChat(('/d [%s] - [%s] %s'):format(u8:decode(departsettings.myorgname.v),u8:decode(departsettings.toorgname.v),u8:decode(departsettings.myorgtext.v)))
					else
						sampSendChat(('/d [%s] - %s - [%s] %s'):format(u8:decode(departsettings.myorgname.v),u8:decode(departsettings.frequency.v):gsub('%.',','),u8:decode(departsettings.toorgname.v),u8:decode(departsettings.myorgtext.v)))
					end
					departsettings.myorgtext.v = ''
				else
					ASHelperMessage('У вас что-то не указано.')
				end
			end
			if #departsettings.myorgtext.v == 0 then
				imgui.SameLine(212)
				imgui.TextColored(imgui.ImVec4(0.5, 0.5, 0.5, 1), u8'Напишите сообщение')
			end
			imgui.End()
		end

		if windows.imgui_changelog.v then
			imgui.SetNextWindowSize(imgui.ImVec2(900, 700), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(ScreenX / 2 , ScreenY / 2),imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
			imgui.Begin(u8'##changelog', windows.imgui_changelog, imgui.WindowFlags.NoTitleBar + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoScrollbar)
			imgui.Image(configuration.main_settings.style ~= 2 and whitechangelog or blackchangelog,imgui.ImVec2(238,25))
			imgui.PushStyleColor(imgui.Col.Button, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonHovered, imgui.ImVec4(1,1,1,0))
			imgui.PushStyleColor(imgui.Col.ButtonActive, imgui.ImVec4(1,1,1,0))
			imgui.SameLine(868)
			if imgui.Button(fa.ICON_FA_TIMES,imgui.ImVec2(23,23)) then
				windows.imgui_changelog.v = false
			end
			imgui.PopStyleColor(3)
			imgui.Separator()
			imgui.PushFont(fontsize16)
			imgui.TextColoredRGB([[
Версия 2.7
 - Добавлена функция задержки между сообщениями в биндере
 - Добавлена причина /expel
 - Исправлены некоторые баги
 - Теперь ранги в хелпере синхронизируются с вашими
 
Версия 2.6.1
 - Испралена неработоспособность скрипта
 
Версия 2.6
 - Добавлена поддержка 17-го сервера (Show-Low)
 - Исправлен краш при открытии вкладки 'Связь со мной'
 - Исправлен баг с восстановлением лекций/вопросов
 
Версия 2.5
 - Добавлена автоотыгровка дубинки
 - Выгонять теперь можно со 2-го ранга
 - Исправлен баг с крашем скрипта при озвучивании прайс листа
 - Переделана система проверки устава
 - Добавлен таймер последнего вопроса в проверку устава		
 
Версия 2.4.1
 - Добавлена функция продажи лицензии на таксование
 - Исправлен баг с вводом /givelicense самостоятельно
 
Версия 2.4
 - Добавлена функция общения в рацию департамента /ashdep
 - Изменён список изменений
 - Удалена светло-тёмная тема
 - Удалена система повышений изначальных правилах из-за ненадобности
 - Добавлена поддержка 16-го сервера (Gilbert)
 - Исправлены размеры изображений
 - Теперь меню лекций доступно с 5-го ранга
 - Исправлены некоторые баги
 
Версия 2.3
 - Убраны зависимости от библиотек rkeys и fAwesome5
 - Добавлена функция показа полосы прокрутки
 - Оптимизирована и улучшена система указаний клавиш для биндера
 - Добавлены png картинки вместо заголовков у окон
 - Добавлены тэги в биндер
 - Незначительные изменения
 
Версия 2.2
 - Добавлена функция увольнения с ЧС через команду
 - Добавлена функция озвучивания лекций /ashlect
 - Исправлен баг с пропадающим курсором после использования быстрого меню
 - Исправлен баг с непродающимися лицензиями (теперь точно)
 - Переделана система проверки нахождения на сервере Аризоны
 - Переработана система правил
 - Исправлен краш при поиске в правилах вводя управляющие символы
 - Исправлены некоторые граматические ошибки
 
Версия 2.1
 - Меню статистики /ashstats сделано более удобным
 - Двойной клик сохранит местоположение статистики /ashstats
 - Изменены кнопки в главном меню /ash
 - Теперь можно тестировать цвета в /ash
 - Исправлен баг с поиском по уставу
 - Исправлены другие мелкие баги
 - Теперь при активации бинда последнее сообщение будет без задержки
 
Версия 2.0
 - Добавлен список изменений
 - Исправлена проверка обновлений через /ash
 - Кардинальный редизайн главного меню /ash
 - Добавлены разные стили окон
 - Добавлены настройки цветов /r чата и /d чата
 - Добавлена функция просмотра правил
 - Добавлена функция быстрого /time + скрин
 - Добавлено автоопределение пола
 - Исправлен баг с ударом при принятии человека в организацию
 - Добавлена функция удаления конфига
 
Версия 1.1 - 1.9
 - Добавлены подсказки в биндере
 - Изменена система собеседований
 - На ESC теперь закрываются окна
 - Сделано более удобное изменение ранга
 - Теперь скрипт вне зависимости от вашего времени на системе подстраивается под часовой пояс МСК
 - Добавлена функция принятие на должность Консультанта
 - При зажатом ALT пропадает курсор во время открытых око
 - Добавлена статистика проданных лицензий (/ashstats)
 - Добавлены замены на серверные сообщения
 - Добавлена функция проверки устава
 - Исправлены баги
 
Версия 1.0
 - Релиз (спасибо zody за помощь в разработке)
]])
			imgui.PopFont()
			imgui.End()
		end

		if windows.imgui_stats.v then
			imgui.SetNextWindowSize(imgui.ImVec2(150, 200), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(imgui.ImVec2(configuration.imgui_pos.posX,configuration.imgui_pos.posY),imgui.Cond.FirstUseEver)
			imgui.Begin(u8'Статистика  ##stats',_,imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoBringToFrontOnFocus + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
			if imgui.IsMouseDoubleClicked(0) and imgui.IsWindowHovered() then
				local pos = imgui.GetWindowPos()
				configuration.imgui_pos.posX = pos.x
				configuration.imgui_pos.posY = pos.y
				if inicfg.save(configuration, 'AS Helper.ini') then
					ASHelperMessage('Позиция была сохранена.')
				end
			end
			imgui.Text(fa.ICON_FA_CAR..u8' Авто - '..configuration.my_stats.avto)
			imgui.Text(fa.ICON_FA_MOTORCYCLE..u8' Мото - '..configuration.my_stats.moto)
			imgui.Text(fa.ICON_FA_FISH..u8' Рыболовство - '..configuration.my_stats.riba)
			imgui.Text(fa.ICON_FA_SHIP..u8' Плавание - '..configuration.my_stats.lodka)
			imgui.Text(fa.ICON_FA_CROSSHAIRS..u8' Оружие - '..configuration.my_stats.guns)
			imgui.Text(fa.ICON_FA_SKULL_CROSSBONES..u8' Охота - '..configuration.my_stats.hunt)
			imgui.Text(fa.ICON_FA_ARCHIVE..u8' Раскопки - '..configuration.my_stats.klad)
			imgui.Text(fa.ICON_FA_TAXI..u8' Такси - '..configuration.my_stats.taxi)
			imgui.End()
		end
	end
end

function getClosestPlayerId()
	local temp = {}
	local tPeds = getAllChars()
	local me = {getCharCoordinates(playerPed)}
	for i, ped in ipairs(tPeds) do 
		local result, id = sampGetPlayerIdByCharHandle(ped)
		if ped ~= playerPed and result then
			local pl = {getCharCoordinates(ped)}
			local dist = getDistanceBetweenCoords3d(me[1], me[2], me[3], pl[1], pl[2], pl[3])
			temp[#temp + 1] = { dist, id }
		end
	end
	if #temp > 0 then
		table.sort(temp, function(a, b) return a[1] < b[1] end)
		return true, temp[1][2]
	end
	return false
end

function checkrules()
	if lfscheck then
		local files = 0
		ruless = {}
		for line in lfs.dir(getWorkingDirectory()..'\\AS Helper\\Rules') do
			if line == nil then
			elseif line:match('.+%.txt') then
				files = files + 1
				local temp = io.open(getWorkingDirectory()..'\\AS Helper\\Rules\\'..line:match('.+%.txt'), 'r+')
				local temptable = {}
				for linee in temp:lines() do
					if linee == '' then
						table.insert(temptable,' ')
					else
						table.insert(temptable,linee)
					end
				end
				table.insert(ruless,{
					name = line:match('(.+)%.txt'),
					text = temptable
				})
				temp:close()
			end
		end
		if files == 0 then
			ruless = default_rules
			for i, block in ipairs(ruless) do
				local temp = io.open(getWorkingDirectory()..'\\AS Helper\\Rules\\'..block.name..'.txt', 'w')
				for _,line in ipairs(block.text) do
					temp:write(line..'\n')
				end
				temp:close()
			end
		end
	end
end

function checkbibl()
	local doupdate = nil
	local function DownloadFile(url, file)
		downloadUrlToFile(url,file,function(id,status)
			if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			end
		end)
		while not doesFileExist(file) do
			wait(1000)
		end
		ASHelperMessage('Скачиваю...')
	end
	createDirectory(getWorkingDirectory()..'\\AS Helper')
	createDirectory(getWorkingDirectory()..'\\AS Helper\\Rules')
	if not doesFileExist(getWorkingDirectory()..'\\AS Helper\\Lections.json') then
		lections = default_lect
		local file = io.open(getWorkingDirectory()..'\\AS Helper\\Lections.json', 'w')
		file:write(encodeJson(lections))
		file:close()
	else
		local file = io.open(getWorkingDirectory()..'\\AS Helper\\Lections.json', 'r')
		lections = decodeJson(file:read('*a'))
		file:close()
	end
	if not doesFileExist(getWorkingDirectory()..'\\AS Helper\\Questions.json') then
		questions = default_questions
		local file = io.open(getWorkingDirectory()..'\\AS Helper\\Questions.json', 'w')
		file:write(encodeJson(questions))
		file:close()
	else
		local file = io.open(getWorkingDirectory()..'\\AS Helper\\Questions.json', 'r')
		questions = decodeJson(file:read('*a'))
		questions.active.redact = false
		file:close()
	end
	checkrules()
	if not imguicheck then
		ASHelperMessage('Отсутствует библиотека imgui. Пытаюсь её установить.')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/MoonImGui.dll', 'moonloader/lib/MoonImGui.dll')
		DownloadFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/imgui.lua', 'moonloader/lib/imgui.lua')
		ASHelperMessage('Библиотека imgui была успешно установлена.')
		NoErrors = true
		thisScript():reload()
		return false
	end
	if not sampevcheck then
		ASHelperMessage('Отсутствует библиотека samp events. Пытаюсь её установить.')
		createDirectory('moonloader/lib/samp')
		createDirectory('moonloader/lib/samp/events')
		DownloadFile('https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events.lua', 'moonloader/lib/samp/events.lua')
		DownloadFile('https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/raknet.lua', 'moonloader/lib/samp/raknet.lua')
		DownloadFile('https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/synchronization.lua', 'moonloader/lib/samp/synchronization.lua')
		DownloadFile('https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/bitstream_io.lua', 'moonloader/lib/samp/events/bitstream_io.lua')
		DownloadFile('https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/core.lua', 'moonloader/lib/samp/events/core.lua')
		DownloadFile('https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/extra_types.lua', 'moonloader/lib/samp/events/extra_types.lua')
		DownloadFile('https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/handlers.lua', 'moonloader/lib/samp/events/handlers.lua')
		DownloadFile('https://raw.githubusercontent.com/THE-FYP/SAMP.Lua/master/samp/events/utils.lua', 'moonloader/lib/samp/events/utils.lua')
		ASHelperMessage('Библиотека samp events была успешно установлена.')
		NoErrors = true
		thisScript():reload()
		return false
	end
	if not encodingcheck then
		ASHelperMessage('Отсутствует библиотека encoding. Пытаюсь её установить.')
		DownloadFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/encoding.lua', 'moonloader/lib/encoding.lua')
		ASHelperMessage('Библиотека encoding была успешно установлена.')
		NoErrors = true
		thisScript():reload()
		return false
	end
	if not lfscheck then
		ASHelperMessage('Отсутствует библиотека lfs. Пытаюсь её установить.')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/lfs.dll','moonloader/lib/lfs.dll')
		ASHelperMessage('Библиотека lfs была успешно установлена.')
		NoErrors = true
		thisScript():reload()
		return false
	end
	if not doesFileExist('moonloader/resource/fonts/fa-solid-900.ttf') then
		ASHelperMessage('Отсутствует файл шрифта. Пытаюсь его установить.')
		createDirectory('moonloader/resource/fonts')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/fa-solid-900.ttf', 'moonloader/resource/fonts/fa-solid-900.ttf')
		ASHelperMessage('Файл шрифта был успешно установлен.')
		NoErrors = true
		thisScript():reload()
		return false
	end
	if not doesFileExist('moonloader/AS Helper/Images/binderblack.png') or not doesFileExist('moonloader/AS Helper/Images/binderwhite.png') or not doesFileExist('moonloader/AS Helper/Images/lectionblack.png') or not doesFileExist('moonloader/AS Helper/Images/lectionwhite.png') or not doesFileExist('moonloader/AS Helper/Images/settingsblack.png') or not doesFileExist('moonloader/AS Helper/Images/settingswhite.png') or not doesFileExist('moonloader/AS Helper/Images/changelogblack.png') or not doesFileExist('moonloader/AS Helper/Images/changelogwhite.png') or not doesFileExist('moonloader/AS Helper/Images/departamentblack.png') or not doesFileExist('moonloader/AS Helper/Images/departamenwhite.png') then
		ASHelperMessage('Отсутствуют PNG файлы. Пытаюсь их скачать.')
		createDirectory('moonloader/AS Helper/Images')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/Images/binderblack.png', 'moonloader/AS Helper/Images/binderblack.png')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/Images/binderwhite.png', 'moonloader/AS Helper/Images/binderwhite.png')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/Images/lectionblack.png', 'moonloader/AS Helper/Images/lectionblack.png')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/Images/lectionwhite.png', 'moonloader/AS Helper/Images/lectionwhite.png')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/Images/settingsblack.png', 'moonloader/AS Helper/Images/settingsblack.png')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/Images/settingswhite.png', 'moonloader/AS Helper/Images/settingswhite.png')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/Images/departamentblack.png', 'moonloader/AS Helper/Images/departamentblack.png')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/Images/departamenwhite.png', 'moonloader/AS Helper/Images/departamenwhite.png')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/Images/changelogblack.png', 'moonloader/AS Helper/Images/changelogblack.png')
		DownloadFile('https://github.com/Just-Mini/biblioteki/raw/main/Images/changelogwhite.png', 'moonloader/AS Helper/Images/changelogwhite.png')
		ASHelperMessage('PNG файлы успешно скачаны.')
		NoErrors = true
		thisScript():reload()
		return false
	end
	if doesFileExist('moonloader/updateashelper.ini') then
		os.remove('moonloader/updateashelper.ini')
	end
	downloadUrlToFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/update.ini', 'moonloader/updateashelper.ini', function(id, status)
		if status == dlstatus.STATUSEX_ENDDOWNLOAD then
			if doesFileExist('moonloader/updateashelper.ini') then
				local updates = io.open('moonloader/updateashelper.ini','r')
				local tempdata = {}
				for line in updates:lines() do
					table.insert(tempdata, line)
				end
				io.close(updates)
				if tonumber(tempdata[1]) > thisScript().version_num then
					ASHelperMessage('Найдено обновление. Пытаюсь установить его.')
					doupdate = true
					configuration.main_settings.changelog = true
					inicfg.save(configuration, 'AS Helper.ini')
				else
					ASHelperMessage('Обновлений не найдено.')
					doupdate = false
				end
				os.remove('moonloader/updateashelper.ini')
			else
				ASHelperMessage('Произошла ошибка во время проверки обновлений.')
			end
		end
	end)
	while doupdate == nil do
		wait(300)
	end
	if doupdate then
		DownloadFile('https://raw.githubusercontent.com/Just-Mini/biblioteki/main/AS%20Helper.lua', thisScript().path)
		NoErrors = true
		ASHelperMessage('Обновление успешно установлено.')
		return false
	end
	return true
end