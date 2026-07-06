// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68302

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+
 

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0" 
#property strict
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_color1 clrSnow
#property indicator_color2 clrSnow
#property indicator_color3 clrSnow
 
 
#property indicator_color4 clrDeepSkyBlue
#property indicator_color5 Blue 
#property indicator_color6 clrRed
#property indicator_color7 clrMaroon 

#property indicator_color8 clrGreen
#property indicator_color9 clrRed

extern int FastEMA=12;
extern int SlowEMA=26;
extern int SignalEMA=9;

enum Price_Types{  Close_Price=1,  Open_Price=2, High_Price=3,Low_Price=4, Median_Price=5,Typical_Price=6 ,Weighted_Price=7};
input  Price_Types Price = Close_Price;	
 
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
input  AveragesMethod fast_MA_Type = EMA; // Fast MA Type
input  AveragesMethod slow_MA_Type = ZeroLagEMA; // Slow MA Type
input ENUM_MA_METHOD signal_type = MODE_SMA; // Signal Type

input bool Show_MACD = true;	
input bool Show_Signal = true;		 	 
input bool Show_Histogram = true;

double MACD[], Signal[], Histogram[];
double Histogram_UpUp[],Histogram_UpDown[];
double Histogram_DownUp[],Histogram_DownDown[];
double MACD_Up[],MACD_Down[];

int init()
{
   double temp = iCustom(NULL, 0, "averages", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'averages' indicator (you can find it on FXCodeBase.com)");
      return INIT_FAILED;
   }
   IndicatorShortName("MACD Custom Indicator");
   IndicatorBuffers(9);
   IndicatorDigits(Digits);
   
   if (Show_MACD)
   {
      SetIndexStyle(0,DRAW_LINE);
      SetIndexBuffer(0,MACD);
      
      SetIndexStyle(7,DRAW_LINE);
      SetIndexBuffer(7,MACD_Up);
      
      SetIndexStyle(8,DRAW_LINE);
      SetIndexBuffer(8,MACD_Down);
   }
   else
   {
      SetIndexStyle(0,DRAW_NONE);
      SetIndexBuffer(0,MACD);
      
      SetIndexStyle(7,DRAW_NONE);
      SetIndexBuffer(7,MACD_Up);
      
      SetIndexStyle(8,DRAW_NONE);
      SetIndexBuffer(8,MACD_Down);
   }
   
   if (Show_Signal)
   {
      SetIndexStyle(1,DRAW_LINE);
      SetIndexBuffer(1,Signal);
   }
   else
   {
      SetIndexStyle(1,DRAW_NONE);
      SetIndexBuffer(1,Signal);
   }
   
   if (Show_Histogram)
   {
      SetIndexStyle(2,DRAW_HISTOGRAM);
      SetIndexBuffer(2,Histogram);
      SetIndexStyle(3,DRAW_HISTOGRAM);
      SetIndexBuffer(3,Histogram_UpUp);
      SetIndexStyle(4,DRAW_HISTOGRAM);
      SetIndexBuffer(4,Histogram_UpDown);
      SetIndexStyle(5,DRAW_HISTOGRAM);
      SetIndexBuffer(5,Histogram_DownUp);
      SetIndexStyle(6,DRAW_HISTOGRAM);
      SetIndexBuffer(6,Histogram_DownDown);
   }
   else
   { 
      SetIndexStyle(2,DRAW_NONE);
      SetIndexBuffer(2,Histogram);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexBuffer(3,Histogram_UpUp);
      SetIndexStyle(4,DRAW_NONE);
      SetIndexBuffer(4,Histogram_UpDown);
      SetIndexStyle(5,DRAW_NONE);
      SetIndexBuffer(5,Histogram_DownUp);
      SetIndexStyle(6,DRAW_NONE);
      SetIndexBuffer(6,Histogram_DownDown);
   }

   return(0);
}

int deinit()
{
   return(0);
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
      double FMA = iCustom(NULL, 0, "averages", FastEMA, Price - 1, fast_MA_Type, 0, pos);
      if (GetLastError() == ERR_INDICATOR_CANNOT_INIT)
         return 0;
      double SMA = iCustom(NULL, 0, "averages", SlowEMA, Price - 1, slow_MA_Type, 0, pos);
      if (GetLastError() == ERR_INDICATOR_CANNOT_INIT)
         return 0;
      
      MACD[pos] = FMA - SMA;
      if (pos + SignalEMA >= Bars || MACD[pos + SignalEMA] == EMPTY_VALUE)
         continue;
      Signal[pos] = iMAOnArray(MACD, 0, SignalEMA, 0, signal_type, pos); 
      Histogram[pos] = MACD[pos]-Signal[pos];
      
      Histogram_UpUp[pos] = EMPTY_VALUE;
      Histogram_UpDown[pos] = EMPTY_VALUE;
      Histogram_DownUp[pos] = EMPTY_VALUE;
      Histogram_DownDown[pos] = EMPTY_VALUE;
      
      if (MACD[pos] > Signal[pos])
      {
         MACD_Up[pos]=MACD[pos];
         if (MACD[pos + 1] < Signal[pos + 1])
            MACD_Up[pos + 1] = MACD[pos + 1];
         MACD_Down[pos] = EMPTY_VALUE;
      }
      else
      {
         MACD_Down[pos] = MACD[pos];
         if (MACD[pos+1] > Signal[pos+1])
            MACD_Down[pos + 1] = MACD[pos+1];
         MACD_Up[pos] = EMPTY_VALUE;
      }
      
      if (Histogram[pos]> 0)
      {
         if( Histogram[pos] > Histogram[pos+1])
            Histogram_UpUp[pos] = Histogram[pos];
         else
            Histogram_UpDown[pos] = Histogram[pos];
      }
      else
      {
         if (Histogram[pos] > Histogram[pos + 1])
            Histogram_DownUp[pos] = Histogram[pos];
         else
            Histogram_DownDown[pos] = Histogram[pos];
      }
   }
   
   return(0);
}

