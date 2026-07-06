// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67207

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

// Dashboard with alerts v.1.3

string   WindowName = "Fast n Smooth MA Dashboard";

#property indicator_separate_window
#property strict

extern int Price = 0; // Price
extern int MA_Period = 21; // MA period
extern string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
extern bool     Include_M1               = true;
extern bool     Include_M5               = true;
extern bool     Include_M15              = true;
extern bool     Include_M30              = true;
extern bool     Include_H1               = true;
extern bool     Include_H4               = true;
extern bool     Include_D1               = true;
extern bool     Include_W1               = true;
extern bool     Include_MN1              = true;
extern color    Labels_Color             = clrWhite;
extern color    Up_Color                 = clrLime;
extern color    Dn_Color                 = clrRed;
extern color    Neutral_Color            = clrDarkGray;

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
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
   virtual void Draw() { ObjectMakeLabel(_id, _x, _y, _text, Labels_Color, 1, WindowNumber, "Arial", 12); }
};

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1
#define EXIT_BUY_SIGNAL 2
#define EXIT_SELL_SIGNAL -2

class ValueCell : public ICell
{
   string _id; int _x; int _y; string _symbol; int _timeframe; datetime _lastDatetime;
public:
   ValueCell(const string id, const int x, const int y, const string symbol, const int timeframe)
   { _id = id; _x = x; _y = y; _symbol = symbol; _timeframe = timeframe; }
   virtual void Draw()
   { int direction = GetDirection(); ObjectMakeLabel(_id, _x, _y, GetDirectionSymbol(direction), GetDirectionColor(direction), 1, WindowNumber, "Arial", 10); }

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
   
   int GetDirection()
   {
      double uptrend = iCustom(_symbol, _timeframe, "Market/Fast n Smooth MA", Price, MA_Period, 1, 0);
      if (uptrend != EMPTY_VALUE)
         return ENTER_BUY_SIGNAL;
      double downtrend = iCustom(_symbol, _timeframe, "Market/Fast n Smooth MA", Price, MA_Period, 2, 0);
      if (downtrend != EMPTY_VALUE)
         return ENTER_SELL_SIGNAL;
      return 0;
   }

   color GetDirectionColor(const int direction) { if (direction >= 1) { return Up_Color; } else if (direction <= -1) { return Dn_Color; } return Neutral_Color; }
   string GetDirectionSymbol(const int direction)
   {
      if (direction == ENTER_BUY_SIGNAL)
      {
         return "BUY";
      }
      else if (direction == ENTER_SELL_SIGNAL)
      {
         return "SELL";
      }
      if (direction == EXIT_BUY_SIGNAL)
      {
         return "EXIT BUY";
      }
      else if (direction == EXIT_SELL_SIGNAL)
      {
         return "EXIT SELL";
      }
      return "-";
   }
};

Row *rows[];

int GetTimeframesCount()
{
   int count = 0;
   if (Include_M1) count++;
   if (Include_M5) count++;
   if (Include_M15) count++;
   if (Include_M30) count++;
   if (Include_H1) count++;
   if (Include_H4) count++;
   if (Include_D1) count++;
   if (Include_W1) count++;
   if (Include_MN1) count++;
   return count;
}

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

int init()
{
   IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   double temp = iCustom(NULL, 0, "Market/Fast n Smooth MA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Fast n Smooth MA' indicator");
      return INIT_FAILED;
   }

   int Original_x = 1000;
   string sym_arr[];
   split(sym_arr, Pairs, ",");
   int sym_count = ArraySize(sym_arr);

   int timeframes_count = GetTimeframesCount();
   ArrayResize(rows, timeframes_count + 1);
   for (int i = 0; i <= timeframes_count; ++i)
   {
      rows[i] = new Row();
   }
   rows[0].Add(new EmptyCell());
   Iterator yIterator(50, 30);
   for (int i = 0; i < sym_count; i++)
   {
      rows[0].Add(new LabelCell(IndicatorObjPrefix + sym_arr[i] + "_Name", sym_arr[i], Original_x + 80, yIterator.GetNext()));
   }

   int currentCell = 1;
   Iterator xIterator(Original_x, -120);
   if (Include_M1)
   {
      int m1_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell(IndicatorObjPrefix + "M1_Label", "M1", m1_x, 20));
      Iterator ym1Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(IndicatorObjPrefix + sym_arr[i] + "_M1", m1_x, ym1Iterator.GetNext(), sym_arr[i], PERIOD_M1));
      }
   }
   if (Include_M5)
   {
      int m5_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell(IndicatorObjPrefix + "M5_Label", "M5", m5_x, 20));
      Iterator ym5Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(IndicatorObjPrefix + sym_arr[i] + "_M5", m5_x, ym5Iterator.GetNext(), sym_arr[i], PERIOD_M5));
      }
   }
   if (Include_M15)
   {
      int m15_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell(IndicatorObjPrefix + "M15_Label", "M15", m15_x, 20));
      Iterator ym15Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(IndicatorObjPrefix + sym_arr[i] + "_M15", m15_x, ym15Iterator.GetNext(), sym_arr[i], PERIOD_M15));
      }
   }
   if (Include_M30)
   {
      int m30_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell(IndicatorObjPrefix + "M30_Label", "M30", m30_x, 20));
      Iterator ym30Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(IndicatorObjPrefix + sym_arr[i] + "_M30", m30_x, ym30Iterator.GetNext(), sym_arr[i], PERIOD_M30));
      }
   }
   if (Include_H1)
   {
      int h1_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell(IndicatorObjPrefix + "H1_Label", "H1", h1_x, 20));
      Iterator yH1Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(IndicatorObjPrefix + sym_arr[i] + "_H1", h1_x, yH1Iterator.GetNext(), sym_arr[i], PERIOD_H1));
      }
   }
   if (Include_H4)
   {
      int h4_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell(IndicatorObjPrefix + "H4_Label", "H4", h4_x, 20));
      Iterator yH4Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(IndicatorObjPrefix + sym_arr[i] + "_H4", h4_x, yH4Iterator.GetNext(), sym_arr[i], PERIOD_H4));
      }
   }
   if (Include_D1)
   {
      int d1_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell(IndicatorObjPrefix + "D1_Label", "D1", d1_x, 20));
      Iterator yD1Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(IndicatorObjPrefix + sym_arr[i] + "_D1", d1_x, yD1Iterator.GetNext(), sym_arr[i], PERIOD_D1));
      }
   }
   if (Include_W1)
   {
      int w1_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell(IndicatorObjPrefix + "W1_Label", "W1", w1_x, 20));
      Iterator yW1Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(IndicatorObjPrefix + sym_arr[i] + "_W1", w1_x, yW1Iterator.GetNext(), sym_arr[i], PERIOD_W1));
      }
   }
   if (Include_MN1)
   {
      int mn1_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell(IndicatorObjPrefix + "MN1_Label", "MN1", mn1_x, 20));
      Iterator yMN1Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(IndicatorObjPrefix + sym_arr[i] + "_MN1", mn1_x, yMN1Iterator.GetNext(), sym_arr[i], PERIOD_MN1));
      }
   }

   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   int i_count = ArraySize(rows);
   for (int i = 0; i < i_count; ++i)
   {
      delete rows[i];
   }
   return(0);
}

int start()
{
   WindowNumber = WindowFind(IndicatorName);
   int i_count = ArraySize(rows);
   for (int i = 0; i < i_count; ++i)
   {
      rows[i].Draw();
   }

   return(0);
}

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