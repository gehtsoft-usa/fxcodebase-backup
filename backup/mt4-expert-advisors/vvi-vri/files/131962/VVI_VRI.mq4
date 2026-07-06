// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69537

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 13

enum modo_tipo_type
{
   FILTRADO_COMPLETO, // FILTRADO COMPLETO
   SIN_FILTRADO, // SIN FILTRADO
   SOLO_FILTRO_DE_TENDENCIA // SOLO FILTRO DE TENDENCIA
};

input string MODO = ""; // ═════════════════ MODO DE OPERACION ══════════════
input modo_tipo_type modo_tipo = FILTRADO_COMPLETO;

input string AD_VRI_VV = ""; // ═════════════ ACTIVAR/DESACTIVAR VRI/VVI ═════════════
input bool VRI_ON = true; // VER VELAS ROJAS IGNORADAS  - VRI
input bool VVI_ON = true; // VER VELAS VERDES IGNORADAS - VVI

input string CMM = ""; // ════════════ CONFIGURACION MEDIAS MOVILES ════════════
input bool ma_1 = true; // VER_MEDIA_LENTA 🐢
input ENUM_MA_METHOD ma_type = MODE_SMA; // 🔹 Tipo = 
input int ma_len = 20; // 🔹 Periodo = 
input ENUM_APPLIED_PRICE ma_src = PRICE_CLOSE; // 🔹 Fuente =
input int reaction_ma_1 = 1; // 🔹 Reaccion =
input bool ma_2 = true; // VER_MEDIA_RAPIDA 🐇
input ENUM_MA_METHOD ma_type_b = MODE_SMA; // 🔹 Tipo =
input int ma_len_b = 8; // 🔹 Periodo =
input ENUM_APPLIED_PRICE ma_src_b = PRICE_CLOSE; // 🔹 Fuente =
input int reaction_ma_2 = 1; // 🔹 Reaccion =

enum config_tend_alc_type
{
   NINGUNA_CONDICION1, //NINGUNA_CONDICION
   PRECIO_MAYOR_A_MEDIA_RAPIDA, // PRECIO_MAYOR_A_MEDIA_RAPIDA 
   PRECIO_MAYOR_A_MEDIA_LENTA, // PRECIO_MAYOR_A_MEDIA_LENTA
   PRECIO_MAYOR_A_MEDIA_RAPIDA_Y_LENTA, // PRECIO_MAYOR_A_MEDIA_RAPIDA_Y_LENTA
   PRECIO_MAYOR_A_MEDIA_LENTA_Y_DIRECCION_ALCISTA, // PRECIO_MAYOR_A_MEDIA_LENTA_Y_DIRECCION_ALCISTA
   PRECIO_MAYOR_A_MEDIA_RAPIDA_Y_DIRECCION_ALCISTA, // PRECIO_MAYOR_A_MEDIA_RAPIDA_Y_DIRECCION_ALCISTA
   PRECIO_MAYOR_A_MEDIA_LENTA_RAPIDA_Y_DIRECCION_ALCISTA, // PRECIO_MAYOR_A_MEDIA_LENTA_RAPIDA_Y_DIRECCION_ALCISTA
   DIRECCION_MEDIA_LENTA_ALCISTA, // DIRECCION_MEDIA_LENTA_ALCISTA
   DIRECCION_MEDIA_RAPIDA_ALCISTA, // DIRECCION_MEDIA_RAPIDA_ALCISTA
   DIRECCION_MEDIA_LENTA_RAPIDA_ALCISTA // DIRECCION_MEDIA_LENTA_RAPIDA_ALCISTA
};
enum config_tend_baj_type
{
   NINGUNA_CONDICION2, // NINGUNA_CONDICION
   PRECIO_MENOR_A_MEDIA_RAPIDA, // PRECIO_MENOR_A_MEDIA_RAPIDA
   PRECIO_MENOR_A_MEDIA_LENTA, // PRECIO_MENOR_A_MEDIA_LENTA
   PRECIO_MENOR_A_MEDIA_RAPIDA_Y_LENTA, // PRECIO_MENOR_A_MEDIA_RAPIDA_Y_LENTA
   PRECIO_MENOR_A_MEDIA_LENTA_Y_DIRECCION_BAJISTA, // PRECIO_MENOR_A_MEDIA_LENTA_Y_DIRECCION_BAJISTA
   PRECIO_MENOR_A_MEDIA_RAPIDA_Y_DIRECCION_BAJISTA, // PRECIO_MENOR_A_MEDIA_RAPIDA_Y_DIRECCION_BAJISTA
   PRECIO_MENOR_A_MEDIA_LENTA_RAPIDA_Y_DIRECCION_BAJISTA, // PRECIO_MENOR_A_MEDIA_LENTA_RAPIDA_Y_DIRECCION_BAJISTA
   DIRECCION_MEDIA_LENTA_BAJISTA, // DIRECCION_MEDIA_LENTA_BAJISTA
   DIRECCION_MEDIA_RAPIDA_BAJISTA, // DIRECCION_MEDIA_RAPIDA_BAJISTA
   DIRECCION_MEDIA_LENTA_RAPIDA_BAJISTA // DIRECCION_MEDIA_LENTA_RAPIDA_BAJISTA
};
input string CT = ""; // ══════════════ CONFIGURACION TENDENCIA ════════════
input config_tend_alc_type config_tend_alc = DIRECCION_MEDIA_LENTA_RAPIDA_ALCISTA; // 🔹 CONDICION TENDENCIA_ALCISTA P/VRI 🐂 =
input config_tend_baj_type config_tend_baj = DIRECCION_MEDIA_LENTA_RAPIDA_BAJISTA; // 🔹 CONDICION TENDENCIA_BAJISTA P/VVI 🐻 =

