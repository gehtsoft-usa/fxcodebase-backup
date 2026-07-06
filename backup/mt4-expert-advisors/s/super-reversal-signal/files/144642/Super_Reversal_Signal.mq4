// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71766

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
#property strict
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 2
#property indicator_color1 clrDeepSkyBlue
#property indicator_color2 clrRed

#property indicator_width1 2
#property indicator_width2 2

extern int    ArrowCodeDn = 233;
extern int    ArrowCodeUp = 234;
extern int    LagBar      = 1;
extern string NoteLagBar  = "0 = Signal on current ; 1 = Wait for close";
input string       TZ                    = "== Notifications ==";  // Notifications
input bool         notifications         = false;                  // Notifications
input bool         desktop_notifications = false;                  // Desktop MT4 Notifications
input bool         email_notifications   = false;                  // Email Notifications
input bool         push_notifications    = false;                  // Push Mobile Notifications

double ArrowsUp[];
double ArrowsDn[];
double body[];
double trend[];

int OnInit()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0, ArrowsUp);
   SetIndexArrow(0, ArrowCodeDn);
   SetIndexBuffer(1, ArrowsDn);
   SetIndexArrow(1, ArrowCodeUp);
   SetIndexBuffer(2, trend);
   SetIndexBuffer(3, body);

   SetIndexStyle(0, DRAW_ARROW);
   SetIndexStyle(1, DRAW_ARROW);

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
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
   // int counted_bars = IndicatorCounted();
   // int i, limit;

   // if (counted_bars < 0) return (-1);
   // if (counted_bars > 0) counted_bars--;
   // limit = MathMin(Bars - counted_bars, Bars - 1);
   int i, limit;
   if (prev_calculated == 0)
   {
      limit = rates_total-4;
   } else
   {
      limit = prev_calculated + 1;
   }

   for (i = limit; i > 0; i--)
   {
      double gap = 3.0 * iATR(NULL, 0, 20, i) / 4.0;

      body[i] = MathAbs(open[i] - close[i]);

      trend[i] = trend[i + 1];

      if (LagBar == 1)
      {
      if ((high[i + 1] <= low[i - 1]) && (body[i] > body[i + 1]) && (body[i] > body[i + 2]) && (body[i] > body[i + 3]) && (iVolume(NULL, 0, i - LagBar) > 1)) { trend[i] = 1; }

      if ((low[i + 1] >= high[i - 1]) && (body[i] > body[i + 1]) && (body[i] > body[i + 2]) && (body[i] > body[i + 3]) && (iVolume(NULL, 0, i - LagBar) > 1)) { trend[i] = -1; }
      }

      if (LagBar == 0)
      {
         i=i-1;
			trend[i] = trend[i + 1];
			body[i] = MathAbs(open[i] - close[i]);
         if ((high[i+1] <= close[i]) && (body[i] > body[i + 1]) && (body[i] > body[i + 2]) && (body[i] > body[i + 3])) { trend[i] = 1; }
         if ((low[i+1] >= close[i]) && (body[i] > body[i + 1]) && (body[i] > body[i + 2]) && (body[i] > body[i + 3])) { trend[i] = -1; }
      }

      ArrowsUp[i] = EMPTY_VALUE;
      ArrowsDn[i] = EMPTY_VALUE;

      if (trend[i] != trend[i + 1])
      {
         if (trend[i] == 1)
         {
            ArrowsUp[i] = low[i] - gap;
         }
         if (trend[i] == -1)
         {
            ArrowsDn[i] = high[i] + gap;
         }
      }
   }

if(ArrowsUp[i+1]!=EMPTY_VALUE) { Notifications(0); }
if(ArrowsDn[i+1]!=EMPTY_VALUE) { Notifications(1); }

   return (prev_calculated);
}

// ------------------------------------------------------------------
void Notifications(int type)
{
   string text = "";
   if (type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + "Super Reversal Signal - BUY ";
   else
      text += _Symbol + " " + GetTimeFrame(_Period) + "Super Reversal Signal - SELL ";

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