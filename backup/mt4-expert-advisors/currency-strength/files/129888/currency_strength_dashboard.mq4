// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69152

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.2"
// ProfitRobots Dashboard template v.1.3
// You can find more templates at https://github.com/sibvic/mq4-templates

#property indicator_separate_window
#property strict

enum DisplayMode
{
   Vertical,
   Horizontal
};

extern int Length = 20;
input bool Include_USD = true; // Include USD
input bool Include_EUR = true; // Include EUR
input bool Include_GBP = true; // Include GBP
input bool Include_JPY = true; // Include JPY
input bool Include_CHF = true; // Include CHF
input bool Include_AUD = true; // Include AUD
input bool Include_NZD = true; // Include NZD
input bool Include_CAD = true; // Include CAD
input bool UseMajorsOnly = true; // Use majors only

input bool     Include_M1               = false;
input bool     Include_M5               = false;
input bool     Include_M15              = false;
input bool     Include_M30              = false;
input bool     Include_H1               = true;
input bool     Include_H4               = false;
input bool     Include_D1               = true;
input bool     Include_W1               = true;
input bool     Include_MN1              = false;
input color    Labels_Color             = clrWhite;
input int x_shift = 900; // X coordinate
input DisplayMode display_mode = Horizontal; // Display mode
input int font_size = 10; // Font Size;
input int cell_width = 80; // Cell width
input int cell_height = 30; // Cell height

#define MAX_LOOPBACK 500

string   WindowName;
int      WindowNumber;

// ABaseCondition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef ABaseCondition_IMP
#define ABaseCondition_IMP
// Abstract condition v1.1

// ICondition v3.1
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period, const datetime date) = 0;
   virtual string GetLogMessage(const int period, const datetime date) = 0;
};

#ifndef ACondition_IMP
#define ACondition_IMP

class ACondition : public ICondition
{
   int _references;
public:
   ACondition()
   {
      _references = 1;
   }

   virtual void AddRef()
   {
      ++_references;
   }

   virtual void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }

   virtual string GetLogMessage(const int period, const datetime date)
   {
      return "";
   }
};

#endif
// Instrument info v.1.4
// More templates and snippets on https://github.com/sibvic/mq4-templates

class InstrumentInfo
{
   string _symbol;
   double _mult;
   double _point;
   double _pipSize;
   int _digits;
   double _tickSize;
public:
   InstrumentInfo(const string symbol)
   {
      _symbol = symbol;
      _point = MarketInfo(symbol, MODE_POINT);
      _digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      _mult = _digits == 3 || _digits == 5 ? 10 : 1;
      _pipSize = _point * _mult;
      _tickSize = MarketInfo(_symbol, MODE_TICKSIZE);
   }
   
   static double GetBid(const string symbol) { return MarketInfo(symbol, MODE_BID); }
   double GetBid() { return GetBid(_symbol); }
   static double GetAsk(const string symbol) { return MarketInfo(symbol, MODE_ASK); }
   double GetAsk() { return GetAsk(_symbol); }
   static double GetPipSize(const string symbol)
   { 
      double point = MarketInfo(symbol, MODE_POINT);
      double digits = (int)MarketInfo(symbol, MODE_DIGITS); 
      double mult = digits == 3 || digits == 5 ? 10 : 1;
      return point * mult;
   }
   double GetPipSize() { return _pipSize; }
   double GetPointSize() { return _point; }
   string GetSymbol() { return _symbol; }
   double GetSpread() { return (GetAsk() - GetBid()) / GetPipSize(); }
   int GetDigits() { return _digits; }
   double GetTickSize() { return _tickSize; }
   double GetMinLots() { return SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MIN); };

   double RoundRate(const double rate)
   {
      return NormalizeDouble(MathFloor(rate / _tickSize + 0.5) * _tickSize, _digits);
   }
};


class ABaseCondition : public ACondition
{
protected:
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo *_instrument;
   string _symbol;
public:
   ABaseCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _instrument = new InstrumentInfo(symbol);
      _timeframe = timeframe;
      _symbol = symbol;
   }
   ~ABaseCondition()
   {
      delete _instrument;
   }
};
#endif

class Iterator
{
   int _initialValue; int _shift; int _current;
public:
   Iterator(int initialValue, int shift) { _initialValue = initialValue; _shift = shift; _current = _initialValue - _shift; }
   int GetNext() { _current += _shift; return _current; }
};

// Empty cell v1.0

// Interface for a cell v1.0

#ifndef ICell_IMP
#define ICell_IMP

class ICell
{
public:
   virtual void Draw() = 0;
protected:
   void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 )
   { 
      ObjectDelete(nm); 
      ObjectCreate(nm, OBJ_LABEL, Window, 0, 0); 
      ObjectSet(nm, OBJPROP_CORNER, LabelCorner); 
      ObjectSet(nm, OBJPROP_XDISTANCE, xoff); 
      ObjectSet(nm, OBJPROP_YDISTANCE, yoff); 
      ObjectSet(nm, OBJPROP_BACK, false); 
      ObjectSetText(nm, LabelTexto, FSize, Font, LabelColor);
   }
};