input string CBC = ""; // ═══════════ CONFIGURACION BARRA DE CONTROL ═════════
input int porc_cuerpo = 30; // 🔹 PORCENTAJE DE CUERPO MINIMO % =

input string CBI = ""; // ════════════ CONFIGURACION BARRA IGNORADA ══════════
input int porc_bar_cont = 30; // 🔹 ARRIBA DE X% DE LA BARRA DE CONTROL =

input string CBS = ""; // ═════════════ CONFIGURACION BARRA SEÑAL ═══════════
input bool NPAMBI = false; //  NO PUEDE ANULAR EL MINIMO DE LA BARRA IGNORADA

input string EXT = ""; // ════════════ TOMA DE GANANCIA / PERDIDA ═══════════
input bool VSLTPR = true; // VER STOP LOSS_Y_TAKE PROFIT RECOMENDADO
enum TTDGP_type
{
   VRI, // VRI
   VVI // VVI
};
input TTDGP_type TTDGP = VRI; // 🔹 PARA =
input int elslxb = 4; // 🔹 EXTENDER LINEA STOP LOSS X BARRAS =
input int eltpxb = 6; // 🔹 EXTENDER LINEA TAKE PROFIT X BARRAS =
input int RPMABE = 1; // 🔹 RATIO PARA MOVER A BREAK EVEN =
input int RTP1 = 2; // 🔹 RATIO TAKE PROFIT 1 =
input int RTP2 = 4; // 🔹 RATIO TAKE PROFIT 2 =

#property strict
#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 14

enum SingalMode
{
   SingalModeLive, // Live
   SingalModeOnBarClose // On bar close
};

enum DisplayType
{
   Arrows, // Arrows
   ArrowsOnMainChart, // Arrows on main chart
   Candles // Candles color
};
input SingalMode signal_mode = SingalModeLive; // Signal mode
input DisplayType Type = Arrows; // Presentation Type
input double shift_arrows_pips = 0.1; // Shift arrows
input color up_color = Blue; // Up color
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

// ACondition v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef ACondition_IMP
#define ACondition_IMP
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

#ifndef AConditionBase_IMP
#define AConditionBase_IMP

class AConditionBase : public ICondition
{
   int _references;
public:
   AConditionBase()
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
// Instrument info v.1.6
// More templates and snippets on https://github.com/sibvic/mq4-templates

#ifndef InstrumentInfo_IMP
#define InstrumentInfo_IMP

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

   // Return < 0 when lot1 < lot2, > 0 when lot1 > lot2 and 0 owtherwise
   int CompareLots(double lot1, double lot2)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
      {
         return lot1 < lot2 ? -1 : (lot1 > lot2 ? 1 : 0);
      }
      int lotSteps1 = (int)floor(lot1 / lotStep + 0.5);
      int lotSteps2 = (int)floor(lot2 / lotStep + 0.5);
      int res = lotSteps1 - lotSteps2;
      return res;
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

   double RoundLots(const double lots)
   {
      double lotStep = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_STEP);
      if (lotStep == 0)
      {
         return 0.0;
      }
      return floor(lots / lotStep) * lotStep;
   }

   double LimitLots(const double lots)
   {
      double minVolume = GetMinLots();
      if (minVolume > lots)
      {
         return 0.0;
      }
      double maxVolume = SymbolInfoDouble(_symbol, SYMBOL_VOLUME_MAX);
      if (maxVolume < lots)
      {
         return maxVolume;
      }
      return lots;
   }

   double NormalizeLots(const double lots)
   {
      return LimitLots(RoundLots(lots));
   }
};

#endif

class ACondition : public AConditionBase
{
protected:
   ENUM_TIMEFRAMES _timeframe;
   InstrumentInfo *_instrument;
   string _symbol;
public:
   ACondition(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _instrument = new InstrumentInfo(symbol);
      _timeframe = timeframe;
      _symbol = symbol;
   }
   ~ACondition()
   {
      delete _instrument;
   }
};
#endif
// Price stream v1.0

#ifndef PriceStream_IMP
#define PriceStream_IMP
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
enum PriceType
{
   PriceClose = PRICE_CLOSE, // Close
   PriceOpen = PRICE_OPEN, // Open
   PriceHigh = PRICE_HIGH, // High
   PriceLow = PRICE_LOW, // Low
   PriceMedian = PRICE_MEDIAN, // Median
   PriceTypical = PRICE_TYPICAL, // Typical
   PriceWeighted = PRICE_WEIGHTED, // Weighted
   PriceMedianBody, // Median (body)
   PriceAverage, // Average
   PriceTrendBiased, // Trend biased
   PriceVolume, // Volume
};

class PriceStream : public AStream
{
   PriceType _price;
public:
   PriceStream(const string symbol, const ENUM_TIMEFRAMES timeframe, const PriceType __price)
      :AStream(symbol, timeframe)
   {
      _price = __price;
   }

