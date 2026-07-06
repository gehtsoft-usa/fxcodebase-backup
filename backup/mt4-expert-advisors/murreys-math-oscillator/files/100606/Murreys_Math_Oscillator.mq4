//+------------------------------------------------------------------+
//|                                      Murreys_Math_Oscillator.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 clrLime
#property indicator_color2 clrSpringGreen
#property indicator_color3 clrLimeGreen
#property indicator_color4 clrGreen
#property indicator_color5 clrSaddleBrown
#property indicator_color6 clrChocolate
#property indicator_color7 clrTan
#property indicator_color8 clrRed

extern int Length=100;
extern double Multiplier=0.125;
extern bool Show_Lines=true;

double OP1[], OP2[], OP3[], OP4[], ON1[], ON2[], ON3[], ON4[];

int init()
{
 IndicatorShortName("Murreys Math oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,OP1);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,OP2);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,OP3);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,OP4);
 SetIndexStyle(4,DRAW_HISTOGRAM);
 SetIndexBuffer(4,ON1);
 SetIndexStyle(5,DRAW_HISTOGRAM);
 SetIndexBuffer(5,ON2);
 SetIndexStyle(6,DRAW_HISTOGRAM);
 SetIndexBuffer(6,ON3);
 SetIndexStyle(7,DRAW_HISTOGRAM);
 SetIndexBuffer(7,ON4);
 
 if (Show_Lines)
 {
  SetLevelValue(0, 2.*Multiplier);
  SetLevelValue(1, 4.*Multiplier);
  SetLevelValue(2, 6.*Multiplier);
  SetLevelValue(3, 8.*Multiplier);
  SetLevelValue(4, -2.*Multiplier);
  SetLevelValue(5, -4.*Multiplier);
  SetLevelValue(6, -6.*Multiplier);
  SetLevelValue(7, -8.*Multiplier);
 }

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
 double Min, Max, Range;
 double MidLine;
 pos=limit;
 while(pos>=0)
 {
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  Range=Max-Min;
  MidLine=Min+Multiplier*Range*4.;
  
  if (Range!=0.)
  {
   OP1[pos]=2.*(Close[pos]-MidLine)/Range;
   OP2[pos]=0.; OP3[pos]=0.; OP4[pos]=0.; ON1[pos]=0.; ON2[pos]=0.; ON3[pos]=0.; ON4[pos]=0.;
   
   if (OP1[pos]>0.)
   {
    if (OP1[pos]>=6.*Multiplier)
    {
     OP4[pos]=OP1[pos];
    }
    else
    {
     if (OP1[pos]>=4.*Multiplier)
     {
      OP3[pos]=OP1[pos];
     }
     else
     {
      if (OP1[pos]>=2.*Multiplier)
      {
       OP2[pos]=OP1[pos];
      }
     }
    }
   }
   else
   {
    ON1[pos]=OP1[pos];
    if (OP1[pos]<=-6.*Multiplier)
    {
     ON4[pos]=OP1[pos];
    }
    else
    {
     if (OP1[pos]<=-4.*Multiplier)
     {
      ON3[pos]=OP1[pos];
     }
     else
     {
      if (OP1[pos]<=-2.*Multiplier)
      {
       ON2[pos]=OP1[pos];
      }
     }
    }
   }
  } 

  pos--;
 } 
 return(0);
}

