// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68981

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
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

input int len = 9; // Length
input int smooth = 9; // Smooth

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

double vwmao[], vwmaoData[], PV_DATA[], volumeData[];
int init()
{
   IndicatorName = GenerateIndicatorName("VWMA Oscilator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(4);

   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, vwmao);
   SetIndexLabel(0, "VWMA");

   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, vwmaoData);

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, PV_DATA);

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, volumeData);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   for (int pos = limit; pos >= 0; --pos)
   {
      volumeData[pos] = (double)Volume[pos];
      PV_DATA[pos] = Volume[pos] * iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_CLOSE, pos);
      double volumeAvg = iMAOnArray(volumeData, 0, len, 0, MODE_SMA, pos);
      double vwma = volumeAvg == 0 ? 0 : iMAOnArray(PV_DATA, 0, len, 0, MODE_SMA, pos) / volumeAvg;
      double sma = iMA(NULL, 0, len, 0, MODE_SMA, PRICE_CLOSE, pos);
      vwmaoData[pos] = vwma - sma;
      vwmao[pos] = iMAOnArray(vwmaoData, 0, smooth, 0, MODE_EMA, pos);
   } 
   return 0;
}