   bool GetValue(const int period, double &val)
   {
      switch (_price)
      {
         case PriceClose:
            val = iClose(_symbol, _timeframe, period);
            break;
         case PriceOpen:
            val = iOpen(_symbol, _timeframe, period);
            break;
         case PriceHigh:
            val = iHigh(_symbol, _timeframe, period);
            break;
         case PriceLow:
            val = iLow(_symbol, _timeframe, period);
            break;
         case PriceMedian:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period)) / 2.0;
            break;
         case PriceTypical:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 3.0;
            break;
         case PriceWeighted:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) * 2) / 4.0;
            break;
         case PriceMedianBody:
            val = (iOpen(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period)) / 2.0;
            break;
         case PriceAverage:
            val = (iHigh(_symbol, _timeframe, period) + iLow(_symbol, _timeframe, period) + iClose(_symbol, _timeframe, period) + iOpen(_symbol, _timeframe, period)) / 4.0;
            break;
         case PriceTrendBiased:
            {
               double close = iClose(_symbol, _timeframe, period);
               if (iOpen(_symbol, _timeframe, period) > iClose(_symbol, _timeframe, period))
                  val = (iHigh(_symbol, _timeframe, period) + close) / 2.0;
               else
                  val = (iLow(_symbol, _timeframe, period) + close) / 2.0;
            }
            break;
         case PriceVolume:
            val = (double)iVolume(_symbol, _timeframe, period);
            break;
      }
      val += _shift * _instrument.GetPipSize();
      return true;
   }
};
#endif
//Signaler v 1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start inputal program
input string   program_path             = ""; // Path to the inputal program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

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

// Alert signal v2.4
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

class IAlertSignalOutput
{
public:
   virtual void Clear(int period) = 0;
   virtual void Set(int period) = 0;
};

class AlertSignalCandleColor : public IAlertSignalOutput
{
   CandleStreams* _candleStreams;
public:
   AlertSignalCandleColor()
   {
      _candleStreams = new CandleStreams();
   }

   ~AlertSignalCandleColor()
   {
      delete _candleStreams;
   }

   int Register(int id, color clr)
   {
      return _candleStreams.RegisterStreams(id, clr);
   }

   virtual void Clear(int period)
   {
      _candleStreams.Clear(period);
   }

   virtual void Set(int period)
   {
      _candleStreams.Set(period, Open[period], High[period], Low[period], Close[period]);
   }
};

class AlertSignalArrow : public IAlertSignalOutput
{
   double _signals[];
   IStream* _price;
public:
   AlertSignalArrow()
   {
      _price = NULL;
   }

   ~AlertSignalArrow()
   {
      if (_price != NULL)
         _price.Release();
   }

   int Register(int id, string name, int code, color clr, IStream* price)
   {
      if (_price != NULL)
         _price.Release();
      _price = price;
      _price.AddRef();

      SetIndexStyle(id, DRAW_ARROW, 0, 2, clr);
      SetIndexBuffer(id, _signals);
      SetIndexLabel(id, name);
      SetIndexArrow(id, code);
      return id + 1;
   }

   virtual void Clear(int period)
   {
      _signals[period] = EMPTY_VALUE;
   }

   virtual void Set(int period)
   {
      double price;
      if (!_price.GetValue(period, price))
         return;

      _signals[period] = price;
   }
};

class MainChartAlertSignalArrow : public IAlertSignalOutput
{
   IStream* _price;
   string _labelId;
   color _color;
   uchar _code;
public:
   MainChartAlertSignalArrow()
   {
      _price = NULL;
   }

   ~MainChartAlertSignalArrow()
   {
      if (_price != NULL)
         _price.Release();
   }

   int Register(int id, string labelId, uchar code, color clr, IStream* price)
   {
      if (_price != NULL)
         _price.Release();
      _price = price;
      _price.AddRef();
      _labelId = labelId;
      _color = clr;
      _code = code;
      
      return id;
   }

   virtual void Clear(int period)
   {
      ResetLastError();
      string id = _labelId + TimeToString(Time[period]);
      ObjectDelete(id);
   }

   virtual void Set(int period)
   {
      double price;
      if (!_price.GetValue(period, price))
         return;
      
      ResetLastError();
      string id = _labelId + TimeToString(Time[period]);
      if (ObjectFind(0, id) == -1)
      {
         if (!ObjectCreate(0, id, OBJ_TEXT, 0, Time[period], price))
         {
            Print(__FUNCTION__, ". Error: ", GetLastError());
            return ;
         }
         ObjectSetString(0, id, OBJPROP_FONT, "Wingdings");
         ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
         ObjectSetInteger(0, id, OBJPROP_COLOR, _color);
      }
      ObjectSetInteger(0, id, OBJPROP_TIME, Time[period]);
      ObjectSetDouble(0, id, OBJPROP_PRICE1, price);
      ObjectSetString(0, id, OBJPROP_TEXT, CharToStr(_code));
   }
};

class AlertSignal
{
   ICondition* _condition;
   Signaler* _signaler;
   string _message;
   datetime _lastSignal;
   bool _onBarClose;
   IAlertSignalOutput* _signalOutput;
public:
   AlertSignal(ICondition* condition, Signaler* signaler, bool onBarClose = false)
   {
      _signalOutput = NULL;
      _condition = condition;
      _signaler = signaler;
      _onBarClose = onBarClose;
   }

   ~AlertSignal()
   {
      delete _signalOutput;
      delete _condition;
   }

   int RegisterArrows(int id, string name, string labelId, int code, color clr, IStream* price)
   {
      _message = name;
      MainChartAlertSignalArrow* signalOutput = new MainChartAlertSignalArrow();
      _signalOutput = signalOutput;
      return signalOutput.Register(id, labelId, (uchar)code, clr, price);
   }

   int RegisterStreams(int id, string name, int code, color clr, IStream* price)
   {
      _message = name;
      AlertSignalArrow* signalOutput = new AlertSignalArrow();
      _signalOutput = signalOutput;
      return signalOutput.Register(id, name, code, clr, price);
   }

   int RegisterStreams(int id, string name, color clr)
   {
      _message = name;
      AlertSignalCandleColor* signalOutput = new AlertSignalCandleColor();
      _signalOutput = signalOutput;
      return signalOutput.Register(id, clr);
   }

