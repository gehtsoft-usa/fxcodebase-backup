// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=60201

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
#property version   "1.1"
#property strict

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Yellow

extern int Length=1;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  
extern int First_Smooth_Length=20;
extern int Second_Smooth_Length=5;
extern int Third_Smooth_Length=3;
extern double Up_Level=25;
extern double Dn_Level=-25;
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // Timeframe

double CI[];
double CM[], CM_MA1[], CM_MA2[], MinMax[], MinMax_MA1[], MinMax_MA2[];

int init()
{
   IndicatorShortName("William Blau Candlestick Index");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,CI);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,CM);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,CM_MA1);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,CM_MA2);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,MinMax);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,MinMax_MA1);
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(6,MinMax_MA2);
   
   SetLevelValue(0, Up_Level);
   SetLevelValue(1, Dn_Level);
   return(0);
}

int deinit()
{
   return(0);
}

int start()
{
   if(Bars<=Length) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   double Min, Max;
   double CM_MA3, MinMax_MA3; 
   int pos = limit;
   while (pos >= 0)
   {
      if (timeframe == _Period || timeframe == PERIOD_CURRENT)
      {
         CM[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)-iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+Length);
         Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
         Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
         MinMax[pos]=Max-Min;

         CM_MA1[pos]=iMAOnArray(CM, 0, First_Smooth_Length, 0, MODE_EMA, pos);
         MinMax_MA1[pos]=iMAOnArray(MinMax, 0, First_Smooth_Length, 0, MODE_EMA, pos);

         CM_MA2[pos]=iMAOnArray(CM_MA1, 0, Second_Smooth_Length, 0, MODE_EMA, pos);
         MinMax_MA2[pos]=iMAOnArray(MinMax_MA1, 0, Second_Smooth_Length, 0, MODE_EMA, pos);

         CM_MA3=iMAOnArray(CM_MA2, 0, Third_Smooth_Length, 0, MODE_EMA, pos);
         MinMax_MA3=iMAOnArray(MinMax_MA2, 0, Third_Smooth_Length, 0, MODE_EMA, pos);
         if (MinMax_MA3!=0)
         {
            CI[pos]=100.*CM_MA3/MinMax_MA3;
         }
         else
         {
            CI[pos]=EMPTY_VALUE;
         } 
      }
      else
      {
         int index = pos == 0 ? 0 : iBarShift(_Symbol, timeframe, Time[pos]);
         if (index != -1)
         {
            double value = iCustom(_Symbol, timeframe, "Blau_Candlestick_Index", 
               Length, Price, First_Smooth_Length, Second_Smooth_Length, 
               Third_Smooth_Length, Up_Level, Dn_Level, 0, index);
            CI[pos] = value;
         }
      }
      
      pos--;
   }  
      
   return(0);
}

