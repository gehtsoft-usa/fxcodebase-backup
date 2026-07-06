//+------------------------------------------------------------------+
//|                                                           Wi.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Lime
#property indicator_color5 Tomato
#property indicator_color6 Aqua

extern int Length=10;
extern int Method=0;

double Wi_Up_P[], Wi_Dn_P[], Wi_Eq_P[], Wi_Up_M[], Wi_Dn_M[], Wi_Eq_M[];
double APrice[];

int init()
  {
   IndicatorShortName("Wi");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Wi_Up_P);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,Wi_Dn_P);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,Wi_Eq_P);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3,Wi_Up_M);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer(4,Wi_Dn_M);
   SetIndexStyle(5,DRAW_HISTOGRAM);
   SetIndexBuffer(5,Wi_Eq_M);
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(6,APrice);

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
 int pos;
 double Wi, Wi1;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  APrice[pos]=2*Close[pos]-High[pos]-Low[pos];
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Wi=iMAOnArray(APrice, 0, Length, 0, Method, pos)/Point;
  Wi1=Wi_Up_P[pos+1]+Wi_Dn_P[pos+1]+Wi_Eq_P[pos+1]+Wi_Up_M[pos+1]+Wi_Dn_M[pos+1]+Wi_Eq_M[pos+1];
  Wi_Up_P[pos]=0;
  Wi_Dn_P[pos]=0;
  Wi_Eq_P[pos]=0;
  Wi_Up_M[pos]=0;
  Wi_Dn_M[pos]=0;
  Wi_Eq_M[pos]=0;
  
  if (Wi>0)
  {
   if (Wi>Wi1)
   {
    Wi_Up_P[pos]=Wi;
   }
   else
   {
    if (Wi<Wi1)
    {
     Wi_Dn_P[pos]=Wi;
    }
    else
    {
     Wi_Eq_P[pos]=Wi;
    }
   }
  }
  else
  {
   if (Wi>Wi1)
   {
    Wi_Up_M[pos]=Wi;
   }
   else
   {
    if (Wi<Wi1)
    {
     Wi_Dn_M[pos]=Wi;
    }
    else
    {
     Wi_Eq_M[pos]=Wi;
    }
   }
  }
  
  pos--;
 }  

 return(0);
}