   void Update(int period)
   {
      string symbol = _signaler.GetSymbol();
      datetime dt = iTime(symbol, _signaler.GetTimeframe(), _onBarClose ? period + 1 : period);

      if (!_condition.IsPass(_onBarClose ? period + 1 : period, dt))
      {
         _signalOutput.Clear(period);
         return;
      }

      if (period == 0)
      {
         dt = iTime(symbol, _signaler.GetTimeframe(), 0);
         if (_lastSignal != dt)
         {
            _signaler.SendNotifications(symbol + "/" + _signaler.GetTimeframeStr() + ": " + _message);
            _lastSignal = dt;
         }
      }

      _signalOutput.Set(period);
   }
};

#endif

// Custom stream v1.0

#ifndef CustomStream_IMP
#define CustomStream_IMP



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

AlertSignal* conditions[];
Signaler* mainSignaler;
CustomStream* customStream;

int CreateAlert(int id, ICondition* upCondition, ICondition* downCondition)
{
   int size = ArraySize(conditions);
   ArrayResize(conditions, size + 2);
   conditions[size] = new AlertSignal(upCondition, mainSignaler, signal_mode == SingalModeOnBarClose);
   conditions[size + 1] = new AlertSignal(downCondition, mainSignaler, signal_mode == SingalModeOnBarClose);
      
   switch (Type)
   {
      case Arrows:
         {
            id = conditions[size].RegisterStreams(id, "Up", 217, up_color, customStream);
            id = conditions[size + 1].RegisterStreams(id, "Down", 218, down_color, customStream);
         }
         break;
      case ArrowsOnMainChart:
         {
            PriceStream* highStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceHigh);
            highStream.SetShift(shift_arrows_pips);
            PriceStream* lowStream = new PriceStream(_Symbol, (ENUM_TIMEFRAMES)_Period, PriceLow);
            lowStream.SetShift(-shift_arrows_pips);
            id = conditions[size].RegisterArrows(id, "Up", IndicatorObjPrefix + "_up", 217, up_color, highStream);
            id = conditions[size + 1].RegisterArrows(id, "Down", IndicatorObjPrefix + "_down", 218, down_color, lowStream);
            lowStream.Release();
            highStream.Release();
         }
         break;
      case Candles:
         {
            id = conditions[size].RegisterStreams(id, "Up", up_color);
            id = conditions[size + 1].RegisterStreams(id, "Down", down_color);
         }
         break;
   }
   return id;
}

// Colored stream v3.0

#ifndef ColoredStream_IMP
#define ColoredStream_IMP

class ColoredStreamData
{
public:
   double Stream[];
};



class ColoredStream : public AStream
{
public:
   ColoredStreamData _streams[];
   double _data[];

   ColoredStream(const string symbol, const ENUM_TIMEFRAMES timeframe)
      :AStream(symbol, timeframe)
   {
   }

   int RegisterInternalStream(int id)
   {
      SetIndexBuffer(id + 0, _data);
      SetIndexStyle(id + 0, DRAW_NONE);
      return id + 1;
   }

   int RegisterStream(int id, color clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      SetIndexStyle(id + 0, lineType, lineStyle, width, clr);
      SetIndexBuffer(id + 0, _streams[size].Stream);
      if (label != "")
         SetIndexLabel(id + 0, label);
      return id + 1;
   }

   int GetColorIndex(int period)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].Stream[period] != EMPTY_VALUE)
            return i;
      }
      return -1;
   }

   void Set(double value, int period, int colorIndex)
   {
      _data[period] = value;
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (colorIndex == i)
         {
            _streams[i].Stream[period] = value;
            if (period + 1 < iBars(_symbol, _timeframe) && _streams[i].Stream[period + 1] == EMPTY_VALUE)
               _streams[i].Stream[period + 1] = _data[period + 1];   
         }
         else
            _streams[i].Stream[period] = EMPTY_VALUE;
      }
   }

   bool GetValue(const int period, double &val)
   {
      if (period >= iBars(_symbol, _timeframe))
      {
         return false;
      }
      val = _data[period];
      return _data[period] != EMPTY_VALUE;
   }
};

#endif

