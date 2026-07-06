// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67050
// Id: 23082
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66535

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
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow
#property strict

enum AveragesMethod
{
   SMA = MODE_SMA, // SMA
   EMA = MODE_EMA, // EMA
   SMMA = MODE_SMMA, // SMMA
   LWMA = MODE_LWMA, // LWMA
   WMA,
   SineWMA,
   TriMA,
   LSMA,
   HMA,
   ZeroLagEMA,
   DEMA,
   T3MA,
   ITrend,
   Median,
   GeoMean,
   REMA,
   ILRS,
   IE2,
   TriMAgen,
   JSmooth
};

extern int Length = 20;
extern int Price = 0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  
extern AveragesMethod Method = SMA; // Method

double AA[];
double wma_k;

int init()
{
   wma_k = 1. / Length;
   IndicatorShortName("Averages");
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, AA);
   switch (Method)
   {
      case SMA:
      case EMA:
      case SMMA:
      case LWMA:
      case WMA:
         break;
      case SineWMA:
         {
            double temp = iCustom(NULL, 0, "SineWMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'SineWMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=63064");
               return INIT_FAILED;
            }
         }
         break;
      case TriMA:
         {
            double temp = iCustom(NULL, 0, "TriMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'TriMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59627");
               return INIT_FAILED;
            }
         }
         break;
      case LSMA:
         {
            double temp = iCustom(NULL, 0, "LSMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'LSMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59628");
               return INIT_FAILED;
            }
         }
         break;
      case HMA:
         {
            double temp = iCustom(NULL, 0, "HMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'HMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59630");
               return INIT_FAILED;
            }
         }
         break;
      case ZeroLagEMA:
         {
            double temp = iCustom(NULL, 0, "ZeroLagEMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'ZeroLagEMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59634");
               return INIT_FAILED;
            }
         }
         break;
      case DEMA:
         {
            double temp = iCustom(NULL, 0, "DEMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'DEMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=20396");
               return INIT_FAILED;
            }
         }
         break;
      case T3MA:
         {
            double temp = iCustom(NULL, 0, "T3_MA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'T3_MA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=63063");
               return INIT_FAILED;
            }
         }
         break;
      case ITrend:
         {
            double temp = iCustom(NULL, 0, "ITrendMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'ITrendMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59635");
               return INIT_FAILED;
            }
         }
         break;
      case Median:
         {
            double temp = iCustom(NULL, 0, "MedianMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'MedianMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=20876");
               return INIT_FAILED;
            }
         }
         break;
      case GeoMean:
         {
            double temp = iCustom(NULL, 0, "GeoMin_MA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'GeoMin_MA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=20877");
               return INIT_FAILED;
            }
         }
         break;
      case REMA:
         {
            double temp = iCustom(NULL, 0, "REMA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'REMA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59636");
               return INIT_FAILED;
            }
         }
         break;
      case ILRS:
         {
            double temp = iCustom(NULL, 0, "ILRS_MA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'ILRS_MA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59963");
               return INIT_FAILED;
            }
         }
         break;
      case IE2:
         {
            double temp = iCustom(NULL, 0, "IE2_MA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'IE2_MA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59964");
               return INIT_FAILED;
            }
         }
         break;
      case TriMAgen:
         {
            double temp = iCustom(NULL, 0, "TriMAgen", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'TriMAgen' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59965");
               return INIT_FAILED;
            }
         }
         break;
      case JSmooth:
         {
            double temp = iCustom(NULL, 0, "JSmooth_MA", 0, 0);
            if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
            {
               Alert("Please, install the 'JSmooth_MA' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59966");
               return INIT_FAILED;
            }
         }
         break;
   }

   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   int pos = limit;
   while(pos>=0)
   {
      switch (Method)
      {
         case SMA:
            AA[pos] = iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos);
            break;
         case EMA:
            AA[pos] = iMA(NULL, 0, Length, 0, MODE_EMA, Price, pos);
            break;
         case SMMA:
            AA[pos] = iMA(NULL, 0, Length, 0, MODE_SMMA, Price, pos);
            break;
         case LWMA:
            AA[pos] = iMA(NULL, 0, Length, 0, MODE_LWMA, Price, pos);
            break;
         case WMA:
            if (pos == Bars - 2)
            {
               AA[pos] = iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos);
            }
            else
            {
               AA[pos] = (iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos) - AA[pos + 1]) * wma_k + AA[pos + 1];
            }
            break;
         case SineWMA:
            AA[pos] = iCustom(NULL, 0, "SineWMA", Length, Price, 0, pos);
            break;
         case TriMA:
            AA[pos] = iCustom(NULL, 0, "TriMA", Length, Price, 0, pos);
            break;
         case LSMA:
            AA[pos] = iCustom(NULL, 0, "LSMA", Length, Price, 0, pos);
            break;
         case HMA:
            AA[pos] = iCustom(NULL, 0, "HMA", Length, Price, 0, pos);
            break;
         case ZeroLagEMA:
            AA[pos] = iCustom(NULL, 0, "ZeroLagEMA", Length, Price, 0, pos);
            break;
         case DEMA:
            AA[pos] = iCustom(NULL, 0, "DEMA", Length, Price, 0, pos);
            break;
         case T3MA:
            AA[pos] = iCustom(NULL, 0, "T3MA", Length, Price, 0, pos);
            break;
         case ITrend:
            AA[pos] = iCustom(NULL, 0, "ITrendMA", Length, Price, 0, pos);
            break;
         case Median:
            AA[pos] = iCustom(NULL, 0, "MedianMA", Length, Price, 0, pos);
            break;
         case GeoMean:
            AA[pos] = iCustom(NULL, 0, "GeoMin_MA", Length, Price, 0, pos);
            break;
         case REMA:
            AA[pos] = iCustom(NULL, 0, "REMA", Length, Price, 0, pos);
            break;
         case ILRS:
            AA[pos] = iCustom(NULL, 0, "ILRS_MA", Length, Price, 0, pos);
            break;
         case IE2:
            AA[pos] = iCustom(NULL, 0, "IE2_MA", Length, Price, 0, pos);
            break;
         case TriMAgen:
            AA[pos] = iCustom(NULL, 0, "TriMAgen", Length, Price, 0, pos);
            break;
         case JSmooth:
            AA[pos] = iCustom(NULL, 0, "JSmooth_MA", Length, Price, 0, pos);
            break;
      }
      
      pos--;
   } 
   return(0);
}

