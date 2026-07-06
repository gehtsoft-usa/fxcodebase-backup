// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72039

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

#property indicator_separate_window
#property indicator_minimum - 5
#property indicator_maximum 105
#property indicator_level1 5
#property indicator_level2 15
#property indicator_level3 20
#property indicator_level4 50
#property indicator_level5 80
#property indicator_level6 85
#property indicator_level7 95

#property indicator_buffers 7
#property indicator_plots 2

#property indicator_color1 Gold
#property indicator_color2 Red
//---- input parameters
extern int RPrice  = 5;  // PRICE_TYPICAL
extern int RPeriod = 13;
extern int KPeriod = 10;
extern int DPeriod = 3;
extern int Slowing = 2;
//---- buffers
double MainBuffer[];
double SignalBuffer[];
double HighesBuffer[];
double LowesBuffer[];
double rsi[];
//----
int draw_begin1 = 0;
int draw_begin2 = 0;
//--- indicator buffers Arrows:
double ArrowUp[];
double ArrowDn[];
// ------------------------------------------------------------------
input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn              = true;                   // Arrows On?
input color  ArrowUpClr            = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr            = clrRed;                 // Arrow Down Color:
// ------------------------------------------------------------------
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
class Arrow
{
  string   _name;
  datetime _iniTm;
  double   _price;
  color    _clr;
  string   _txt;
  string   _type;
  int      _count;

 public:
  Arrow() { ;}
  Arrow(string inpName, datetime inpIniTm, double inpPrice, color inpClr, string inpLabelTxt = "", string inpType="up")
  {
    _name  = inpName;
    _iniTm = inpIniTm;
    _price = inpPrice;
    _clr   = inpClr;
    _txt   = inpLabelTxt;
    _type  = inpType;
  }
  ~Arrow() { ; }

  Arrow* price(double inpPrice)
  {
    _price = inpPrice;
    return &this;
  }
  Arrow* txt(string inpTxt)
  {
    _txt = inpTxt;
    return &this;
  }
  Arrow* Color(color clr)
  {
     _clr = clr;
     return &this;
  }
  Arrow* Type(string direction)
  {
     _type    = direction;
     return &this;
  }
  Arrow* candle(int shift)
  {
     _iniTm = TimeByCandles(shift);
     return &this;
  }
  
  datetime TimeByCandles(int candlesBack)
  {
     _iniTm = Time[candlesBack];
     return _iniTm;
  }

  void draw()
  {
    // draw arrow
    if(_type =="up")
    {
       _name = AutoName();
      //  _iniTm = TimeByCandles(1);
       ObjectCreate(0, _name, OBJ_ARROW, 0, _iniTm, 0, 0, 0);
       ObjectSetInteger(0, _name, OBJPROP_ARROWCODE, 233);                     // Set the arrow code
       ObjectSetInteger(0, _name, OBJPROP_ANCHOR, ANCHOR_TOP);            // Set the arrow Anchor
      //  ObjectSetDouble(0, _name, OBJPROP_PRICE, iLow(Symbol(), Period(), 1) -100*_Point);  // Set price 
       ObjectSetDouble(0, _name, OBJPROP_PRICE, _price);  // Set price 
    }

    if(_type =="down")
    {
      _name = AutoName();
      // _iniTm = TimeByCandles(1);
      ObjectCreate(0, _name, OBJ_ARROW, 0, _iniTm, _price, TimeCurrent(), _price);
      ObjectSetInteger(0,_name,OBJPROP_ARROWCODE,234);    // Set the arrow code 
      ObjectSetInteger(0, _name, OBJPROP_ANCHOR, ANCHOR_BOTTOM);    // Set the arrow Anchor
      // ObjectSetDouble(0,_name,OBJPROP_PRICE,iHigh(Symbol(),Period(),1)+100*_Point);// Set price 
      ObjectSetDouble(0,_name,OBJPROP_PRICE,_price);// Set price 
    }
    ObjectSetInteger(0, _name, OBJPROP_COLOR, _clr);

    // draw label
    if (_txt != NULL) {
      //  Period() * 2 * 60
      ObjectCreate(0, _name + "Label", OBJ_TEXT, 0, TimeCurrent(), _price);
      ObjectSetInteger(0, _name + "Label", OBJPROP_ANCHOR, ANCHOR_RIGHT);
      ObjectSetString(0, _name + "Label", OBJPROP_FONT, "Calibri Light");
      ObjectSetInteger(0, _name + "Label", OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, _name + "Label", OBJPROP_COLOR, _clr);
      ObjectSetString(0, _name + "Label", OBJPROP_TEXT, _txt);
      // ObjectSetInteger(0, _name + "Label", OBJPROP_STYLE, STYLE_DOT);
    }
  }

  void erase()
  {
    ObjectDelete(0, _name);
    ObjectDelete(0, _name + "Label");
  }