#endif

#ifndef EmptyCell_IMP
#define EmptyCell_IMP

class EmptyCell : public ICell
{
public:
   virtual void Draw() { }
};

#endif
// Label cell v1.0



#ifndef LabelCell_IMP
#define LabelCell_IMP

class LabelCell : public ICell
{
   string _id;
   string _text; 
   int _x; 
   int _y;
public:
   LabelCell(const string id, const string text, const int x, const int y) 
   { 
      _id = id; 
      _text = text; 
      _x = x; 
      _y = y; 
   } 
   virtual void Draw() 
   { 
      ObjectMakeLabel(_id, _x, _y, _text, Labels_Color, 1, WindowNumber, "Arial", font_size); 
   }
};

#endif
// Grid v1.0

// Row v1.0

#ifndef Row_IMP
#define Row_IMP

class Row
{
   ICell *_cells[];
public:
   ~Row() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         delete _cells[i]; 
      } 
   }
   void Draw() 
   { 
      int count = ArraySize(_cells); 
      for (int i = 0; i < count; ++i) 
      { 
         _cells[i].Draw(); 
      } 
   }
   void Add(ICell *cell) 
   {
      int count = ArraySize(_cells); 
      ArrayResize(_cells, count + 1); 
      _cells[count] = cell; 
   } 
};

#endif

#ifndef Grid_IMP
#define Grid_IMP

class Grid
{
   Row *_rows[];
public:
   ~Grid()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         delete _rows[i];
      }
   }

   Row *AddRow()
   {
      int count = ArraySize(_rows);
      ArrayResize(_rows, count + 1);
      _rows[count] = new Row();
      return _rows[count];
   }
   
   Row *GetRow(const int index)
   {
      return _rows[index];
   }
   
   void Draw()
   {
      int count = ArraySize(_rows);
      for (int i = 0; i < count; ++i)
      {
         _rows[i].Draw();
      }
   }
};

#endif

class TextValueCell : public ICell
{
   string _id; 
   int _x; 
   int _y; 
   string _symbol; 
   ENUM_TIMEFRAMES _timeframe; 
   datetime _lastDatetime;
   int _currency;
public:
   TextValueCell(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe, int currency)
   { 
      _currency = currency;
      _id = id; 
      _x = x; 
      _y = y; 
      _symbol = symbol; 
      _timeframe = timeframe; 
   }

   ~TextValueCell()
   {
   }

   virtual void Draw()
   { 
      double upvalue = iCustom(_Symbol, _timeframe, "currency_strength", Length, _currency, UseMajorsOnly, 0, 0);
      double downvalue = iCustom(_Symbol, _timeframe, "currency_strength", Length, _currency, UseMajorsOnly, 1, 0);
      string label = "+" + IntegerToString((int)upvalue) + "/-" + IntegerToString((int)downvalue);
      ObjectMakeLabel(_id, _x, _y, label, Labels_Color, 1, WindowNumber, "Arial", font_size); 
   }
};

// Text value cell factory v1.0

// Interface for a cell factory v1.0



#ifndef ICellFactory_IMP
#define ICellFactory_IMP

class ICellFactory
{
public:
   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe, int currency) = 0;
};

#endif

#ifndef TextValueCellFactory_IMP
#define TextValueCellFactory_IMP

class TextValueCellFactory : public ICellFactory
{
public:
   virtual ICell* Create(const string id, const int x, const int y, const string symbol, const ENUM_TIMEFRAMES timeframe, int currency)
   {
      return new TextValueCell(id, x, y, symbol, timeframe, currency);
   }
};
#endif

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

Grid *grid;

// Grid builder v1.3



#ifndef GridBuilder_IMP
#define GridBuilder_IMP

class GridBuilder
{
   string _symbols[];
   int _symbolParsms[];
   int _symbolsCount;
   Grid *grid;
   int _originalX;
   int _originalY;
   Iterator _xIterator;
   Iterator _yIterator;
   bool _verticalMode;
   ICellFactory* _cellFactory;
public:
   GridBuilder(int x, int y, bool verticalMode, ICellFactory* cellFactory)
      :_xIterator(x, -cell_width), _yIterator(y, cell_height)
   {
      _cellFactory = cellFactory;
      _verticalMode = verticalMode;
      _originalY = y;
      _originalX = x;
      grid = new Grid();
   }
   ~GridBuilder()
   {
      delete _cellFactory;
   }