class UpCondition : public ACondition
{
public:
   UpCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int pos, const datetime date)
   {
      bool PMAMR = config_tend_alc == PRECIO_MAYOR_A_MEDIA_RAPIDA && Close[pos] > ma_series_b._data[pos];
      bool PMAML = config_tend_alc == PRECIO_MAYOR_A_MEDIA_LENTA && Close[pos] > ma_series._data[pos];
      bool PMAMRYL = config_tend_alc == PRECIO_MAYOR_A_MEDIA_RAPIDA_Y_LENTA && Close[pos] > ma_series._data[pos] && Close[pos] > ma_series_b._data[pos];
      bool PMAMLYDA = config_tend_alc == PRECIO_MAYOR_A_MEDIA_LENTA_Y_DIRECCION_ALCISTA && Close[pos] > ma_series._data[pos] && direction[pos] > 0;
      bool PMAMRYDA = config_tend_alc == PRECIO_MAYOR_A_MEDIA_RAPIDA_Y_DIRECCION_ALCISTA && Close[pos] > ma_series_b._data[pos] && direction_b[pos] > 0;
      bool PMAMLRYDA = config_tend_alc == PRECIO_MAYOR_A_MEDIA_LENTA_RAPIDA_Y_DIRECCION_ALCISTA && Close[pos] > ma_series._data[pos] && Close[pos] > ma_series_b._data[pos] && direction[pos] > 0 && direction_b[pos] > 0;
      bool DMLA = config_tend_alc == DIRECCION_MEDIA_LENTA_ALCISTA && direction[pos] > 0;
      bool DMRA = config_tend_alc == DIRECCION_MEDIA_RAPIDA_ALCISTA && direction_b[pos] > 0;
      bool DMLRA = config_tend_alc == DIRECCION_MEDIA_LENTA_RAPIDA_ALCISTA && direction[pos] > 0 && direction_b[pos] > 0;
      bool NCA = config_tend_alc == NINGUNA_CONDICION1;
      bool VRI_0 = Close[pos + 2] > Open[pos + 2] && Open[pos + 1] > Close[pos + 1] && Close[pos] > Open[pos];
      bool VRI_1 = VRI_0 && High[pos] >= Open[pos + 1];
      bool VRI_2 = VRI_1 && Low[pos + 1] > Low[pos + 2];
      bool VRI_3 = VRI_2 && PMAMR ? true : VRI_2 && PMAML ? true : VRI_2 && PMAMRYL ? true : VRI_2 && PMAMLYDA ? true : VRI_2 && PMAMRYDA ? true : VRI_2 && PMAMLRYDA ? true : VRI_2 && DMLA ? true : VRI_2 && DMRA ? true : VRI_2 && DMLRA ? true : VRI_2 && NCA;
      bool VRI_3_A = VRI_1 && PMAMR ? true : VRI_1 && PMAML ? true : VRI_1 && PMAMRYL ? true : VRI_1 && PMAMLYDA ? true : VRI_1 && PMAMRYDA ? true : VRI_1 && PMAMLRYDA ? true : VRI_1 && DMLA ? true : VRI_1 && DMRA ? true : VRI_1 && DMLRA ? true : VRI_1 && NCA;
      bool VRI_4 = VRI_3 && MathAbs(Open[pos + 2] - Close[pos + 1]) * 100 / MathAbs(High[pos + 2] - Low[pos + 2]) >= porc_cuerpo;
      bool VRI_5 = VRI_4 && MathAbs(Low[pos + 1] - Low[pos + 2]) * 100 / MathAbs(High[pos + 2] - Low[pos + 2]) >= porc_bar_cont;
      bool VRI_6 = VRI_5 && NPAMBI && Low[pos] >= Low[pos + 1] ? true : VRI_5 && !NPAMBI;
      if (VRI_6 && VRI_ON && modo_tipo == FILTRADO_COMPLETO ? true : VRI_1 && VRI_ON && modo_tipo == SIN_FILTRADO ? true : VRI_3_A && VRI_ON && modo_tipo == SOLO_FILTRO_DE_TENDENCIA)
      {
         if (VSLTPR && TTDGP == VRI)
         {
            double UR_VRI = MathAbs(Open[pos + 1] - Low[pos + 1]);
            double BE_VRI = Open[pos + 1] + UR_VRI * RPMABE;
            double TP1_VRI = Open[pos + 1] + UR_VRI * RTP1;
            double TP2_VRI = Open[pos + 1] + UR_VRI * RTP2;

            ResetLastError();
            string id = IndicatorObjPrefix+ TimeToString(Time[pos]) + "1l";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TEXT, 0, Time[pos], Low[pos + 1]))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetString(0, id, OBJPROP_FONT, "Arial");
               ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
               ObjectSetInteger(0, id, OBJPROP_COLOR, Pink);
            }
            ObjectSetInteger(0, id, OBJPROP_TIME, Time[pos]);
            ObjectSetDouble(0, id, OBJPROP_PRICE1, Low[pos + 1]);
            ObjectSetString(0, id, OBJPROP_TEXT, "SL=" + DoubleToString(Low[pos + 1], Digits));
            ResetLastError();
            id = IndicatorObjPrefix+ TimeToString(Time[pos]) + "2l";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TEXT, 0, Time[pos + 4], BE_VRI))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetString(0, id, OBJPROP_FONT, "Arial");
               ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
               ObjectSetInteger(0, id, OBJPROP_COLOR, Pink);
            }
            ObjectSetInteger(0, id, OBJPROP_TIME, Time[pos + 4]);
            ObjectSetDouble(0, id, OBJPROP_PRICE1, BE_VRI);
            ObjectSetString(0, id, OBJPROP_TEXT, "BE=" + DoubleToString(BE_VRI, Digits));
            ResetLastError();
            id = IndicatorObjPrefix+ TimeToString(Time[pos]) + "3l";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TEXT, 0, Time[pos + 4], TP1_VRI))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetString(0, id, OBJPROP_FONT, "Arial");
               ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
               ObjectSetInteger(0, id, OBJPROP_COLOR, Pink);
            }
            ObjectSetInteger(0, id, OBJPROP_TIME, Time[pos + 4]);
            ObjectSetDouble(0, id, OBJPROP_PRICE1, TP1_VRI);
            ObjectSetString(0, id, OBJPROP_TEXT, "TP1=" + DoubleToString(TP1_VRI, Digits));
            ResetLastError();
            id = IndicatorObjPrefix+ TimeToString(Time[pos]) + "4l";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TEXT, 0, Time[pos + 4], TP2_VRI))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetString(0, id, OBJPROP_FONT, "Arial");
               ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
               ObjectSetInteger(0, id, OBJPROP_COLOR, Pink);
            }
            ObjectSetInteger(0, id, OBJPROP_TIME, Time[pos + 4]);
            ObjectSetDouble(0, id, OBJPROP_PRICE1, TP2_VRI);
            ObjectSetString(0, id, OBJPROP_TEXT, "TP2=" + DoubleToString(TP2_VRI, Digits));
            ResetLastError();
            id = IndicatorObjPrefix + TimeToString(Time[pos]) + "_1";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[pos + 1], Low[pos + 1], Time[pos] + (Time[pos] - Time[pos + 1]) * (elslxb - 1), Low[pos + 1]))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetInteger(0, id, OBJPROP_COLOR, Pink);
               ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
            }
            ObjectSetDouble(0, id, OBJPROP_PRICE1, Low[pos + 1]);
            ObjectSetDouble(0, id, OBJPROP_PRICE2, Low[pos + 1]);
            ObjectSetInteger(0, id, OBJPROP_TIME1, Time[pos + 1]);
            ObjectSetInteger(0, id, OBJPROP_TIME2, Time[pos] + (Time[pos] - Time[pos + 1]) * (elslxb - 1));
            ResetLastError();
            id = IndicatorObjPrefix + TimeToString(Time[pos]) + "_2";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[pos + 3], BE_VRI, Time[pos] + (Time[pos] - Time[pos + 1]), BE_VRI))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetInteger(0, id, OBJPROP_COLOR, Azure);
               ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
            }
            ObjectSetDouble(0, id, OBJPROP_PRICE1, BE_VRI);
            ObjectSetDouble(0, id, OBJPROP_PRICE2, BE_VRI);
            ObjectSetInteger(0, id, OBJPROP_TIME1, Time[pos + 3]);
            ObjectSetInteger(0, id, OBJPROP_TIME2, Time[pos] + (Time[pos] - Time[pos + 1]));
            ResetLastError();
            id = IndicatorObjPrefix + TimeToString(Time[pos]) + "_3";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[pos + 3], TP1_VRI, Time[pos] + (Time[pos] - Time[pos + 1]), TP1_VRI))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetInteger(0, id, OBJPROP_COLOR, Azure);
               ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
            }
            ObjectSetDouble(0, id, OBJPROP_PRICE1, TP1_VRI);
            ObjectSetDouble(0, id, OBJPROP_PRICE2, TP1_VRI);
            ObjectSetInteger(0, id, OBJPROP_TIME1, Time[pos + 3]);
            ObjectSetInteger(0, id, OBJPROP_TIME2, Time[pos] + (Time[pos] - Time[pos + 1]));
            ResetLastError();
            id = IndicatorObjPrefix + TimeToString(Time[pos]) + "_4";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[pos + 3], TP2_VRI, Time[pos] + (Time[pos] - Time[pos + 1]), TP2_VRI))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetInteger(0, id, OBJPROP_COLOR, Azure);
               ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
            }
            ObjectSetDouble(0, id, OBJPROP_PRICE1, TP2_VRI);
            ObjectSetDouble(0, id, OBJPROP_PRICE2, TP2_VRI);
            ObjectSetInteger(0, id, OBJPROP_TIME1, Time[pos + 3]);
            ObjectSetInteger(0, id, OBJPROP_TIME2, Time[pos] + (Time[pos] - Time[pos + 1]));
         }
         return true;
      }
      return false;
   }
};

