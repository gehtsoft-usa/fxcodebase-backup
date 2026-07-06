// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66875

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

// Dashboard with alerts v.1.1

//basically you need:
string   WindowName = "ADX DMI Screener";

#property indicator_separate_window
#property strict

extern int ADXLength = 10; // ADX length
extern int ADXLevel = 20; // ADX Level
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
//Signaler v 1.2.1
extern bool     Popup_Alert              = true; // Popup message
extern bool     Notification_Alert       = false; // Push notification
extern bool     Email_Alert              = false; // Email
extern bool     Play_Sound               = false; // Play sound on alert
extern string   Sound_File               = ""; // Sound file
extern bool     Advanced_Alert           = false; // Advanced alert
extern string   Advanced_Key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a advanced alert key by starting a dialog with @profit_robots_bot Telegram bot -";
extern string   Comment3                 = "- Also, you need to install AdvancedNotificationsLib.dll and allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Make sure that Microsoft .NET Framework 4.6 is installed on your PC -";

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
   { 
      ObjectDelete(IndicatorObjPrefix + nm); 
      ObjectCreate(IndicatorObjPrefix + nm, OBJ_LABEL, Window, 0, 0); 
      ObjectSet(IndicatorObjPrefix + nm, OBJPROP_CORNER, LabelCorner); 
      ObjectSet(IndicatorObjPrefix + nm, OBJPROP_XDISTANCE, xoff); 
      ObjectSet(IndicatorObjPrefix + nm, OBJPROP_YDISTANCE, yoff); 
      ObjectSet(IndicatorObjPrefix + nm, OBJPROP_BACK, false); 
      ObjectSetText(IndicatorObjPrefix + nm, LabelTexto, FSize, Font, LabelColor); 
   }
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

#define UNDER_LEVEL 1

class ValueCell : public ICell
{
   string _id; int _x; int _y; string _symbol; int _timeframe; datetime _lastDatetime;
public:
   ValueCell(const string id, const int x, const int y, const string symbol, const int timeframe)
   { _id = id; _x = x; _y = y; _symbol = symbol; _timeframe = timeframe; }
   virtual void Draw()
   { int direction = GetDirection(); SendNotifications(direction); ObjectMakeLabel(_id, _x, _y, GetDirectionSymbol(direction), GetDirectionColor(direction), 1, WindowNumber, "Arial", 10); }

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

   void SendNotifications(const int direction)
   {
      if (direction == 0 || IsTesting())
         return;

      datetime currentTime = iTime(_Symbol, _Period, 0);
      if (_lastDatetime == currentTime)
         return;

      _lastDatetime = currentTime;
      string tf = GetTimeframe();
      string alert_Subject;
      string alert_Body;
      switch (direction)
      {
         case UNDER_LEVEL:
            alert_Subject = "ADX DMI crossed under level for " + _Symbol + "/" + tf;
            alert_Body = "ADX DMI crossed under level for " + _Symbol + "/" + tf;
            break;
      }
      SendNotifications(alert_Subject, alert_Body, _Symbol, tf);
   }

   void SendNotifications(const string subject, const string message, const string symbol, const string timeframe)
   {
      if (Popup_Alert)
         Alert(message);
      if (Email_Alert)
         SendMail(subject, message);
      if (Play_Sound)
         PlaySound(Sound_File);
      if (Notification_Alert)
         SendNotification(message);
      if (Advanced_Alert && Advanced_Key != "")
         AdvancedAlert(Advanced_Key, message, symbol, timeframe);
   }

   bool BuySignal(const int period)
   {
      double adx = iADX(_symbol, _timeframe, ADXLength, PRICE_CLOSE, MODE_MAIN, period);
      double minusDi = iADX(_symbol, _timeframe, ADXLength, PRICE_CLOSE, MODE_MINUSDI, period);
      double plusDi = iADX(_symbol, _timeframe, ADXLength, PRICE_CLOSE, MODE_PLUSDI, period);
      return ADXLevel >= adx && ADXLevel >= minusDi && ADXLevel >= plusDi;
   }

