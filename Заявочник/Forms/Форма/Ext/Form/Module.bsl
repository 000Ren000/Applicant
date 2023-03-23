﻿
&НаКлиенте
Процедура Сформировать(Команда)
	Если ЗначениеЗаполнено(Объект.Дата) Тогда
		СформироватьНаСервере();
		СформироватьДатуДляЗаголовкаТаблицы(Объект.Дата);   
		РасчитатьКоэффициент(Команда);
		
		Сортировать = Истина;
		ВыполнитьСортировку();
		
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СформироватьДатуДляЗаголовкаТаблицы(Дата)  
	Элементы.ТоварыПр1.Заголовок = Формат(Дата - (60*60*24*1), "ДФ='ddd'");
	Элементы.ТоварыПр2.Заголовок = Формат(Дата - (60*60*24*2), "ДФ='ddd'");
	Элементы.ТоварыПр3.Заголовок = Формат(Дата - (60*60*24*3), "ДФ='ddd'");
	Элементы.ТоварыПр4.Заголовок = Формат(Дата - (60*60*24*4), "ДФ='ddd'");
	
	Элементы.ТоварыСпис1.Заголовок = Формат(Дата - (60*60*24*1), "ДФ='dd.MM.yy'");
	Элементы.ТоварыСпис2.Заголовок = Формат(Дата - (60*60*24*2), "ДФ='dd.MM.yy'");
	Элементы.ТоварыСпис3.Заголовок = Формат(Дата - (60*60*24*3), "ДФ='dd.MM.yy'");
	Элементы.ТоварыСпис4.Заголовок = Формат(Дата - (60*60*24*4), "ДФ='dd.MM.yy'");
	
КонецПроцедуры 

