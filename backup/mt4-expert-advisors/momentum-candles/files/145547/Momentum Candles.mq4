// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72040

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 4
//--- plot Linea1
#property indicator_label1 "Bull Open"
#property indicator_label2 "Bull Close"
#property indicator_label3 "Bear Open"
#property indicator_label4 "Bear Close"

//--- indicator buffers
double BullOpen[];
double BullClose[];
double BearOpen[];
double BearClose[];
// ------------------------------------------------------------------
string T0                    = "== Break Setup ==";    // Break Setup
int    nCandles              = 1;                      // Maximum candle to break previous:
input string T2                    = "== Set Signals ==";    // Set Signals
input int    uPips                 = 30;                     // Pips To Signal:
input color  uColorBull            = clrLimeGreen;           // Color Bull Candle:
input color  uColorBear            = clrOrangeRed;           // Color Bear Candle:
input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications


// ------------------------------------------------------------------
class CCandle
{
   int    _timeFrame;
   string _symbol;
   double _open;
   double _high;
   double _low;
   double _close;
   float  _size;
   string _type;
   string _direction;
   float  _bodySize;
   float  _shadowSup;
   float  _shadowInf;

  public:
   CCandle() { ; }
   CCandle(string sym, int tf) : _symbol(sym), _timeFrame(tf) {}
   ~CCandle() { ; }

   // Getters
   float  Size(void) { return _size; }
   string Type(void) { return _type; }
   double Open(void) { return _open; }
   double High(void) { return _high; }
   double Low(void) { return _low; }
   double Close(void) { return _close; }
   string Direction(void) { return _direction; }
   float  BodySize(void) { return _bodySize; }
   float  ShadowSup(void) { return _shadowSup; }
   float  ShadowInf(void) { return _shadowInf; }

   void setCandle(int shift = 1)
   {
      _open  = iOpen(_symbol, _timeFrame, shift);
      _high  = iHigh(_symbol, _timeFrame, shift);
      _low   = iLow(_symbol, _timeFrame, shift);
      _close = iClose(_symbol, _timeFrame, shift);

      setDirection();
      setSize();
      setBodySize();
      setShadows();
   }
   void setSize()
   {
      _size = 1;
      if (Distance(_high, _low, _symbol) > 0)
      {
         _size = Distance(_high, _low, _symbol);
      }
   }
   void setBodySize()
   {
      _bodySize = 1;
      if (Distance(_open, _close, _symbol) > 0)
      {
         _bodySize = Distance(_open, _close, _symbol);
      }
   }
   void setDirection()
   {
      if (_open < _close)
      {
         _direction = "up";
      }
      if (_open > _close)
      {
         _direction = "down";
      }
      if (_open == _close)
      {
         _direction = "null";
      }
   }
   void PrintCandle()
   {
      Print(__FUNCTION__, " ", "symbol", " ", _symbol);
      Print(__FUNCTION__, " ", "open", " ", _open);
      Print(__FUNCTION__, " ", "high", " ", _high);
      Print(__FUNCTION__, " ", "low", " ", _low);
      Print(__FUNCTION__, " ", "close", " ", _close);
      Print(__FUNCTION__, " ", "_size;", " ", _size);
      Print(__FUNCTION__, " ", "_type;", " ", _type);
      Print(__FUNCTION__, " ", "_direction;", " ", _direction);
      Print(__FUNCTION__, " ", "_bodySize;", " ", _bodySize);
      Print(__FUNCTION__, " ", "_shadowSup;", " ", _shadowSup);
      Print(__FUNCTION__, " ", "_shadowInf;", " ", _shadowInf);
   }
   void setShadows()
   {
      if (Direction() == "up")
      {
         _shadowInf = Distance(_open, _low, _symbol);
         _shadowSup = Distance(_close, _high, _symbol);
      }
      if (Direction() == "down")
      {
         _shadowInf = Distance(_close, _low, _symbol);
         _shadowSup = Distance(_open, _high, _symbol);
      }
      if (Direction() == "null")
      {
         _shadowInf = Distance(_close, _low, _symbol);
         _shadowSup = Distance(_open, _high, _symbol);
      }
   }
   float Distance(double precioA, double precioB, string par)
   {
      double mPoint     = MarketInfo(par, MODE_POINT);
      double dist       = fabs(precioA - precioB);
      double distReturn = 0;
      if (mPoint > 0) distReturn = dist / mPoint;
      return distReturn;
   }
};
CCandle candle1();
CCandle candle2();

