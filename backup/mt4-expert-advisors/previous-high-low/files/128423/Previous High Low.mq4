// Id: 26258
// More information about this indicator can be found at:
// http://fxcodebase.com/

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
#property strict

#property indicator_chart_window
#property indicator_buffers 0
#property indicator_color1 Red

input bool show_d1 = true; // Show daily
input bool show_w1 = true; // Show weekly
input bool show_mn1 = true; // Show monthly
input bool show_y1 = true; // Show yearly
input color color_d1 = Red; // Daily color
input color color_w1 = Green; // Weekly color
input color color_mn1 = Blue; // Monthly color
input color color_y1 = Yellow; // Yearly color
input int width_d1 = 1; // Daily thickness
input int width_w1 = 1; // Weekly thickness
input int width_mn1 = 1; // Monthly thickness
input int width_y1 = 1; // Yearly thickness
input color color_label = Gray; // Label color
input int font_size = 12; // Font size
input bool show_text = true; // Show text
input int line_length = 2; // Line length, bars

//Signaler v 1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates
extern string   AlertsSection            = ""; // == Alerts ==
extern bool     popup_alert              = false; // Popup message
extern bool     notification_alert       = false; // Push notification
extern bool     email_alert              = false; // Email
extern bool     play_sound               = false; // Play sound on alert
extern string   sound_file               = ""; // Sound file
extern bool     start_program            = false; // Start external program
extern string   program_path             = ""; // Path to the external program executable
extern bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
extern string   advanced_key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
extern string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   string _prefix;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   string GetSymbol()
   {
      return _symbol;
   }

   ENUM_TIMEFRAMES GetTimeframe()
   {
      return _timeframe;
   }

   string GetTimeframeStr()
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

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlert(advanced_key, message, symbol, timeframe);
   }
};

// int OnInit()
// {
//    if (!IsDllsAllowed() && advanced_alert)
//    {
//       Print("Error: Dll calls must be allowed!");
//       return INIT_FAILED;
//    }
// }

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

// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};

// Custom timeframe bar stream v1.0

// ACustomBarStream v1.0

interface IBarStream : public IStream
{
public:
   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close) = 0;

   virtual bool GetOpen(const int period, double &open) = 0;
   virtual bool GetHigh(const int period, double &high) = 0;
   virtual bool GetLow(const int period, double &low) = 0;
   virtual bool GetClose(const int period, double &close) = 0;
   
   virtual bool GetHighLow(const int period, double &high, double &low) = 0;

   virtual bool GetIsAscending(const int period, bool &res) = 0;

   virtual bool GetIsDescending(const int period, bool &res) = 0;

   virtual bool GetDate(const int period, datetime &dt) = 0;

   virtual int Size() = 0;

   virtual void Refresh() = 0;
};

#ifndef ACustomBarStream_IMP
#define ACustomBarStream_IMP

class ACustomBarStream : public IBarStream
{
protected:
   int _references;

   datetime _dates[];
   double _open[];
   double _close[];
   double _high[];
   double _low[];
   int _size;