   int GetDirection()
   {
      if (BuySignal(0) && !BuySignal(1))
         return UNDER_LEVEL;
      return 0;
   }

   color GetDirectionColor(const int direction) { if (direction >= 1) { return Up_Color; } else if (direction <= -1) { return Dn_Color; } return Neutral_Color; }
   string GetDirectionSymbol(const int direction)
   {
      if (direction == UNDER_LEVEL)
      {
         return "UNDER";
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
string IndicatorObjPostfix;

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
   IndicatorObjPostfix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

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
      rows[0].Add(new LabelCell(sym_arr[i] + "_Name" + IndicatorObjPostfix, sym_arr[i], Original_x + 80, yIterator.GetNext()));
   }

   int currentCell = 1;
   Iterator xIterator(Original_x, -120);
   if (Include_M1)
   {
      int m1_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell("M1_Label" + IndicatorObjPostfix, "M1", m1_x, 20));
      Iterator ym1Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(sym_arr[i] + "_M1" + IndicatorObjPostfix, m1_x, ym1Iterator.GetNext(), sym_arr[i], PERIOD_M1));
      }
   }
   if (Include_M5)
   {
      int m5_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell("M5_Label" + IndicatorObjPostfix, "M5", m5_x, 20));
      Iterator ym5Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(sym_arr[i] + "_M5" + IndicatorObjPostfix, m5_x, ym5Iterator.GetNext(), sym_arr[i], PERIOD_M5));
      }
   }
   if (Include_M15)
   {
      int m15_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell("M15_Label" + IndicatorObjPostfix, "M15", m15_x, 20));
      Iterator ym15Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(sym_arr[i] + "_M15" + IndicatorObjPostfix, m15_x, ym15Iterator.GetNext(), sym_arr[i], PERIOD_M15));
      }
   }
   if (Include_M30)
   {
      int m30_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell("M30_Label" + IndicatorObjPostfix, "M30", m30_x, 20));
      Iterator ym30Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(sym_arr[i] + "_M30" + IndicatorObjPostfix, m30_x, ym30Iterator.GetNext(), sym_arr[i], PERIOD_M30));
      }
   }
   if (Include_H1)
   {
      int h1_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell("H1_Label" + IndicatorObjPostfix, "H1", h1_x, 20));
      Iterator yH1Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(sym_arr[i] + "_H1" + IndicatorObjPostfix, h1_x, yH1Iterator.GetNext(), sym_arr[i], PERIOD_H1));
      }
   }
   if (Include_H4)
   {
      int h4_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell("H4_Label" + IndicatorObjPostfix, "H4", h4_x, 20));
      Iterator yH4Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(sym_arr[i] + "_H4" + IndicatorObjPostfix, h4_x, yH4Iterator.GetNext(), sym_arr[i], PERIOD_H4));
      }
   }
   if (Include_D1)
   {
      int d1_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell("D1_Label" + IndicatorObjPostfix, "D1", d1_x, 20));
      Iterator yD1Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(sym_arr[i] + "_D1" + IndicatorObjPostfix, d1_x, yD1Iterator.GetNext(), sym_arr[i], PERIOD_D1));
      }
   }
   if (Include_W1)
   {
      int w1_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell("W1_Label" + IndicatorObjPostfix, "W1", w1_x, 20));
      Iterator yW1Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(sym_arr[i] + "_W1" + IndicatorObjPostfix, w1_x, yW1Iterator.GetNext(), sym_arr[i], PERIOD_W1));
      }
   }
   if (Include_MN1)
   {
      int mn1_x = xIterator.GetNext();
      rows[currentCell++].Add(new LabelCell("MN1_Label" + IndicatorObjPostfix, "MN1", mn1_x, 20));
      Iterator yMN1Iterator(50, 30);
      for (int i = 0; i < sym_count; i++)
      {
         rows[currentCell - 1].Add(new ValueCell(sym_arr[i] + "_MN1" + IndicatorObjPostfix, mn1_x, yMN1Iterator.GetNext(), sym_arr[i], PERIOD_MN1));
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