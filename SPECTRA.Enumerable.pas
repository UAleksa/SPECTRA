unit SPECTRA.Enumerable;

interface

uses
  {$IFDEF MSWINDOWS}
  Winapi.Windows, Winapi.Messages, Winapi.ActiveX,
  {$ENDIF MSWINDOWS}
  System.SysUtils, System.Variants, System.Classes,
  System.Generics.Defaults, System.RTLConsts, System.Types, System.Rtti;

type
  TProcIndex<T> = reference to procedure (Arg: T; Index: Integer);
  TPredicateIndex<T> = reference to function (Arg: T; Index: Integer): Boolean;

  ISPEnumerator<T> = interface
  ['{3CB550B9-E597-4CEC-A07E-8F7ADDE82CAC}']
    function Clone: ISPEnumerator<T>;
    procedure Reset;
    function MoveNext: Boolean;
    function GetCurrent: T;
    function GetCurrentIndex: Integer;
    property Current: T read GetCurrent;
    property CurrentIndex: Integer read GetCurrentIndex;
  end;

  TSPEnumerable<T> = class;
  
  ISPEnumerable<T> = interface
  ['{5119F9B5-A5BB-41D6-941D-802AD0533800}']
    function GetEnumerator: ISPEnumerator<T>;

    function Cast: TSPEnumerable<T>;
    
    function ToArray: TArray<T>;
    function ToList(List: TObject; const AddName: string = 'Add'): TObject;
    procedure ToAnyCollection(Proc: TProcIndex<T>);

    function Aggregate(const Func: TFunc<T, T, T>): T;

    function All(const Predicate: TPredicate<T>): boolean;

    function Any: boolean; overload;
    function Any(const Predicate: TPredicate<T>): boolean; overload;

    function Append(Element: T): ISPEnumerable<T>; overload;
    function Append(Proc: TProc; Enumerator: ISPEnumerator<T>): ISPEnumerable<T>; overload;

    function Average: Double; overload;
    function Average(const Selector: TFunc<T, Int64>): Double; overload;
    function Average(const Selector: TFunc<T, Double>): Double; overload;

    function Concat(const Second: array of T): ISPEnumerable<T>; overload;
    function Concat(const Second: ISPEnumerable<T>): ISPEnumerable<T>; overload;

    function Contains(Element: T; const Comparer: IComparer<T>): boolean; overload;
    function Contains(Element: T): boolean; overload;

    function Count: Integer; overload;
    function Count(const Predicate: TPredicate<T>): Integer; overload;

    function Distinct(const Comparer: IComparer<T>): ISPEnumerable<T>; overload;
    function Distinct: ISPEnumerable<T>; overload;

    function ElementAt(Index: Integer): T;
    function ElementAtOrDefault(Index: Integer): T;

    function ExceptFor(const Inner: ISPEnumerable<T>; const Comparer: IComparer<T>): ISPEnumerable<T>; overload;
    function ExceptFor(const Inner: ISPEnumerable<T>): ISPEnumerable<T>; overload;

    function First: T; overload;
    function First(const Predicate: TPredicate<T>): T; overload;

    function FirstOrDefault: T; overload;
    function FirstOrDefault(const Predicate: TPredicate<T>): T; overload;

    function Insert(Index: Integer; Element: T): ISPEnumerable<T>; overload;
    function Insert(Proc: TProc; Enumerator: ISPEnumerator<T>): ISPEnumerable<T>; overload;

    function Intersect(const Inner: ISPEnumerable<T>; const Comparer: IComparer<T>): ISPEnumerable<T>; overload;
    function Intersect(const Inner: ISPEnumerable<T>): ISPEnumerable<T>; overload;

    function Last: T; overload;
    function Last(const Predicate: TPredicate<T>): T; overload;

    function LastOrDefault: T; overload;
    function LastOrDefault(const Predicate: TPredicate<T>): T; overload;

    function Max(const Comparer: IComparer<T>): T; overload;
    function Max: T; overload;

    function Min(const Comparer: IComparer<T>): T; overload;
    function Min: T; overload;

    function Prepend(Element: T): ISPEnumerable<T>; overload;
    function Prepend(Proc: TProc; Enumerator: ISPEnumerator<T>): ISPEnumerable<T>; overload;

    function SequenceEqual(const Second: ISPEnumerable<T>): boolean; overload;
    function SequenceEqual(const Second: ISPEnumerable<T>;
      const Comparer: IComparer<T>): boolean; overload;

    function Single(const Predicate: TPredicate<T>): T; overload;
    function Single(const Predicate: TPredicateIndex<T>): T; overload;
    function SingleOrDefault(const Predicate: TPredicate<T>): T; overload;
    function SingleOrDefault(const Predicate: TPredicateIndex<T>): T; overload;

    function Skip(const Count: Integer): ISPEnumerable<T>;
    function SkipLast(const Count: Integer): ISPEnumerable<T>;
    function SkipWhile(const Predicate: TPredicate<T>): ISPEnumerable<T>; overload;
    function SkipWhile(const Predicate: TPredicateIndex<T>): ISPEnumerable<T>; overload;

    function Sum(const Selector: TFunc<T, Double>): Double; overload;
    function Sum(const Selector: TFunc<T, Int64>): Int64; overload;
    function Sum(const SumFunc: TFunc<T, T, T>): T; overload;

    function Take(const Count: Integer): ISPEnumerable<T>;
    function TakeLast(const Count: Integer): ISPEnumerable<T>;
    function TakeWhile(const Predicate: TPredicate<T>): ISPEnumerable<T>; overload;
    function TakeWhile(const Predicate: TPredicateIndex<T>): ISPEnumerable<T>; overload;

    function Union(const Inner: ISPEnumerable<T>; const Comparer: IComparer<T>): ISPEnumerable<T>; overload;
    function Union(const Inner: ISPEnumerable<T>): ISPEnumerable<T>; overload;

    function Where(const Predicate: TPredicate<T>): ISPEnumerable<T>; overload;
    function Where(const Predicate: TPredicateIndex<T>): ISPEnumerable<T>; overload;
  end;

  IGrouping<TKey, T> = interface
  ['{9D916E8A-4D70-436F-A3BC-0AAD59362295}']
  //private
    function GetKey: TKey;
  //public
    property Key: TKey read GetKey;
    function GetEnumerator: ISPEnumerator<T>;
  end;

  TSourceType = (stNone, stArray, stEnumerable, stList, stEnumerator);

  TSPEnumerable<T> = class(TInterfacedObject, ISPEnumerable<T>)
  private
    FSourceType: TSourceType;
    FValues: TArray<T>;
    FEnumerable: ISPEnumerable<T>;
    FEnumerator: ISPEnumerator<T>;
    FSL: TObject;
    FItemsName: string;
    FCountName: string;

    function ToInteger(const Item: T): Int64;
    function ToDouble(const Item: T): Double;
    function InvokeListMethod(List: TObject; MethodName: string; 
      const Parameters: array of TValue): boolean;
  public
    constructor Create(const Source: TArray<T>); overload;
    constructor Create(const Source: array of T); overload;
    constructor Create(const Source: ISPEnumerable<T>); overload;
    constructor Create(const aList: TObject;
      const ItemsName: string = 'Items';
      const CountName: string = 'Count'); overload;
    constructor Create(const Enumerator: ISPEnumerator<T>); overload;
    destructor Destroy; override;

    function GetEnumerator: ISPEnumerator<T>; virtual;

    ///  Создает массив из объекта ISPEnumerable<T>
    function ToArray: TArray<T>;
    ///  Создает список объектов из ISPEnumerable<T>
    function ToList(List: TObject; const AddName: string = 'Add'): TObject;

    procedure ToAnyCollection(Proc: TProcIndex<T>);

    ///  Применяет к последовательности агрегатную функцию.
    function Aggregate(const Func: TFunc<T, T, T>): T; overload;
    ///  Применяет к последовательности агрегатную функцию. Указанное начальное значение
    ///  используется в качестве исходного значения агрегатной операции.
    function Aggregate<TAccumulate>(const Seed: TAccumulate;
      const Func: TFunc<TAccumulate, T, TAccumulate>): TAccumulate; overload;
    ///  Применяет к последовательности агрегатную функцию.
    ///  Указанное начальное значение служит исходным значением для агрегатной операции,
    ///  а указанная функция используется для выбора результирующего значения.
    function Aggregate<TAccumulate, TResult>(const Seed: TAccumulate;
      const Func: TFunc<TAccumulate, T, TAccumulate>;
      const Selector: TFunc<TAccumulate, TResult>): TResult; overload;

    ///  Проверяет, все ли элементы последовательности удовлетворяют условию.
    function All(const Predicate: TPredicate<T>): boolean;

    ///   Проверяет, содержит ли последовательность какие-либо элементы.
    function Any: boolean; overload;
    ///   Проверяет, удовлетворяет ли какой-либо элемент последовательности заданному условию.
    function Any(const Predicate: TPredicate<T>): boolean; overload;

    ///  Добавляет значение в конец последовательности
    function Append(Element: T): ISPEnumerable<T>; overload;
    function Append(Proc: TProc; Enumerator: ISPEnumerator<T>): ISPEnumerable<T>; overload;
    
    ///  Вычисляет среднее последовательности значений, если T = Double или Int64
    function Average: Double; overload;
    ///   Вычисляет среднее для последовательности Int64
    function Average(const Selector: TFunc<T, Int64>): Double; overload;
    ///   Вычисляет среднее для последовательности Double
    function Average(const Selector: TFunc<T, Double>): Double; overload;

    function Cast: TSPEnumerable<T>; overload;
    ///  Приводит элементы объекта ISPEnumerable<T> к заданному типу TResult
    ///  с помощью функции Selector
    function Cast<TResult>(const Selector: TFunc<T, TResult>): TSPEnumerable<TResult>; overload;
    ///  Приводит элементы объекта ISPEnumerable<T> к заданному типу TResult
    function Cast<TResult>: TSPEnumerable<TResult>; overload;

    ///  Объединяет две последовательность ISPEnumerable<T> и массив
    function Concat(const Second: array of T): ISPEnumerable<T>; overload;
    ///  Объединяет две последовательности
    function Concat(const Second: ISPEnumerable<T>): ISPEnumerable<T>; overload;


    ///  Определяет, содержится ли указанный элемент в последовательности, используя компаратор Comparer
    function Contains(Element: T; const Comparer: IComparer<T>): boolean; overload;
    ///  Определяет, содержится ли указанный элемент в последовательности, используя компаратор по умолчанию
    function Contains(Element: T): boolean; overload;

    ///  Возвращает количество элементов в последовательности
    function Count: Integer; overload;
    ///  Возвращает количество элементов в последовательности с учетом условия Predicate
    function Count(const Predicate: TPredicate<T>): Integer; overload;


    ///  Возвращает различающиеся элементы последовательности,
    ///  используя для сравнения значений компаратор Comparer
    function Distinct(const Comparer: IComparer<T>): ISPEnumerable<T>; overload;
    ///  Возвращает различающиеся элементы последовательности
    function Distinct: ISPEnumerable<T>; overload;

    ///  Возвращает элемент по указанному индексу в последовательности
    function ElementAt(Index: Integer): T;
    ///  Возвращает элемент последовательности по указанному индексу или значение по умолчанию
    function ElementAtOrDefault(Index: Integer): T;

    ///  Находит разность множеств, представленных двумя последовательностями,
    ///  используя для сравнения значений компаратор Comparer
    function ExceptFor(const Inner: ISPEnumerable<T>; const Comparer: IComparer<T>): ISPEnumerable<T>; overload;
    ///  Находит разность множеств, представленных двумя последовательностями,
    ///  используя для сравнения значений компаратор проверки на равенство по умолчанию
    function ExceptFor(const Inner: ISPEnumerable<T>): ISPEnumerable<T>; overload;

    ///  Возвращает первый элемент последовательности
    function First: T; overload;
    ///  Возвращает первый элемент последовательности, удовлетворяющий указанному условию
    function First(const Predicate: TPredicate<T>): T; overload;

    ///  Возвращает первый элемент последовательности или значение по умолчанию,
    ///  если последовательность не содержит элементов
    function FirstOrDefault: T; overload;
    ///  Возвращает первый элемент последовательности, удовлетворяющий указанному условию,
    ///  или значение по умолчанию, если ни одного такого элемента не найдено
    function FirstOrDefault(const Predicate: TPredicate<T>): T; overload;

    /// Вставляет значение с индексом Index в последовательность
    function Insert(Index: Integer; Element: T): ISPEnumerable<T>; overload;
    function Insert(Proc: TProc; Enumerator: ISPEnumerator<T>): ISPEnumerable<T>; overload;
    
    ///  Находит пересечение множеств, представленных двумя последовательностями,
    ///  используя для сравнения значений указанный компаратор
    function Intersect(const Inner: ISPEnumerable<T>; const Comparer: IComparer<T>): ISPEnumerable<T>; overload;
    ///  Находит пересечение множеств, представленных двумя последовательностями,
    ///  используя для сравнения значений компаратор проверки на равенство по умолчанию
    function Intersect(const Inner: ISPEnumerable<T>): ISPEnumerable<T>; overload;

    ///  Устанавливает корреляцию между элементами двух последовательностей на основе сопоставления ключей.
    ///  Для сравнения ключей используется компаратор проверки на равенство по умолчанию
    function Join<TInner, TKey, TResult>(const Inner: ISPEnumerable<TInner>;
      const OuterKeySelector: TFunc<T, TKey>;
      const InnerKeySelector: TFunc<TInner, TKey>;
      const ResultSelector: TFunc<T, TInner, TResult>;
      const Comparer: IComparer<TKey>): TSPEnumerable<TResult>; overload;
    function Join<TInner, TKey, TResult>(const Inner: ISPEnumerable<TInner>;
      const OuterKeySelector: TFunc<T, Integer, TKey>;
      const InnerKeySelector: TFunc<TInner, Integer, TKey>;
      const ResultSelector: TFunc<T, Integer, TInner, Integer, TResult>;
      const Comparer: IComparer<TKey>): TSPEnumerable<TResult>; overload;
    function Join<TInner, TKey, TResult>(const Inner: ISPEnumerable<TInner>;
      const OuterKeySelector: TFunc<T, TKey>;
      const InnerKeySelector: TFunc<TInner, TKey>;
      const ResultSelector: TFunc<T, TInner, TResult>): TSPEnumerable<TResult>; overload;
    function Join<TInner, TKey, TResult>(const Inner: ISPEnumerable<TInner>;
      const OuterKeySelector: TFunc<T, Integer, TKey>;
      const InnerKeySelector: TFunc<TInner, Integer, TKey>;
      const ResultSelector: TFunc<T, Integer, TInner, Integer, TResult>): TSPEnumerable<TResult>; overload;

    ///  Группирует элементы последовательности в соответствии с заданной функцией селектора ключа
    ///  Ключи сравниваются с использованием заданного компаратора
    function GroupBy<TKey>(const KeySelector: TFunc<T, TKey>;
      const Comparer: IComparer<TKey>): ISPEnumerable<IGrouping<TKey, T>>; overload;
    ///  Группирует элементы последовательности в соответствии с заданной функцией селектора ключа
    function GroupBy<TKey>(const KeySelector: TFunc<T, TKey>): ISPEnumerable<IGrouping<TKey, T>>; overload;

    ///  Устанавливает корреляцию между элементами двух последовательностей на
    ///  основе равенства ключей и группирует результаты.
    ///  Для сравнения ключей используется компаратор по умолчанию
    function GroupJoin<TInner, TKey, TResult>(const Inner: ISPEnumerable<TInner>;
      const OuterKeySelector: TFunc<T, TKey>;
      const InnerKeySelector: TFunc<TInner, TKey>;
      const ResultSelector: TFunc<T, ISPEnumerable<TInner>, TResult>): TSPEnumerable<TResult>; overload;
    ///  Устанавливает корреляцию между элементами двух последовательностей на
    ///  основе равенства ключей и группирует результаты.
    ///  Для сравнения ключей используется указанный компаратор
    function GroupJoin<TInner, TKey, TResult>(const Inner: ISPEnumerable<TInner>;
      const OuterKeySelector: TFunc<T, TKey>;
      const InnerKeySelector: TFunc<TInner, TKey>;
      const ResultSelector: TFunc<T, ISPEnumerable<TInner>, TResult>;
      const Comparer: IComparer<TKey>): TSPEnumerable<TResult>; overload;

    ///  Возвращает последний элемент последовательности
    function Last: T; overload;
    ///  Возвращает последний элемент последовательности, удовлетворяющий указанному условию
    function Last(const Predicate: TPredicate<T>): T; overload;

    ///  Возвращает последний элемент последовательности или значение по умолчанию,
    ///  если последовательность не содержит элементов
    function LastOrDefault: T; overload;
    ///  Возвращает последний элемент последовательности, удовлетворяющий указанному условию,
    ///  или значение по умолчанию, если ни одного такого элемента не найдено
    function LastOrDefault(const Predicate: TPredicate<T>): T; overload;

    ///  Возвращает максимальное значение, содержащееся в последовательности значений
    function Max(const Comparer: IComparer<T>): T; overload;
    function Max: T; overload;
    function Max<TResult>(const Selector: TFunc<T, TResult>; const Comparer: IComparer<TResult>): TResult; overload;
    function Max<TResult>(const Selector: TFunc<T, TResult>): TResult; overload;

    ///  Возвращает минимальное значение, содержащееся в последовательности значений
    function Min(const Comparer: IComparer<T>): T; overload;
    function Min: T; overload;
    function Min<TResult>(const Selector: TFunc<T, TResult>; const Comparer: IComparer<TResult>): TResult; overload;
    function Min<TResult>(const Selector: TFunc<T, TResult>): TResult; overload;

    ///  Сортирует элементы последовательности в порядке возрастания
    function OrderBy<TKey>(const KeySelector: TFunc<T, TKey>;
      const Comparer: IComparer<TKey>): ISPEnumerable<T>; overload;
    function OrderBy<TKey>(const KeySelector: TFunc<T, TKey>): ISPEnumerable<T>; overload;

    ///  Сортирует элементы последовательности в порядке убывания
    function OrderByDesc<TKey>(const KeySelector: TFunc<T, TKey>;
      const Comparer: IComparer<TKey>): ISPEnumerable<T>; overload;
    function OrderByDesc<TKey>(const KeySelector: TFunc<T, TKey>): ISPEnumerable<T>; overload;

    ///  Добавляет значение в начало последовательности
    function Prepend(Element: T): ISPEnumerable<T>; overload;
    function Prepend(Proc: TProc; Enumerator: ISPEnumerator<T>): ISPEnumerable<T>; overload;

    ///  Проецирует каждый элемент последовательности в новую форму
    function Select<T, TResult>(const Selector: TFunc<T, Integer, TResult>): TSPEnumerable<TResult>; overload;
    function Select<T, TResult>(const Selector: TFunc<T, TResult>): TSPEnumerable<TResult>; overload;
    ///  Проецирует каждый элемент последовательности в объект ISPEnumerable<T> и
    ///  объединяет результирующие последовательности в одну последовательность.
    function SelectMany<T, TResult>(const Selector: TFunc<T, ISPEnumerable<TResult>>): TSPEnumerable<TResult>; overload;
    ///  Проецирует каждый элемент последовательности в новую форму
    function SelectMany<T, TResult>(const Selector: TFunc<T, Integer, ISPEnumerable<TResult>>): TSPEnumerable<TResult>; overload;

    ///  Определяет, совпадают ли две последовательности, используя функцию сравнения на равенство
    function SequenceEqual(const Second: ISPEnumerable<T>): boolean; overload;
    function SequenceEqual(const Second: ISPEnumerable<T>;
      const Comparer: IComparer<T>): boolean; overload;

    ///  Возвращает единственный конкретный элемент последовательности
    function Single(const Predicate: TPredicate<T>): T; overload;
    function Single(const Predicate: TPredicateIndex<T>): T; overload;
    ///  Возвращает единственный конкретный элемент последовательности или
    ///  значение по умолчанию, если этот элемент не найден
    function SingleOrDefault(const Predicate: TPredicate<T>): T; overload;
    function SingleOrDefault(const Predicate: TPredicateIndex<T>): T; overload;

    ///  Пропускает заданное число элементов с начала последовательности и возвращает остальные элементы
    function Skip(const Count: Integer): ISPEnumerable<T>;
    ///  Пропускает заданное число элементов с конца последовательности и возвращает остальные элементы
    function SkipLast(const Count: Integer): ISPEnumerable<T>;
    ///  Пропускает элементы в последовательности, пока они удовлетворяют заданному условию, и затем возвращает оставшиеся элементы
    function SkipWhile(const Predicate: TPredicate<T>): ISPEnumerable<T>; overload;
    function SkipWhile(const Predicate: TPredicateIndex<T>): ISPEnumerable<T>; overload;


    ///  Вычисляет сумму последовательности числовых значений,
    ///  если T = Double или Int64, тогда Selector может равняться nil
    function Sum(const Selector: TFunc<T, Double>): Double; overload;
    //если T = Double или Int64, тогда Selector может равняться nil
    function Sum(const Selector: TFunc<T, Int64>): Int64; overload;
    function Sum(const SumFunc: TFunc<T, T, T>): T; overload;
    function Sum<TResult>(const Selector: TFunc<T, TResult>;
      const SumFunc: TFunc<TResult, TResult, TResult>): TResult; overload;

    ///  Возвращает указанное число подряд идущих элементов с начала последовательности
    function Take(const Count: Integer): ISPEnumerable<T>;
    ///  Возвращает указанное число подряд идущих элементов с конца последовательности
    function TakeLast(const Count: Integer): ISPEnumerable<T>;
    ///  Возвращает элементы последовательности, пока они удовлетворяют
    ///  заданному условию, и затем пропускает оставшиеся элементы
    function TakeWhile(const Predicate: TPredicate<T>): ISPEnumerable<T>; overload;
    function TakeWhile(const Predicate: TPredicateIndex<T>): ISPEnumerable<T>; overload;

    ///  Выполняет дополнительное упорядочение элементов последовательности в порядке возрастания
    function ThenBy<TKey>(const KeySelector: TFunc<T, TKey>;
      const Comparer: IComparer<TKey>): TSPEnumerable<T>;
    function ThenByDesc<TKey>(const KeySelector: TFunc<T, TKey>;
      const Comparer: IComparer<TKey>): TSPEnumerable<T>;

    ///  Находит объединение множеств, представленных двумя последовательностями
    function Union(const Inner: ISPEnumerable<T>; const Comparer: IComparer<T>): ISPEnumerable<T>; overload;
    function Union(const Inner: ISPEnumerable<T>): ISPEnumerable<T>; overload;

    ///  Выполняет фильтрацию последовательности значений на основе заданного предиката
    function Where(const Predicate: TPredicate<T>): ISPEnumerable<T>; overload;
    function Where(const Predicate: TPredicateIndex<T>): ISPEnumerable<T>; overload;
  end;

  TListEnumerator<T> = class(TInterfacedObject, ISPEnumerator<T>)
  private
    FList: TObject;
    FIndex: Integer;
    FCurrent: T;
    FCurrentIndex: Integer;
    FItemsName: string;
    FCountName: string;

    function Clone: ISPEnumerator<T>;
    procedure Reset;
    function GetCurrent: T;
    function GetCurrentIndex: Integer;
  public
    constructor Create(const AList: TObject; const ItemsName, CountName: string);
    destructor Destroy; override;

    function MoveNext: Boolean;
    property Current: T read GetCurrent;
    property CurrentIndex: Integer read GetCurrentIndex;
  end;

  TSelectorEnumerator<T, TResult> = class(TSPEnumerable<TResult>, ISPEnumerator<TResult>)
  private
    FCurrent: TResult;
    FCurrentIndex: Integer;
    FSelector: TFunc<T, TResult>;
    FSelectorIndex: TFunc<T, Integer, TResult>;
    FEnumerator: ISPEnumerator<T>;
    FSource: ISPEnumerable<T>;

    function Clone: ISPEnumerator<TResult>;
    procedure Reset;
    function GetCurrent: TResult;
    function GetCurrentIndex: Integer;
  public
    constructor Create(const Source: ISPEnumerable<T>;
      const Selector: TFunc<T, TResult>);
    constructor CreateWithIndexes(const Source: ISPEnumerable<T>;
      const Selector: TFunc<T, Integer, TResult>);

    function MoveNext: Boolean;
    function GetEnumerator: ISPEnumerator<TResult>; override;
    property Current: TResult read GetCurrent;
    property CurrentIndex: Integer read GetCurrentIndex;
  end;

  TSelectorManyEnumerator<T, TResult> = class(TSPEnumerable<TResult>, ISPEnumerator<TResult>)
  private
    FCurrent: TResult;
    FCurrentIndex: Integer;
    FSelector: TFunc<T, ISPEnumerable<TResult>>;
    FSelectorIndex: TFunc<T, Integer, ISPEnumerable<TResult>>;
    FEnumerator: ISPEnumerator<T>;
    FSource: ISPEnumerable<T>;
    FSourceOut: ISPEnumerable<TResult>;
    FEnumeratorOut: ISPEnumerator<TResult>;
    FOutFlag: boolean;

    function Clone: ISPEnumerator<TResult>;
    procedure Reset;
    function GetCurrent: TResult;
    function GetCurrentIndex: Integer;
  public
    constructor Create(const Source: ISPEnumerable<T>;
      const Selector: TFunc<T, ISPEnumerable<TResult>>);
    constructor CreateWithIndexes(const Source: ISPEnumerable<T>;
      const Selector: TFunc<T, Integer, ISPEnumerable<TResult>>);

    function MoveNext: Boolean;
    function GetEnumerator: ISPEnumerator<TResult>; override;
    property Current: TResult read GetCurrent;
    property CurrentIndex: Integer read GetCurrentIndex;
  end;

  TKeyIndex<TKey> = record
    Key: TKey;
    Index: Integer;
  end;

  TPredicateMode = (pmNone, pmTakeWile, pmSkipWhile);

  TPredicateEnumerator<T> = class(TSPEnumerable<T>, ISPEnumerator<T>)
  private
    FCurrent: T;
    FCurrentIndex: Integer;
    FPredicate: TPredicate<T>;
    FPredicateIndex: TPredicateIndex<T>;
    FEnumerator: ISPEnumerator<T>;
    FSource: ISPEnumerable<T>;
    FMode: TPredicateMode;

    function Clone: ISPEnumerator<T>;
    procedure Reset;
    function GetCurrent: T;
    function GetCurrentIndex: Integer;
  public
    constructor Create(const Source: ISPEnumerable<T>;
      const Predicate: TPredicate<T>; Mode: TPredicateMode=pmNone);
    constructor CreateWithIndexes(const Source: ISPEnumerable<T>;
      const Predicate: TPredicateIndex<T>; Mode: TPredicateMode=pmNone);

    function MoveNext: Boolean;
    function GetEnumerator: ISPEnumerator<T>; override;
    property Current: T read GetCurrent;
    property CurrentIndex: Integer read GetCurrentIndex;
  end;

  TSortType = (stOrder, stThen);

  TSortedEnumerator<TKey, T> = class(TSPEnumerable<T>, ISPEnumerator<T>)
  private
    FKeySelector: TFunc<T, TKey>;
    FSource: ISPEnumerable<T>;
    FEnumerator: ISPEnumerator<T>;
    FComparer: IComparer<TKey>;
    FArray: TArray<TKeyIndex<TKey>>;
    FIndex: Integer;
    FCurrent: T;
    FCurrentIndex: Integer;
    FDescending: boolean;
    FSortType: TSortType;

    function Clone: ISPEnumerator<T>;
    procedure Reset;
    function GetCurrent: T;
    function GetCurrentIndex: Integer;
    function ToArray: TArray<TKeyIndex<TKey>>;
    procedure QuickSort(var aArray: TArray<TKeyIndex<TKey>>; Index, Count: Integer;
      const aComparer: IComparer<TKey>);
    procedure InjectionSort(var aArray: TArray<TKeyIndex<TKey>>; Index, Count: Integer;
      const aComparer: IComparer<TKey>);
    function Seek(var aArray: TArray<TKeyIndex<TKey>>; Index, Count: Integer;
      Key: TKey; const aComparer: IComparer<TKey>): Integer;
    function GetArrayIndex(Index: Integer): Integer;
    procedure Reverse(var aArray: TArray<TKeyIndex<TKey>>);
  public
    constructor Create(const Source: ISPEnumerable<T>;
      const KeySelector: TFunc<T, TKey>; const Comparer: IComparer<TKey>;
      Descending: boolean=false; SortType: TSortType=stOrder);

    function MoveNext: Boolean;
    function GetEnumerator: ISPEnumerator<T>; override;
    property Current: T read GetCurrent;
    property CurrentIndex: Integer read GetCurrentIndex;
  end;

  TArrayEnumerator<T> = class(TSPEnumerable<T>, ISPEnumerator<T>)
  private
    FArray: TArray<T>;
    FIndex: Integer;
    FCurrent: T;
    FCurrentIndex: Integer;

    function Clone: ISPEnumerator<T>;
    procedure Reset;
    function GetCurrent: T;
    function GetCurrentIndex: Integer;
  public
    constructor Create(const Source: TArray<T>);
    constructor CreateFromArray(const Source: array of T);

    function MoveNext: Boolean;
    function GetEnumerator: ISPEnumerator<T>; override;
    property Current: T read GetCurrent;
    property CurrentIndex: Integer read GetCurrentIndex;
  end;

  TLinkEnumerator<T> = class(TSPEnumerable<T>, ISPEnumerator<T>)
  private
    FIndex: Integer;
    FCurrent: T;
    FCurrentIndex: Integer;
    FEnumeratorFirst: ISPEnumerator<T>;
    FEnumeratorSecond: ISPEnumerator<T>;
    FSourceFirst: ISPEnumerable<T>;
    FSourceSecond: ISPEnumerable<T>;
    FSecond: boolean;

    function Clone: ISPEnumerator<T>;
    procedure Reset;
    function GetCurrent: T;
    function GetCurrentIndex: Integer;
  public
    constructor Create(const SourceFirst, SourceSecond: ISPEnumerable<T>);

    function MoveNext: Boolean;
    function GetEnumerator: ISPEnumerator<T>; override;
    property Current: T read GetCurrent;
    property CurrentIndex: Integer read GetCurrentIndex;
  end;

  TEnumeratorAdapter<T> = class(TInterfacedObject, ISPEnumerator<T>)
  private
    FSource: ISPEnumerable<T>;
    FEnumerator: ISPEnumerator<T>;
    FCurrent: T;
    FCurrentIndex: Integer;

    function Clone: ISPEnumerator<T>;
    procedure Reset;
    function GetCurrent: T;
    function GetCurrentIndex: Integer;
  public
    constructor Create(const Source: ISPEnumerable<T>);

    function MoveNext: Boolean;
    property Current: T read GetCurrent;
    property CurrentIndex: Integer read GetCurrentIndex;
  end;

  TJoinEnumerator<T, TInner, TKey, TResult> = class(TSPEnumerable<TResult>, ISPEnumerator<TResult>)
  private
    FCurrent: TResult;
    FCurrentIndex: Integer;
    FOuter: ISPEnumerable<T>;
    FInner: ISPEnumerable<TInner>;
    FInnerEnumerator: ISPEnumerator<TInner>;
    FOuterEnumerator: ISPEnumerator<T>;
    FInnerKeySelector: TFunc<TInner, TKey>;
    FOuterKeySelector: TFunc<T, TKey>;
    FResultSelector: TFunc<T, TInner, TResult>;
    FGroupResultSelector: TFunc<T, ISPEnumerable<TInner>, TResult>;
    FInnerKeySelectorIndex: TFunc<TInner, Integer, TKey>;
    FOuterKeySelectorIndex: TFunc<T, Integer, TKey>;
    FResultSelectorIndex: TFunc<T, Integer, TInner, Integer, TResult>;
    FComparer: IComparer<TKey>;
    FIndex: Integer;
    FKey: TKey;
    FPredicateEnumerable: ISPEnumerable<TInner>;
    FPredicate: TPredicate<TInner>;
    FGroup: boolean;

    function Clone: ISPEnumerator<TResult>;
    procedure Reset;
    function GetCurrent: TResult;
    function GetCurrentIndex: Integer;
    function FindByKey(OuterCurrent: T; OuterIndex: Integer): boolean;
  public
    constructor Create(const Outer: ISPEnumerable<T>;
      const Inner: ISPEnumerable<TInner>;
      const OuterKeySelector: TFunc<T, TKey>;
      const InnerKeySelector: TFunc<TInner, TKey>;
      const ResultSelector: TFunc<T, TInner, TResult>;
      const aComparer: IComparer<TKey>);
    constructor CreateWithIndexes(const Outer: ISPEnumerable<T>;
      const Inner: ISPEnumerable<TInner>;
      const OuterKeySelector: TFunc<T, Integer, TKey>;
      const InnerKeySelector: TFunc<TInner, Integer, TKey>;
      const ResultSelector: TFunc<T, Integer, TInner, Integer, TResult>;
      const aComparer: IComparer<TKey>);
    constructor CreateGroupJoin(const Outer: ISPEnumerable<T>;
      const Inner: ISPEnumerable<TInner>;
      const OuterKeySelector: TFunc<T, TKey>;
      const InnerKeySelector: TFunc<TInner, TKey>;
      const ResultSelector: TFunc<T, ISPEnumerable<TInner>, TResult>;
      const aComparer: IComparer<TKey>);

    function MoveNext: Boolean;
    function GetEnumerator: ISPEnumerator<TResult>; override;
    property Current: TResult read GetCurrent;
    property CurrentIndex: Integer read GetCurrentIndex;
  end;

  TDistinctEnumerator<T> = class(TSPEnumerable<T>, ISPEnumerator<T>)
  private
    FCurrent: T;
    FCurrentIndex: Integer;
    FEnumerator: ISPEnumerator<T>;
    FSource: ISPEnumerable<T>;
    FComparer: IComparer<T>;
    FIndex: Integer;

    function Clone: ISPEnumerator<T>;
    procedure Reset;
    function GetCurrent: T;
    function GetCurrentIndex: Integer;
  public
    constructor Create(const Source: ISPEnumerable<T>;
      const aComparer: IComparer<T>);

    function MoveNext: Boolean;
    function GetEnumerator: ISPEnumerator<T>; override;
    property Current: T read GetCurrent;
    property CurrentIndex: Integer read GetCurrentIndex;
  end;

  TSetType = (stUnion, stIntersect, stExcept);

  TSetsEnumerator<T> = class(TSPEnumerable<T>, ISPEnumerator<T>)
  private
    FCurrent: T;
    FCurrentIndex: Integer;
    FSourceFirst: ISPEnumerable<T>;
    FSourceSecond: ISPEnumerable<T>;
    FComparer: IComparer<T>;
    FIndex: Integer;
    FEnumerable: ISPEnumerable<T>;
    FEnumerator: ISPEnumerator<T>;
    FType: TSetType;

    function Clone: ISPEnumerator<T>;
    procedure Reset;
    function GetCurrent: T;
    function GetCurrentIndex: Integer;
  public
    constructor Create(const SourceFirst, SourceSecond: ISPEnumerable<T>;
      const aComparer: IComparer<T>; SetType: TSetType=stUnion);

    function MoveNext: Boolean;
    function GetEnumerator: ISPEnumerator<T>; override;
    property Current: T read GetCurrent;
    property CurrentIndex: Integer read GetCurrentIndex;
  end;

  TCastEnumerator<T, TResult> = class(TSPEnumerable<TResult>, ISPEnumerator<TResult>)
  private
    FCurrent: TResult;
    FCurrentIndex: Integer;
    FSource: ISPEnumerable<T>;
    FIndex: Integer;
    FEnumerator: ISPEnumerator<T>;
    FSelector: TFunc<T, TResult>;

    function Clone: ISPEnumerator<TResult>;
    procedure Reset;
    function GetCurrent: TResult;
    function GetCurrentIndex: Integer;
  public
    constructor Create(const Source: ISPEnumerable<T>;
      const Selector: TFunc<T, TResult>);

    function MoveNext: Boolean;
    function GetEnumerator: ISPEnumerator<TResult>; override;
    property Current: TResult read GetCurrent;
    property CurrentIndex: Integer read GetCurrentIndex;
  end;

  TGrouping<TKey, T> = class(TInterfacedObject, IGrouping<TKey, T>)
  private
    FKey: TKey;
    FValues: ISPEnumerable<T>;
    function GetKey: TKey;
  public
    constructor Create(const Key: TKey; Values: ISPEnumerable<T>);
    function GetEnumerator: ISPEnumerator<T>;
  end;

  TGroupingEnumerator<TKey, T> = class(TSPEnumerable<IGrouping<TKey, T>>, ISPEnumerator<IGrouping<TKey, T>>)
  private
    FCurrent: IGrouping<TKey, T>;
    FCurrentIndex: Integer;
    FSource: ISPEnumerable<T>;
    FComparer: IComparer<TKey>;
    FIndex: Integer;
    FKeySelector: TFunc<T, TKey>;
    FSelector: ISPEnumerable<TKey>;
    FSourceEnum: ISPEnumerable<TKey>;
    FEnumerator: ISPEnumerator<TKey>;
    FDisSource: ISPEnumerable<TKey>;

    function Clone: ISPEnumerator<IGrouping<TKey, T>>;
    procedure Reset;
    function GetCurrent: IGrouping<TKey, T>;
    function GetCurrentIndex: Integer;
  public
    constructor Create(const Source: ISPEnumerable<T>;
      const KeySelector: TFunc<T, TKey>;
      const aComparer: IComparer<TKey>);

    function MoveNext: Boolean;
    function GetEnumerator: ISPEnumerator<IGrouping<TKey, T>>; override;
    property Current: IGrouping<TKey, T> read GetCurrent;
    property CurrentIndex: Integer read GetCurrentIndex;
  end;

  Enumerable<T> = record
  private
    FSource: TArray<T>;
    FSourceInt: TArray<Integer>;
  public
    class function From(const Source: array of T): ISPEnumerable<T>; overload; static;
    class function From(const Source: TArray<T>): ISPEnumerable<T>; overload; static;
    class function From(const Source: ISPEnumerable<T>): ISPEnumerable<T>; overload; static;
    class function From(const Source: ISPEnumerator<T>): ISPEnumerable<T>; overload; static;
    class function From(const List: TObject; const ItemsName: string = 'Items';
      const CountName: string = 'Count'): ISPEnumerable<T>; overload; static;

    ///  Генерирует последовательность целых чисел
    function Range(Start: Integer; Count: Integer): ISPEnumerable<Integer>;
    ///  Генерирует последовательность, повторяя указанный элемент заданное количество раз
    function Repeat_(Element: T; Count: Integer): ISPEnumerable<T>;

    class function Select<T, TResult>(const Source: ISPEnumerable<T>;
      const Selector: TFunc<T, TResult>): ISPEnumerable<TResult>; overload; static;
    class function Select<T, TResult>(const Source: ISPEnumerable<T>;
      const Selector: TFunc<T, Integer, TResult>): ISPEnumerable<TResult>; overload; static;
    class function SelectMany<T, TResult>(const Source: ISPEnumerable<T>;
      const Selector: TFunc<T, ISPEnumerable<TResult>>): TSPEnumerable<TResult>; overload; static;
    class function SelectMany<T, TResult>(const Source: ISPEnumerable<T>;
      const Selector: TFunc<T, Integer, ISPEnumerable<TResult>>): TSPEnumerable<TResult>; overload; static;
  end;

  E_SPECTRA_EnumerableException = class(Exception);

