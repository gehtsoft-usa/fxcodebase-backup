// Id: 15314
//+------------------------------------------------------------------+
//|                                          Average_Of_Averages.mq4 |
//|                               Copyright � 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=20;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double AA[];

int init()
{
     double temp = iCustom(NULL, 0, "WMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'WMA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "SineWMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'SineWMA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "TriMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'TriMA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "LSMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'LSMA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "HMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'HMA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "ZeroLagEMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'ZeroLagEMA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "DEMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'DEMA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "T3MA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'T3MA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "ITrendMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'ITrendMA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "MedianMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'MedianMA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "GeoMin_MA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'GeoMin_MA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "REMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'REMA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "ILRS_MA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'ILRS_MA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "IE2_MA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'IE2_MA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "TriMAgen", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'TriMAgen' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "JSmooth_MA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'JSmooth_MA' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Average Of Averages");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,AA);

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
 int pos;
 
 double MVA, EMA, WMA, LWMA, SineWMA, TriMA, LSMA, SMMA, HMA, ZeroLagEMA, DEMA, T3MA, ITrend, Median, GeoMean, REMA, ILRS, IE2, TriMAgen, JSmooth;
 
 pos=limit;
 while(pos>=0)
 {
  MVA=iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  EMA=iMA(NULL, 0, Length, 0, MODE_EMA, Price, pos);
  WMA=iCustom(NULL, 0, "WMA", Length, Price, 0, pos);
  LWMA=iMA(NULL, 0, Length, 0, MODE_LWMA, Price, pos);
  SineWMA=iCustom(NULL, 0, "SineWMA", Length, Price, 0, pos);
  TriMA=iCustom(NULL, 0, "TriMA", Length, Price, 0, pos);
  LSMA=iCustom(NULL, 0, "LSMA", Length, Price, 0, pos);
  SMMA=iMA(NULL, 0, Length, 0, MODE_SMMA, Price, pos);
  HMA=iCustom(NULL, 0, "HMA", Length, Price, 0, pos);
  ZeroLagEMA=iCustom(NULL, 0, "ZeroLagEMA", Length, Price, 0, pos);
  DEMA=iCustom(NULL, 0, "DEMA", Length, Price, 0, pos);
  T3MA=iCustom(NULL, 0, "T3MA", Length, Price, 0, pos);
  ITrend=iCustom(NULL, 0, "ITrendMA", Length, Price, 0, pos);
  Median=iCustom(NULL, 0, "MedianMA", Length, Price, 0, pos);
  GeoMean=iCustom(NULL, 0, "GeoMin_MA", Length, Price, 0, pos);
  REMA=iCustom(NULL, 0, "REMA", Length, Price, 0, pos);
  ILRS=iCustom(NULL, 0, "ILRS_MA", Length, Price, 0, pos);
  IE2=iCustom(NULL, 0, "IE2_MA", Length, Price, 0, pos);
  TriMAgen=iCustom(NULL, 0, "TriMAgen", Length, Price, 0, pos);
  JSmooth=iCustom(NULL, 0, "JSmooth_MA", Length, Price, 0, pos);
  
  AA[pos]=(MVA+EMA+WMA+LWMA+SineWMA+TriMA+LSMA+SMMA+HMA+ZeroLagEMA+DEMA+T3MA+ITrend+Median+GeoMean+REMA+ILRS+IE2+TriMAgen+JSmooth)/20.;

  pos--;
 } 
 return(0);
}

