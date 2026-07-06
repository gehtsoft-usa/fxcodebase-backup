//+------------------------------------------------------------------+
//|                                                       VORTEX.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=14;

double VIP[], VIM[];
double iVIP[], iVIM[], _ATR[];

int init()
{
 IndicatorShortName("VORTEX");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,VIP);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,VIM);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,iVIP);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,iVIM);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,_ATR);

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
  iVIP[pos]=MathAbs(High[pos]-Low[pos+1]);
  iVIM[pos]=MathAbs(Low[pos]-High[pos+1]);
  _ATR[pos]=iATR(NULL, 0, 1, pos);

  pos--;
 } 
 
 double svip, svim, satr;
 pos=limit;
 while(pos>=0)
 {
  svip=iMAOnArray(iVIP, 0, Length, 0, MODE_SMA, pos);
  svim=iMAOnArray(iVIM, 0, Length, 0, MODE_SMA, pos);
  satr=iMAOnArray(_ATR, 0, Length, 0, MODE_SMA, pos);
  if (satr!=0.)
  {
   VIP[pos]=100.*svip/satr;
   VIM[pos]=100.*svim/satr;
  }
  else
  {
   VIP[pos]=EMPTY_VALUE;
   VIM[pos]=EMPTY_VALUE;
  }

  pos--;
 }
   
 return(0);
}

