// Id: 23809
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67304

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

enum CurrencyPairs{ USD=1,  EUR=2, GBP=3,JPY=4, CHF=5,  AUD=6, NZD=7, CAD=8, ANY= 9};

extern int Length = 20;
extern color    Labels_Color             = clrWhite;
input int x_shift = 1000; // X coordinate
input int font_size = 10; // Font Size;
input int cell_width = 120; // Cell width
input int cell_height = 30; // Cell height

string   WindowName;
int      WindowNumber;

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

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1
#define EXIT_BUY_SIGNAL 2
#define EXIT_SELL_SIGNAL -2
class ValueCell : public ICell
{
   string _id; int _x; int _y; string _symbol; int _timeframe; datetime _lastDatetime;
   CurrencyPairs _mode;
public:
   ValueCell(const string id, const int x, const int y, const string symbol, const int timeframe, const CurrencyPairs mode)
   { _id = id; _x = x; _y = y; _symbol = symbol; _timeframe = timeframe; _mode = mode; }
   virtual void Draw()
   { ObjectMakeLabel(_id, _x, _y, GetValue(), Labels_Color, 1, WindowNumber, "Arial", 10); }

private:
   string GetTimeframe()
   {
      switch (_timeframe)
      {
         case PERIOD_M1: return "M1";
         case PERIOD_M5: return "M5";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H4: return "H4";
         case PERIOD_M15: return "M15";
         case PERIOD_M30: return "M30";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }

   string GetValue()
   {
      double value = iCustom(_Symbol, _Period, "Beta Coefficient", Length, _mode, 0, 0);
      return DoubleToStr(value);
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
   CurrencyPairs modes[];
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

   void Init()
   {
      Iterator yIterator(50, cell_height);
      Row *row = grid.AddRow();
      row.Add(new EmptyCell());
      sym_count = 9;
      ArrayResize(sym_arr, sym_count);
      ArrayResize(modes, sym_count);
      sym_arr[0] = "USD";
      sym_arr[1] = "EUR";
      sym_arr[2] = "GBP";
      sym_arr[3] = "JPY";
      sym_arr[4] = "CHF";
      sym_arr[5] = "AUD";
      sym_arr[6] = "NZD";
      sym_arr[7] = "CAD";
      sym_arr[8] = "ANY";
      modes[0] = USD;
      modes[1] = EUR;
      modes[2] = GBP;
      modes[3] = JPY;
      modes[4] = CHF;
      modes[5] = AUD;
      modes[6] = NZD;
      modes[7] = CAD;
      modes[8] = ANY;

      for (int i = 0; i < sym_count; i++)
      {
         row.Add(new LabelCell(IndicatorObjPrefix + sym_arr[i] + "_Name", sym_arr[i], Original_x + 80, yIterator.GetNext()));
      }
   }

   void AddTimeframe(const string label, const ENUM_TIMEFRAMES timeframe)
   {
      int x = xIterator.GetNext();
      Row *row = grid.AddRow();
      row.Add(new LabelCell(IndicatorObjPrefix + label + "_Label", label, x, 20));
      Iterator yIterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         row.Add(new ValueCell(IndicatorObjPrefix + sym_arr[i] + "_" + label, x, yIterator.GetNext(), sym_arr[i], timeframe, modes[i]));
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
   IndicatorName = GenerateIndicatorName("Beta Coefficient List");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   GridBuilder builder(x_shift);
   builder.Init();

   builder.AddTimeframe("Value", PERIOD_CURRENT);

   grid = builder.Build();
   
   double temp = iCustom(NULL, 0, "Beta Coefficient", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Beta Coefficient' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=67304");
      return INIT_FAILED;
   }

   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   delete grid;
   return 0;
}

int start()
{
   WindowNumber = WindowFind(IndicatorName);
   grid.Draw();
   
   return 0;
}