   ACustomBarStream()
   {
      _size = 0;
      _references = 1;
   }
public:
   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }
   virtual bool GetValue(const int period, double &val)
   {
      if (period >= _size)
         return false;
      val = _close[_size - 1 - period];
      return true;
   }

   virtual bool GetDate(const int period, datetime &dt)
   {
      if (period >= _size)
         return false;
      dt = _dates[_size - 1 - period];
      return true;
   }

   virtual bool GetOpen(const int period, double &open)
   {
      if (_size <= period)
         return false;
      open = _open[_size - 1 - period];
      return true;
   }

   virtual bool GetHigh(const int period, double &high)
   {
      if (_size <= period)
         return false;
      high = _high[_size - 1 - period];
      return true;
   }

   virtual bool GetLow(const int period, double &low)
   {
      if (_size <= period)
         return false;
      low = _low[_size - 1 - period];
      return true;
   }

   virtual bool GetClose(const int period, double &close)
   {
      if (_size <= period)
         return false;
      close = _close[_size - 1 - period];
      return true;
   }

   virtual bool GetValues(const int period, double &open, double &high, double &low, double &close)
   {
      if (period >= _size)
         return false;
      high = _high[_size - 1 - period];
      low = _low[_size - 1 - period];
      open = _open[_size - 1 - period];
      close = _close[_size - 1 - period];
      return true;
   }

   virtual bool GetHighLow(const int period, double &high, double &low)
   {
      if (period >= _size)
         return false;
      high = _high[_size - 1 - period];
      low = _low[_size - 1 - period];
      return true;
   }

   virtual bool GetIsAscending(const int period, bool &res)
   {
      if (period >= _size)
         return false;
      res = _open[_size - 1 - period] < _close[_size - 1 - period];
      return true;
   }

   virtual bool GetIsDescending(const int period, bool &res)
   {
      if (period >= _size)
         return false;
      res = _open[_size - 1 - period] > _close[_size - 1 - period];
      return true;
   }

   virtual int Size()
   {
      return _size;
   }
};
#endif

#ifndef CustomTimeframeBarStream_IMP
#define CustomTimeframeBarStream_IMP

class CustomTimeframeBarStream : public ACustomBarStream
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   int _timeframeMult;
public:
   CustomTimeframeBarStream(const string symbol, const ENUM_TIMEFRAMES timeframe, int timeframeMult)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _timeframeMult = timeframeMult;
   }

   virtual void Refresh()
   {
      int start = iBars(_symbol, _timeframe) - 1;
      if (_size > 0)
         start = iBarShift(_symbol, _timeframe, _dates[_size - 1]);

      int periodLength = ((int)_timeframe * _timeframeMult * 60);
      for (int i = start; i >= 0; --i)
      {
         datetime barStart = (iTime(_symbol, _timeframe, i) / periodLength) * periodLength;
         if (_size == 0 || barStart != _dates[_size - 1])
         {
            ++_size;
            ArrayResize(_dates, _size);
            ArrayResize(_open, _size);
            ArrayResize(_high, _size);
            ArrayResize(_low, _size);
            ArrayResize(_close, _size);
            _dates[_size - 1] = barStart;
            _open[_size - 1] = iOpen(_symbol, _timeframe, i);
            _high[_size - 1] = iHigh(_symbol, _timeframe, i);
            _low[_size - 1] = iLow(_symbol, _timeframe, i);
         }
         else
         {
            _high[_size - 1] = MathMax(iHigh(_symbol, _timeframe, i), _high[_size - 1]);
            _low[_size - 1] = MathMin(iLow(_symbol, _timeframe, i), _low[_size - 1]);
         }
         _close[_size - 1] = iClose(_symbol, _timeframe, i);
      }
   }
};
#endif
CustomTimeframeBarStream* _stream;

int init()
{
   IndicatorName = GenerateIndicatorName("Previous High Low");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(0);

   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   signaler.SetMessagePrefix(_Symbol + ": ");
   _stream = new CustomTimeframeBarStream(_Symbol, PERIOD_MN1, 12);

   return 0;
}

int deinit()
{
   delete _stream;
   _stream = NULL;
   delete signaler;
   signaler = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

void DrawLine(string id, double value, color clr, int width, string label)
{
   datetime start_time = Time[0] + Time[0] - Time[1];
   datetime stop_time = Time[0] + Time[0] - Time[1 + line_length];
   ResetLastError();
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TREND, 0, start_time, value, stop_time, value))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
      ObjectSetInteger(0, id, OBJPROP_WIDTH, width);
      ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
   }
   ObjectSetInteger(0, id, OBJPROP_TIME1, start_time);
   ObjectSetInteger(0, id, OBJPROP_TIME2, stop_time);
   ObjectSetDouble(0, id, OBJPROP_PRICE1, value);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, value);
   
   ResetLastError();
   string labelId = id + "label";
   if (ObjectFind(0, labelId) == -1)
   {
      if (!ObjectCreate(0, labelId, OBJ_TEXT, 0, (start_time + stop_time) / 2, value))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetString(0, labelId, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, labelId, OBJPROP_FONTSIZE, font_size);
      ObjectSetInteger(0, labelId, OBJPROP_COLOR, color_label);
      ObjectSetInteger(0, labelId, OBJPROP_ANCHOR, ANCHOR_UPPER);
   }
   ObjectSetInteger(0, labelId, OBJPROP_TIME, (start_time + stop_time) / 2);
   ObjectSetDouble(0, labelId, OBJPROP_PRICE1, value);
   ObjectSetString(0, labelId, OBJPROP_TEXT, label);
}

