// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76270

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
#property indicator_chart_window
#property indicator_buffers 4
#property  indicator_plots 2
#property indicator_color1  clrLime
#property indicator_color2  clrRed



input ENUM_TIMEFRAMES  inpTimeFrame      = PERIOD_CURRENT;  // Time frame to use
input int              BarLimit          = 1000;
input int              KPeriod           = 13;               // Stochastic K period
input int              DPeriod           = 2;               // Stochastic D period
input int              Slowing           = 8;               // Stochastic slowing
input ENUM_MA_METHOD   MA_Method         = MODE_SMMA;       // Stochastic ma type
input ENUM_STO_PRICE   PriceField        = 0;               // Stochastic price
input bool             arr_onKD_cross    = true;            // Show arrows on stoch/signal cross
input bool             arr_onK_OBOScross = true;            // Show arrows on stoch leaving OB/OS
input bool             arr_onD_OBOScross = true;            // Show arrows on stoch signal leaving OB/OS
input double           OverBoughtLevel   = 80;              // Overbought level
input double           OverSoldLevel     = 20;              // Oversold level
input bool             alertsOn          = true;            // Alerts on true/false?
input bool             alertsOnCurrent   = false;           // Alerts current bar true/false?
input bool             alertsMessage     = true;            // Alerts message true/false?
input bool             alertsSound       = false;           // Alerts sound true/false?
input bool             alertsEmail       = false;           // Alerts email true/false?
input bool             alertsNotify      = false;           // Alerts notification true/false?
input string           soundFile         = "alert2.wav";    // Alerts Sound file
input bool             ArrowOnFirst      = true;            // Arrow on first mtf bar
input int              ArrowCodeUp       = 241;             // Up arrow code
input int              ArrowCodeDn       = 242;             // Down arrow code
input double           ArrowGapUp        = 0.5;             // Up arrow gap
input double           ArrowGapDn        = 0.5;             // Down arrow gap
input int              ArrowSizeUp       = 2;               // Up arrow size
input int              ArrowSizeDn       = 2;               // Down arrow size

