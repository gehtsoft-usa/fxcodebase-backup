//+------------------------------------------------------------------+
//|                                   Market_Direction_Indicator.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Gray
#property indicator_color2 clrLime
#property indicator_color3 clrGreen
#property indicator_color4 clrRed
#property indicator_color5 clrOrange

extern int Short_Length=13;
extern int Long_Length=55;
extern int cutoff=2;
extern bool Show_Below_Zero=true;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double MDI[], MDI2[], MDI3[], MDI4[], MDI5[];
double cp[];

int init()
{
 IndicatorShortName("Market Direction Indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,MDI);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,MDI2);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,MDI3);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,MDI4);
 SetIndexStyle(4,DRAW_HISTOGRAM);
 SetIndexBuffer(4,MDI5);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,cp);

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
 double Pr0, Pr1;
 pos=limit;
 while(pos>=0)
 {
  if (Long_Length!=Short_Length)
  {
   cp[pos]=Short_Length*Long_Length*(iMA(NULL, 0, Long_Length, 0, MODE_SMA, Price, pos)-iMA(NULL, 0, Short_Length, 0, MODE_SMA, Price, pos)/(Long_Length-Short_Length));
  } 
  
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  
  if (Show_Below_Zero)
  {
   if (Pr0+Pr1!=0.)
   {
    MDI[pos]=200.*(cp[pos+1]-cp[pos])/(Pr0+Pr1)/Point;
   } 
  }
  else
  {
   MDI[pos]=200.*MathAbs((cp[pos+1]-cp[pos])/(Pr0+Pr1))/Point;
  }
  
  MDI2[pos]=0.; MDI3[pos]=0.; MDI4[pos]=0.; MDI5[pos]=0.;
  if (MDI[pos]<-cutoff/Point)
  {
   if (MDI[pos]>MDI[pos+1])
   {
    MDI4[pos]=MDI[pos];
   }
   else
   {
    MDI5[pos]=MDI[pos];
   }
  }
  else
  {
   if (MDI[pos]>cutoff/Point)
   {
    if (MDI[pos]>MDI[pos+1])
    {
     MDI2[pos]=MDI[pos];
    }
    else
    {
     MDI3[pos]=MDI[pos];
    }
   }
  }

  pos--;
 } 
 return(0);
}