class CNewCandle
{
  private:
   int    _initialCandles;
   string _symbol;
   int    _tf;

  public:
   CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
   CNewCandle()
   {
      // toma los valores del chart actual
      _initialCandles = iBars(Symbol(), Period());
      _symbol         = Symbol();
      _tf             = Period();
   }
   ~CNewCandle() { ; }

   bool IsNewCandle()
   {
      int _currentCandles = iBars(_symbol, _tf);
      if (_currentCandles > _initialCandles)
      {
         _initialCandles = _currentCandles;
         return true;
      }

      return false;
   }
};
CNewCandle newCandle();

//+------------------------------------------------------------------+
int OnInit()
{
   //--- indicator buffers mapping
   SetIndexBuffer(0, BullOpen, INDICATOR_DATA);
   SetIndexArrow(0, 233);
   SetIndexStyle(0, DRAW_HISTOGRAM, EMPTY, 3, uColorBull);
   SetIndexBuffer(1, BullClose, INDICATOR_DATA);
   SetIndexStyle(1, DRAW_HISTOGRAM, EMPTY, 3, uColorBull);
   SetIndexArrow(1, 234);
   SetIndexBuffer(2, BearOpen, INDICATOR_DATA);
   SetIndexStyle(2, DRAW_HISTOGRAM, EMPTY, 3, uColorBear);
   SetIndexArrow(2, 234);
   SetIndexBuffer(3, BearClose, INDICATOR_DATA);
   SetIndexStyle(3, DRAW_HISTOGRAM, EMPTY, 3, uColorBear);
   SetIndexArrow(3, 234);
   // SetIndexStyle(0, DRAW_NONE);
   // SetIndexStyle(1, DRAW_NONE);
   //---
   return (INIT_SUCCEEDED);
}
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
   int i = rates_total - prev_calculated + 1;
   if (i >= rates_total) i = rates_total - 1;
   for (; i > 0; i--)
   {
      for (int j = 1; j <= nCandles; j++)
      {
         setCandles(i, j);
         if (haveSignalUp(i))
         {
            setBufferUp(i);
            if (newCandle.IsNewCandle())
            {
               Notifications(0);
            }
            break;
         }
         if (haveSignalDown(i))
         {
            setBufferDn(i);
            if (newCandle.IsNewCandle())
            {
               Notifications(1);
            }
            break;
         }
      }
   }

   return (rates_total);
}

// ------------------------------------------------------------------
void setCandles(int i, int shift)
{
   candle1.setCandle(i + shift);
   candle2.setCandle(i);
}
bool haveSignalUp(int i)
{
   // TODO: signal up
   // last candle > 30 pips
   // is a bull candle
   if (candle2.Direction() == "up" && candle2.BodySize() > uPips * 10)
   {
      return true;
   }

   return false;
}
bool haveSignalDown(int i)
{
   // TODO: signal down
   if (candle2.Direction() == "down" && candle2.BodySize() > uPips * 10)
   {
      return true;
   }

   return false;
}
void setBufferUp(int i)
{
   BullOpen[i] = candle2.Open();
   BullClose[i] = candle2.Close();
}
void setBufferDn(int i)
{
   BearOpen[i] = candle2.Open();
   BearClose[i] = candle2.Close();
}
void Notifications(int type)
{
   string text = "";
   if (type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
   else
      text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

   text += " ";

   if (!notifications)
      return;
   if (desktop_notifications)
      Alert(text);
   if (push_notifications)
      SendNotification(text);
   if (email_notifications)
      SendMail("MetaTrader Notification", text);
}
string GetTimeFrame(int lPeriod)
{
   switch (lPeriod)
   {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
   }
   return IntegerToString(lPeriod);
}
