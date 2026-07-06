// Id: 13329
//+------------------------------------------------------------------+
//|                                                         WMAO.mq4 |
//|                               Copyright � 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Short_Length=5;
extern int Long_Length=20;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double WMAO[], WMAO_Dn[];

int init()
{
     double temp = iCustom(NULL, 0, "WMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'WMA' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Wilders moving average Oscilator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,WMAO);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,WMAO_Dn);

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
 double WMA_S, WMA_L;
 pos=limit;
 while(pos>=0)
 {
  WMA_S=iCustom(NULL, 0, "WMA", Short_Length, Price, 0, pos);
  WMA_L=iCustom(NULL, 0, "WMA", Long_Length, Price, 0, pos);
  
  WMAO[pos]=WMA_S-WMA_L;
  
  if (WMAO[pos]>=WMAO[pos+1])
  {
   WMAO_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   WMAO_Dn[pos]=WMAO[pos];
  }

  pos--;
 } 
 return(0);
}