datetime last_d1_h;
datetime last_d1_l;
datetime last_w1_h;
datetime last_w1_l;
datetime last_mn1_h;
datetime last_mn1_l;
datetime last_y1_h;
datetime last_y1_l;
Signaler* signaler;

int start()
{
   if (show_d1)
   {
      double high = iHigh(_Symbol, PERIOD_D1, 1);
      DrawLine(IndicatorObjPrefix + "hd1idValue", high, color_d1, width_d1, "PDH");
      if (Close[0] > high && Close[1] <= high && last_d1_h != Time[0])
      {
         last_d1_h = Time[0];
         signaler.SendNotifications("Price crossed over previous day high");
      }
      double low = iLow(_Symbol, PERIOD_D1, 1);
      DrawLine(IndicatorObjPrefix + "ld1idValue", low, color_d1, width_d1, "PDL");
      if (Close[0] < low && Close[1] >= low && last_d1_l != Time[0])
      {
         last_d1_l = Time[0];
         signaler.SendNotifications("Price crossed under previous day low");
      }
   }
   if (show_w1)
   {
      double high = iHigh(_Symbol, PERIOD_W1, 1);
      DrawLine(IndicatorObjPrefix + "hw1idValue", high, color_w1, width_w1, "PWH");
      if (Close[0] > high && Close[1] <= high && last_w1_h != Time[0])
      {
         last_w1_h = Time[0];
         signaler.SendNotifications("Price crossed over previous week high");
      }
      double low = iLow(_Symbol, PERIOD_W1, 1);
      DrawLine(IndicatorObjPrefix + "lw1idValue", low, color_w1, width_w1, "PWL");
      if (Close[0] < low && Close[1] >= low && last_w1_l != Time[0])
      {
         last_w1_l = Time[0];
         signaler.SendNotifications("Price crossed under previous week low");
      }
   }
   if (show_mn1)
   {
      double high = iHigh(_Symbol, PERIOD_MN1, 1);
      DrawLine(IndicatorObjPrefix + "hmn1idValue", high, color_mn1, width_mn1, "PMH");
      if (Close[0] > high && Close[1] <= high && last_mn1_h != Time[0])
      {
         last_mn1_h = Time[0];
         signaler.SendNotifications("Price crossed over previous month high");
      }
      double low = iLow(_Symbol, PERIOD_MN1, 1);
      DrawLine(IndicatorObjPrefix + "lmn1idValue", low, color_mn1, width_mn1, "PML");
      if (Close[0] < low && Close[1] >= low && last_mn1_l != Time[0])
      {
         last_mn1_l = Time[0];
         signaler.SendNotifications("Price crossed under previous month low");
      }
   }
   if (show_y1)
   {
      _stream.Refresh();
      double high, low;
      if (!_stream.GetHighLow(1, high, low))
         return 0;
      DrawLine(IndicatorObjPrefix + "hy1idValue", high, color_y1, width_y1, "PYH");
      if (Close[0] > high && Close[1] <= high && last_y1_h != Time[0])
      {
         last_y1_h = Time[0];
         signaler.SendNotifications("Price crossed over previous year high");
      }
      DrawLine(IndicatorObjPrefix + "ly1idValue", low, color_y1, width_y1, "PYL");
      if (Close[0] < low && Close[1] >= low && last_y1_l != Time[0])
      {
         last_y1_l = Time[0];
         signaler.SendNotifications("Price crossed under previous year low");
      }
   }
   return 0;
}