implementation

uses
  System.TypInfo, SPECTRA.Consts, System.Generics.Collections;

constructor TSPEnumerable<T>.Create(const Source: TArray<T>);
begin
  FSourceType:= stArray;
  FValues:= Source;
end;

constructor TSPEnumerable<T>.Create(const Source: array of T);
begin
  FSourceType:= stArray;
  TArray.Copy<T>(Source, FValues, Length(Source));
end;

constructor TSPEnumerable<T>.Create(const Source: ISPEnumerable<T>);
begin
  FSourceType:= stEnumerable;
  FEnumerable:= Source;
end;

constructor TSPEnumerable<T>.Create(const aList: TObject;
  const ItemsName, CountName: string);
begin
  FSourceType:= stList;
  FSL:= aList;
  FItemsName:= ItemsName;
  FCountName:= CountName;
end;

constructor TSPEnumerable<T>.Create(const Enumerator: ISPEnumerator<T>);
begin
  FSourceType:= stEnumerator;
  FEnumerator:= Enumerator;
end;

destructor TSPEnumerable<T>.Destroy;
begin
  case FSourceType of
    stArray: FValues:= nil;
    stEnumerable: FEnumerable:= nil;
    stEnumerator: FEnumerator:= nil;
    stList: FSL:= nil;
  end;
  inherited;