class DownCondition : public ACondition
{
public:
   DownCondition(const string symbol, ENUM_TIMEFRAMES timeframe)
      :ACondition(symbol, timeframe)
   {

   }

   bool IsPass(const int pos, const datetime date)
   {
      bool PMEAMR = config_tend_baj == PRECIO_MENOR_A_MEDIA_RAPIDA && Close[pos] < ma_series_b._data[pos];
      bool PMEAML = config_tend_baj == PRECIO_MENOR_A_MEDIA_LENTA && Close[pos] < ma_series._data[pos];
      bool PMEAMRYL = config_tend_baj == PRECIO_MENOR_A_MEDIA_RAPIDA_Y_LENTA && Close[pos] < ma_series._data[pos] && Close[pos] < ma_series_b._data[pos];
      bool PMEAMLYDB = config_tend_baj == PRECIO_MENOR_A_MEDIA_LENTA_Y_DIRECCION_BAJISTA && Close[pos] < ma_series._data[pos] && direction[pos] < 0;
      bool PMEAMRYDB = config_tend_baj == PRECIO_MENOR_A_MEDIA_RAPIDA_Y_DIRECCION_BAJISTA && Close[pos] < ma_series_b._data[pos] && direction_b[pos] < 0;
      bool PMEAMLRYDB = config_tend_baj == PRECIO_MENOR_A_MEDIA_LENTA_RAPIDA_Y_DIRECCION_BAJISTA && Close[pos] < ma_series._data[pos] && Close[pos] < ma_series_b._data[pos] && direction[pos] < 0 && direction_b[pos] < 0;
      bool DMLB = config_tend_baj == DIRECCION_MEDIA_LENTA_BAJISTA && direction[pos] < 0;
      bool DMRB = config_tend_baj == DIRECCION_MEDIA_RAPIDA_BAJISTA && direction_b[pos] < 0;
      bool DMLRB = config_tend_baj == DIRECCION_MEDIA_LENTA_RAPIDA_BAJISTA && direction[pos] < 0 && direction_b[pos] < 0;
      bool NCB = config_tend_baj == NINGUNA_CONDICION2;
      bool VVI_0 = Open[pos + 2] > Close[pos + 2] && Close[pos + 1] > Open[pos + 1] && Open[pos] > Close[pos];
      bool VVI_1 = VVI_0 && Low[pos] <= Open[pos + 1];
      bool VVI_2 = VVI_1 && High[pos + 1] < High[pos + 2];
      bool VVI_3 = VVI_2 && PMEAMR ? true : VVI_2 && PMEAML ? true : VVI_2 && PMEAMRYL ? true : VVI_2 && PMEAMLYDB ? true : VVI_2 && PMEAMRYDB ? true : VVI_2 && PMEAMLRYDB ? true : VVI_2 && DMLB ? true : VVI_2 && DMRB ? true : VVI_2 && DMLRB ? true : VVI_2 && NCB;
      bool VVI_3_A = VVI_1 && PMEAMR ? true : VVI_1 && PMEAML ? true : VVI_1 && PMEAMRYL ? true : VVI_1 && PMEAMLYDB ? true : VVI_1 && PMEAMRYDB ? true : VVI_1 && PMEAMLRYDB ? true : VVI_1 && DMLB ? true : VVI_1 && DMRB ? true : VVI_1 && DMLRB ? true : VVI_1 && NCB;
      bool VVI_4 = VVI_3 && MathAbs(Open[pos + 2] - Close[pos + 1]) * 100 / MathAbs(High[pos + 2] - Low[pos + 2]) >= porc_cuerpo;
      bool VVI_5 = VVI_4 && MathAbs(High[pos + 1] - High[pos + 2]) * 100 / MathAbs(High[pos + 2] - Low[pos + 2]) >= porc_bar_cont;
      bool VVI_6 = VVI_5 && NPAMBI && High[pos] <= High[pos + 1] ? true : VVI_5 && !NPAMBI;
      if (VVI_6 && VVI_ON && modo_tipo == FILTRADO_COMPLETO ? true : VVI_1 && VVI_ON && modo_tipo == SIN_FILTRADO ? true : VVI_3_A && VVI_ON && modo_tipo == SOLO_FILTRO_DE_TENDENCIA)
      {
         if (VSLTPR && TTDGP == VVI)
         {
            double UR_VVI = MathAbs(Open[pos + 1] - High[pos + 1]);
            double BE_VVI = Open[pos + 1] - UR_VVI * RPMABE;
            double TP1_VVI = Open[pos + 1] - UR_VVI * RTP1;
            double TP2_VVI = Open[pos + 1] - UR_VVI * RTP2;

            ResetLastError();
            string id = IndicatorObjPrefix+ TimeToString(Time[pos]) + "1l";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TEXT, 0, Time[pos], High[pos + 1]))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetString(0, id, OBJPROP_FONT, "Arial");
               ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
               ObjectSetInteger(0, id, OBJPROP_COLOR, Pink);
            }
            ObjectSetInteger(0, id, OBJPROP_TIME, Time[pos]);
            ObjectSetDouble(0, id, OBJPROP_PRICE1, High[pos + 1]);
            ObjectSetString(0, id, OBJPROP_TEXT, "SL=" + DoubleToString(High[pos + 1], Digits));
            ResetLastError();
            id = IndicatorObjPrefix+ TimeToString(Time[pos]) + "2l";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TEXT, 0, Time[pos + 4], BE_VVI))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetString(0, id, OBJPROP_FONT, "Arial");
               ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
               ObjectSetInteger(0, id, OBJPROP_COLOR, Pink);
            }
            ObjectSetInteger(0, id, OBJPROP_TIME, Time[pos + 4]);
            ObjectSetDouble(0, id, OBJPROP_PRICE1, BE_VVI);
            ObjectSetString(0, id, OBJPROP_TEXT, "BE=" + DoubleToString(BE_VVI, Digits));
            ResetLastError();
            id = IndicatorObjPrefix+ TimeToString(Time[pos]) + "3l";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TEXT, 0, Time[pos + 4], TP1_VVI))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetString(0, id, OBJPROP_FONT, "Arial");
               ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
               ObjectSetInteger(0, id, OBJPROP_COLOR, Pink);
            }
            ObjectSetInteger(0, id, OBJPROP_TIME, Time[pos + 4]);
            ObjectSetDouble(0, id, OBJPROP_PRICE1, TP1_VVI);
            ObjectSetString(0, id, OBJPROP_TEXT, "TP1=" + DoubleToString(TP1_VVI, Digits));
            ResetLastError();
            id = IndicatorObjPrefix+ TimeToString(Time[pos]) + "4l";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TEXT, 0, Time[pos + 4], TP2_VVI))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetString(0, id, OBJPROP_FONT, "Arial");
               ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
               ObjectSetInteger(0, id, OBJPROP_COLOR, Pink);
            }
            ObjectSetInteger(0, id, OBJPROP_TIME, Time[pos + 4]);
            ObjectSetDouble(0, id, OBJPROP_PRICE1, TP2_VVI);
            ObjectSetString(0, id, OBJPROP_TEXT, "TP2=" + DoubleToString(TP2_VVI, Digits));
            id = IndicatorObjPrefix + TimeToString(Time[pos]) + "_1";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[pos + 1], High[pos + 1], Time[pos] + (Time[pos] - Time[pos + 1]) * (elslxb - 1), High[pos + 1]))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetInteger(0, id, OBJPROP_COLOR, Pink);
               ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
            }
            ObjectSetDouble(0, id, OBJPROP_PRICE1, High[pos + 1]);
            ObjectSetDouble(0, id, OBJPROP_PRICE2, High[pos + 1]);
            ObjectSetInteger(0, id, OBJPROP_TIME1, Time[pos + 1]);
            ObjectSetInteger(0, id, OBJPROP_TIME2, Time[pos] + (Time[pos] - Time[pos + 1]) * (elslxb - 1));
            ResetLastError();
            id = IndicatorObjPrefix + TimeToString(Time[pos]) + "_2";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[pos + 3], BE_VVI, Time[pos] + (Time[pos] - Time[pos + 1]), BE_VVI))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetInteger(0, id, OBJPROP_COLOR, Purple);
               ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
            }
            ObjectSetDouble(0, id, OBJPROP_PRICE1, BE_VVI);
            ObjectSetDouble(0, id, OBJPROP_PRICE2, BE_VVI);
            ObjectSetInteger(0, id, OBJPROP_TIME1, Time[pos + 3]);
            ObjectSetInteger(0, id, OBJPROP_TIME2, Time[pos] + (Time[pos] - Time[pos + 1]));
            ResetLastError();
            id = IndicatorObjPrefix + TimeToString(Time[pos]) + "_3";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[pos + 3], TP1_VVI, Time[pos] + (Time[pos] - Time[pos + 1]), TP1_VVI))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetInteger(0, id, OBJPROP_COLOR, Purple);
               ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
            }
            ObjectSetDouble(0, id, OBJPROP_PRICE1, TP1_VVI);
            ObjectSetDouble(0, id, OBJPROP_PRICE2, TP1_VVI);
            ObjectSetInteger(0, id, OBJPROP_TIME1, Time[pos + 3]);
            ObjectSetInteger(0, id, OBJPROP_TIME2, Time[pos] + (Time[pos] - Time[pos + 1]));
            ResetLastError();
            id = IndicatorObjPrefix + TimeToString(Time[pos]) + "_4";
            if (ObjectFind(0, id) == -1)
            {
               if (!ObjectCreate(0, id, OBJ_TREND, 0, Time[pos + 3], TP2_VVI, Time[pos] + (Time[pos] - Time[pos + 1]), TP2_VVI))
               {
                  Print(__FUNCTION__, ". Error: ", GetLastError());
               }
               ObjectSetInteger(0, id, OBJPROP_COLOR, Purple);
               ObjectSetInteger(0, id, OBJPROP_STYLE, STYLE_SOLID);
               ObjectSetInteger(0, id, OBJPROP_WIDTH, 1);
               ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, false);
            }
            ObjectSetDouble(0, id, OBJPROP_PRICE1, TP2_VVI);
            ObjectSetDouble(0, id, OBJPROP_PRICE2, TP2_VVI);
            ObjectSetInteger(0, id, OBJPROP_TIME1, Time[pos + 3]);
            ObjectSetInteger(0, id, OBJPROP_TIME2, Time[pos] + (Time[pos] - Time[pos + 1]));
         }
         return true;
      }
      return false;
   }
};

