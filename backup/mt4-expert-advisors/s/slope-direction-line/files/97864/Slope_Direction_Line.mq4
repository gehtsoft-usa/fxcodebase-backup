//+------------------------------------------------------------------+
//|                                         Slope_Direction_Line.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow
#property indicator_color2 Green
#property indicator_color3 Red

extern int Length=80;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double SDL[], SDL_Up[], SDL_Dn[];
double vect[], trend[];
int Length2, LengthS;

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SDL);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,SDL_Up);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,SDL_Dn);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,vect);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,trend);
 
 Length2=MathFloor(Length/2.);
 LengthS=MathFloor(MathSqrt(Length));

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
 double MA, MA2, MA_A;
 pos=limit;
 while(pos>=0)
 {
  MA=iMA(NULL, 0, Length, 0, Method, Price, pos);
  MA2=iMA(NULL, 0, Length2, 0, Method, Price, pos);
  
  vect[pos]=2.*MA2-MA;
  
  pos--;
 }
  
 pos=limit;
 while(pos>=0)
 {
  MA_A=iMAOnArray(vect, 0, LengthS, 0, Method, pos);
  
  SDL[pos]=MA_A;
  
  trend[pos]=trend[pos+1];
  if (SDL[pos]>SDL[pos+1])
  {
   trend[pos]=1.;
  }
  else
  {
   if (SDL[pos]<SDL[pos+1])
   {
    trend[pos]=-1.;
   }
  }
  
  if (trend[pos]>0.)
  {
   SDL_Up[pos]=SDL[pos];
   if (trend[pos+1]<0.)
   {
    SDL_Up[pos+1]=SDL[pos+1];
   }
  }
  else
  {
   SDL_Dn[pos]=SDL[pos];
   if (trend[pos+1]>0.)
   {
    SDL_Dn[pos+1]=SDL[pos+1];
   }
  }

  pos--;
 } 
 
 return(0);
}

