// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68994

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
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 11
#property indicator_color1  Silver
#property indicator_color2  Lime
#property indicator_color3  Red
#property indicator_width2  2
#property indicator_width3  2

extern int TrixPeriod = 4;

double stcBuffer[];
double Upper[];
double Lower[];
double trix_buffer3[];
double cdBuffer[];
double fastKBuffer[];
double fastDBuffer[];
double fastKKBuffer[];


double trix_buffer1[];
double trix_buffer2[];

enum SingalMode
{
   SingalModeLive, // Live
   SingalModeOnBarClose // On bar close
};

enum DisplayType
{
   Arrows, // Arrows
   Candles // Candles Color
};
input SingalMode signal_mode = SingalModeLive; // Signal mode
input DisplayType Type = Arrows; // Presentation Type
input double shift_arrows_pips = 0.1; // Shift arrows
input color up_color = Green; // Up color
input color down_color = Red; // Down color

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

// ABaseCondition v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef ABaseCondition_IMP
#define ABaseCondition_IMP
// Abstract condition v1.0

// ICondition v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface ICondition
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   virtual bool IsPass(const int period) = 0;
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
// Custom stream v1.0

#ifndef CustomStream_IMP
#define CustomStream_IMP

// Abstract stream v1.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AStream_IMP
// Stream v.2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

interface IStream
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;

   virtual bool GetValue(const int period, double &val) = 0;
};


class AStream : public IStream
{
protected:
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   double _shift;
   InstrumentInfo *_instrument;
   int _references;

   AStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
   {
      _references = 1;
      _shift = 0.0;
      _symbol = symbol;
      _timeframe = timeframe;
      _instrument = new InstrumentInfo(_symbol);
   }

   ~AStream()
   {
      delete _instrument;
   }
public:
   void SetShift(const double shift)
   {
      _shift = shift;
   }

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
};
#define AStream_IMP
#endif

class CustomStream : public AStream
{
public:
   double _stream[];

   CustomStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   int RegisterStream(int id, color clr, int width, ENUM_LINE_STYLE style, string name)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_LINE, style, width, clr);
      SetIndexLabel(id, name);
      return id + 1;
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id, _stream);
      SetIndexStyle(id, DRAW_NONE);
      return id + 1;
   }

   bool GetValue(const int period, double &val)
   {
      val = _stream[period];
      return _stream[period] != EMPTY_VALUE;
   }
};

#endif
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
// Alert signal v.2.2
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef AlertSignal_IMP
#define AlertSignal_IMP

// Candles stream v.1.2
class CandleStreams
{
public:
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
   }

   int RegisterStreams(const int id, const color clr)
   {
      SetIndexStyle(id + 0, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 0, OpenStream);
      SetIndexLabel(id + 0, "Open");
      SetIndexStyle(id + 1, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 1, CloseStream);
      SetIndexLabel(id + 1, "Close");
      SetIndexStyle(id + 2, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 2, HighStream);
      SetIndexLabel(id + 2, "High");
      SetIndexStyle(id + 3, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 3, LowStream);
      SetIndexLabel(id + 3, "Low");
      return id + 4;
   }

   void AddTick(const int index, const double val)
   {
      if (OpenStream[index] == EMPTY_VALUE)
      {
         Set(index, val, val, val, val);
         return;
      }
      HighStream[index] = MathMax(HighStream[index], val);
      LowStream[index] = MathMin(LowStream[index], val);
      CloseStream[index] = val;
   }

   void Set(const int index, const double open, const double high, const double low, const double close)
   {
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
   }
};

class AlertSignal
{
   double _signals[];
   ICondition* _condition;
   IStream* _price;
   Signaler* _signaler;
   string _message;
   datetime _lastSignal;
   CandleStreams* _candleStreams;
   bool _onBarClose;
public:
   AlertSignal(ICondition* condition, Signaler* signaler, bool onBarClose = false)
   {
      _condition = condition;
      _price = NULL;
      _candleStreams = NULL;
      _signaler = signaler;
      _onBarClose = onBarClose;
   }

