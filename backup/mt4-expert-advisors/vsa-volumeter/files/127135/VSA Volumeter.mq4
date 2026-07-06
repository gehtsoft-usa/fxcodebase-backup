// Id: 25415
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68610

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
#property indicator_color1 Green
#property indicator_label1 "VSA"

extern int Depth = 12; // Depth
extern int Deviation = 5; // Deviation
extern int Backstep = 3; // Backstep

double out[], up[], down[];

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
   IndicatorName = GenerateIndicatorName("VSA Volumeter");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorBuffers(3);

   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, out);

   SetIndexBuffer(1, up);
   SetIndexBuffer(2, down);
   
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
            volume += Volume[i];
            vol = (double)volume / (i - first);
            return true;
         }
      }
      if (first != -1)
      {
         volume += Volume[i];
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
         if (isUp)
         {
            up[second] = up[second + 1] == EMPTY_VALUE ? Volume[second + 1] : up[second + 1] + Volume[second + 1];
            down[second] = down[second + 1];
         }
         else
         {
            down[second] = down[second + 1] == EMPTY_VALUE ? Volume[second + 1] : down[second + 1] + Volume[second + 1];
            up[second] = up[second + 1];
         }
         out[second] = up[second] / (up[second] + down[second]) * 100;
         for (int i = second - 1; i >= first; --i)
         {
            if (isUp)
            {
               up[i] = up[i + 1] + Volume[i];
               down[i] = down[i + 1];
            }
            else
            {
               down[i] = down[i + 1] + Volume[i];
               up[i] = up[i + 1];
            }
            out[i] = up[i] / (up[i] + down[i]) * 100;
         }
      }
      pos--;
   } 
   return 0;
}