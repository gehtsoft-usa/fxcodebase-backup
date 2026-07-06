// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67051

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

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green
#property indicator_label1 "Oscillator"

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

extern string Caption1 = ""; // 1. MA Calculation
extern AveragesMethod Method1 = ZeroLagEMA; // Method
extern int Period1 = 14; // Period
extern string Caption2 = ""; // 2. MA Calculation
extern AveragesMethod Method2 = EMA; // Method
extern int Period2 = 28; // Period
extern string Caption3 = ""; // 3. MA Calculation
extern AveragesMethod Method3 = SMA; // Method
extern int Period3 = 1; // Period

double out[];

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
   double temp = iCustom(NULL, 0, "averages", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'averages' indicator");
      return INIT_FAILED;
   }

   IndicatorName = GenerateIndicatorName("Three MA oscillators");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out);
   
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
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      double val1 = iCustom(NULL, 0, "averages", Period1, PRICE_CLOSE, Method1, 0, pos);
      double val2 = iCustom(NULL, 0, "averages", Period2, PRICE_CLOSE, Method2, 0, pos);
      double val3 = iCustom(NULL, 0, "averages", Period3, PRICE_CLOSE, Method3, 0, pos);
      if (val3 != 0.0)
         out[pos] = (val1 - val2) / val3;
      pos--;
   } 
   return(0);
}

