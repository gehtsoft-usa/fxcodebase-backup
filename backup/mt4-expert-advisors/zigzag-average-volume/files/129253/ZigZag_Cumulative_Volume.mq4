// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67212

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
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_label1 "Volune (up)"
#property indicator_color2 Red
#property indicator_label2 "Volune (down)"

extern int Depth = 12; // Depth
extern int Deviation = 5; // Deviation
extern int Backstep = 3; // Backstep

extern int Period = 100; // Backstep

extern int Length = 60;

double outUp[], outDown[];

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
   double temp = iCustom(NULL, 0, "ZigZag", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'ZigZag' indicator");
      return INIT_FAILED;
   }
   temp = iCustom(NULL, 0, "Cumulative_Volume v1.3", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'Cumulative_Volume v1.3' indicator");
      return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("ZigZag Volume");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, outUp);
   SetIndexStyle(1, DRAW_HISTOGRAM);
   SetIndexBuffer(1, outDown);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

bool GetZZ(const int period, bool &isUp, double &vol, int &first, int &second)
{
   first = -1;
   double firstZZ = 0;

   int i = period;
   long volume = 0;
   while (i < Bars)
   {
      double zigzag = iCustom(_Symbol, _Period, "ZigZag", Depth, Deviation, Backstep, 0, i);
      double vol2 = iCustom(_Symbol, _Period, "Cumulative_Volume v1.3", Length, 0, i);
      if (vol2 != EMPTY_VALUE)
      {
         if (zigzag != 0.0)
         {
            if (first == -1)
            {
               firstZZ = zigzag;
               first = i;
            }
            else
            {
               second = i;
               isUp = firstZZ > zigzag;
               volume += vol2;
               vol = (double)volume;
               return true;
            }
         }
         if (first != -1)
         {
            volume += vol2;
         }
      }
	  
      ++i;
   }
   return false;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = Bars - 1;
   if(ExtCountedBars > 1) 
      limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      bool isUp;
      double vol;
      int first;
      int second;
      if (GetZZ(pos, isUp, vol, first, second))
      {
         for (int i = first; i <= second; ++i)
         {
            if (isUp)
            {
               outUp[i] = vol;
               outDown[i] = EMPTY_VALUE;
            }
            else
            {
               outUp[i] = EMPTY_VALUE;
               outDown[i] = vol;
            }
         }
      }
      pos--;
   } 
   return 0;
}