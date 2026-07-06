//+------------------------------------------------------------------+
//|                                                     CCI_Dots.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int CCI_Length=14;
extern int CCI_Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int Length=10;                       

double Up[], Dn[];

int init()
  {
   IndicatorShortName("CCI dots");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,119);
   SetIndexBuffer(0,Up);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,119);
   SetIndexBuffer(1,Dn);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=MathMax(CCI_Length, Length)) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  double Range=(iMA(NULL, 0, Length, 0, MODE_SMA, MODE_HIGH, pos)-iMA(NULL, 0, Length, 0, MODE_SMA, MODE_LOW, pos))/2;
  double CCI0=iCCI(NULL, 0, CCI_Length, CCI_Price, pos);
  double CCI1=iCCI(NULL, 0, CCI_Length, CCI_Price, pos+1);
  if (CCI1>=0 && CCI0<0)
  {
   Up[pos]=High[pos]+Range;
   Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   if (CCI1<=0 && CCI0>0)
   {
    Up[pos]=EMPTY_VALUE;
    Dn[pos]=Low[pos]-Range;
   }
   else
   {
    Up[pos]=EMPTY_VALUE;
    Dn[pos]=EMPTY_VALUE;
   }
  }
  pos--;
 }

 return(0);
}

