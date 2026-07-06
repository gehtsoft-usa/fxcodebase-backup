//+------------------------------------------------------------------+
//|                                                          IMI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=14;
extern double Overbought_Level=70;
extern double Oversold_Level=30;                        
extern int LevelWidth=1;
extern color LevelColor=Gray;                        

double IMI[];
double Up[], Down[];

int init()
{
 IndicatorShortName("Intraday Momentum Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,IMI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Up);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Down);

 SetLevelValue(0, 50);
 SetLevelValue(1, Overbought_Level);
 SetLevelValue(2, Oversold_Level);
 SetLevelStyle(EMPTY, LevelWidth, LevelColor);

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
 double diff;
 pos=limit;
 while(pos>=0)
 {
  diff=Close[pos]-Open[pos];
  if (diff>0.)
  {
   Up[pos]=diff;
   Down[pos]=0.;
  }
  else
  {
   Up[pos]=0.;
   Down[pos]=-diff;
  }

  pos--;
 } 
 
 double U, D;
 pos=limit;
 while(pos>=0)
 {
  U=iMAOnArray(Up, 0, Length, 0, MODE_SMA, pos);
  D=iMAOnArray(Down, 0, Length, 0, MODE_SMA, pos);
  if (U+D!=0.)
  {
   IMI[pos]=100.*U/(U+D);
  }
  else
  {
   IMI[pos]=EMPTY_VALUE;
  }

  pos--;
 }
   
 return(0);
}