end;

function TSPEnumerable<T>.Distinct: ISPEnumerable<T>;
begin
  Result:= TDistinctEnumerator<T>.Create(Self, TComparer<T>.Default);
end;

function TSPEnumerable<T>.ElementAt(Index: Integer): T;
var
  Item: T;
  aIndex: Integer;
begin
  if (Index < 0) or (Index >= Count) then raise EArgumentOutOfRangeException.Create(SArgumentOutOfRange);
  aIndex:= -1;

  for Item in Self do
  begin
    Inc(aIndex);
    if aIndex = Index then
    begin
      Result:= Item;
      Break;
    end;
  end;
end;

function TSPEnumerable<T>.ElementAtOrDefault(Index: Integer): T;
var
  Item: T;
  aIndex: Integer;
begin
  Result:= Default(T);
  aIndex:= -1;

  for Item in Self do
  begin
    Inc(aIndex);
    if aIndex = Index then
    begin
      Result:= Item;
      Break;
    end;
  end;
end;

function TSPEnumerable<T>.ExceptFor(
  const Inner: ISPEnumerable<T>): ISPEnumerable<T>;
begin
  Result:= TSetsEnumerator<T>.Create(Self, Inner, TComparer<T>.Default, stExcept);
end;

function TSPEnumerable<T>.InvokeListMethod(List: TObject; MethodName: string;
  const Parameters: array of TValue): boolean;
var
  AContext: TRttiContext;
  AMethod: TRttiMethod;
  AType: TRttiType;
begin
  Result:= false;
  if not Assigned(List) then Exit;

  AContext:= TRttiContext.Create;
  try
    AType:= AContext.GetType(List.ClassInfo);

    while (AType <> nil) do
    begin
      for AMethod in AType.GetMethods do
        if AnsiSameText(AMethod.Name, MethodName) then
        begin
          if Length(AMethod.GetParameters) = Length(Parameters) then
            AMethod.Invoke(List, Parameters)
          else
            raise E_SPECTRA_EnumerableException.CreateRes(@sParamsMismatch);

          Exit(true);
        end;

      AType:= AType.BaseType;
    end;
  finally
    AContext.Free;
  end;
end;

function TSPEnumerable<T>.First(const Predicate: TPredicate<T>): T;
var
  Enumerator: ISPEnumerator<T>;
  IsEmpty: boolean;
begin
  IsEmpty:= true;
  if not Assigned(Predicate) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sConditionIsNotSpecifed);

  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
  begin
    IsEmpty:= false;
    if Predicate(Enumerator.Current) then
    begin
      Result:= Enumerator.Current;
      Exit;
    end;
  end;

  if IsEmpty then
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty)
  else
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionNotContainElement);
end;

function TSPEnumerable<T>.FirstOrDefault(const Predicate: TPredicate<T>): T;
var
  Enumerator: ISPEnumerator<T>;
begin
  Result:= Default(T);

  if not Assigned(Predicate) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sConditionIsNotSpecifed);

  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
  begin
    if Predicate(Enumerator.Current) then
    begin
      Result:= Enumerator.Current;
      Break;
    end;
  end;
end;

function TSPEnumerable<T>.FirstOrDefault: T;
var
  Enumerator: ISPEnumerator<T>;
begin
  Result:= Default(T);

  Enumerator:= Self.GetEnumerator;
  if Enumerator.MoveNext then
    Result:= Enumerator.Current;
end;

function TSPEnumerable<T>.First: T;
var
  Enumerator: ISPEnumerator<T>;
begin
  Enumerator:= Self.GetEnumerator;
  if Enumerator.MoveNext then
    Result:= Enumerator.Current
  else
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);
end;

function TSPEnumerable<T>.ExceptFor(const Inner: ISPEnumerable<T>;
  const Comparer: IComparer<T>): ISPEnumerable<T>;
begin
  Result:= TSetsEnumerator<T>.Create(Self, Inner, Comparer, stExcept);
end;

function TSPEnumerable<T>.Distinct(
  const Comparer: IComparer<T>): ISPEnumerable<T>;
begin
  Result:= TDistinctEnumerator<T>.Create(Self, Comparer);
end;

function TSPEnumerable<T>.GetEnumerator: ISPEnumerator<T>;
var
  AContext: TRttiContext;
