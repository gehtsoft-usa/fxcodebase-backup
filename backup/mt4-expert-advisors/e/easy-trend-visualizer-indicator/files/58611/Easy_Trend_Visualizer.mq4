//+------------------------------------------------------------------+
//|                                        Easy_Trend_Visualizer.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red

extern int ADX_Length1=10;
extern int ADX_Length2=14;
extern int ADX_Length3=20;
extern double Level1=35;
extern double Level2=30;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int ArrowSize=1;                       

double Level[], Up[], Dn[], To[], Tc[];

int init()
  {
   IndicatorShortName("Easy Trend Visualizer");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Level);
   SetIndexStyle(1,DRAW_ARROW, 0, ArrowSize);
   SetIndexArrow(1,233);
   SetIndexBuffer(1,Up);
   SetIndexStyle(2,DRAW_ARROW, 0, ArrowSize);
   SetIndexArrow(2,234);
   SetIndexBuffer(2,Dn);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,To);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,Tc);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=MathMax(ADX_Length1, MathMax(ADX_Length2, ADX_Length3))) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 double H, L;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  double ADX1_0=iADX(NULL, 0, ADX_Length1, Price, MODE_MAIN, pos); 
  double ADX1_1=iADX(NULL, 0, ADX_Length1, Price, MODE_MAIN, pos+1); 
  double ADX2_0=iADX(NULL, 0, ADX_Length2, Price, MODE_MAIN, pos); 
  double ADX2_1=iADX(NULL, 0, ADX_Length2, Price, MODE_MAIN, pos+1); 
  double ADX3_0=iADX(NULL, 0, ADX_Length3, Price, MODE_MAIN, pos); 
  double ADX3_1=iADX(NULL, 0, ADX_Length3, Price, MODE_MAIN, pos+1); 
  if (ADX1_0>ADX1_1 && ADX2_0>ADX2_1 && ADX3_0>ADX3_1 && ADX1_0>Level1 && ADX2_0>Level2)
  {
   double di=iADX(NULL, 0, ADX_Length1, Price, MODE_PLUSDI, pos)-iADX(NULL, 0, ADX_Length1, Price, MODE_MINUSDI, pos);
   double hi=MathMax(Open[pos], Close[pos]);
   double lo=MathMin(Open[pos], Close[pos]);
   double op=Open[pos];
   if (di>0)
   {
    To[pos]=lo;
    Tc[pos]=hi;
    if (To[pos+1]==0 || To[pos+1]==EMPTY_VALUE)
    {
     Up[pos]=op;
    }
   }
   else
   {
    To[pos]=hi;
    Tc[pos]=lo;
    if (To[pos+1]==0 || To[pos+1]==EMPTY_VALUE)
    {
     Dn[pos]=op;
    }
   }
  }
  else
  {
   if (To[pos+1]!=0 && To[pos+1]!=EMPTY_VALUE)
   {
    Level[pos]=Close[pos+1];
   }
   else
   {
    Level[pos]=Level[pos+1];
   }
  }
  pos--;
 }

 return(0);
}

