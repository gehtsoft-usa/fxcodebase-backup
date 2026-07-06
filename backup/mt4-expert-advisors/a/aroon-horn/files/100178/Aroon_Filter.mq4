//+------------------------------------------------------------------+
//|                                                   Aroon_Filter.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Gray
#property indicator_color2 Green
#property indicator_color3 Red

extern int Length=10;
extern double Filter=25.;

double AH[], AH_Up[], AH_Dn[];

int init()
{
 IndicatorShortName("Aroon Filter");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,AH);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,AH_Up);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,AH_Dn);

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
 int MinBar, MaxBar;
 double Aroon_Up, Aroon_Dn;
 pos=limit;
 while(pos>=0)
 {
  MinBar=iLowest(NULL, 0, MODE_LOW, Length, pos);
  MaxBar=iHighest(NULL, 0, MODE_HIGH, Length, pos);
  
  Aroon_Up=100.*(Length-MaxBar+pos)/Length;
  Aroon_Dn=100.*(Length-MinBar+pos)/Length;
  
  AH[pos]=Aroon_Up-Aroon_Dn;
  
  if (AH[pos]>=Filter)
  {
   AH_Up[pos]=AH[pos];
  }
  else
  {
   if (AH[pos]<=-Filter)
   {
    AH_Dn[pos]=AH[pos];
   }
  }

  pos--;
 } 
 return(0);
}