begin
  AContext:= TRttiContext.Create;
  try
    case FSourceType of
      stArray:
          begin
            if AContext.GetType(TypeInfo(T)).TypeKind = tkClass then
              ISPEnumerator<TObject>(Result):= TArrayEnumerator<TObject>.Create(TArray<TObject>(FValues))
            else
              Result:= TArrayEnumerator<T>.Create(FValues);
          end;
      stEnumerable:
          begin
            if AContext.GetType(TypeInfo(T)).TypeKind = tkClass then
              ISPEnumerator<TObject>(Result):= TEnumeratorAdapter<TObject>.Create(TSPEnumerable<TObject>(FEnumerable))
            else
              Result:= TEnumeratorAdapter<T>.Create(FEnumerable);
          end;
      stList:
          begin
            ISPEnumerator<T>(Result):= TListEnumerator<T>.Create(FSL, FItemsName, FCountName);
          end;
      stEnumerator:
          begin
            Result:= FEnumerator;
          end;
    end;
  finally
    AContext.Free;
  end;
end;

function TSPEnumerable<T>.GroupBy<TKey>(const KeySelector: TFunc<T, TKey>;
  const Comparer: IComparer<TKey>): ISPEnumerable<IGrouping<TKey, T>>;
begin
  Result:= TGroupingEnumerator<TKey, T>.Create(Self, KeySelector, Comparer) as ISPEnumerable<IGrouping<TKey, T>>;
end;

function TSPEnumerable<T>.GroupBy<TKey>(
  const KeySelector: TFunc<T, TKey>): ISPEnumerable<IGrouping<TKey, T>>;
begin
  Result:= TGroupingEnumerator<TKey, T>.Create(Self, KeySelector, TComparer<TKey>.Default) as ISPEnumerable<IGrouping<TKey, T>>;
end;

function TSPEnumerable<T>.GroupJoin<TInner, TKey, TResult>(
  const Inner: ISPEnumerable<TInner>; const OuterKeySelector: TFunc<T, TKey>;
  const InnerKeySelector: TFunc<TInner, TKey>;
  const ResultSelector: TFunc<T, ISPEnumerable<TInner>, TResult>;
  const Comparer: IComparer<TKey>): TSPEnumerable<TResult>;
begin
  Result:= TJoinEnumerator<T, TInner, TKey, TResult>.CreateGroupJoin(Self,
                                                                     Inner,
                                                                     OuterKeySelector,
                                                                     InnerKeySelector,
                                                                     ResultSelector,
                                                                     Comparer);
end;

function TSPEnumerable<T>.GroupJoin<TInner, TKey, TResult>(
  const Inner: ISPEnumerable<TInner>; const OuterKeySelector: TFunc<T, TKey>;
  const InnerKeySelector: TFunc<TInner, TKey>;
  const ResultSelector: TFunc<T, ISPEnumerable<TInner>, TResult>): TSPEnumerable<TResult>;
begin
  Result:= TJoinEnumerator<T, TInner, TKey, TResult>.CreateGroupJoin(Self,
                                                                     Inner,
                                                                     OuterKeySelector,
                                                                     InnerKeySelector,
                                                                     ResultSelector,
                                                                     TComparer<TKey>.Default);
end;

function TSPEnumerable<T>.Insert(Index: Integer; Element: T): ISPEnumerable<T>;
var
  I: Integer;
begin
  case FSourceType of
    stArray:
        begin
          if Length(FValues) = 0 then
          begin
            SetLength(FValues, High(FValues)+2);
            FValues[High(FValues)]:= Element;
          end else
          begin
            SetLength(FValues, High(FValues)+2);

            for I := Length(FValues)-1 downto Index do
            begin
              FValues[I]:= FValues[I-1];
              if I-2 < Index then Break;
            end;
            FValues[Index]:= Element;
          end;

          Result:= TSPEnumerable<T>.Create(FValues);
        end;
    stEnumerable:
        begin
          Result:= FEnumerable.Insert(Index, Element);
        end;
    stList:
        begin
          InvokeListMethod(FSL, 'Insert', [TValue.From<Integer>(Index), TValue.From<T>(Element)]);
          Result:= TSPEnumerable<T>.Create(FSL, FItemsName, FCountName);
        end;
    stEnumerator:
        begin
          Result:= Self;
          raise E_SPECTRA_EnumerableException.CreateResFmt(@sMethodNotSupport,['Insert']);
        end;
  end;
end;

function TSPEnumerable<T>.Insert(Proc: TProc;
  Enumerator: ISPEnumerator<T>): ISPEnumerable<T>;
begin
  Result:= Append(Proc, Enumerator);
end;

function TSPEnumerable<T>.Intersect(
  const Inner: ISPEnumerable<T>): ISPEnumerable<T>;
begin
  Result:= TSetsEnumerator<T>.Create(Self, Inner, TComparer<T>.Default, stIntersect);
end;

function TSPEnumerable<T>.Intersect(const Inner: ISPEnumerable<T>;
  const Comparer: IComparer<T>): ISPEnumerable<T>;
begin
  Result:= TSetsEnumerator<T>.Create(Self, Inner, Comparer, stIntersect);
end;

function TSPEnumerable<T>.Aggregate(const Func: TFunc<T, T, T>): T;
var
  Enumerator: ISPEnumerator<T>;
begin
  Result:= Default(T);

  if not Assigned(Func) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sFunctionNotAssigned);

  Enumerator:= Self.GetEnumerator;

  if not Enumerator.MoveNext then
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);

  Result:= Enumerator.Current;
  while Enumerator.MoveNext do
    Result:= Func(Result, Enumerator.Current);
end;

function TSPEnumerable<T>.Aggregate<TAccumulate, TResult>(
  const Seed: TAccumulate; const Func: TFunc<TAccumulate, T, TAccumulate>;
  const Selector: TFunc<TAccumulate, TResult>): TResult;
var
  Enumerator: ISPEnumerator<T>;
  Accumulate: TAccumulate;
begin
  Result:= Default(TResult);

  if not Assigned(Func) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sFunctionNotAssigned);
  if not Assigned(Selector) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sSelectorNotAssigned);

  Enumerator:= Self.GetEnumerator;

  if not Enumerator.MoveNext then
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);

  Enumerator.Reset;
  Accumulate:= Seed;
  while Enumerator.MoveNext do
    Accumulate:= Func(Accumulate, Enumerator.Current);

  Result:= Selector(Accumulate);
end;

function TSPEnumerable<T>.Aggregate<TAccumulate>(const Seed: TAccumulate;
  const Func: TFunc<TAccumulate, T, TAccumulate>): TAccumulate;
var
  Enumerator: ISPEnumerator<T>;
begin
  Result:= Default(TAccumulate);

  if not Assigned(Func) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sFunctionNotAssigned);

  Enumerator:= Self.GetEnumerator;

  if not Enumerator.MoveNext then
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);

  Enumerator.Reset;
  Result:= Seed;
  while Enumerator.MoveNext do
    Result:= Func(Result, Enumerator.Current);
end;

function TSPEnumerable<T>.All(const Predicate: TPredicate<T>): boolean;
var
  Item: T;
begin
  Result:= false;

  if not Assigned(Predicate) then Exit;

  for Item in Self do
    if not Predicate(Item) then
      Exit;

  Result:= true;
end;

function TSPEnumerable<T>.Any(const Predicate: TPredicate<T>): boolean;
var
  Item: T;
begin
  Result:= false;

  if not Assigned(Predicate) then Exit;

  for Item in Self do
    if Predicate(Item) then
      Exit(true);
end;

function TSPEnumerable<T>.Append(Proc: TProc; Enumerator: ISPEnumerator<T>): ISPEnumerable<T>;
begin
  if not Assigned(Proc) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sProcNotAssigned);

  Proc;
  Result:= TSPEnumerable<T>.Create(Enumerator);
end;

function TSPEnumerable<T>.Append(Element: T): ISPEnumerable<T>;
var
  I: Integer;
begin
  case FSourceType of
    stArray:
        begin
          SetLength(FValues, High(FValues)+2);
          FValues[High(FValues)]:= Element;

          Result:= TSPEnumerable<T>.Create(FValues);
        end;
    stEnumerable:
        begin
          Result:= FEnumerable.Append(Element);
        end;
    stList:
        begin
          InvokeListMethod(FSL, 'Add', [TValue.From<T>(Element)]);

          Result:= TSPEnumerable<T>.Create(FSL);
        end;
    stEnumerator:
        begin
          Result:= Self;
          raise E_SPECTRA_EnumerableException.CreateResFmt(@sMethodNotSupport,['Append']);
        end;
  end;
end;

function TSPEnumerable<T>.Average: Double;
var
  Enumerator: ISPEnumerator<T>;
  SumInt: Int64;
  SumDouble: Double;
  Count: Integer;
begin
  Result:= 0;
  SumInt:= 0;
  SumDouble:= 0;
  Count:= 0;

  case PTypeInfo(TypeInfo(T)).Kind of
    tkInteger,
    tkInt64: begin

             end;
    tkFloat: begin
               case GetTypeData(TypeInfo(T)).FloatType of
                 ftSingle,
                 ftDouble: begin

                           end;
               else
                 raise E_SPECTRA_EnumerableException.CreateRes(@sEnumerableTypeMismatch);
               end;
             end;
    else
      raise E_SPECTRA_EnumerableException.CreateRes(@sEnumerableTypeMismatch);
  end;

  Enumerator:= Self.GetEnumerator;
  while Enumerator.MoveNext do
  begin
    case PTypeInfo(TypeInfo(T)).Kind of
      tkInteger,
      tkInt64: begin
                 SumInt:= SumInt + ToInteger(Enumerator.Current);
                 Inc(Count);
               end;
      tkFloat: begin
                 case GetTypeData(TypeInfo(T)).FloatType of
                   ftSingle,
                   ftDouble: begin
                               SumDouble:= SumDouble + ToDouble(Enumerator.Current);
                               Inc(Count);
                             end;
                 end;
               end;
    end;
  end;

  if Count > 0 then
    case PTypeInfo(TypeInfo(T)).Kind of
      tkInteger,
      tkInt64: Result:= SumInt / Count;
      tkFloat: begin
                 case GetTypeData(TypeInfo(T)).FloatType of
                   ftSingle,
                   ftDouble: Result:= SumDouble / Count;
                 end;
               end;
    end
  else
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);
end;

function TSPEnumerable<T>.Average(const Selector: TFunc<T, Int64>): Double;
var
  Enumerator: ISPEnumerator<T>;
  Sum: Int64;
  Count: Integer;
begin
  Result:= 0;
  Sum:= 0;
  Count:= 0;

  if not Assigned(Selector) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sSelectorNotAssigned);

  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
  begin
    Sum:= Sum + Selector(Enumerator.Current);
    Inc(Count);
  end;

  if Count > 0 then
    Result:= Sum / Count
  else
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);
end;

function TSPEnumerable<T>.Average(const Selector: TFunc<T, Double>): Double;
var
  Enumerator: ISPEnumerator<T>;
  Sum: Double;
  Count: Integer;
begin
  Result:= 0;
  Sum:= 0;
  Count:= 0;

  if not Assigned(Selector) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sSelectorNotAssigned);

  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
  begin
    Sum:= Sum + Selector(Enumerator.Current);
    Inc(Count);
  end;

  if Count > 0 then
    Result:= Sum / Count
  else
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);
end;

function TSPEnumerable<T>.Any: boolean;
var
  Enumerator: ISPEnumerator<T>;
begin
  Enumerator:= Self.GetEnumerator;
  Result:= Enumerator.MoveNext;
end;

function TSPEnumerable<T>.Cast: TSPEnumerable<T>;
begin
  Result:= Self;
end;

function TSPEnumerable<T>.Cast<TResult>: TSPEnumerable<TResult>;
begin
  Result:= TCastEnumerator<T, TResult>.Create(Self, nil);
end;

function TSPEnumerable<T>.Cast<TResult>(
  const Selector: TFunc<T, TResult>): TSPEnumerable<TResult>;
begin
  Result:= TCastEnumerator<T, TResult>.Create(Self, Selector);
end;

function TSPEnumerable<T>.Concat(
  const Second: ISPEnumerable<T>): ISPEnumerable<T>;
begin
  Result:= TLinkEnumerator<T>.Create(Self, Second);
end;

function TSPEnumerable<T>.Contains(Element: T): boolean;
begin
  Result:= Self.Contains(Element, TComparer<T>.Default);
end;

function TSPEnumerable<T>.Contains(Element: T;
  const Comparer: IComparer<T>): boolean;
var
  Enumerator: ISPEnumerator<T>;
begin
  Result:= false;
  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
    if Comparer.Compare(Element, Enumerator.Current) = 0 then
      Exit(true);
end;

function TSPEnumerable<T>.Count(const Predicate: TPredicate<T>): Integer;
var
  Item: T;
begin
  Result:= 0;

  if not Assigned(Predicate) then Exit;

  for Item in Self do
    if Predicate(Item) then
      Inc(Result);
end;

function TSPEnumerable<T>.Count: Integer;
var
  Item: T;
begin
  Result:= 0;

  for Item in Self do
    Inc(Result);
end;

function TSPEnumerable<T>.Concat(
  const Second: array of T): ISPEnumerable<T>;
begin
  Result:= TLinkEnumerator<T>.Create(Self, TArrayEnumerator<T>.CreateFromArray(Second));
end;

function TSPEnumerable<T>.Last(const Predicate: TPredicate<T>): T;
var
  Enumerator: ISPEnumerator<T>;
  IsEmpty: boolean;
begin
  IsEmpty:= true;
  if not Assigned(Predicate) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sConditionIsNotSpecifed);

  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
  begin
    IsEmpty:= false;
    if Predicate(Enumerator.Current) then
      Result:= Enumerator.Current;
  end;

  if IsEmpty then
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty)
  else
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionNotContainElement);
end;

function TSPEnumerable<T>.LastOrDefault(const Predicate: TPredicate<T>): T;
var
  Enumerator: ISPEnumerator<T>;
begin
  Result:= Default(T);

  if not Assigned(Predicate) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sConditionIsNotSpecifed);

  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
  begin
    if Predicate(Enumerator.Current) then
      Result:= Enumerator.Current;
  end;
end;

function TSPEnumerable<T>.Max: T;
begin
  Result:= Max(TComparer<T>.Default);
end;

function TSPEnumerable<T>.Max(const Comparer: IComparer<T>): T;
var
  Enumerator: ISPEnumerator<T>;
  IsEmpty: boolean;
begin
  Result:= Default(T);
  IsEmpty:= true;
  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
  begin
    if IsEmpty then
      Result:= Enumerator.Current;

    IsEmpty:= false;
    if Comparer.Compare(Enumerator.Current, Result) = 1 then
      Result:= Enumerator.Current;
  end;

  if IsEmpty then
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);
end;

function TSPEnumerable<T>.Max<TResult>(
  const Selector: TFunc<T, TResult>): TResult;
begin
  Result:= Self.Max<TResult>(Selector, TComparer<TResult>.Default);
end;

function TSPEnumerable<T>.Min(const Comparer: IComparer<T>): T;
var
  Enumerator: ISPEnumerator<T>;
  IsEmpty: boolean;
