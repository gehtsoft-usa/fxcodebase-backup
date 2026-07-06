// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71861

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
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 6
//--- EMA
#property indicator_label1 "MA"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
//--- TMA
#property indicator_label2 "TMA UP BAND"
#property indicator_type2  DRAW_LINE
#property indicator_color2 Green
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label3 "TMA DOWN BAND"
#property indicator_type3  DRAW_LINE
#property indicator_color3 Blue
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_label4 "TMA Main"
#property indicator_type4  DRAW_LINE
#property indicator_color4 Red
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
//--- ARROWS
#property indicator_label5 "Buy"
#property indicator_type5  DRAW_ARROW
#property indicator_color5 Green
#property indicator_label6 "Sell"
#property indicator_type6  DRAW_ARROW
#property indicator_color6 Red



input string  ITAM         = "== TMA Setup ==";  // == TMA Setup ==
extern string TimeFrame       = "current time frame";
extern int    HalfLength      = 20;
extern ENUM_APPLIED_PRICE    Price           = PRICE_CLOSE;
extern double BandsDeviations = 1;
extern bool   Interpolate     = true;
bool          alertsOn        = false;
bool          alertsOnCurrent = false;
bool          alertsOnHighLow = false;
bool          alertsMessage   = false;
bool          alertsSound     = false;
bool          alertsEmail     = false;

class TMA
{
   string _symbol;
   int    _tf;
   string _file;
   struct Parameters
   {
      int setup0;  // setup0
      int setup1;  // setup1
   };
   Parameters _setup;

  public:
   TMA(string Symbol, int TimeFrame)
   {
      _symbol = Symbol;
      _tf     = TimeFrame;
      _file   = "TMA Bands.ex4";
   }
   ~TMA() { ;}

   TMA* file(string setfile)
   {
      _file = setfile;
      return &this;
   }

   void setSetup(int set0, int set1)
   {
      _setup.setup0 = set0;
      _setup.setup1 = set1;
   }

   double calculate(int buffer, int shift)
   {
      return iCustom(_symbol, _tf, _file, 
                     TimeFrame,
                     HalfLength,                     
                     Price,
                     BandsDeviations,
                     Interpolate,
                     alertsOn,
                     alertsOnCurrent,
                     alertsOnHighLow,
                     alertsMessage,
                     alertsSound,
                     alertsEmail, 
                     buffer, shift);
   }

   double lastValue(int buffer, bool candle = false)
   {
      double value = 0;
      int    i     = 0;
      while (value == 0 || i == 2000)
      {
         value = calculate(buffer, i);
         i++;
      }

      if (candle)
      {
         return i;
      }
      return value;
   }

   double upBand(int shift)
   {
      return calculate(1,shift);
   }
   double downBand(int shift)
   {
      return calculate(2, shift);
   }
   double main(int shift)
   {
      return calculate(0, shift);
   }


   void printSetup()
   {
      Print("setup0 : ", _setup.setup0);
      Print("setup1 : ", _setup.setup1);
      // Print("setup2 : ", _setup.setup2);
      // Print("setup3 : ", _setup.setup3);
      // Print("setup4 : ", _setup.setup4);
      // Print("setup5 : ", _setup.setup5);
      // Print("setup6 : ", _setup.setup6);
      // Print("setup7 : ", _setup.setup7);
      // Print("setup8 : ", _setup.setup8);
      // Print("setup9 : ", _setup.setup9);
      // Print("setup10: ", _setup.setup10);
   }
};
TMA tma(_Symbol, _Period);

//--- indicator buffers
double TMAup[];
double TMAdn[];
double TMAmain[];
double MA[];
double arrowUp[];
double arrowDn[];

// ------------------------------------------------------------------
input string             Iema           = "== Moving Average Setup ==";  // == Moving Average Setup ==
input int                maPeriod       = 5;                             // Period
int                      maShift        = 0;                             // Ma Shift
input ENUM_MA_METHOD     maMethod       = MODE_EMA;                      // Method
input ENUM_APPLIED_PRICE maAppliedPrice = PRICE_CLOSE;                   // Applied Price
input string       TZ                      = "== Notifications ==";      // Notifications
input bool         notifications           = false;                      // Notifications
input bool         desktop_notifications   = false;                      // Desktop MT4 Notifications
input bool         email_notifications     = false;                      // Email Notifications
input bool         push_notifications      = false;                      // Push Mobile Notifications
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   //--- indicator buffers mapping
   SetIndexBuffer(0, MA, INDICATOR_DATA);
   SetIndexBuffer(1, TMAup, INDICATOR_DATA);
   SetIndexBuffer(2, TMAdn, INDICATOR_DATA);
   SetIndexBuffer(3, TMAmain, INDICATOR_DATA);
   SetIndexBuffer(4, arrowUp, INDICATOR_DATA);
   SetIndexBuffer(5, arrowDn, INDICATOR_DATA);

   SetIndexArrow(4, 233);
   SetIndexArrow(5, 234);
   // SetIndexStyle(0,DRAW_HISTOGRAM, 0, 2, Red);

   //---
   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   int limit;
   if (prev_calculated == 0)
   {
      limit = 500 - maPeriod;
   } else
   {
      limit = prev_calculated + 1;
   }

   for (int i = limit; i > 0; i--)
   {
      MA[i]      = iMA(_Symbol, _Period, maPeriod, 0, maMethod, maAppliedPrice, i);
      TMAup[i]   = tma.upBand(i);
      TMAdn[i]   = tma.downBand(i);
      TMAmain[i] = tma.main(i);

      // cross up - UpBand
      if (MA[i] > TMAup[i] && MA[i + 1] <= TMAup[i + 1])  // && arrowUp[i] == EMPTY_VALUE)
      {
         arrowUp[i] = TMAup[i];
         Notifications(0);
      }
      if (MA[i] < TMAup[i] && MA[i + 1] >= TMAup[i + 1])  //  && arrowDn[i] == EMPTY_VALUE)
      {
         arrowDn[i] = TMAup[i];
			Notifications(1);
      }

      if (MA[i] > TMAdn[i] && MA[i + 1] <= TMAdn[i + 1])  //  && arrowUp[i] == EMPTY_VALUE)
      {
         arrowUp[i] = TMAdn[i];
			Notifications(0);
      }
      if (MA[i] < TMAdn[i] && MA[i + 1] >= TMAdn[i + 1])  //  && arrowDn[i] == EMPTY_VALUE)
      {
         arrowDn[i] = TMAdn[i];
			Notifications(1);
      }
   }

   return (i);
}

void Notifications(int type)
{
   string text = "TMA-MA: ";
   if (type == 0) text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
   else text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

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