&НаСервере
Процедура СформироватьНаСервере()
	
	Объект.Товары.Очистить();
	
	Запрос = Новый Запрос;
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	Номенклатура.Ссылка КАК Номенклатура
	|ПОМЕСТИТЬ втНоменклатура
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|ГДЕ
	|	Номенклатура.Ссылка В ИЕРАРХИИ(&ГруппаНоменклатуры)
	|	И Номенклатура.ЭтоГруппа = ЛОЖЬ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	КОНЕЦПЕРИОДА(ТоварыНаСкладахОбороты.Период, ДЕНЬ) КАК Период,
	|	ТоварыНаСкладахОбороты.Номенклатура КАК Номенклатура,
	|	СУММА(ЕСТЬNULL(ТоварыНаСкладахОбороты.ВНаличииРасход, 0)) КАК Расход,
	|	СУММА(ВЫБОР
	|			КОГДА ТИПЗНАЧЕНИЯ(ТоварыНаСкладахОбороты.Регистратор) = ТИП(Документ.СписаниеНедостачТоваров)
	|					ИЛИ ТИПЗНАЧЕНИЯ(ТоварыНаСкладахОбороты.Регистратор) = ТИП(Документ.ПеремещениеТоваров)
	|					ИЛИ ТИПЗНАЧЕНИЯ(ТоварыНаСкладахОбороты.Регистратор) = ТИП(Документ.ВозвратТоваровПоставщику)
	|				ТОГДА ТоварыНаСкладахОбороты.ВНаличииРасход
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК Списания
	|ПОМЕСТИТЬ втОстаткиИРасход
	|ИЗ
	|	РегистрНакопления.ТоварыНаСкладах.Обороты(
	|			ДОБАВИТЬКДАТЕ(&ДатаНачала, ДЕНЬ, -4),
	|			&ДатаОкончания,
	|			Регистратор,
	|			Номенклатура В ИЕРАРХИИ (&ГруппаНоменклатуры)
	|				И Склад = &Склад) КАК ТоварыНаСкладахОбороты
	|
	|СГРУППИРОВАТЬ ПО
	|	КОНЕЦПЕРИОДА(ТоварыНаСкладахОбороты.Период, ДЕНЬ),
	|	ТоварыНаСкладахОбороты.Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ТоварыНаСкладахОбороты.Номенклатура КАК Номенклатура,
	|	СУММА(ТоварыНаСкладахОбороты.ВНаличииРасход) КАК РасходЗаПериод
	|ПОМЕСТИТЬ втРасходЗаПериод
	|ИЗ
	|	РегистрНакопления.ТоварыНаСкладах.Обороты(
	|			&ПериодДатаНачала,
	|			&ПериодДатаОкончания,
	|			Период,
	|			Номенклатура В ИЕРАРХИИ (&ГруппаНоменклатуры)
	|				И Склад = &Склад) КАК ТоварыНаСкладахОбороты
	|
	|СГРУППИРОВАТЬ ПО
	|	ТоварыНаСкладахОбороты.Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	втОстаткиИРасход.Номенклатура КАК Номенклатура,
	|	СУММА(ВЫБОР
	|			КОГДА втОстаткиИРасход.Период = ДОБАВИТЬКДАТЕ(&ДатаОкончания, ДЕНЬ, -1)
	|				ТОГДА втОстаткиИРасход.Расход
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК Расх1,
	|	СУММА(ВЫБОР
	|			КОГДА втОстаткиИРасход.Период = ДОБАВИТЬКДАТЕ(&ДатаОкончания, ДЕНЬ, -2)
	|				ТОГДА втОстаткиИРасход.Расход
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК Расх2,
	|	СУММА(ВЫБОР
	|			КОГДА втОстаткиИРасход.Период = ДОБАВИТЬКДАТЕ(&ДатаОкончания, ДЕНЬ, -3)
	|				ТОГДА втОстаткиИРасход.Расход
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК Расх3,
	|	СУММА(ВЫБОР
	|			КОГДА втОстаткиИРасход.Период = ДОБАВИТЬКДАТЕ(&ДатаОкончания, ДЕНЬ, -4)
	|				ТОГДА втОстаткиИРасход.Расход
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК Расх4,
	|	СУММА(ВЫБОР
	|			КОГДА втОстаткиИРасход.Период = ДОБАВИТЬКДАТЕ(&ДатаОкончания, ДЕНЬ, -1)
	|				ТОГДА втОстаткиИРасход.Списания
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК Спис1,
	|	СУММА(ВЫБОР
	|			КОГДА втОстаткиИРасход.Период = ДОБАВИТЬКДАТЕ(&ДатаОкончания, ДЕНЬ, -2)
	|				ТОГДА втОстаткиИРасход.Списания
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК Спис2,
	|	СУММА(ВЫБОР
	|			КОГДА втОстаткиИРасход.Период = ДОБАВИТЬКДАТЕ(&ДатаОкончания, ДЕНЬ, -3)
	|				ТОГДА втОстаткиИРасход.Списания
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК Спис3,
	|	СУММА(ВЫБОР
	|			КОГДА втОстаткиИРасход.Период = ДОБАВИТЬКДАТЕ(&ДатаОкончания, ДЕНЬ, -4)
	|				ТОГДА втОстаткиИРасход.Списания
	|			ИНАЧЕ 0
	|		КОНЕЦ) КАК Спис4
	|ПОМЕСТИТЬ втПодготовкаПередИтоговойТаблицей
	|ИЗ
	|	втОстаткиИРасход КАК втОстаткиИРасход
	|
	|СГРУППИРОВАТЬ ПО
	|	втОстаткиИРасход.Номенклатура
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА втРасходЗаПериод.РасходЗаПериод ЕСТЬ NULL
	|				И ТоварыНаСкладахОстатки.ВНаличииОстаток ЕСТЬ NULL
	|			ТОГДА 2
	|		ИНАЧЕ 1
	|	КОНЕЦ КАК Порядок,
	|	втНоменклатура.Номенклатура КАК Номенклатура,
	|	ВЫБОР
	|		КОГДА ТоварыНаСкладахОстатки.Номенклатура.ЕдиницаИзмерения ЕСТЬ NULL
	|			ТОГДА ЗНАЧЕНИЕ(Справочник.УпаковкиЕдиницыИзмерения.ПустаяСсылка)
	|		ИНАЧЕ ТоварыНаСкладахОстатки.Номенклатура.ЕдиницаИзмерения
	|	КОНЕЦ КАК ЕдИзм,
	|	ЕСТЬNULL(ТоварыНаСкладахОстатки.ВНаличииОстаток, 0) КАК Остаток,
	|	ЕСТЬNULL(втРасходЗаПериод.РасходЗаПериод, 0) КАК Период,
	|	ЕСТЬNULL(втПодготовкаПередИтоговойТаблицей.Расх1 - втПодготовкаПередИтоговойТаблицей.Спис1, 0) КАК Расх1,
	|	ЕСТЬNULL(втПодготовкаПередИтоговойТаблицей.Расх2 - втПодготовкаПередИтоговойТаблицей.Спис2, 0) КАК Расх2,
	|	ЕСТЬNULL(втПодготовкаПередИтоговойТаблицей.Расх3 - втПодготовкаПередИтоговойТаблицей.Спис3, 0) КАК Расх3,
	|	ЕСТЬNULL(втПодготовкаПередИтоговойТаблицей.Расх4 - втПодготовкаПередИтоговойТаблицей.Спис4, 0) КАК Расх4,
	|	ЕСТЬNULL(втПодготовкаПередИтоговойТаблицей.Спис1, 0) КАК Спис1,
	|	ЕСТЬNULL(втПодготовкаПередИтоговойТаблицей.Спис2, 0) КАК Спис2,
	|	ЕСТЬNULL(втПодготовкаПередИтоговойТаблицей.Спис3, 0) КАК Спис3,
	|	ЕСТЬNULL(втПодготовкаПередИтоговойТаблицей.Спис4, 0) КАК Спис4,
	|	ВЫБОР
	|		КОГДА ТоварыНаСкладахОстатки.ВНаличииОстаток - втРасходЗаПериод.РасходЗаПериод < 0
	|			ТОГДА -(ТоварыНаСкладахОстатки.ВНаличииОстаток - втРасходЗаПериод.РасходЗаПериод)
	|		ИНАЧЕ 0
	|	КОНЕЦ КАК КЗаказу
	|ИЗ
	|	втНоменклатура КАК втНоменклатура
	|		ЛЕВОЕ СОЕДИНЕНИЕ втПодготовкаПередИтоговойТаблицей КАК втПодготовкаПередИтоговойТаблицей
	|		ПО втНоменклатура.Номенклатура = втПодготовкаПередИтоговойТаблицей.Номенклатура
	|		ЛЕВОЕ СОЕДИНЕНИЕ РегистрНакопления.ТоварыНаСкладах.Остатки(&ДатаОкончания, Склад = &Склад) КАК ТоварыНаСкладахОстатки
	|		ПО втНоменклатура.Номенклатура = ТоварыНаСкладахОстатки.Номенклатура
	|		ЛЕВОЕ СОЕДИНЕНИЕ втРасходЗаПериод КАК втРасходЗаПериод
	|		ПО втНоменклатура.Номенклатура = втРасходЗаПериод.Номенклатура
	|
	|УПОРЯДОЧИТЬ ПО
	|	Порядок,
	|	Номенклатура
	|АВТОУПОРЯДОЧИВАНИЕ";
	
	Запрос.УстановитьПараметр("ГруппаНоменклатуры",  ГруппаНоменклатуры);  
	Запрос.УстановитьПараметр("ДатаНачала", 				 НачалоДня(Объект.Дата));
	Запрос.УстановитьПараметр("ДатаОкончания", 			 КонецДня(Объект.Дата));
	Запрос.УстановитьПараметр("ПериодДатаОкончания", Объект.Период.ДатаОкончания);   
	Запрос.УстановитьПараметр("ПериодДатаНачала", 	 Объект.Период.ДатаНачала);   	
	Запрос.УстановитьПараметр("Склад", 							 Объект.Склад);
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Строка = Объект.Товары.Добавить();
		ЗаполнитьЗначенияСвойств(Строка, ВыборкаДетальныеЗаписи);
	КонецЦикла;
	
КонецПроцедуры


&НаКлиенте
Процедура ТоварыВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	Период = Новый СтандартныйПериод;
	Период.ДатаНачала = Объект.Дата - 60*60*24 * 14;
	Период.ДатаОкончания = Объект.Дата;
	Если СтрНайти(Поле.Имя, "Спис") > 0 Или СтрНайти(Поле.Имя, "Пр")Тогда
		ПараметрыОткрытия = Новый Структура("СформироватьПриОткрытии", 
			Истина);
		ПараметрыОткрытия.Вставить("Отбор", 
		Новый Структура("Номенклатура, Склад, ПериодОтчета", Элементы.Товары.ТекущиеДанные.Номенклатура,
		Объект.Склад,
		Период)); 
		
		
			
			ОткрытьФорму("Отчет.ВедомостьПоТоварамНаСкладахВЦенахНоменклатуры.Форма",
			ПараметрыОткрытия,ЭтаФорма,,,,,РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
		
		//Отчетик = ПолучитьОтчет();  
		//ВариантыОтчетовКлиент.ОткрытьФормуОтчета(ЭтаФорма, Отчетик, ПараметрыОткрытия)	   
		//
	КонецЕсли;
	
КонецПроцедуры


&НаКлиенте
Процедура КоэффициентРегулирование(Элемент, Направление, СтандартнаяОбработка)
	СтандартнаяОбработка = Ложь;
	Объект.Коэффициент = Объект.Коэффициент + Направление * 10;
КонецПроцедуры


&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Объект.Дата = ТекущаяДата();
	Если Не ЗначениеЗаполнено(Объект.Коэффициент) Тогда
		Объект.Коэффициент = 20;
	КонецЕсли;
КонецПроцедуры


&НаКлиенте
Процедура РасчитатьКоэффициент(Команда)
	Для каждого Строка Из Объект.Товары Цикл  
		//Разница = Строка.Остаток - Строка.Период;
		//Процент = Разница * Объект.Коэффициент / 100;  
		Процент = Строка.Период * Объект.Коэффициент / 100;     
  	КЗаказу = Строка.Остаток - (Процент + Строка.Период);
		Строка.КЗаказу = ?(КЗаказу < 0, -КЗаказу, 0); 
	КонецЦикла;   
	ОкруглитьЗначенияКолонкиКЗаказу();
КонецПроцедуры


&НаКлиенте
Процедура СоздатьЗаказ(Команда)
	Режим = РежимДиалогаВопрос.ДаНет;
	Оповещение = Новый ОписаниеОповещения("ПослеЗакрытияВопроса", ЭтотОбъект, Параметры);
	ПоказатьВопрос(Оповещение,"Создать документ Заказ поставщику?", Режим, 0);	
КонецПроцедуры

&НаКлиенте
Процедура ПослеЗакрытияВопроса(Результат, Параметры) Экспорт
    Если Результат = КодВозвратаДиалога.Нет Тогда
        Возврат;
    КонецЕсли;
    СоздатьЗаказПоТоварам();
КонецПроцедуры

&НаСервере
Процедура СоздатьЗаказПоТоварам() 

	Сумма = 0;
		//ввод основных реквизитов
		ОбъектДокумента = Документы.ЗаказПоставщику.СоздатьДокумент();
		ОбъектДокумента.Партнер 	= Поставщик;
		ОбъектДокумента.Дата 	 	= Объект.Дата;
		ОбъектДокумента.Приоритет 	= Справочники.Приоритеты.НайтиПоНаименованию("Средний");
		ОбъектДокумента.Организация = Справочники.Организации.НайтиПоНаименованию("Коков Вячеслав Михайлович ИП");
		ОбъектДокумента.Склад 		= Объект.Склад;
		ОбъектДокумента.ВариантПриемкиТоваров  = Перечисления.ВариантыПриемкиТоваров.РазделенаТолькоПоНакладным;	
		ОбъектДокумента.Валюта 				   = Справочники.Валюты.НайтиПоНаименованию("RUB");
		ОбъектДокумента.НалогообложениеНДС 	   = Перечисления.ТипыНалогообложенияНДС.ПродажаОблагаетсяНДС;
		ОбъектДокумента.ЗакупкаПодДеятельность = Перечисления.ТипыНалогообложенияНДС.ПродажаНеОблагаетсяНДС;
		//Ввод табличной части
		Для Каждого Строка из Объект.Товары Цикл
			Если Строка.КЗаказу <> 0 Тогда
				ЦенаПоставщика = ПолучитьЦенуПоставщика(Строка.Номенклатура);
				СтрокаТЧДокумента = ОбъектДокумента.Товары.Добавить();
				СтрокаТЧДокумента.Номенклатура 	 	= Строка.Номенклатура;
				//СтрокаТЧДокумента.Номенклатура.ЕдиницаИзмерения = ПолучитьЕдиницуИзмерения(Строка.Товар);
				Если ЦенаПоставщика.ВидЦены = Неопределено Тогда
					Сообщить("Не указана цена поставщика у: " + Строка.Товар);
				КонецЕсли;
				СтрокаТЧДокумента.ВидЦеныПоставщика = ЦенаПоставщика.ВидЦены; //вид цены
				СтрокаТЧДокумента.Цена 				= ЦенаПоставщика.Цена;//цена
				СтрокаТЧДокумента.КоличествоУпаковок = Строка.КЗаказу;//Количество
				СтрокаТЧДокумента.Количество		= Строка.КЗаказу;
				СтрокаТЧДокумента.Сумма 			= ЦенаПоставщика.Цена * Строка.КЗаказу;//сумма
				СтрокаТЧДокумента.СтавкаНДС			= Перечисления.СтавкиНДС.БезНДС;
				СтрокаТЧДокумента.СуммаСНДС			= СтрокаТЧДокумента.Сумма;
				Сумма = Сумма + СтрокаТЧДокумента.Сумма;
			КонецЕсли;
		КонецЦикла;
		
		ОбъектДокумента.СуммаДокумента = Сумма;
	Попытка
		ОбъектДокумента.Записать(РежимЗаписиДокумента.Проведение);
		Сообщить("Документ успешно создан" + ОбъектДокумента);
	Исключение
		Сообщить("Не удалось создать документ!");
	КонецПопытки;
	
	
	
КонецПроцедуры // СоздатьЗаказПоТоварам()

//Запрос на получение цены и вида цен поставщика
//
&НаСервере
Функция ПолучитьЦенуПоставщика(Номенклатура)
	Запрос = Новый Запрос;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ЦеныНоменклатурыПоставщиковСрезПоследних.Партнер КАК Поставщик,
		|	ЦеныНоменклатурыПоставщиковСрезПоследних.ВидЦеныПоставщика КАК ВидЦены,
		|	ЦеныНоменклатурыПоставщиковСрезПоследних.Цена КАК Цена,
		|	ЦеныНоменклатурыПоставщиковСрезПоследних.Номенклатура КАК Номенклатура
		|ИЗ
		|	РегистрСведений.ЦеныНоменклатурыПоставщиков.СрезПоследних(
		|			&Период,
		|			Номенклатура = &Номенклатура
		|				И Партнер = &Поставщик) КАК ЦеныНоменклатурыПоставщиковСрезПоследних";
	
	Запрос.УстановитьПараметр("Период", ТекущаяДата());
	Запрос.УстановитьПараметр("Поставщик", Поставщик);
	Запрос.УстановитьПараметр("Номенклатура", Номенклатура);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	ВыборкаДетальныеЗаписи.Следующий();
	 
	Результат = Новый Структура("ВидЦены, Цена", ВыборкаДетальныеЗаписи.ВидЦены, ВыборкаДетальныеЗаписи.Цена); 	
	
	Возврат Результат;
КонецФункции

&НаСервере
Процедура ОкруглитьЗначенияКолонкиКЗаказу()
	 ЕдИзШТ = Справочники.УпаковкиЕдиницыИзмерения.НайтиПоНаименованию("шт");	
	
	 Для каждого Строка Из Объект.Товары Цикл
	 
		Если Строка.ЕдИзм = ЕдИзШТ Тогда
		 	Строка.КЗаказу =  Окр(Строка.КЗаказу, 0,РежимОкругления.Окр15как20);  
		Иначе
			Строка.КЗаказу =  Окр(Строка.КЗаказу, 2,РежимОкругления.Окр15как20); 
			
			Модуль = Строка.КЗаказу % 1;			
			Если Модуль = 0 Тогда 
				Округление = Строка.КЗаказу;
			ИначеЕсли Модуль < 0.5 Тогда
				Округление =  0.5 - Модуль + Строка.КЗаказу;	
			Иначе
				Округление = 1 - Модуль + Строка.КЗаказу;
			КонецЕсли;
			
			Строка.КЗаказу = Округление;
		КонецЕсли;
		 
	 КонецЦикла;

КонецПроцедуры 


&НаСервере
Функция ПолучитьОтчет()        
		Отчет = "Отчет.ВедомостьПоТоварамНаСкладах";
		Отчет1 = Справочники.ИдентификаторыОбъектовМетаданных.НайтиПоНаименованию("Ведомость по товарам на складах (Отчет)");
		Пользователь = Справочники.Пользователи.НайтиПоНаименованию("Макашкина Елена");   
	  СписокКлючейОтчета = ВариантыОтчетов.КлючиВариантовОтчета(Отчет, Пользователь);
		НужныйКлюч = СписокКлючейОтчета[0].Значение; 
		ВариантОтчета = ВариантыОтчетов.ВариантОтчета(Отчет1, НужныйКлюч);  
		Возврат ВариантОтчета;	
КонецФункции 

&НаКлиенте
Процедура СортироватьПриИзменении(Элемент)
	ВыполнитьСортировку();	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьСортировку()
	
	Если Сортировать Тогда
		Объект.Товары.Сортировать("Порядок Возр,КЗаказу Убыв");	
	Иначе
		Объект.Товары.Сортировать("Порядок,Номенклатура");
	КонецЕсли;
	
	
КонецПроцедуры 