ColoredStream* ma_series;
ColoredStream* ma_series_b;
double direction[], direction_b[];

int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("VVI_VRI");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   mainSignaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");

   ma_series = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ma_series_b = new ColoredStream(_Symbol, (ENUM_TIMEFRAMES)_Period);

   int id = 0;
   id = ma_series.RegisterInternalStream(id);
   id = ma_series_b.RegisterInternalStream(id);
   id = ma_series.RegisterStream(id, up_color, "Media Lenta");
   id = ma_series.RegisterStream(id, down_color, "Media Lenta");
   id = ma_series_b.RegisterStream(id, up_color, "Media Rapida");
   id = ma_series_b.RegisterStream(id, down_color, "Media Rapida");
   
   if (Type == Arrows)
   {
      customStream = new CustomStream(_Symbol, (ENUM_TIMEFRAMES)_Period);
   }
   ICondition* upCondition = (ICondition*) new UpCondition(_Symbol, (ENUM_TIMEFRAMES)_Period);
   ICondition* downCondition = (ICondition*) new DownCondition(_Symbol, (ENUM_TIMEFRAMES)_Period);
   id = CreateAlert(id, upCondition, downCondition);
   if (customStream != NULL)
   {
      id = customStream.RegisterInternalStream(id);
   }
   id = ma_series.RegisterInternalStream(id);
   id = ma_series_b.RegisterInternalStream(id);
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, direction);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, direction_b);
   ++id;

   return 0;
}