begin
  Result:= Default(T);
  IsEmpty:= true;
  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
  begin
    if IsEmpty then
      Result:= Enumerator.Current;

    IsEmpty:= false;
    if Comparer.Compare(Enumerator.Current, Result) = -1 then
      Result:= Enumerator.Current;
  end;

  if IsEmpty then
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);
end;

function TSPEnumerable<T>.Min: T;
begin
  Result:= Min(TComparer<T>.Default);
end;

function TSPEnumerable<T>.Min<TResult>(const Selector: TFunc<T, TResult>;
  const Comparer: IComparer<TResult>): TResult;
var
  Enumerator: ISPEnumerator<T>;
  IsEmpty: boolean;
begin
  Result:= Default(TResult);
  if not Assigned(Selector) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sFunctionNotAssigned);

  IsEmpty:= true;
  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
  begin
    if IsEmpty then
      Result:= Selector(Enumerator.Current);

    IsEmpty:= false;
    if Comparer.Compare(Selector(Enumerator.Current), Result) = -1 then
      Result:= Selector(Enumerator.Current);
  end;

  if IsEmpty then
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);
end;

function TSPEnumerable<T>.Min<TResult>(
  const Selector: TFunc<T, TResult>): TResult;
begin
  Result:= Self.Min<TResult>(Selector, TComparer<TResult>.Default);
end;

function TSPEnumerable<T>.Max<TResult>(const Selector: TFunc<T, TResult>;
  const Comparer: IComparer<TResult>): TResult;
var
  Enumerator: ISPEnumerator<T>;
  IsEmpty: boolean;
begin
  Result:= Default(TResult);
  if not Assigned(Selector) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sFunctionNotAssigned);

  IsEmpty:= true;
  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
  begin
    if IsEmpty then
      Result:= Selector(Enumerator.Current);

    IsEmpty:= false;
    if Comparer.Compare(Selector(Enumerator.Current), Result) = 1 then
      Result:= Selector(Enumerator.Current);
  end;

  if IsEmpty then
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);
end;

function TSPEnumerable<T>.LastOrDefault: T;
var
  Enumerator: ISPEnumerator<T>;
begin
  Result:= Default(T);

  Enumerator:= Self.GetEnumerator;
  while Enumerator.MoveNext do
    Result:= Enumerator.Current;
end;

function TSPEnumerable<T>.Last: T;
var
  Enumerator: ISPEnumerator<T>;
  IsEmpty: boolean;
begin
  IsEmpty:= true;
  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
  begin
    IsEmpty:= false;
    Result:= Enumerator.Current;
  end;

  if IsEmpty then
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);
end;

function TSPEnumerable<T>.Join<TInner, TKey, TResult>(
  const Inner: ISPEnumerable<TInner>; const OuterKeySelector: TFunc<T, TKey>;
  const InnerKeySelector: TFunc<TInner, TKey>;
  const ResultSelector: TFunc<T, TInner, TResult>;
  const Comparer: IComparer<TKey>): TSPEnumerable<TResult>;
begin
  Result:= TJoinEnumerator<T,TInner,TKey,TResult>.Create(Self,
                                                         Inner,
                                                         OuterKeySelector,
                                                         InnerKeySelector,
                                                         ResultSelector,
                                                         Comparer)
end;

function TSPEnumerable<T>.Join<TInner, TKey, TResult>(
  const Inner: ISPEnumerable<TInner>;
  const OuterKeySelector: TFunc<T, Integer, TKey>;
  const InnerKeySelector: TFunc<TInner, Integer, TKey>;
  const ResultSelector: TFunc<T, Integer, TInner, Integer, TResult>): TSPEnumerable<TResult>;
begin
  Result:= TJoinEnumerator<T,TInner,TKey,TResult>.CreateWithIndexes(Self,
                                                                    Inner,
                                                                    OuterKeySelector,
                                                                    InnerKeySelector,
                                                                    ResultSelector,
                                                                    TComparer<TKey>.Default)
end;

function TSPEnumerable<T>.Join<TInner, TKey, TResult>(
  const Inner: ISPEnumerable<TInner>; const OuterKeySelector: TFunc<T, TKey>;
  const InnerKeySelector: TFunc<TInner, TKey>;
  const ResultSelector: TFunc<T, TInner, TResult>): TSPEnumerable<TResult>;
begin
  Result:= TJoinEnumerator<T,TInner,TKey,TResult>.Create(Self,
                                                         Inner,
                                                         OuterKeySelector,
                                                         InnerKeySelector,
                                                         ResultSelector,
                                                         TComparer<TKey>.Default)
end;

function TSPEnumerable<T>.Join<TInner, TKey, TResult>(
  const Inner: ISPEnumerable<TInner>;
  const OuterKeySelector: TFunc<T, Integer, TKey>;
  const InnerKeySelector: TFunc<TInner, Integer, TKey>;
  const ResultSelector: TFunc<T, Integer, TInner, Integer, TResult>;
  const Comparer: IComparer<TKey>): TSPEnumerable<TResult>;
begin
  Result:= TJoinEnumerator<T,TInner,TKey,TResult>.CreateWithIndexes(Self,
                                                                    Inner,
                                                                    OuterKeySelector,
                                                                    InnerKeySelector,
                                                                    ResultSelector,
                                                                    Comparer)
end;

function TSPEnumerable<T>.OrderBy<TKey>(const KeySelector: TFunc<T, TKey>;
  const Comparer: IComparer<TKey>): ISPEnumerable<T>;
begin
  Result:= TSortedEnumerator<TKey, T>.Create(Self, KeySelector, Comparer);
end;

function TSPEnumerable<T>.OrderBy<TKey>(
  const KeySelector: TFunc<T, TKey>): ISPEnumerable<T>;
begin
  Result:= OrderBy<TKey>(KeySelector, TComparer<TKey>.Default);
end;

function TSPEnumerable<T>.OrderByDesc<TKey>(
  const KeySelector: TFunc<T, TKey>): ISPEnumerable<T>;
begin
  Result:= OrderByDesc<TKey>(KeySelector, TComparer<TKey>.Default);
end;

function TSPEnumerable<T>.Prepend(Proc: TProc;
  Enumerator: ISPEnumerator<T>): ISPEnumerable<T>;
begin
  Result:= Append(Proc, Enumerator);
end;

function TSPEnumerable<T>.Prepend(Element: T): ISPEnumerable<T>;
var
  I: Integer;
begin
  case FSourceType of
    stArray:
        begin
          if Length(FValues) = 0 then
          begin
            SetLength(FValues, High(FValues)+2);
            FValues[High(FValues)]:= Element;
          end else
          begin
            SetLength(FValues, High(FValues)+2);

            for I := Length(FValues)-1 downto 0 do
            begin
              FValues[I]:= FValues[I-1];
              if I-2 < 0 then Break;
            end;
            FValues[0]:= Element;
          end;

          Result:= TSPEnumerable<T>.Create(FValues);
        end;
    stEnumerable:
        begin
          Result:= FEnumerable.Prepend(Element);
        end;
    stList:
        begin
          InvokeListMethod(FSL, 'Insert', [TValue.From<Integer>(0), TValue.From<T>(Element)]);
          Result:= TSPEnumerable<T>.Create(FSL, FItemsName, FCountName);
        end;
    stEnumerator:
        begin
          Result:= self;
          raise E_SPECTRA_EnumerableException.CreateResFmt(@sMethodNotSupport,['Prepend']);
        end;
  end;
end;

function TSPEnumerable<T>.OrderByDesc<TKey>(const KeySelector: TFunc<T, TKey>;
  const Comparer: IComparer<TKey>): ISPEnumerable<T>;
begin
  Result:= TSortedEnumerator<TKey, T>.Create(Self, KeySelector, Comparer, true);
end;

function TSPEnumerable<T>.Skip(const Count: Integer): ISPEnumerable<T>;
begin
  Result:= TPredicateEnumerator<T>.CreateWithIndexes(Self,
     function(Itm: T; Index: Integer): boolean
     begin
       Result:= Index >= Count;
     end);
end;

function TSPEnumerable<T>.SkipLast(const Count: Integer): ISPEnumerable<T>;
begin
  Result:= TPredicateEnumerator<T>.CreateWithIndexes(Self,
     function(Itm: T; Index: Integer): boolean
     begin
       Result:= (Self.Count - Index) > Count;
     end);
end;

function TSPEnumerable<T>.SkipWhile(
  const Predicate: TPredicateIndex<T>): ISPEnumerable<T>;
begin
  Result:= TPredicateEnumerator<T>.CreateWithIndexes(Self, Predicate, pmSkipWhile);
end;

function TSPEnumerable<T>.Sum(const SumFunc: TFunc<T, T, T>): T;
var
  Enumerator: ISPEnumerator<T>;
begin
  Result:= Default(T);

  if not Assigned(SumFunc) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sFunctionNotAssigned);

  Enumerator:= Self.GetEnumerator;

  if not Enumerator.MoveNext then
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);

  Result:= Enumerator.Current;
  while Enumerator.MoveNext do
    Result:= SumFunc(Result, Enumerator.Current);
end;

function TSPEnumerable<T>.Sum(const Selector: TFunc<T, Int64>): Int64;
var
  Enumerator: ISPEnumerator<T>;
begin
  Result:= 0;

  Enumerator:= Self.GetEnumerator;

  if not Enumerator.MoveNext then
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);

  if Assigned(Selector) then
    Result:= Selector(Enumerator.Current)
  else
    Result:= ToInteger(Enumerator.Current);

  while Enumerator.MoveNext do
    if Assigned(Selector) then
      Result:= Result + Selector(Enumerator.Current)
    else
      Result:= Result + ToInteger(Enumerator.Current);
end;

function TSPEnumerable<T>.Sum(const Selector: TFunc<T, Double>): Double;
var
  Enumerator: ISPEnumerator<T>;
begin
  Result:= 0;

  Enumerator:= Self.GetEnumerator;

  if not Enumerator.MoveNext then
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);

  if Assigned(Selector) then
    Result:= Selector(Enumerator.Current)
  else
    Result:= ToDouble(Enumerator.Current);

  while Enumerator.MoveNext do
    if Assigned(Selector) then
      Result:= Result + Selector(Enumerator.Current)
    else
      Result:= Result + ToDouble(Enumerator.Current);
end;

function TSPEnumerable<T>.Sum<TResult>(const Selector: TFunc<T, TResult>;
  const SumFunc: TFunc<TResult, TResult, TResult>): TResult;
var
  Enumerator: ISPEnumerator<T>;
begin
  Result:= Default(TResult);

  if not Assigned(SumFunc) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sFunctionNotAssigned);
  if not Assigned(Selector) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sSelectorNotAssigned);

  Enumerator:= Self.GetEnumerator;

  if not Enumerator.MoveNext then
    raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionIsEmpty);

  Result:= Selector(Enumerator.Current);
  while Enumerator.MoveNext do
    Result:= SumFunc(Result, Selector(Enumerator.Current));
end;

function TSPEnumerable<T>.SkipWhile(
  const Predicate: TPredicate<T>): ISPEnumerable<T>;
begin
  Result:= TPredicateEnumerator<T>.Create(Self, Predicate, pmSkipWhile);
end;

function TSPEnumerable<T>.Take(const Count: Integer): ISPEnumerable<T>;
begin
  Result:= TPredicateEnumerator<T>.CreateWithIndexes(Self,
     function(Itm: T; Index: Integer): boolean
     begin
       Result:= Index < Count;
     end);
end;

function TSPEnumerable<T>.TakeLast(const Count: Integer): ISPEnumerable<T>;
begin
  Result:= TPredicateEnumerator<T>.CreateWithIndexes(Self,
     function(Itm: T; Index: Integer): boolean
     begin
       Result:= (Self.Count - Index) <= Count;
     end);
end;

function TSPEnumerable<T>.TakeWhile(
  const Predicate: TPredicateIndex<T>): ISPEnumerable<T>;
begin
  Result:= TPredicateEnumerator<T>.CreateWithIndexes(Self, Predicate, pmTakeWile);
end;

function TSPEnumerable<T>.ThenBy<TKey>(const KeySelector: TFunc<T, TKey>;
  const Comparer: IComparer<TKey>): TSPEnumerable<T>;
begin
  Result:= TSortedEnumerator<TKey, T>.Create(Self, KeySelector, Comparer, false, stThen);
end;

function TSPEnumerable<T>.ThenByDesc<TKey>(const KeySelector: TFunc<T, TKey>;
  const Comparer: IComparer<TKey>): TSPEnumerable<T>;
begin
  Result:= TSortedEnumerator<TKey, T>.Create(Self, KeySelector, Comparer, true, stThen);
end;

procedure TSPEnumerable<T>.ToAnyCollection(Proc: TProcIndex<T>);
var
  Enumerator: ISPEnumerator<T>;
begin
  if not Assigned(Proc) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sProcNotAssigned);

  Enumerator:= Self.GetEnumerator;
  while Enumerator.MoveNext do
     Proc(Enumerator.Current, Enumerator.CurrentIndex);
end;

function TSPEnumerable<T>.ToArray: TArray<T>;
var
  Enumerator: ISPEnumerator<T>;
begin
  Enumerator:= Self.GetEnumerator;

  SetLength(Result, Self.Count);
  while Enumerator.MoveNext do
    Result[Enumerator.CurrentIndex]:= Enumerator.Current;
end;

function TSPEnumerable<T>.ToDouble(const Item: T): Double;
var
  Value: TValue;
begin
  Result:= Default(Double);
  Value:= TValue.From<T>(Item);
  Result:= Value.AsType<Double>;
end;

function TSPEnumerable<T>.ToInteger(const Item: T): Int64;
var
  Value: TValue;
begin
  Result:= Default(Int64);
  Value:= TValue.From<T>(Item);
  Result:= Value.AsType<Int64>;
end;

function TSPEnumerable<T>.ToList(List: TObject;
  const AddName: string): TObject;
var
  Enumerator: ISPEnumerator<T>;
begin
  Result:= List;

  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
    InvokeListMethod(List, AddName, [TValue.From<T>(Enumerator.Current)]);
end;

function TSPEnumerable<T>.Union(
  const Inner: ISPEnumerable<T>): ISPEnumerable<T>;
begin
  Result:= TSetsEnumerator<T>.Create(Self, Inner, TComparer<T>.Default);
end;

function TSPEnumerable<T>.Union(const Inner: ISPEnumerable<T>;
  const Comparer: IComparer<T>): ISPEnumerable<T>;
begin
  Result:= TSetsEnumerator<T>.Create(TSPEnumerable<T>(Self), Inner, Comparer);
end;

function TSPEnumerable<T>.TakeWhile(
  const Predicate: TPredicate<T>): ISPEnumerable<T>;
begin
  Result:= TPredicateEnumerator<T>.Create(Self, Predicate, pmTakeWile);
end;

function TSPEnumerable<T>.Select<T, TResult>(
  const Selector: TFunc<T, TResult>): TSPEnumerable<TResult>;
begin
  Result:= TSelectorEnumerator<T, TResult>.Create(Self as ISPEnumerable<T>, Selector);
end;

function TSPEnumerable<T>.SelectMany<T, TResult>(
  const Selector: TFunc<T, Integer, ISPEnumerable<TResult>>): TSPEnumerable<TResult>;
