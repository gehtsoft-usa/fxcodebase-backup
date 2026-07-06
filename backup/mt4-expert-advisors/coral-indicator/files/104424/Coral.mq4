//+------------------------------------------------------------------+
//|                                                        Coral.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Yellow

extern double Coeff=0.063492063492;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double C[];
double B1[], B2[], B3[], B4[], B5[], B6[];
double Coeff2;

int init()
{
 IndicatorShortName("Coral indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,C);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,B1);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,B2);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,B3);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,B4);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,B5);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,B6);
 
 Coeff2=1.-Coeff;

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
 double Pr;
 pos=limit;
 while(pos>=0)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  
  if (pos==Bars-2)
  {
   B1[pos]=Pr;
   B2[pos]=Pr;
   B3[pos]=Pr;
   B4[pos]=Pr;
   B5[pos]=Pr;
   B6[pos]=Pr;
  }
  else
  {
   B1[pos]=Coeff*Pr+Coeff2*B1[pos+1];
   B2[pos]=Coeff*B1[pos]+Coeff2*B2[pos+1];
   B3[pos]=Coeff*B2[pos]+Coeff2*B3[pos+1];
   B4[pos]=Coeff*B3[pos]+Coeff2*B4[pos+1];
   B5[pos]=Coeff*B4[pos]+Coeff2*B5[pos+1];
   B6[pos]=Coeff*B5[pos]+Coeff2*B6[pos+1];
   C[pos]=(-0.064)*B6[pos]+0.672*B5[pos]-2.352*B4[pos]+2.744*B3[pos];
  }

  pos--;
 } 
 return(0);
}

