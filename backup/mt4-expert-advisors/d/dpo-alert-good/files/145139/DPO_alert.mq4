// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71882

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

// Your donations will allow the service to continue onward.
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
#property link "http://fxcodebase.com"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_color2 Red
//----
extern int x_prd     = 14;
extern int CountBars = 300;
// ------------------------------------------------------------------
input string TZ                    = "== Notifications ==";  // Notifications
input bool   notificationsOn       = false;                  // Notifications On:
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
//---- buffers
double dpo[], dpou[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

bool reset     = false;
int  last_time = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
   string short_name;
   //---- indicator line
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, dpo);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, dpou);
   //---- name for DataWindow and indicator subwindow label
   short_name = "DPO(" + x_prd + ")";
   IndicatorShortName(short_name);
   SetIndexLabel(0, short_name);
   //----
   if (CountBars >= Bars)
      CountBars = Bars;
   SetIndexDrawBegin(0, Bars - CountBars + x_prd + 1);
   //----
   return (0);
}
//+------------------------------------------------------------------+
//| DPO                                                              |
//+------------------------------------------------------------------+
int start()
{
   int    i, counted_bars = IndicatorCounted();
   double t_prd;
   //----
   if (Bars <= x_prd)
      return (0);
   //---- initial zero
   if (counted_bars < x_prd)
   {
      for (i = 1; i <= x_prd; i++)
         dpo[CountBars - i] = 0.0;
   }
   //----
   i     = CountBars - x_prd - 1;
   t_prd = x_prd / 2 + 1;
   //----
   double val;
   while (i >= 0)
   {
      val = Close[i] - iMA(NULL, 0, x_prd, t_prd, MODE_SMA, PRICE_CLOSE, i);
      dpo[i] = val;
      if (val>=0) 
      {
         dpou[i] = val;
      }
      i--;
   }
   //----
   if (notificationsOn)
   {
      if (last_time != Time[0])
      {
         last_time = Time[0];
         reset     = true;
      }
      if (reset == true && dpo[1] > 0 && dpo[0] <= 0)
      {
         Notify(1);
         reset = false;
      }
      if (reset == true && dpo[1] < 0 && dpo[0] >= 0)
      {
         Notify(0);
         reset = false;
      }
   }
   return (0);
}
//+------------------------------------------------------------------+
void Notify(int type)
{
   string text = "DPO Indicator: ";
   switch (type)
   {
      case 0: text += " Cross Zero Line to UP -" + _Symbol + " " + GetTimeFrame(_Period); break;
      case 1: text += " Cross Zero Line to Down -" + _Symbol + " " + GetTimeFrame(_Period); break;
   }

   text += " ";

   if (!notificationsOn)
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