begin
  Result:= TSelectorManyEnumerator<T, TResult>.CreateWithIndexes(Self as ISPEnumerable<T>, Selector);
end;

function TSPEnumerable<T>.SelectMany<T, TResult>(
  const Selector: TFunc<T, ISPEnumerable<TResult>>): TSPEnumerable<TResult>;
begin
  Result:= TSelectorManyEnumerator<T, TResult>.Create(Self as ISPEnumerable<T>, Selector);
end;

function TSPEnumerable<T>.SequenceEqual(const Second: ISPEnumerable<T>;
  const Comparer: IComparer<T>): boolean;
var
  EnumeratorFirst: ISPEnumerator<T>;
  EnumeratorSecond: ISPEnumerator<T>;
begin
  Result:= true;

  if Self.Count <> Second.Count then
    Exit(false);

  EnumeratorFirst:= Self.GetEnumerator;
  EnumeratorSecond:= Second.GetEnumerator;

  while EnumeratorFirst.MoveNext do
    if EnumeratorSecond.MoveNext then
    begin
      if Comparer.Compare(EnumeratorFirst.Current, EnumeratorSecond.Current) <> 0 then
        Exit(false);
    end else
      Exit(false);
end;

function TSPEnumerable<T>.Single(const Predicate: TPredicateIndex<T>): T;
var
  Enumerator: ISPEnumerator<T>;
begin
  if not Assigned(Predicate) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sConditionIsNotSpecifed);

  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
    if Predicate(Enumerator.Current, Enumerator.CurrentIndex) then
    begin
      Result:= Enumerator.Current;
      Exit;
    end;

  raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionNotContainElement);
end;

function TSPEnumerable<T>.SingleOrDefault(
  const Predicate: TPredicateIndex<T>): T;
var
  Enumerator: ISPEnumerator<T>;
begin
  if not Assigned(Predicate) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sConditionIsNotSpecifed);

  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
    if Predicate(Enumerator.Current, Enumerator.CurrentIndex) then
    begin
      Result:= Enumerator.Current;
      Exit;
    end;

  Result:= Default(T);
end;

function TSPEnumerable<T>.SingleOrDefault(const Predicate: TPredicate<T>): T;
var
  Enumerator: ISPEnumerator<T>;
begin
  if not Assigned(Predicate) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sConditionIsNotSpecifed);

  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
    if Predicate(Enumerator.Current) then
    begin
      Result:= Enumerator.Current;
      Exit;
    end;

  Result:= Default(T);
end;

function TSPEnumerable<T>.Single(const Predicate: TPredicate<T>): T;
var
  Enumerator: ISPEnumerator<T>;
begin
  if not Assigned(Predicate) then
    raise E_SPECTRA_EnumerableException.CreateRes(@sConditionIsNotSpecifed);

  Enumerator:= Self.GetEnumerator;

  while Enumerator.MoveNext do
    if Predicate(Enumerator.Current) then
    begin
      Result:= Enumerator.Current;
      Exit;
    end;

  raise E_SPECTRA_EnumerableException.CreateRes(@sCollectionNotContainElement);
end;

function TSPEnumerable<T>.SequenceEqual(
  const Second: ISPEnumerable<T>): boolean;
begin
  Result:= Self.SequenceEqual(Second, TComparer<T>.Default);
end;

function TSPEnumerable<T>.Select<T, TResult>(
  const Selector: TFunc<T, Integer, TResult>): TSPEnumerable<TResult>;
begin
  Result:= TSelectorEnumerator<T, TResult>.CreateWithIndexes(Self as ISPEnumerable<T>, Selector);
end;

function TSPEnumerable<T>.Where(
  const Predicate: TPredicateIndex<T>): ISPEnumerable<T>;
begin
  Result:= TPredicateEnumerator<T>.CreateWithIndexes(Self, Predicate);
end;

function TSPEnumerable<T>.Where(
  const Predicate: TPredicate<T>): ISPEnumerable<T>;
begin
  Result:= TPredicateEnumerator<T>.Create(Self, Predicate);
end;

{ TSelectorEnumerator<T, TResult> }

function TSelectorEnumerator<T, TResult>.Clone: ISPEnumerator<TResult>;
begin
  Result:= TSelectorEnumerator<T, TResult>.Create(FSource, FSelector); //FEnumerator.Clone;
end;

constructor TSelectorEnumerator<T, TResult>.Create(
  const Source: ISPEnumerable<T>; const Selector: TFunc<T, TResult>);
begin
  FSelector:= Selector;
  FSource:= Source;
  FEnumerator:= FSource.GetEnumerator;
  FCurrent:= Default(TResult);
end;

constructor TSelectorEnumerator<T, TResult>.CreateWithIndexes(
  const Source: ISPEnumerable<T>; const Selector: TFunc<T, Integer, TResult>);
begin
  FSelectorIndex:= Selector;
  FSource:= Source;
  FEnumerator:= FSource.GetEnumerator;
  FCurrent:= Default(TResult);
end;

function TSelectorEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result:= FCurrent;
end;

function TSelectorEnumerator<T, TResult>.GetCurrentIndex: Integer;
begin
  Result:= FCurrentIndex;
end;

function TSelectorEnumerator<T, TResult>.GetEnumerator: ISPEnumerator<TResult>;
begin
  Result:= Self as ISPEnumerator<TResult>;
end;

function TSelectorEnumerator<T, TResult>.MoveNext: Boolean;
begin
  Result:= false;

  if FEnumerator.MoveNext then
  begin
    FCurrentIndex:= FEnumerator.CurrentIndex;
    if Assigned(FSelector) then
      FCurrent:= FSelector(FEnumerator.Current)
    else
      if Assigned(FSelectorIndex) then
        FCurrent:= FSelectorIndex(FEnumerator.Current, FCurrentIndex)
      else
      begin
        FCurrent:= Default(TResult);
        Exit;
      end;

    Exit(true);
  end;
end;

procedure TSelectorEnumerator<T, TResult>.Reset;
begin
  FEnumerator.Reset
end;

{ TPredicateEnumerator<T> }

function TPredicateEnumerator<T>.Clone: ISPEnumerator<T>;
begin
  Result:= TPredicateEnumerator<T>.Create(FSource, FPredicate, FMode); //FEnumerator.Clone;
end;

constructor TPredicateEnumerator<T>.Create(const Source: ISPEnumerable<T>;
   const Predicate: TPredicate<T>; Mode: TPredicateMode);
begin
  FPredicate:= Predicate;
  FPredicateIndex:= nil;
  FSource:= Source;
  FEnumerator := FSource.GetEnumerator;
  FCurrent:= Default(T);
  FMode:= Mode;
end;

constructor TPredicateEnumerator<T>.CreateWithIndexes(const Source: ISPEnumerable<T>;
  const Predicate: TPredicateIndex<T>; Mode: TPredicateMode);
begin
  FPredicate:= nil;
  FPredicateIndex:= Predicate;
  FSource:= Source;
  FEnumerator := FSource.GetEnumerator;
  FCurrent:= Default(T);
  FMode:= Mode;
end;

function TPredicateEnumerator<T>.GetCurrent: T;
begin
  Result:= FCurrent;
end;

function TPredicateEnumerator<T>.GetCurrentIndex: Integer;
begin
  Result:= FCurrentIndex;
end;

function TPredicateEnumerator<T>.GetEnumerator: ISPEnumerator<T>;
begin
  Result:= Self as ISPEnumerator<T>;
end;

function TPredicateEnumerator<T>.MoveNext: Boolean;
var
  Current: T;
  Index: Integer;
begin
  Result:= false;

  while FEnumerator.MoveNext do
  begin
    Current:= FEnumerator.Current;
    Index:= FEnumerator.CurrentIndex;

    if (Assigned(FPredicate) and FPredicate(Current)) or
       (Assigned(FPredicateIndex) and FPredicateIndex(Current, Index))
    then
    begin
      case FMode of
       pmNone,
       pmTakeWile:
          begin
            FCurrent:= Current;
            FCurrentIndex:= Index;
            Exit(true);
          end;
       pmSkipWhile: ;
      end;
    end else
    begin
      case FMode of
       pmNone: ;
       pmTakeWile:
          begin
            FCurrent:= Default(T);
            FCurrentIndex:= -1;
            Break;
          end;
       pmSkipWhile:
          begin
            FCurrent:= Current;
            FCurrentIndex:= Index;
            Exit(true);
          end;
      end;
    end;
  end;
end;

procedure TPredicateEnumerator<T>.Reset;
begin
  FEnumerator.Reset
end;

{ TSortedEnumerator<T> }

function TSortedEnumerator<TKey, T>.Clone: ISPEnumerator<T>;
begin
  Result:= TSortedEnumerator<TKey, T>.Create(FSource, FKeySelector, FComparer, FDescending, FSortType);
end;

constructor TSortedEnumerator<TKey, T>.Create(const Source: ISPEnumerable<T>;
  const KeySelector: TFunc<T, TKey>; const Comparer: IComparer<TKey>;
  Descending: boolean; SortType: TSortType);
begin
  FKeySelector:= KeySelector;
  FComparer:= Comparer;
  FSource:= Source;
  FCurrent:= Default(T);
  FIndex:= -1;
  FDescending:= Descending;
  FSortType:= SortType;

  FArray:= ToArray;
  if (Length(FArray) > 0) and Assigned(FComparer) then
    case SortType of
     stOrder: QuickSort(FArray, Low(FArray), High(FArray), FComparer);
     stThen: InjectionSort(FArray, Low(FArray), High(FArray), FComparer);
    end;
  if Descending then Reverse(FArray);
end;

function TSortedEnumerator<TKey, T>.GetArrayIndex(Index: Integer): Integer;
begin
  Result:= -1;
  if Length(FArray) = 0 then Exit;

  if (Index >= Low(FArray)) and (Index <= High(FArray)) then
    Result:= FArray[Index].Index;
end;

function TSortedEnumerator<TKey, T>.GetCurrent: T;
begin
  Result:= FCurrent;
end;

function TSortedEnumerator<TKey, T>.GetCurrentIndex: Integer;
begin
  Result:= FCurrentIndex;
end;

function TSortedEnumerator<TKey, T>.GetEnumerator: ISPEnumerator<T>;
begin
  Result:= Self as ISPEnumerator<T>;
end;

procedure TSortedEnumerator<TKey, T>.InjectionSort(
  var aArray: TArray<TKeyIndex<TKey>>; Index, Count: Integer;
  const aComparer: IComparer<TKey>);
var
  i, j, k: Integer;
  tmp: TKeyIndex<TKey>;
begin
  for i:= Index + 1 to Count do
  begin
    if aComparer.Compare(aArray[i].Key, aArray[i-1].Key) >= 0 then Continue;

    if aComparer.Compare(aArray[i].Key, aArray[Index].Key) < 0 then
      j:= Index
    else
      j:= Seek(aArray, Index, i-1, aArray[i].Key, aComparer);

    tmp:= aArray[i];
    for k:= i downto j+1 do
      aArray[k]:= aArray[k-1];

    aArray[j]:= tmp;
  end;
end;

function TSortedEnumerator<TKey, T>.MoveNext: Boolean;
var
  I: Integer;
  IndexDummy: Integer;
begin
  Result:= false;

  Inc(FIndex);
  if FIndex <= High(FArray) then
  begin
    I:= 0;
    IndexDummy:= GetArrayIndex(FIndex);

    if IndexDummy > -1 then
    begin
      FEnumerator:= FSource.GetEnumerator;
      FEnumerator.Reset;
    end;

    while FEnumerator.MoveNext do
    begin
      if IndexDummy = I then
      begin
        FCurrent:= FEnumerator.Current;
        FCurrentIndex:= FIndex;
        Exit(true);
      end;
      Inc(I);
    end;
  end;
  FIndex:= -1;
end;

procedure TSortedEnumerator<TKey, T>.QuickSort(var aArray: TArray<TKeyIndex<TKey>>;
  Index, Count: Integer; const aComparer: IComparer<TKey>);
var
  Lo, Hi: Integer;
  Pivot, T: TKeyIndex<TKey>;
begin
  Lo:= Index;
  Hi:= Count;
  Pivot:= aArray[(Lo + Hi) div 2];

  repeat
    while aComparer.Compare(aArray[Lo].Key, Pivot.Key) < 0 do Inc(Lo);
    while aComparer.Compare(aArray[Hi].Key, Pivot.Key) > 0 do Dec(Hi);
    if Lo <= Hi then
    begin
      T:= aArray[Lo];
      aArray[Lo]:= aArray[Hi];
      aArray[Hi]:= T;
      Inc(Lo);
      Dec(Hi);
    end;
  until Lo > Hi;
  if Hi > Index then QuickSort(aArray, Index, Hi, aComparer);
  if Lo < Count then QuickSort(aArray, Lo, Count, aComparer);
end;

procedure TSortedEnumerator<TKey, T>.Reset;
begin
  FIndex:= -1;
end;

procedure TSortedEnumerator<TKey, T>.Reverse(var aArray: TArray<TKeyIndex<TKey>>);
var
  Lo, Hi: Integer;
  T: TKeyIndex<TKey>;
begin
  if Length(FArray) = 0 then Exit;

  Lo:= Low(FArray);
  Hi:= High(FArray);

  while Lo < Hi do
  begin
    T:= aArray[Lo];
    aArray[Lo]:= aArray[Hi];
    aArray[Hi]:= T;
    Inc(Lo);
    Dec(Hi);
  end;
end;

function TSortedEnumerator<TKey, T>.Seek(var aArray: TArray<TKeyIndex<TKey>>; Index,
  Count: Integer; Key: TKey; const aComparer: IComparer<TKey>): Integer;
begin
  Result:= Index + ((Count-Index) div 2);
  if Count - Index <= 1 then
    Result:= Result + 1
  else
    if aComparer.Compare(Key, aArray[Result].Key) < 0 then
      Result:= Seek(aArray, Index, Result, Key, aComparer)
    else
      Result:= Seek(aArray, Result, Count, Key, aComparer)
end;

function TSortedEnumerator<TKey, T>.ToArray: TArray<TKeyIndex<TKey>>;
var
  Count: Integer;
  Item: T;
  ItemDummy: TKeyIndex<TKey>;
begin
  Result:= nil;

  if not Assigned(FSource) then Exit;
  if not Assigned(FKeySelector) then Exit;

  Count:= 0;
  for Item in FSource do
  begin
    if Result = nil then
      SetLength(Result, 4)
    else
      if Length(Result) = Count then
        SetLength(Result, Count * 2);

    ItemDummy.Key:= FKeySelector(Item);
    ItemDummy.Index:= Count;
    Result[Count]:= ItemDummy;
    Inc(Count);
  end;
  SetLength(Result, Count);
end;

{ TArrayEnumerator<T> }

function TArrayEnumerator<T>.Clone: ISPEnumerator<T>;
begin
  Result:= TArrayEnumerator<T>.Create(FArray);
end;

constructor TArrayEnumerator<T>.Create(const Source: TArray<T>);
begin
  FArray:= Source;
  FIndex:= -1;
  FCurrent:= Default(T);
end;