double CrossUp[], CrossDn[], trend[], count[];
string indicatorFileName;
ENUM_TIMEFRAMES TimeFrame;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, CrossUp, INDICATOR_DATA);
   SetIndexBuffer(1, CrossDn, INDICATOR_DATA);
   SetIndexBuffer(2, trend, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, count, INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, ArrowCodeUp);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_ARROW, ArrowCodeDn);
   ArraySetAsSeries(CrossUp, true);
   ArraySetAsSeries(CrossDn, true);
   ArraySetAsSeries(trend, true);
   ArraySetAsSeries(count, true);
   if(inpTimeFrame == PERIOD_CURRENT || inpTimeFrame <= Period())
      TimeFrame = Period();
   else
     {
      TimeFrame = inpTimeFrame;
      EventSetMillisecondTimer(500);
     }
   IndicatorSetString(INDICATOR_SHORTNAME, (string)(TimeFrame) + " Stoch cross");
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ChartSetSymbolPeriod(ChartID(), _Symbol, Period());
   ChartRedraw();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int  OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[],
                 const double &open[],
                 const double &high[],
                 const double &low[],
                 const double &close[],
                 const long &tick_volume[],
                 const long &volume[],
                 const int &spread[])
  {
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   int counted_bars = prev_calculated;
   if(counted_bars < 0)
      return(-1);
   if(counted_bars > 0)
      counted_bars--;
   int limit = MathMin(rates_total, BarLimit);
   for(int i = limit - 1; i >= 0; i--)
     {
      datetime barTime = iTime(_Symbol, Period(), i);
      int y = iBarShift(_Symbol, TimeFrame, barTime);
      if(y < 0)
         y = 0;
      //
      double stoNow = iStochasticMQL4(Symbol(), TimeFrame, KPeriod, DPeriod, Slowing, MA_Method, PriceField, 0, y);
      double stoPre = iStochasticMQL4(Symbol(), TimeFrame, KPeriod, DPeriod, Slowing, MA_Method, PriceField, 0, y + 1);
      double sigNow = iStochasticMQL4(Symbol(), TimeFrame, KPeriod, DPeriod, Slowing, MA_Method, PriceField, 1, y);
      double sigPre = iStochasticMQL4(Symbol(), TimeFrame, KPeriod, DPeriod, Slowing, MA_Method, PriceField, 1, y + 1);
      trend[i] = EMPTY_VALUE;
      CrossUp[i] = EMPTY_VALUE;
      CrossDn[i] = EMPTY_VALUE;
      if(arr_onK_OBOScross && trend[i] == EMPTY_VALUE)
         trend[i] = (stoNow > OverSoldLevel && stoPre < OverSoldLevel) ? 1 : (stoNow < OverBoughtLevel && stoPre > OverBoughtLevel) ? -1 : EMPTY_VALUE;
      if(arr_onD_OBOScross && trend[i] == EMPTY_VALUE)
         trend[i] = (sigNow > OverSoldLevel && sigPre < OverSoldLevel) ? 1 : (sigNow < OverBoughtLevel && sigPre > OverBoughtLevel) ? -1 : EMPTY_VALUE;
      if(arr_onKD_cross && trend[i] == EMPTY_VALUE)
         trend[i] = (stoNow > sigNow && stoPre < sigPre) ? 1 : (stoNow < sigNow && stoPre > sigPre) ? -1 : EMPTY_VALUE;
      if(i < rates_total - 1 && trend[i] != trend[i + 1])
        {
         if(trend[i] ==  1)
            CrossUp[i] =  low[i] - iATRMQL4(Symbol(), Period(), 15, i) * ArrowGapUp;
         if(trend[i] == -1)
            CrossDn[i] = high[i] + iATRMQL4(Symbol(), Period(), 15, i) * ArrowGapDn;
        }
     }
   if(alertsOn)
     {
      int whichBar = (alertsOnCurrent) ? 0 : 1;
      if(trend[whichBar] != trend[whichBar + 1])
        {
         if(trend[whichBar] == 1)
            doAlert(whichBar, "buy");
         if(trend[whichBar] == -1)
            doAlert(whichBar, "sell");
        }
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(int forBar, string doWhat)
  {
   static string   previousAlert = "nothing";
   static datetime previousTime;
   string message;
   if(previousAlert != doWhat || previousTime != iTime(Symbol(), Period(), forBar))
     {
      previousAlert  = doWhat;
      previousTime   = iTime(Symbol(), Period(), forBar);
      message = timeFrameToString(_Period) + " " + _Symbol + " at " + TimeToString(TimeLocal(), TIME_SECONDS) + " Stochastic crossing " + doWhat;
      if(alertsMessage)
         Alert(message);
      if(alertsNotify)
         SendNotification(message);
      if(alertsEmail)
         SendMail(_Symbol + " Stochastic crossing ", message);
      if(alertsSound)
         PlaySound(soundFile);
     }
  }

string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int    iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string timeFrameToString(int tf)
  {
   for(int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if(tf == iTfTable[i])
         return(sTfTable[i]);
   return("");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iATRMQL4(string symbol, int tf, int period, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   int handle = iATR(symbol, timeframe, period);
   if(handle < 0)
     {
      Print("The iATR object is not created: Error", GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle, 0, shift));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iStochasticMQL4(string symbol, int tf, int Kperiod, int Dperiod, int slowing, int method, int field, int mode, int shift)
  {
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   ENUM_MA_METHOD ma_method = MethodMigrate(method);
   ENUM_STO_PRICE price_field = StoFieldMigrate(field);
   int handle = iStochastic(symbol, timeframe, Kperiod, Dperiod,
                            slowing, ma_method, price_field);
   if(handle < 0)
     {
      Print("The iStochastic object is not created: Error", GetLastError());
      return(-1);
     }
   else
      return(CopyBufferMQL4(handle, mode, shift));
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0:
         return(PERIOD_CURRENT);
      case 1:
         return(PERIOD_M1);
      case 5:
         return(PERIOD_M5);
      case 15:
         return(PERIOD_M15);
      case 30:
         return(PERIOD_M30);
      case 60:
         return(PERIOD_H1);
      case 240:
         return(PERIOD_H4);
      case 1440:
         return(PERIOD_D1);
      case 10080:
         return(PERIOD_W1);
      case 43200:
         return(PERIOD_MN1);
      case 2:
         return(PERIOD_M2);
      case 3:
         return(PERIOD_M3);
      case 4:
         return(PERIOD_M4);
      case 6:
         return(PERIOD_M6);
      case 10:
         return(PERIOD_M10);
      case 12:
         return(PERIOD_M12);
      case 16385:
         return(PERIOD_H1);
      case 16386:
         return(PERIOD_H2);
      case 16387:
         return(PERIOD_H3);
      case 16388:
         return(PERIOD_H4);
      case 16390:
         return(PERIOD_H6);
      case 16392:
         return(PERIOD_H8);
      case 16396:
         return(PERIOD_H12);
      case 16408:
         return(PERIOD_D1);
      case 32769:
         return(PERIOD_W1);
      case 49153:
         return(PERIOD_MN1);
      default:
         return(PERIOD_CURRENT);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CopyBufferMQL4(int handle, int index, int shift)
  {
   double buf[];
   switch(index)
     {
      case 0:
         if(CopyBuffer(handle, 0, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 1:
         if(CopyBuffer(handle, 1, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 2:
         if(CopyBuffer(handle, 2, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 3:
         if(CopyBuffer(handle, 3, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      case 4:
         if(CopyBuffer(handle, 4, shift, 1, buf) > 0)
            return(buf[0]);
         break;
      default:
         break;
     }
   return(EMPTY_VALUE);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_MA_METHOD MethodMigrate(int method)
  {
   switch(method)
     {
      case 0:
         return(MODE_SMA);
      case 1:
         return(MODE_EMA);
      case 2:
         return(MODE_SMMA);
      case 3:
         return(MODE_LWMA);
      default:
         return(MODE_SMA);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_APPLIED_PRICE PriceMigrate(int price)
  {
   switch(price)
     {
      case 1:
         return(PRICE_CLOSE);
      case 2:
         return(PRICE_OPEN);
      case 3:
         return(PRICE_HIGH);
      case 4:
         return(PRICE_LOW);
      case 5:
         return(PRICE_MEDIAN);
      case 6:
         return(PRICE_TYPICAL);
      case 7:
         return(PRICE_WEIGHTED);
      default:
         return(PRICE_CLOSE);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_STO_PRICE StoFieldMigrate(int field)
  {
   switch(field)
     {
      case 0:
         return(STO_LOWHIGH);
      case 1:
         return(STO_CLOSECLOSE);
      default:
         return(STO_LOWHIGH);
     }
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=76270

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+