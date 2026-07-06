// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67202

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Blue
#property indicator_label1 "Arrows"

double out[], range[];

extern double Multiplicator = 5; // Times the average range
extern int AveragePeriods = 20; // Average periods
extern bool DrawArrow = false; // Draw arrow instead of line
extern color LineColor = clrRed; // Line color
extern int BarsLimit = 1000; // Bars limit

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

int init()
{
   IndicatorName = GenerateIndicatorName("...");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);

   IndicatorBuffers(2);

   SetIndexStyle(0, DRAW_ARROW, 0, 2);
   SetIndexArrow(0, 217);
   SetIndexBuffer(0, out);

   SetIndexBuffer(1, range);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   int limit = Bars - 1;
   if(ExtCountedBars > 1) 
      limit = MathMax(1, Bars - ExtCountedBars - 1);
   int pos = MathMin(BarsLimit, limit);
   while (pos > 0)
   {
      out[pos] = EMPTY_VALUE;
      range[pos] = High[pos] - Low[pos];
      if (pos < limit)
      {
         double avg = iMAOnArray(range, 0, AveragePeriods, 0, MODE_SMA, pos + 1);
         if (range[pos] >= avg * Multiplicator)
         {
            if (DrawArrow)
               out[pos] = Close[pos];
            else
            {
               ObjectCreate(0, IndicatorObjPrefix + TimeToStr(Time[pos]), OBJ_TREND, 0, Time[pos], Close[pos], Time[pos - 1], Close[pos]);
               ObjectSetInteger(0, IndicatorObjPrefix + TimeToStr(Time[pos]), OBJPROP_COLOR, LineColor); 
               ObjectSetInteger(0, IndicatorObjPrefix + TimeToStr(Time[pos]), OBJPROP_RAY_RIGHT, true); 
            }
         }
      }

      pos--;
   } 
   return(0);
}