constructor TArrayEnumerator<T>.CreateFromArray(const Source: array of T);
begin
  FArray:= nil;
  SetLength(FArray, Length(Source));
  if Length(Source) > 0 then
    TArray.Copy<T>(Source,FArray,Length(Source));

  FIndex:= -1;
  FCurrent:= Default(T);
end;

function TArrayEnumerator<T>.GetCurrent: T;
begin
  Result:= FCurrent;
end;

function TArrayEnumerator<T>.GetCurrentIndex: Integer;
begin
  Result:= FCurrentIndex;
end;

function TArrayEnumerator<T>.GetEnumerator: ISPEnumerator<T>;
begin
  Result:= Self as ISPEnumerator<T>;
end;

function TArrayEnumerator<T>.MoveNext: Boolean;
begin
  Inc(FIndex);
  Result:= FIndex < Length(FArray);

  if (FIndex < Length(FArray)) then
  begin
    FCurrent:= FArray[FIndex];
    FCurrentIndex:= FIndex;
  end else
  begin
    FCurrent:= Default(T);
    FCurrentIndex:= -1;
  end;
end;

procedure TArrayEnumerator<T>.Reset;
begin
  FIndex:= -1;
end;

{ TLinkEnumerator<T> }

function TLinkEnumerator<T>.Clone: ISPEnumerator<T>;
begin
  Result:= TLinkEnumerator<T>.Create(FSourceFirst, FSourceSecond);
end;

constructor TLinkEnumerator<T>.Create(const SourceFirst,
  SourceSecond: ISPEnumerable<T>);
begin
  FSecond:= false;
  FIndex:= -1;
  FSourceFirst:= SourceFirst;
  FSourceSecond:= SourceSecond;
  FEnumeratorFirst:= FSourceFirst.GetEnumerator;
  FEnumeratorSecond:= FSourceSecond.GetEnumerator;
  FCurrent:= Default(T);
end;

function TLinkEnumerator<T>.GetCurrent: T;
begin
  Result:= FCurrent;
end;

function TLinkEnumerator<T>.GetCurrentIndex: Integer;
begin
  Result:= FCurrentIndex;
end;

function TLinkEnumerator<T>.GetEnumerator: ISPEnumerator<T>;
begin
  Result:= Self as ISPEnumerator<T>;
end;

function TLinkEnumerator<T>.MoveNext: Boolean;
begin
  Result:= false;

  Inc(FIndex);

  if not FSecond and FEnumeratorFirst.MoveNext then
  begin
    FCurrentIndex:= FIndex;
    FCurrent:= FEnumeratorFirst.Current;
    Exit(true);
  end else
    if FEnumeratorSecond.MoveNext then
    begin
      FSecond:= true;
      FCurrentIndex:= FIndex;
      FCurrent:= FEnumeratorSecond.Current;
      Exit(true);
    end else
    begin
      FCurrent:= Default(T);
      FCurrentIndex:= -1;
      FIndex:= -1;
      FSecond:= false;
    end;
end;

procedure TLinkEnumerator<T>.Reset;
begin
  FEnumeratorFirst.Reset;
  FEnumeratorSecond.Reset;
  FIndex:= -1;
  FSecond:= false;
end;

{ TEnumeratorAdapter<T> }

function TEnumeratorAdapter<T>.Clone: ISPEnumerator<T>;
begin
  Result:= TEnumeratorAdapter<T>.Create(FSource);
end;

constructor TEnumeratorAdapter<T>.Create(const Source: ISPEnumerable<T>);
begin
  inherited Create;
  FEnumerator:= nil;
  FSource:= Source;
  FCurrent:= Default(T);
end;

function TEnumeratorAdapter<T>.GetCurrent: T;
begin
  if FEnumerator = nil then
    FEnumerator:= FSource.GetEnumerator;

  Result:= FEnumerator.Current;
end;

function TEnumeratorAdapter<T>.GetCurrentIndex: Integer;
begin
  if FEnumerator = nil then
    FEnumerator:= FSource.GetEnumerator;

  Result:= FEnumerator.CurrentIndex;
end;

function TEnumeratorAdapter<T>.MoveNext: Boolean;
begin
  if FEnumerator = nil then
    FEnumerator:= FSource.GetEnumerator;

  Result:= FEnumerator.MoveNext;
end;

procedure TEnumeratorAdapter<T>.Reset;
begin

end;

{ TJoinEnumerator<T, TInner, TKey, TResult> }

function TJoinEnumerator<T, TInner, TKey, TResult>.Clone: ISPEnumerator<TResult>;
begin
  Result:= TJoinEnumerator<T, TInner, TKey, TResult>.Create(FOuter,
                                                            FInner,
                                                            FOuterKeySelector,
                                                            FInnerKeySelector,
                                                            FResultSelector,
                                                            FComparer
                                                            );
end;

constructor TJoinEnumerator<T, TInner, TKey, TResult>.Create(
  const Outer: ISPEnumerable<T>; const Inner: ISPEnumerable<TInner>;
  const OuterKeySelector: TFunc<T, TKey>;
  const InnerKeySelector: TFunc<TInner, TKey>;
  const ResultSelector: TFunc<T, TInner, TResult>;
  const aComparer: IComparer<TKey>);
begin
  FInnerKeySelectorIndex:= nil;
  FOuterKeySelectorIndex:= nil;
  FResultSelectorIndex:= nil;
  FGroupResultSelector:= nil;

  FCurrent:= Default(TResult);
  FCurrentIndex:= -1;
  FInner:= Inner;
  FOuterEnumerator:= Outer.GetEnumerator;
  FInnerEnumerator:= FInner.GetEnumerator;
  FInnerKeySelector:= InnerKeySelector;
  FOuterKeySelector:= OuterKeySelector;
  FResultSelector:= ResultSelector;
  FComparer:= aComparer;
  FIndex:= -1;
  FKey:= Default(TKey);
  FGroup:= false;
end;

constructor TJoinEnumerator<T, TInner, TKey, TResult>.CreateWithIndexes(
  const Outer: ISPEnumerable<T>; const Inner: ISPEnumerable<TInner>;
  const OuterKeySelector: TFunc<T, Integer, TKey>;
  const InnerKeySelector: TFunc<TInner, Integer, TKey>;
  const ResultSelector: TFunc<T, Integer, TInner, Integer, TResult>;
  const aComparer: IComparer<TKey>);
begin
  FInnerKeySelector:= nil;
  FOuterKeySelector:= nil;
  FResultSelector:= nil;
  FGroupResultSelector:= nil;

  FCurrent:= Default(TResult);
  FCurrentIndex:= -1;
  FInner:= Inner;
  FOuterEnumerator:= Outer.GetEnumerator;
  FInnerEnumerator:= FInner.GetEnumerator;
  FInnerKeySelectorIndex:= InnerKeySelector;
  FOuterKeySelectorIndex:= OuterKeySelector;
  FResultSelectorIndex:= ResultSelector;
  FComparer:= aComparer;
  FIndex:= -1;
  FKey:= Default(TKey);
  FGroup:= false;
end;

constructor TJoinEnumerator<T, TInner, TKey, TResult>.CreateGroupJoin(
  const Outer: ISPEnumerable<T>; const Inner: ISPEnumerable<TInner>;
  const OuterKeySelector: TFunc<T, TKey>;
  const InnerKeySelector: TFunc<TInner, TKey>;
  const ResultSelector: TFunc<T, ISPEnumerable<TInner>, TResult>;
  const aComparer: IComparer<TKey>);
begin
  FCurrent:= Default(TResult);
  FCurrentIndex:= -1;
  FInner:= Inner;
  FOuterEnumerator:= Outer.GetEnumerator;
  FInnerEnumerator:= FInner.GetEnumerator;
  FInnerKeySelector:= InnerKeySelector;
  FOuterKeySelector:= OuterKeySelector;
  FGroupResultSelector:= ResultSelector;
  FComparer:= aComparer;
  FIndex:= -1;
  FKey:= Default(TKey);
  FGroup:= true;
  FPredicate:= function(Itm: TInner): boolean
               begin
                 Result:= FComparer.Compare(FInnerKeySelector(Itm), FKey) = 0
               end;
end;

function TJoinEnumerator<T, TInner, TKey, TResult>.FindByKey(OuterCurrent: T;
  OuterIndex: Integer): boolean;
var
  IsEqual: boolean;
begin
  Result:= false;
  IsEqual:= false;

  if not Assigned(FComparer) then Exit;

  if FGroup then
  begin
    FInnerEnumerator.Reset;
    while FInnerEnumerator.MoveNext do
    begin
      if Assigned(FInnerKeySelector) then
        Result:= FComparer.Compare(FInnerKeySelector(FInnerEnumerator.Current), FKey) = 0;

      if Result then Break;
    end;
  end else
  begin
    while FInnerEnumerator.MoveNext do
    begin
      if Assigned(FInnerKeySelector) then
        IsEqual:= FComparer.Compare(FInnerKeySelector(FInnerEnumerator.Current), FKey) = 0
      else
        if Assigned(FInnerKeySelectorIndex) then
          IsEqual:= FComparer.Compare(FInnerKeySelectorIndex(FInnerEnumerator.Current, FInnerEnumerator.CurrentIndex), FKey) = 0;

      if IsEqual then
      begin
        Inc(FIndex);

        if Assigned(FResultSelector) then
          FCurrent:= FResultSelector(OuterCurrent, FInnerEnumerator.Current)
        else
          if Assigned(FResultSelectorIndex) then
            FCurrent:= FResultSelectorIndex(OuterCurrent, Outerindex, FInnerEnumerator.Current, FInnerEnumerator.CurrentIndex);

        FCurrentIndex:= FIndex;
        Exit(true);
      end;
    end;
  end;
end;

function TJoinEnumerator<T, TInner, TKey, TResult>.GetCurrent: TResult;
begin
  Result:= FCurrent;
end;

function TJoinEnumerator<T, TInner, TKey, TResult>.GetCurrentIndex: Integer;
begin
  Result:= FCurrentIndex;
end;

function TJoinEnumerator<T, TInner, TKey, TResult>.GetEnumerator: ISPEnumerator<TResult>;
begin
  Result:= Self as ISPEnumerator<TResult>;
end;

function TJoinEnumerator<T, TInner, TKey, TResult>.MoveNext: Boolean;
begin
  Result:= false;

  if not FGroup then
    if (FIndex > -1) then
      if FindByKey(FOuterEnumerator.Current, FOuterEnumerator.CurrentIndex) then Exit(true);

  while FOuterEnumerator.MoveNext do
  begin
    if not FGroup then
    begin
      FInnerEnumerator.Reset;

      if Assigned(FOuterKeySelector) then
        FKey:= FOuterKeySelector(FOuterEnumerator.Current)
      else
        if Assigned(FOuterKeySelectorIndex) then
          FKey:= FOuterKeySelectorIndex(FOuterEnumerator.Current, FOuterEnumerator.Currentindex)
        else
          Break;

      if FindByKey(FOuterEnumerator.Current, FOuterEnumerator.CurrentIndex) then Exit(true);
    end else
    begin
      if Assigned(FOuterKeySelector) then
        FKey:= FOuterKeySelector(FOuterEnumerator.Current)
      else
        Break;

      if FindByKey(FOuterEnumerator.Current, FOuterEnumerator.CurrentIndex) then
      begin
        FInnerEnumerator.Reset;
        Inc(FIndex);
        FCurrentIndex:= FIndex;
        FPredicateEnumerable:= TPredicateEnumerator<TInner>.Create(FInner, FPredicate);

        if Assigned(FGroupResultSelector) then
          FCurrent:= FGroupResultSelector(FOuterEnumerator.Current, FPredicateEnumerable);

        Exit(true);
      end;
    end;
  end;

  FCurrent:= Default(TResult);
  FCurrentIndex:= -1;
  FIndex:= -1;
end;

procedure TJoinEnumerator<T, TInner, TKey, TResult>.Reset;
begin
  FIndex:= -1;
  FOuterEnumerator.Reset;
  FInnerEnumerator.Reset;
end;

{ Enumerable }

class function Enumerable<T>.From(const Source: array of T): ISPEnumerable<T>;
begin
  Result:= TSPEnumerable<T>.Create(Source);
end;

class function Enumerable<T>.From(const Source: TArray<T>): ISPEnumerable<T>;
begin
  Result:= TSPEnumerable<T>.Create(Source);
end;

class function Enumerable<T>.From(
  const Source: ISPEnumerable<T>): ISPEnumerable<T>;
begin
  Result:= TSPEnumerable<T>.Create(Source);
end;

class function Enumerable<T>.From(const List: TObject;
  const ItemsName, CountName: string): ISPEnumerable<T>;
begin
  Result:= TSPEnumerable<T>.Create(List, ItemsName, CountName);
end;

class function Enumerable<T>.From(
  const Source: ISPEnumerator<T>): ISPEnumerable<T>;
begin
  Result:= TSPEnumerable<T>.Create(Source);
end;

function Enumerable<T>.Range(Start, Count: Integer): ISPEnumerable<Integer>;
var
  I: Integer;
  Index: Integer;
begin
  Result:= nil;
  if Count <= 0 then Exit;

  FSourceInt:= nil;
  SetLength(FSourceInt, Count);
  I:= Start;
  Index:= 0;
  while I < Start + Count do
  begin
    FSourceInt[Index]:= I;
    Inc(Index);
    Inc(I);
  end;

  Result:= TSPEnumerable<Integer>.Create(FSourceInt);
end;

function Enumerable<T>.Repeat_(Element: T; Count: Integer): ISPEnumerable<T>;
var
  I: Integer;
begin
  Result:= nil;
  if Count <= 0 then Exit;

  FSource:= nil;
  SetLength(FSource, Count);
  I:= 0;
  while I < Count do
  begin
    FSource[I]:= Element;
    Inc(I);
  end;

  Result:= TSPEnumerable<T>.Create(FSource);
end;

class function Enumerable<T>.Select<T, TResult>(const Source: ISPEnumerable<T>;
  const Selector: TFunc<T, Integer, TResult>): ISPEnumerable<TResult>;
begin
  Result:= TSelectorEnumerator<T, TResult>.CreateWithIndexes(Source, Selector);
end;

class function Enumerable<T>.SelectMany<T, TResult>(
  const Source: ISPEnumerable<T>;
  const Selector: TFunc<T, Integer, ISPEnumerable<TResult>>): TSPEnumerable<TResult>;
begin
  Result:= TSelectorManyEnumerator<T, TResult>.CreateWithIndexes(Source, Selector);
end;

class function Enumerable<T>.SelectMany<T, TResult>(
  const Source: ISPEnumerable<T>;
  const Selector: TFunc<T, ISPEnumerable<TResult>>): TSPEnumerable<TResult>;
begin
  Result:= TSelectorManyEnumerator<T, TResult>.Create(Source, Selector);
end;

class function Enumerable<T>.Select<T, TResult>(const Source: ISPEnumerable<T>;
  const Selector: TFunc<T, TResult>): ISPEnumerable<TResult>;
begin
  Result:= TSelectorEnumerator<T, TResult>.Create(Source, Selector);
end;

{ TDistinctEnumerator<T> }

function TDistinctEnumerator<T>.Clone: ISPEnumerator<T>;
begin
  Result:= TDistinctEnumerator<T>.Create(FSource, FComparer);
end;