   ~AlertSignal()
   {
      if (_price != NULL)
         _price.Release();
      if (_candleStreams != NULL)
         delete _candleStreams;
      delete _condition;
   }

   int RegisterStreams(int id, string name, int code, color clr, IStream* price)
   {
      _message = name;
      _price = price;
      _price.AddRef();
      SetIndexStyle(id + 0, DRAW_ARROW, 0, 2, clr);
      SetIndexBuffer(id + 0, _signals);
      SetIndexLabel(id + 0, name);
      SetIndexArrow(id + 0, code);
      
      return id + 1;
   }

   int RegisterStreams(int id, string name, color clr)
   {
      _message = name;
      _candleStreams = new CandleStreams();
      return _candleStreams.RegisterStreams(id, clr);
   }

   void Update(int period)
   {
      if (!_condition.IsPass(_onBarClose ? period + 1 : period))
      {
         if (_candleStreams != NULL)
            _candleStreams.Clear(period);
         else
            _signals[period] = EMPTY_VALUE;
         return;
      }

      if (period == 0)
      {
         string symbol = _signaler.GetSymbol();
         datetime dt = iTime(symbol, _signaler.GetTimeframe(), 0);
         if (_lastSignal != dt)
         {
            _signaler.SendNotifications(symbol + "/" + _signaler.GetTimeframeStr() + ": " + _message);
            _lastSignal = dt;
         }
      }

      if (_candleStreams != NULL)
      {
         _candleStreams.Set(period, Open[period], High[period], Low[period], Close[period]);
         return;
      }
      double price;
      if (!_price.GetValue(period, price))
         return;

      _signals[period] = price;
   }
};

#endif


AlertSignal* conditions[];
CustomStream* upStream;
CustomStream* downStream;
Signaler* mainSignaler;

int CreateAlert(int id, ICondition* upCondition, ICondition* downCondition)
{
   int size = ArraySize(conditions);
   ArrayResize(conditions, size + 2);
   conditions[size] = new AlertSignal(upCondition, mainSignaler, signal_mode == SingalModeOnBarClose);
   conditions[size + 1] = new AlertSignal(downCondition, mainSignaler, signal_mode == SingalModeOnBarClose);
      
   if (Type == Arrows)
   {
      id = conditions[size].RegisterStreams(id, "Up", 217, up_color, upStream);
      id = conditions[size + 1].RegisterStreams(id, "Down", 218, down_color, downStream);
   }
   else
   {
      id = conditions[size].RegisterStreams(id, "Up", up_color);
      id = conditions[size + 1].RegisterStreams(id, "Down", down_color);
   }
   return id;
}

class UpAlertCondition : public ABaseCondition
{
public:
   UpAlertCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      return Upper[period + 1] != EMPTY_VALUE && Upper[period + 2] == EMPTY_VALUE;
   }
};

class DownAlertCondition : public ABaseCondition
{
public:
   DownAlertCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ABaseCondition(symbol, timeframe)
   {

   }

   bool IsPass(const int period)
   {
      return Lower[period + 1] != EMPTY_VALUE && Lower[period + 2] == EMPTY_VALUE;
   }
};

