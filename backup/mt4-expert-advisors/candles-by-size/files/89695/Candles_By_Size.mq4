//+------------------------------------------------------------------+
//|                                              Candles_By_Size.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int HL_Level=20;
extern bool HL_Less_Level=true;
extern int OC_Level=10;
extern bool OC_Less_Level=true;
extern bool OC_Abs=true;

double Buff[];
double HL_Level_Pips, OC_Level_Pips;

int init()
{
 IndicatorShortName("Candles by size");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,4);
 SetIndexArrow(0,119);
 SetIndexBuffer(0,Buff);
 HL_Level_Pips=HL_Level*Point;
 OC_Level_Pips=OC_Level*Point;
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
 double HL, OC;
 pos=limit;
 while(pos>=0)
 {
  HL=High[pos]-Low[pos];
  if (OC_Abs)
  {
   OC=MathAbs(Open[pos]-Close[pos]);
  }
  else
  {
   OC=Open[pos]-Close[pos];
  }
  
  if (((HL_Less_Level && HL<HL_Level_Pips) || (!HL_Less_Level && HL>HL_Level_Pips)) && ((OC_Less_Level && OC<OC_Level_Pips) || (!OC_Less_Level && OC>OC_Level_Pips)))
  {
   Buff[pos]=High[pos];
  }
  pos--;
 } 
 return(0);
}