constructor TDistinctEnumerator<T>.Create(const Source: ISPEnumerable<T>;
  const aComparer: IComparer<T>);
begin
  FIndex:= -1;
  FSource:= Source;
  FEnumerator:= FSource.GetEnumerator;
  FCurrent:= Default(T);
  FComparer:= aComparer;
end;

function TDistinctEnumerator<T>.GetCurrent: T;
begin
  Result:= FCurrent;
end;

function TDistinctEnumerator<T>.GetCurrentIndex: Integer;
begin
  Result:= FCurrentIndex;
end;

function TDistinctEnumerator<T>.GetEnumerator: ISPEnumerator<T>;
begin
  Result:= Self as ISPEnumerator<T>;
end;

function TDistinctEnumerator<T>.MoveNext: Boolean;
var
  Enumerator: ISPEnumerator<T>;
  Source: ISPEnumerable<T>;
  bFind: boolean;
begin
  Result:= false;

  while FEnumerator.MoveNext do
  begin
    Enumerator:= FSource.GetEnumerator.Clone;
    bFind:= false;

    while Enumerator.MoveNext do
    begin
      if Enumerator.CurrentIndex >= FEnumerator.CurrentIndex then Break;

      if FComparer.Compare(FEnumerator.Current, Enumerator.Current) = 0 then
      begin
        bFind:= true;
        Break;
      end;
    end;

    if not bFind then
    begin
      Inc(FIndex);
      FCurrent:= FEnumerator.Current;
      FCurrentIndex:= FIndex;
      Exit(true);
    end;
  end;

  FCurrent:= Default(T);
  FCurrentIndex:= -1;
  FIndex:= -1;
end;

procedure TDistinctEnumerator<T>.Reset;
begin
  FEnumerator.Reset;
  FIndex:= -1;
end;

{ TSetsEnumerator<T> }

function TSetsEnumerator<T>.Clone: ISPEnumerator<T>;
begin
  Result:= TSetsEnumerator<T>.Create(FSourceFirst, FSourceSecond, FComparer, FType);
end;

constructor TSetsEnumerator<T>.Create(const SourceFirst,
  SourceSecond: ISPEnumerable<T>; const aComparer: IComparer<T>;
  SetType: TSetType);
begin
  FType:= SetType;
  FIndex:= -1;
  FCurrent:= Default(T);
  FComparer:= aComparer;
  FSourceFirst:= SourceFirst;
  FSourceSecond:= SourceSecond;

  case FType of
    stUnion: FEnumerable:= TLinkEnumerator<T>.Create(TDistinctEnumerator<T>.Create(FSourceFirst, FComparer),
                                                     TDistinctEnumerator<T>.Create(FSourceSecond, FComparer));
    stIntersect,
    stExcept: FEnumerable:= TDistinctEnumerator<T>.Create(FSourceFirst, FComparer);
  end;
  FEnumerator:= FEnumerable.GetEnumerator;
end;

function TSetsEnumerator<T>.GetCurrent: T;
begin
  Result:= FCurrent;
end;

function TSetsEnumerator<T>.GetCurrentIndex: Integer;
begin
  Result:= FCurrentIndex;
end;

function TSetsEnumerator<T>.GetEnumerator: ISPEnumerator<T>;
begin
  Result:= Self as ISPEnumerator<T>;
end;

function TSetsEnumerator<T>.MoveNext: Boolean;
var
  Enumerator: ISPEnumerator<T>;
  Enumerable: ISPEnumerable<T>;
  bFind: boolean;
begin
  Result:= false;

  while FEnumerator.MoveNext do
  begin
    case FType of
      stUnion: Enumerable:= TLinkEnumerator<T>.Create(TDistinctEnumerator<T>.Create(FSourceFirst, FComparer),
                                                      TDistinctEnumerator<T>.Create(FSourceSecond, FComparer));
      stIntersect,
      stExcept: Enumerable:= TDistinctEnumerator<T>.Create(FSourceSecond, FComparer);
    end;
    Enumerator:= Enumerable.GetEnumerator;
    bFind:= false;

    while Enumerator.MoveNext do
    begin
      if FType = stUnion then
        if Enumerator.CurrentIndex >= FEnumerator.CurrentIndex then Break;

      if FComparer.Compare(FEnumerator.Current, Enumerator.Current) = 0 then
      begin
        bFind:= true;
        Break;
      end;
    end;

    case FType of
      stExcept,
      stUnion: if not bFind then
               begin
                 Inc(FIndex);
                 FCurrent:= FEnumerator.Current;
                 FCurrentIndex:= FIndex;
                 Exit(true);
               end;
      stIntersect: if bFind then
                   begin
                     Inc(FIndex);
                     FCurrent:= FEnumerator.Current;
                     FCurrentIndex:= FIndex;
                     Exit(true);
                   end;
    end;
  end;

  FCurrent:= Default(T);
  FCurrentIndex:= -1;
  FIndex:= -1;
end;

procedure TSetsEnumerator<T>.Reset;
begin
  FEnumerator.Reset;
  FIndex:= -1;
end;

{ TCastEnumerator<T, TResult> }

function TCastEnumerator<T, TResult>.Clone: ISPEnumerator<TResult>;
begin
  Result:= TCastEnumerator<T, TResult>.Create(FSource, FSelector);
end;

constructor TCastEnumerator<T, TResult>.Create(const Source: ISPEnumerable<T>;
  const Selector: TFunc<T, TResult>);
begin
  FCurrent:= Default(TResult);
  FCurrentIndex:= -1;
  FIndex:= -1;
  FSource:= Source;
  FSelector:= Selector;
  FEnumerator:= FSource.GetEnumerator;
end;

function TCastEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result:= FCurrent;
end;

function TCastEnumerator<T, TResult>.GetCurrentIndex: Integer;
begin
  Result:= FCurrentIndex;
end;

function TCastEnumerator<T, TResult>.GetEnumerator: ISPEnumerator<TResult>;
begin
  Result:= Self as ISPEnumerator<TResult>;
end;

function TCastEnumerator<T, TResult>.MoveNext: Boolean;
var
  Value: TValue;
begin
  Result:= false;

  while FEnumerator.MoveNext do
  begin
    Inc(FIndex);

    if Assigned(FSelector) then
    begin
      FCurrent:= FSelector(FEnumerator.Current);
      FCurrentIndex:= FIndex;
      Exit(true);
    end else
    begin
      Value:= TValue.From<T>(FEnumerator.Current);
      FCurrent:= Value.AsType<TResult>;
      FCurrentIndex:= FIndex;
      Exit(True);
    end;
  end;

  FCurrent:= Default(TResult);
  FCurrentIndex:= -1;
  FIndex:= -1;
end;

procedure TCastEnumerator<T, TResult>.Reset;
begin
  FEnumerator.Reset;
  FIndex:= -1;
end;

{ TGroupingEnumerator<TKey, T> }

function TGroupingEnumerator<TKey, T>.Clone: ISPEnumerator<IGrouping<TKey, T>>;
begin
  Result:= TGroupingEnumerator<TKey, T>.Create(FSource, FKeySelector, FComparer);
end;

constructor TGroupingEnumerator<TKey, T>.Create(const Source: ISPEnumerable<T>;
  const KeySelector: TFunc<T, TKey>; const aComparer: IComparer<TKey>);
begin
  FCurrent:= Default(IGrouping<TKey, T>);
  FCurrentIndex:= -1;
  FIndex:= -1;
  FSource:= Source;
  FKeySelector:= KeySelector;
  FComparer:= aComparer;

  FSelector:= TSPEnumerable<T>(FSource).Select<T,TKey>({FSource, }FKeySelector);
  FSourceEnum:= TSPEnumerable<TKey>(FSelector).Distinct(FComparer);
  FEnumerator:= FSourceEnum.GetEnumerator;
end;

function TGroupingEnumerator<TKey, T>.GetCurrent: IGrouping<TKey, T>;
begin
  Result:= FCurrent;
end;

function TGroupingEnumerator<TKey, T>.GetCurrentIndex: Integer;
begin
  Result:= FCurrentIndex;
end;

function TGroupingEnumerator<TKey, T>.GetEnumerator: ISPEnumerator<IGrouping<TKey, T>>;
begin
  Result:= Self as ISPEnumerator<IGrouping<TKey, T>>;
end;

function TGroupingEnumerator<TKey, T>.MoveNext: Boolean;
var
  FWhereEnum: ISPEnumerable<T>;
  Key: TKey;
  Comparer: IComparer<TKey>;
begin
  Result:= false;

  Comparer:= TComparer<TKey>.Default;

  while FEnumerator.MoveNext do
  begin
    Inc(FIndex);

    Key:= FEnumerator.Current;
    FWhereEnum:= TPredicateEnumerator<T>.Create(FSource,
        function(Item: T): boolean
        begin
          Result:= Comparer.Compare(FKeySelector(Item), Key) = 0;
        end);

    FCurrent:= TGrouping<TKey, T>.Create(Key, FWhereEnum);
    FCurrentIndex:= FIndex;
    Exit(true);
  end;

  FCurrent:= Default(IGrouping<TKey, T>);
  FCurrentIndex:= -1;
  FIndex:= -1;
end;

procedure TGroupingEnumerator<TKey, T>.Reset;
begin
  FEnumerator.Reset;
  FIndex:= -1;
end;


{ TGrouping<TKey, T> }

constructor TGrouping<TKey, T>.Create(const Key: TKey;
  Values: ISPEnumerable<T>);
begin
  FKey:= Key;
  FValues:= Values;
end;

function TGrouping<TKey, T>.GetEnumerator: ISPEnumerator<T>;
begin
  Result:= FValues.GetEnumerator;
end;

function TGrouping<TKey, T>.GetKey: TKey;
begin
  Result:= FKey;
end;

{ TListEnumerator<T> }

function TListEnumerator<T>.Clone: ISPEnumerator<T>;
begin
  Result:= TListEnumerator<T>.Create(FList, FItemsName, FCountName);
end;

constructor TListEnumerator<T>.Create(const AList: TObject;
  const ItemsName, CountName: string);
begin
  inherited Create;
  FList:= AList;
  FIndex:= -1;
  FCurrent:= Default(T);
  FItemsName:= ItemsName;
  FCountName:= CountName;
end;

destructor TListEnumerator<T>.Destroy;
begin
  FList:= nil;
  inherited;
end;

function TListEnumerator<T>.GetCurrent: T;
begin
  Result:= FCurrent;
end;

function TListEnumerator<T>.GetCurrentIndex: Integer;
begin
  Result:= FCurrentIndex;
end;

function TListEnumerator<T>.MoveNext: Boolean;
var
  AContext: TRttiContext;
  AType: TRttiType;
  AProp: TRttiProperty;
  APropI: TRttiIndexedProperty;
  ACount: Integer;
  AItem: TValue;
begin
  Result:= false;

  if FItemsName.IsEmpty or
     FCountName.IsEmpty
  then
    Exit;

  ACount:= 0;
  AContext:= TRttiContext.Create;
  try
    AType:= AContext.GetType(FList.ClassInfo);
    for AProp in AType.GetProperties do
      if AnsiSameText(AProp.Name, FCountName) then
      begin
        ACount:= AProp.GetValue(FList).AsInteger;
        Break;
      end;

    if FIndex + 1 >= ACount then Exit;

    while (AType <> nil) do
    begin
      for APropI in AType.GetIndexedProperties do
        if AnsiSameText(APropI.Name, FItemsName) then
        begin
          AItem:= APropI.GetValue(FList, [FIndex+1]);
          Break;
        end;

      if not AItem.IsEmpty then Break;

      AType:= AType.BaseType;
    end;

    Inc(FIndex);
    if (FIndex < ACount) then
    begin
      if not AItem.IsEmpty then
      begin
        FCurrent:= AItem.AsType<T>;
        FCurrentIndex:= FIndex;
        Result:= true;
      end;
    end else
    begin
      FIndex:= -1;
      FCurrentIndex:= FIndex;
      FCurrent:= Default(T);
    end;
  finally
    AContext.Free;
  end;
end;

procedure TListEnumerator<T>.Reset;
begin
  FIndex:= -1;
end;

{ TSelectorManyEnumerator<T, TResult> }

function TSelectorManyEnumerator<T, TResult>.Clone: ISPEnumerator<TResult>;
begin
  Result:= TSelectorManyEnumerator<T, TResult>.Create(FSource, FSelector);
end;

constructor TSelectorManyEnumerator<T, TResult>.Create(
  const Source: ISPEnumerable<T>;
  const Selector: TFunc<T, ISPEnumerable<TResult>>);
begin
  FCurrent:= Default(TResult);
  FCurrentIndex:= -1;
  FSelector:= Selector;
  FSelectorIndex:= nil;
  FEnumerator:= Source.GetEnumerator;
  FSource:= Source;
  FSourceOut:= nil;
  FEnumeratorOut:= nil;
  FOutFlag:= false;
end;

constructor TSelectorManyEnumerator<T, TResult>.CreateWithIndexes(
  const Source: ISPEnumerable<T>;
  const Selector: TFunc<T, Integer, ISPEnumerable<TResult>>);
begin
  FCurrent:= Default(TResult);
  FCurrentIndex:= -1;
  FSelector:= nil;
  FSelectorIndex:= Selector;
  FEnumerator:= Source.GetEnumerator;
  FSource:= Source;
  FSourceOut:= nil;
  FEnumeratorOut:= nil;
  FOutFlag:= false;
end;

function TSelectorManyEnumerator<T, TResult>.GetCurrent: TResult;
begin
  Result:= FCurrent;
end;

function TSelectorManyEnumerator<T, TResult>.GetCurrentIndex: Integer;
begin
  Result:= FCurrentIndex;
end;

function TSelectorManyEnumerator<T, TResult>.GetEnumerator: ISPEnumerator<TResult>;
begin
  Result:= Self as ISPEnumerator<TResult>;
end;

function TSelectorManyEnumerator<T, TResult>.MoveNext: Boolean;
begin
  Result:= false;

  while FOutFlag or FEnumerator.MoveNext do
  begin
    if not FOutFlag then
    begin
      if Assigned(FSelector) then
      begin
        FSourceOut:= FSelector(FEnumerator.Current);
        FEnumeratorOut:= FSourceOut.GetEnumerator;
        FOutFlag:= true;
      end else
        if Assigned(FSelectorIndex) then
        begin
          FSourceOut:= FSelectorIndex(FEnumerator.Current, FCurrentIndex);
          FEnumeratorOut:= FSourceOut.GetEnumerator;
          FOutFlag:= true;
        end else
        begin
          FCurrent:= Default(TResult);
          FCurrentIndex:= -1;
          Exit;
        end;
    end;

    if FOutFlag and Assigned(FEnumeratorOut) then
      if FEnumeratorOut.MoveNext then
      begin
        FCurrent:= FEnumeratorOut.Current;
        FCurrentIndex:= FEnumeratorOut.CurrentIndex;
        Exit(true);
      end else
        FOutFlag:= false;
  end;

  FCurrent:= Default(TResult);
  FCurrentIndex:= -1;
  FEnumeratorOut:= nil;
end;

procedure TSelectorManyEnumerator<T, TResult>.Reset;
begin
  FEnumerator.Reset;
end;

end.