int init()
{
   IndicatorBuffers(19);
   SetIndexBuffer(0,stcBuffer);
   SetIndexBuffer(1,Upper);
   SetIndexBuffer(2,Lower);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_LINE, STYLE_SOLID, 2);
   SetIndexStyle(2,DRAW_LINE, STYLE_SOLID, 2);

   SetIndexBuffer(11,trix_buffer3);
   SetIndexBuffer(12,cdBuffer);
   SetIndexBuffer(13,fastKBuffer);
   SetIndexBuffer(14,fastDBuffer);
   SetIndexBuffer(15,fastKKBuffer);
   
   ArraySetAsSeries(trix_buffer1,true);
   ArraySetAsSeries(trix_buffer2,true);
   
   int index = Bars;
   ArrayResize(trix_buffer1,index);
   ArrayResize(trix_buffer2,index);
   upStream = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   downStream = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);

   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("Trix TC1");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   mainSignaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");

   int id = 3;

   ICondition* upCondition = new UpAlertCondition(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ICondition* downCondition = new DownAlertCondition(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = CreateAlert(id, upCondition, downCondition);

   id = upStream.RegisterInternalStream(id);
   id = downStream.RegisterInternalStream(id);

   return(0);
}

int deinit()
{
   upStream.Release();
   upStream = NULL;
   downStream.Release();
   downStream = NULL;
   delete mainSignaler;
   mainSignaler = NULL;
   for (int i = 0; i < ArraySize(conditions); ++i)
   {
      delete conditions[i];
   }
   ArrayResize(conditions, 0);
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   double alphaCD      = 2.0 / (1.0 + 3.0);
   int    counted_bars = IndicatorCounted();
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 6;

   for(int i=0; i<limit; i++) 
      trix_buffer1[i]=iMA(NULL,0,TrixPeriod,0,MODE_SMMA,(PRICE_CLOSE+PRICE_HIGH+PRICE_LOW),i);
   for(int i=0; i<limit; i++) 
      trix_buffer2[i]=iMAOnArray(trix_buffer1,0,TrixPeriod,0,MODE_SMMA,i);
   for(int i=0; i<limit; i++) 
      trix_buffer3[i]=iMAOnArray(trix_buffer2,0,TrixPeriod,0,MODE_EMA,i);
  
   Comment(trix_buffer3[0]);
   
   for(int i = limit; i >= 0; i--)
   {
      upStream._stream[i] = 100;
      downStream._stream[i] = 0;
      cdBuffer[i]   = cdBuffer[i+1]+alphaCD*(trix_buffer3[i]-trix_buffer3[i+1]);

      double lowCd  = minValue(cdBuffer,i);
      double highCd = maxValue(cdBuffer,i)-lowCd;
      if (highCd > 0)
         fastKBuffer[i] = 100 * ((cdBuffer[i]-lowCd)/highCd);
      else  
         fastKBuffer[i] = fastKBuffer[i + 1];
      fastDBuffer[i] = fastDBuffer[i + 1] + 0.5 * (fastKBuffer[i] - fastDBuffer[i + 1]);
                     
      double lowStoch  = minValue(fastDBuffer, i);
      double highStoch = maxValue(fastDBuffer, i) - lowStoch;
      if (highStoch > 0)
         fastKKBuffer[i] = 100 * ((fastDBuffer[i] - lowStoch) / highStoch);
      else  
         fastKKBuffer[i] = fastKKBuffer[i+1];
      stcBuffer[i]    = stcBuffer[i+1]+0.5*(fastKKBuffer[i] - stcBuffer[i + 1]);
   
      if (stcBuffer[i] > stcBuffer[i+1]) 
      { 
         Upper[i] = stcBuffer[i]; 
         Upper[i+1] = stcBuffer[i+1]; 
      }
      else if (stcBuffer[i] < stcBuffer[i+1])
      { 
         Lower[i] = stcBuffer[i];
         Lower[i+1] = stcBuffer[i+1];
      }
      else if (stcBuffer[i] == stcBuffer[i+1] && Lower[i+1]!=EMPTY_VALUE && Upper[i+1]==EMPTY_VALUE)
         Lower[i] = Lower[i+1];
      else if (stcBuffer[i] == stcBuffer[i+1] && Upper[i+1]!=EMPTY_VALUE && Lower[i+1]==EMPTY_VALUE)
         Upper[i] = Upper[i+1];

      for (int ii = 0; ii < ArraySize(conditions); ++ii)
      {
         AlertSignal* item = conditions[ii];
         item.Update(i);
      }
   }  

   return(0);
}

double minValue(double& array[],int shift)
{
   double minValue = array[shift];
   for (int i=1; i<4; i++) minValue = MathMin(minValue,array[shift+i]);
   return(minValue);
}
double maxValue(double& array[],int shift)
{
   double maxValue = array[shift];
   for (int i=1; i<4; i++) maxValue = MathMax(maxValue,array[shift+i]);
   return(maxValue);
}