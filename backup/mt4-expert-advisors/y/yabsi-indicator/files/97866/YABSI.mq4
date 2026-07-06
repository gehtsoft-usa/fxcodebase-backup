//+------------------------------------------------------------------+
//|                                                        YABSI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Blue

extern bool Show_Typical=false;

double Up[], Dn[], Typical[];
double BS_Switch[];

int init()
{
 IndicatorShortName("YABSI");
 IndicatorDigits(Digits);
 SetIndexBuffer(0,Up);
 SetIndexBuffer(1,Dn);   
 SetIndexStyle(0,DRAW_ARROW,0,4);
 SetIndexArrow(0,119);
 SetIndexStyle(1,DRAW_ARROW,0,4);
 SetIndexArrow(1,119);
 SetIndexEmptyValue(0,0.0);
 SetIndexEmptyValue(1,0.0);
 if (Show_Typical)
 {
  SetIndexStyle(2,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(2,DRAW_NONE);
 } 
 SetIndexBuffer(2,Typical);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,BS_Switch);

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
  Typical[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_TYPICAL, pos);
  
  BS_Switch[pos]=BS_Switch[pos+1];
  
  if ((Close[pos+1]<High[pos] && Typical[pos+2]<Close[pos+1]) || Typical[pos+3]<Close[pos+1])
  {
   if (BS_Switch[pos]!=1.)
   {
    Up[pos]=High[pos];
    BS_Switch[pos]=1.;
   }
  }

  if ((Close[pos+1]>High[pos] && Typical[pos+2]>Close[pos+1]) || Typical[pos+3]>Close[pos+1])
  {
   if (BS_Switch[pos]!=-1.)
   {
    Dn[pos]=Low[pos];
    BS_Switch[pos]=-1.;
   }
  }

  pos--;
 } 
 return(0);
}

