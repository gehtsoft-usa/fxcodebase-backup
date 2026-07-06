//+------------------------------------------------------------------+
//|                                     Positive_Negative_Volume.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern bool Use_HA_Method=false; // true - Heikin Ashi method, false - Price method

double Up[], Dn[];
double O[], C[];

int init()
{
 IndicatorShortName("Positive Negative Volume");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,O);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,C);

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
  if (Use_HA_Method)
  {
   if (pos==Bars-2)
   {
    O[pos]=(Open[pos+1]+Close[pos+1])/2;
   }
   else
   {
    O[pos]=(O[pos+1]+C[pos+1])/2;
   } 
   C[pos]=(Open[pos]+High[pos]+Low[pos]+Close[pos])/4;
  }
  else
  {
   O[pos]=Open[pos];
   C[pos]=Close[pos];
  }
  
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (C[pos]>O[pos])
  {
   Up[pos]=Volume[pos];
   Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   Up[pos]=EMPTY_VALUE;
   Dn[pos]=-Volume[pos];
  }

  pos--;
 }
   
 return(0);
}

