// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72012

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
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red



//----
extern double ki = 2;
//----
double za[], z, za2[], z2;

// ------------------------------------------------------------------
input string       TZ                      = "== Notifications ==";      // Notifications
input bool         notifications           = false;                      // Notifications
input bool         desktop_notifications   = false;                      // Desktop MT4 Notifications
input bool         email_notifications     = false;                      // Email Notifications
input bool         push_notifications      = false;                      // Push Mobile Notifications

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   SetIndexBuffer(0, za);
   SetIndexBuffer(1, za2);
   SetIndexStyle(0, DRAW_LINE, 0, 2);
   SetIndexStyle(1, DRAW_LINE, 0, 2);
   return (0);
}
//+------------------------------------------------------------------+
//| Custom indicator start function                                  |
//+------------------------------------------------------------------+
// clang-format off
int start() 
  {
   int i, cbi;
   int n, ai, bi, f, ai2, bi2, f2; 
   cbi = Bars - IndicatorCounted() - 1;
   if(IndicatorCounted()==0) cbi--;
//----
   for(i = cbi; i >= 0; i--) 
     { 
       if(Close[i] > z && Close[i] > Close[i+1]) z = za[i+1] + (Close[i] - za[i+1]) / ki;
       if(Close[i] < z && Close[i] < Close[i+1]) z = za[i+1] + (Close[i] - za[i+1]) / ki;
       if(Close[i] > z2 && Close[i] < Close[i+1]) z2 = za2[i+1] + (Close[i] - za2[i+1]) / ki;
       if(Close[i] < z2 && Close[i] > Close[i+1]) z2 = za2[i+1] + (Close[i] - za2[i+1]) / ki;
       if(i > Bars - 5) 
         {
           z = Close[i]; 
           z2 = z;
         }
       za[i] = z;  
       za2[i] = z2;
     
      if(crossUp(i)) { Notifications(0); }
      if(crossDn(i)) { Notifications(1); }
     }

//----
   return(0);
  }

// clang-format on
bool crossUp(int i)
{
  if(za[i] > za2[i] && za[i+1] <= za2[i+1])
  {
    return true;
  }
  return false;
}
bool crossDn(int i)
{
  if(za[i] < za2[i] && za[i+1] >= za2[i+1])
  {
    return true;
  }
  return false;
}


void Notifications(int type)
{
   if (!notifications) return;

   string text = "ang_Zad_2Ci - ";
   if (type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " Signal BUY ";
   else
      text += _Symbol + " " + GetTimeFrame(_Period) + " Signal SELL ";
   text += " ";

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