   void SetSymbols(const string symbols)
   {
      if (Include_USD)
      {
         int size = ArraySize(_symbols);
         ArrayResize(_symbols, size + 1);
         ArrayResize(_symbolParsms, size + 1);
         _symbols[size] = "USD";
         _symbolParsms[size] = 1;
      }
      if (Include_EUR)
      {
         int size = ArraySize(_symbols);
         ArrayResize(_symbols, size + 1);
         ArrayResize(_symbolParsms, size + 1);
         _symbols[size] = "EUR";
         _symbolParsms[size] = 2;
      }
      if (Include_GBP)
      {
         int size = ArraySize(_symbols);
         ArrayResize(_symbols, size + 1);
         ArrayResize(_symbolParsms, size + 1);
         _symbols[size] = "GBP";
         _symbolParsms[size] = 3;
      }
      if (Include_JPY)
      {
         int size = ArraySize(_symbols);
         ArrayResize(_symbols, size + 1);
         ArrayResize(_symbolParsms, size + 1);
         _symbols[size] = "JPY";
         _symbolParsms[size] = 4;
      }
      if (Include_CHF)
      {
         int size = ArraySize(_symbols);
         ArrayResize(_symbols, size + 1);
         ArrayResize(_symbolParsms, size + 1);
         _symbols[size] = "CHF";
         _symbolParsms[size] = 5;
      }
      if (Include_AUD)
      {
         int size = ArraySize(_symbols);
         ArrayResize(_symbols, size + 1);
         ArrayResize(_symbolParsms, size + 1);
         _symbols[size] = "AUD";
         _symbolParsms[size] = 6;
      }
      if (Include_NZD)
      {
         int size = ArraySize(_symbols);
         ArrayResize(_symbols, size + 1);
         ArrayResize(_symbolParsms, size + 1);
         _symbols[size] = "NZD";
         _symbolParsms[size] = 7;
      }
      if (Include_CAD)
      {
         int size = ArraySize(_symbols);
         ArrayResize(_symbols, size + 1);
         ArrayResize(_symbolParsms, size + 1);
         _symbols[size] = "CAD";
         _symbolParsms[size] = 8;
      }
      _symbolsCount = ArraySize(_symbols);

      if (_verticalMode)
      {
         Iterator yIterator(_originalY, cell_height);
         Row *row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], _originalX + cell_width, yIterator.GetNext()));
         }
      }
      else
      {
         Iterator xIterator(_originalX - cell_width, -cell_width);
         Row *row = grid.AddRow();
         row.Add(new EmptyCell());
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_Name";
            row.Add(new LabelCell(id, _symbols[i], xIterator.GetNext(), _originalY - cell_height));
         }
      }
   }

   void AddTimeframe(const string label, const ENUM_TIMEFRAMES timeframe)
   {
      if (_verticalMode)
      {
         int x = _xIterator.GetNext();
         Row *row = grid.AddRow();
         row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, x, cell_height));
         Iterator yIterator(_originalY, cell_height);
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            row.Add(_cellFactory.Create(id, x, yIterator.GetNext(), _symbols[i], timeframe, _symbolParsms[i]));
         }
      }
      else
      {
         int y = _yIterator.GetNext();
         Row *row = grid.AddRow();
         row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, _originalX, y));
         Iterator xIterator(_originalX - cell_width, -cell_width);
         for (int i = 0; i < _symbolsCount; i++)
         {
            string id = IndicatorObjPrefix + _symbols[i] + "_" + label;
            row.Add(_cellFactory.Create(id, xIterator.GetNext(), y, _symbols[i], timeframe, _symbolParsms[i]));
         }
      }
   }

   Grid *Build()
   {
      return grid;
   }

private:
   void split(string& arr[], string str, string sym) 
   {
      ArrayResize(arr, 0);
      int len = StringLen(str);
      for (int i=0; i < len;)
      {
         int pos = StringFind(str, sym, i);
         if (pos == -1)
            pos = len;
   
         string item = StringSubstr(str, i, pos-i);
         item = StringTrimLeft(item);
         item = StringTrimRight(item);
   
         int size = ArraySize(arr);
         ArrayResize(arr, size+1);
         arr[size] = item;
   
         i = pos+1;
      }
   }
};
#endif

int init()
{
   double temp = iCustom(NULL, 0, "currency_strength", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'currency_strength' indicator");
      return INIT_FAILED;
   }

   IndicatorName = GenerateIndicatorName("Currenct Strength Dashboard");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   GridBuilder builder(x_shift, 50, display_mode == Vertical, new TextValueCellFactory());
   builder.SetSymbols("");

   if (Include_M1)
      builder.AddTimeframe("M1", PERIOD_M1);
   if (Include_M5)
      builder.AddTimeframe("M5", PERIOD_M5);
   if (Include_M15)
      builder.AddTimeframe("M15", PERIOD_M15);
   if (Include_M30)
      builder.AddTimeframe("M30", PERIOD_M30);
   if (Include_H1)
      builder.AddTimeframe("H1", PERIOD_H1);
   if (Include_H4)
      builder.AddTimeframe("H4", PERIOD_H4);
   if (Include_D1)
      builder.AddTimeframe("D1", PERIOD_D1);
   if (Include_W1)
      builder.AddTimeframe("W1", PERIOD_W1);
   if (Include_MN1)
      builder.AddTimeframe("MN1", PERIOD_MN1);

   grid = builder.Build();

   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete grid;
   grid = NULL;
   return 0;
}

int start()
{
   WindowNumber = MathMax(0, WindowFind(IndicatorName));
   grid.Draw();
   
   return 0;
}
