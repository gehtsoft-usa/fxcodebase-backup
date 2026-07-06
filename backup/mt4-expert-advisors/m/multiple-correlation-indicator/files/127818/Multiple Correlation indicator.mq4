// Id:  
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68695

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
#property version   "1.1"
#property strict

#property indicator_separate_window

input int correlation_period = 100; // Correlation period
input string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
input string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
input color    Labels_Color             = clrWhite; // Labels color
input int highlight_threshold = 90; // Highligh if greater than
input color    Highlight_color             = Red; // Highlight color
input int x_shift = 1000; // X coordinate
input int font_size = 10; // Font size
input int cell_width = 120; // Cell width
input int cell_height = 30; // Cell height

string   WindowName;
int      WindowNumber;

// ICondition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface ICondition
{
public:
   virtual bool IsPass(const int period) = 0;
};

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

// ABaseCondition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

class ABaseCondition : public ICondition
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

// Dashboard v.1.2
class Iterator
{
   int _initialValue; int _shift; int _current;
public:
   Iterator(int initialValue, int shift) { _initialValue = initialValue; _shift = shift; _current = _initialValue - _shift; }
   int GetNext() { _current += _shift; return _current; }
};

class ICell
{
public:
   virtual void Draw() = 0;
protected:
   void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 )
   { ObjectDelete(nm); ObjectCreate(nm, OBJ_LABEL, Window, 0, 0); ObjectSet(nm, OBJPROP_CORNER, LabelCorner); ObjectSet(nm, OBJPROP_XDISTANCE, xoff); ObjectSet(nm, OBJPROP_YDISTANCE, yoff); ObjectSet(nm, OBJPROP_BACK, false); ObjectSetText(nm, LabelTexto, FSize, Font, LabelColor); }
};

class Row
{
   ICell *_cells[];
public:
   ~Row() { int count = ArraySize(_cells); for (int i = 0; i < count; ++i) { delete _cells[i]; } }
   void Draw() { int count = ArraySize(_cells); for (int i = 0; i < count; ++i) { _cells[i].Draw(); } }
   void Add(ICell *cell) { int count = ArraySize(_cells); ArrayResize(_cells, count + 1); _cells[count] = cell; } 
};

//draws nothing
class EmptyCell : public ICell
{
public:
   virtual void Draw() { }
};

//draws a label
class LabelCell : public ICell
{
   string _id; string _text; int _x; int _y;
public:
   LabelCell(const string id, const string text, const int x, const int y) { _id = id; _text = text; _x = x; _y = y; } 
   virtual void Draw() { ObjectMakeLabel(_id, _x, _y, _text, Labels_Color, 1, WindowNumber, "Arial", font_size); }
};

class TrendValueCell : public ICell
{
   string _id; int _x; int _y; 
   string _symbol1; 
   string _symbol2; 
   ENUM_TIMEFRAMES _timeframe; datetime _lastDatetime;
public:
   TrendValueCell(const string id, const int x, const int y, const string symbol1, const string symbol2, const ENUM_TIMEFRAMES timeframe)
   { 
      _id = id; 
      _x = x; 
      _y = y; 
      _symbol1 = symbol1;
      _symbol2 = symbol2;
      _timeframe = timeframe; 
   }

   virtual void Draw()
   {
      double summXY = 0;
      double summX = 0;
      double summY = 0;
      double summX2 = 0;
      double summY2 = 0;
      int n = 0;
      for (int i = 0; i < correlation_period; ++i)
      {
         datetime dt = iTime(_symbol1, _timeframe, i);
         int index = iBarShift(_symbol2, _timeframe, dt);
         if (index < 0)
            continue;
         ++n;
         double x = iClose(_symbol1, _timeframe, i);
         double y = iClose(_symbol2, _timeframe, index);
         summXY += x * y;
         summX += x;
         summY += y;
         summX2 += x * x;
         summY2 += y * y;
      }
      double correlation = (n * summXY - summX * summY) / MathSqrt(MathAbs((n * summX2 - summX * summX) * (n * summY2 - summY * summY)));
      bool highlight = correlation > highlight_threshold / 100.0;
      ObjectMakeLabel(_id, _x, _y, DoubleToString(correlation, 1), highlight ? Highlight_color : Labels_Color, 1, WindowNumber, "Arial", font_size); 
   }
};

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

Grid *grid;

class GridBuilder
{
   string sym_arr[];
   int sym_count;
   Grid *grid;
   int Original_x;
   Iterator xIterator;
public:
   GridBuilder(int x)
      :xIterator(x, -cell_width)
   {
      Original_x = x;
      grid = new Grid();
   }

   void SetSymbols(const string symbols)
   {
      split(sym_arr, symbols, ",");
      sym_count = ArraySize(sym_arr);

      Iterator yIterator(50, cell_height);
      Row *mainRow = grid.AddRow();
      mainRow.Add(new EmptyCell());
      for (int i = 0; i < sym_count; i++)
      {
         mainRow.Add(new LabelCell(IndicatorObjPrefix + sym_arr[i] + "_Name", sym_arr[i], Original_x + 80, yIterator.GetNext()));
         
         int x = xIterator.GetNext();
         Row* row = grid.AddRow();
         row.Add(new LabelCell(IndicatorObjPrefix + sym_arr[i] + "_Label", sym_arr[i], x, 20));
         Iterator yIterator2(50, cell_height);
         for (int ii = 0; ii < sym_count; ii++)
         {
            row.Add(new TrendValueCell(IndicatorObjPrefix + sym_arr[i] + "_" + sym_arr[ii], x, yIterator2.GetNext(), sym_arr[i], sym_arr[ii], (ENUM_TIMEFRAMES)_Period));
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

int init()
{
   IndicatorName = GenerateIndicatorName("Multiple Correlation Indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   GridBuilder builder(x_shift);
   builder.SetSymbols(Pairs);
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
   WindowNumber = WindowFind(IndicatorName);
   grid.Draw();
   
   return 0;
}
