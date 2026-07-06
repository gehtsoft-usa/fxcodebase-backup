//+------------------------------------------------------------------+
//|                                            Candle_Size_Alert.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 Yellow

extern int LevelSize=20;
extern bool OnlyLastBar=false;
extern bool EnableAlert=false;

double HighSize[];
double LevelSizePip;

int init()
  {
   IndicatorShortName("Candle size alert");
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexBuffer(0,HighSize);
   SetIndexArrow(0,108);
   LevelSizePip=LevelSize*Point;
   return(0);
  }

int deinit()
  {

   return(0);
  }
  
string PeriodStr()
{
 int P=Period();
 if (P==1) return ("M1");
 if (P==5) return ("M5");
 if (P==15) return ("M15");
 if (P==30) return ("M30");
 if (P==60) return ("H1");
 if (P==240) return ("H4");
 if (P==1440) return ("D1");
 if (P==10080) return ("W1");
 if (P==43200) return ("MN1");
 return ("");
}  

int start()
{
 if (High[0]-Low[0]>=LevelSizePip)
 {
  if (EnableAlert && HighSize[0]==EMPTY_VALUE)
  {
   Alert(Symbol(),", ",PeriodStr(),": Candle size>",LevelSize," pips");
  }
  HighSize[0]=High[0];
 }
 if (OnlyLastBar) 
 {
  HighSize[1]=EMPTY_VALUE;
 }
 else
 { 
  if(Bars<=3) return(0);
  int ExtCountedBars=IndicatorCounted();
  if (ExtCountedBars<0) return(-1);
  int    pos=Bars-2;
  if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
  while(pos>0)
  {
   if (High[pos]-Low[pos]>=LevelSizePip)
   {
    HighSize[pos]=High[pos];
   }
   pos--;
  } 
 } 
 return(0);
}