  Arrow* redraw()
  {
    erase();
    draw();
    return &this;
  }

string AutoName()
{
   _count++;
   _name = "arrow ";
   return _name + _count;
}

void EraseAll()
{
  ObjectsDeleteAll(0, OBJ_ARROW);
}

};
Arrow arrows();
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   string short_name;
   //---- 3 additional buffers are used for counting.
   IndicatorBuffers(7);
   SetIndexBuffer(2, HighesBuffer);
   SetIndexBuffer(3, LowesBuffer);
   SetIndexBuffer(4, rsi);
	SetIndexStyle(2, DRAW_NONE);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexStyle(4, DRAW_NONE);
   //---- indicator lines
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexBuffer(0, MainBuffer);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 1);
   SetIndexBuffer(1, SignalBuffer);
   //---- name for DataWindow and indicator subwindow label
   short_name = "StochRSI(" + RPeriod + "," + KPeriod + "," + DPeriod + "," + Slowing + ")";
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);
   SetIndexLabel(1, "Signal");
   //----
   draw_begin1 = KPeriod + Slowing;
   draw_begin2 = draw_begin1 + DPeriod;
   SetIndexDrawBegin(0, draw_begin1);
   SetIndexDrawBegin(1, draw_begin2);
   //----
   SetIndexBuffer(5, ArrowUp, INDICATOR_DATA);
   SetIndexArrow(5, 233);
   // SetIndexStyle(5, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
   SetIndexBuffer(6, ArrowDn, INDICATOR_DATA);
   // SetIndexStyle(6, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
   SetIndexArrow(6, 234);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexStyle(6, DRAW_NONE);
   //---
   return (0);
}
void OnDeinit(const int reason)
{
   arrows.EraseAll();
}
//+------------------------------------------------------------------+
//| Stochastics formula applied to RSI                               |
//+------------------------------------------------------------------+
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
   int i, k;
   int counted_bars = IndicatorCounted();
   //---- check Slowing
   if (Slowing <= 0) Slowing = 1;
   //----
   if (Bars <= draw_begin2) return (0);
   //---- initial zero
   if (counted_bars < 1)
   {
      for (i = 1; i <= draw_begin1; i++) MainBuffer[Bars - i] = 0;
      for (i = 1; i <= draw_begin2; i++) SignalBuffer[Bars - i] = 0;
   }
   //---- initial RSI
   i = Bars - RPeriod;
   if (counted_bars > RPeriod) i = Bars - counted_bars - 1;
   while (i >= 0)
   {
      rsi[i] = iRSI(NULL, 0, RPeriod, RPrice, i);
      i--;
   }
   //---- minimums & maximums counting
   i = Bars - KPeriod;
   if (counted_bars > KPeriod) i = Bars - counted_bars - 1;
   while (i >= 0)
   {
      double min = 1000000, max = -1000000;
      k = i + KPeriod - 1;
      while (k >= i)
      {
         min = MathMin(min, rsi[k]);
         max = MathMax(max, rsi[k]);
         k--;
      }
      LowesBuffer[i]  = min;
      HighesBuffer[i] = max;
      i--;
   }
   //---- %K line of RSI
   i = Bars - draw_begin1;
   if (counted_bars > draw_begin1) i = Bars - counted_bars - 1;
   while (i >= 0)
   {
      double sumlow  = 0.0;
      double sumhigh = 0.0;
      for (k = (i + Slowing - 1); k >= i; k--)
      {
         sumlow += rsi[k] - LowesBuffer[k];
         sumhigh += HighesBuffer[k] - LowesBuffer[k];
      }
      if (sumhigh == 0.0)
         MainBuffer[i] = 100.0;
      else
         MainBuffer[i] = sumlow / sumhigh * 100;
      i--;
   }
   //---- last counted bar will be recounted
   if (counted_bars > 0) counted_bars--;
   int limit = Bars - counted_bars;
   //---- signal line is simple movimg average
   for (i = 0; i < limit; i++)
      SignalBuffer[i] = iMAOnArray(MainBuffer, Bars, DPeriod, 0, MODE_SMA, i);

   //---- Arrows and Notifications:
   // int j = rates_total - prev_calculated + 1;
   int j = 100 - prev_calculated + 1;
   if (j < 0) return 0;

   // if (j >= rates_total) j = rates_total - 1;
   for (; j > 0; j--)
   {
      if (haveSignalUp(j))
      {
         ArrowUp[j] = Low[j];

         if(ArrowsOn)
         arrows.price(ArrowUp[j]).Color(ArrowUpClr).Type("up").candle(j).draw();

         if (newCandle.IsNewCandle())
         {
            Notifications(0);
         }
      }
      if (haveSignalDown(j))
      {
         ArrowDn[j] = High[j];
         
         if(ArrowsOn)
			arrows.price(ArrowDn[j]).Color(ArrowDnClr).Type("down").candle(j).draw();
			
         if (newCandle.IsNewCandle())
         {
            Notifications(1);
         }
      }
   }
   return (0);
}
//+------------------------------------------------------------------+

bool haveSignalUp(int i)
{
   // TODO: signal up
   if (SignalBuffer[i + 1] <= MainBuffer[i + 1] && SignalBuffer[i] > MainBuffer[i])
   {
      return true;
   }

   return false;
}

bool haveSignalDown(int i)
{
   // TODO: signal down
   if (SignalBuffer[i + 1] >= MainBuffer[i + 1] && SignalBuffer[i] < MainBuffer[i])
   {
      return true;
   }

   return false;
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
