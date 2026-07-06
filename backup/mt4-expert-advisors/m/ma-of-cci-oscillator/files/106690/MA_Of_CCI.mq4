//+------------------------------------------------------------------+
//|                                                    MA_Of_CCI.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Red

extern int CCI_Length=14;
extern string PriceStr="Price: 0-Close, 1-Open, 2-High, 3-Low, 4-Median, 5-Typical, 6-Weighted";
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted 

extern int MA_Length=20;
extern string MethodStr="Method: 0-SMA, 1-EMA, 2-SMMA, 3-LWMA";
extern int MA_Method=0;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA

double CCI[], MA_CCI[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CCI);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,MA_CCI);

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
 pos=limit;
 while(pos>=0)
 {
  CCI[pos]=iCCI(NULL, 0, CCI_Length, Price, pos);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  MA_CCI[pos]=iMAOnArray(CCI, 0, MA_Length, 0, MA_Method, pos);

  pos--;
 }
   
 return(0);
}