int deinit()
{
   ma_series.Release();
   ma_series = NULL;
   ma_series_b.Release();
   ma_series_b = NULL;
   if (customStream != NULL)
   {
      customStream.Release();
      customStream = NULL;
   }
   delete mainSignaler;
   mainSignaler = NULL;
   for (int i = 0; i < ArraySize(conditions); ++i)
   {
      delete conditions[i];
   }
   ArrayResize(conditions, 0);
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int minBars = 2;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int pos = limit; pos >= 0; --pos)
   {  
      double ma_series_val = iMA(_Symbol, _Period, ma_len, 0, ma_type, ma_src, pos);
      double ma_series_b_val = iMA(_Symbol, _Period, ma_len_b, 0, ma_type_b, ma_src_b, pos);
      
      direction[pos] = direction[pos + 1];
      if (reaction_ma_1 < Bars - 1 && ma_series._data[pos + reaction_ma_1] != EMPTY_VALUE)
      {
         if (ma_series_val > ma_series._data[pos + reaction_ma_1])
         {
            direction[pos] = 1;
         }
         else if (ma_series_val < ma_series._data[pos + reaction_ma_1])
         {
            direction[pos] = -1;
         }
      }
      if (reaction_ma_2 < Bars - 1 && ma_series_b._data[pos + reaction_ma_2] != EMPTY_VALUE)
      {
         if (ma_series_b_val > ma_series_b._data[pos + reaction_ma_1])
         {
            direction_b[pos] = 1;
         }
         else if (ma_series_b_val < ma_series_b._data[pos + reaction_ma_1])
         {
            direction_b[pos] = -1;
         }
      }

      int pcol = direction[pos] > 0 ? 0 : 1;
      int pcol_b = direction_b[pos] > 0 ? 0 : 1;
      ma_series.Set(ma_series_val, pos, pcol);
      ma_series_b.Set(ma_series_b_val, pos, pcol_b);
      
      double atr = iATR(_Symbol, _Period, 50, pos) / 2;
      datetime dt = Time[pos] - Time[pos + 1];      

      if (customStream != NULL)
      {
         customStream._stream[pos] = Close[pos];
      }
      for (int i = 0; i < ArraySize(conditions); ++i)
      {
         AlertSignal* item = conditions[i];
         item.Update(pos);
      }
   } 
   return 0;
}
