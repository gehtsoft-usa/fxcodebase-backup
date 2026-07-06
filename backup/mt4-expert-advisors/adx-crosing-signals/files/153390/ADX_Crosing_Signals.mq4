//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=74364

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                       
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property version "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_label1 "Arrow Up"
#property indicator_type1  DRAW_ARROW
#property indicator_color1 clrBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label2 "Arrow Down"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrRed
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
//--- indicator buffers
double ArrowUp[];
double ArrowDn[];

int nextSignal = 0; // 1.bull 2.bear
// ------------------------------------------------------------------

input string T0                    = "== Break Setup ==";    // ————————————
input int    nCandles              = 2;                      // Maximum candle to break previous:
input string T1                    = "== Notifications ==";  // ————————————
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input string T2                    = "== Set Arrows ==";     // ————————————
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

input string             tADX            = "== ADX Setup ==";  // ————————————
input int                AdxPeriod       = 14;                 // Period Main
input int                AdxPeriodFast   = 7;                 // Period Fast
input int                AdxPeriodSlow   = 21;                 // Period Slow
input ENUM_APPLIED_PRICE AdxAppliedPrice = PRICE_CLOSE;        // Applied Price
input double             AdxLevelMain    = 25;                 // Signal Main Level
input double             AdxLevelBuy     = 15;                 // Signal DM+ Level
input double             AdxLevelSell    = 15;                 // Signal DM- Level

// ------------------------------------------------------------------

class ADX
{
   string _symbol;
   int    _tf;
   struct ADXParameters
   {
      int setup0;  // Period
      int setup1;  // AppliedPrice
   };
   ADXParameters _setup;

  public:
   ADX(string Symbol, int TimeFrame)
   {
      _symbol = Symbol;
      _tf     = TimeFrame;
      setSetup(AdxPeriod, AdxAppliedPrice);
   }
   ADX()
   {
      _symbol = _Symbol;
      _tf     = _Period;
      setSetup(AdxPeriod, AdxAppliedPrice);
   }

   ~ADX() { ;}

   void setSetup(int period, int apPrice)
   {
      _setup.setup0 = period;
      _setup.setup1 = apPrice;
   }

   double calculate(int buffer, int shift)
   {
      return iADX(_symbol, _tf, _setup.setup0, _setup.setup1, buffer, shift);
   }

   // LINES:
   double Main(int shift)
   {
      return calculate(0, shift);
   }
   double PlusDi(int shift)
   {
      return calculate(1, shift);
   }
   double MinusDi(int shift)
   {
      return calculate(2, shift);
   }

   // DIRECTIONS:
   bool bull(int shift)
   {
      if (PlusDi(shift) > MinusDi(shift))
      {
         return true;
      }
      return false;
   }
   bool bear(int shift)
   {
      if (PlusDi(shift) < MinusDi(shift))
      {
         return true;
      }
      return false;
   }

   // MAIN 
   bool MainBull(int shift)
   {
      double actual = calculate(0, shift);
      if ( actual > AdxLevelMain )
      {
         return true;
      }
      return false;
   }
   bool MainBear(int shift)
   {
      double actual = calculate(0, shift);
      if ( actual < AdxLevelMain )
      {
         return true;
      }
      return false;
   }
   // LEVEL CROSSES
   bool MainCrossLevel(int shift)
   {
      double actual = calculate(0, shift);
      double before = calculate(0, shift + 1);
      if ((actual > AdxLevelMain) && (before <= AdxLevelMain))
      {
         return true;
      }
      return false;
   }
   bool PlusDiCrossLevel(int shift)
   {
      double actual = calculate(1, shift);
      double before = calculate(1, shift + 1);
      if ((actual > AdxLevelBuy) && (before <= AdxLevelBuy))
      {
         return true;
      }
      return false;
   }
   bool MinusDiCrossLevel(int shift)
   {
      double actual = calculate(2, shift);
      double before = calculate(2, shift + 1);
      if ((actual > AdxLevelSell) && (before <= AdxLevelSell))
      {
         return true;
      }
      return false;
   }

};
ADX adxMain();
ADX adxFast();
ADX adxSlow();

// ------------------------------------------------------------------
int OnInit()
{
   //--- indicator buffers mapping
   SetIndexBuffer(0, ArrowUp, INDICATOR_DATA);
   SetIndexArrow(0, 233);
   SetIndexStyle(0, DRAW_ARROW, EMPTY, 1, ArrowUpClr);
   SetIndexBuffer(1, ArrowDn, INDICATOR_DATA);
   SetIndexStyle(1, DRAW_ARROW, EMPTY, 1, ArrowDnClr);
   SetIndexArrow(1, 234);
   if (!ArrowsOn)
   {
      SetIndexStyle(0, DRAW_NONE);
      SetIndexStyle(1, DRAW_NONE);
   }
   //---

   adxMain.setSetup(AdxPeriod, AdxAppliedPrice);
   adxFast.setSetup(AdxPeriodFast, AdxAppliedPrice);
   adxSlow.setSetup(AdxPeriodSlow, AdxAppliedPrice);
       
    return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }
// ------------------------------------------------------------------

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
       if(nextSignal == 1 || nextSignal==0)
       if(haveSignalUp(i))
         {
             nextSignal = 2;
             ArrowUp[i] = Low[i];
            if (newCandle.IsNewCandle())
            {
               Notifications(0);
            }
       }

       if(nextSignal == 2 || nextSignal == 0)
           if(haveSignalDown(i))
         {
             nextSignal = 1;
             ArrowDn[i] = High[i];
            if (newCandle.IsNewCandle())
            {
               Notifications(1);
            }
         }
   }

   return (rates_total);
}

// ------------------------------------------------------------------

bool haveSignalUp(int i)
{
   // TODO: signal up

   //	"Strong Up Trend";
   // DMI+ / DMI Level CrossOver
   // ADX > ADX Level
   // ADM+ > DMI-

    // if(adx.bull(i) == true && adx.PlusDiCrossLevel(i) == true && adx.Main(i) > AdxLevelMain)
    if(adxMain.MainBull(i) == true && adxFast.MainBull(i) == true && adxSlow.MainBull(i))
    {
      return true;
    }

   return false;
}

bool haveSignalDown(int i)
{
   // TODO: signal down

   // "Strong Down Trend";
   // DMI- / DMI Level CrossOver
   // ADX > ADX Level
   // ADM+ < DMI-
    // if (adx.bear(i) == true && adx.MinusDiCrossLevel(i)== true && adx.Main(i) > AdxLevelMain)
    if(adxMain.MainBear(i) == true && adxFast.MainBear(i) == true && adxSlow.MainBear(i))
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
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+