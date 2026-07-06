//+------------------------------------------------------------------+
//|                                                     SVE_ARSI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+

// The formula is from here: http://forum.vtsystems.com/index.php?showtopic=9941
// {Provided By: Visual Trading Systems, LLC & Capital Market Services, LLC © Copyright 2008}
// {Description: The Asymmetrical RSI (ARSI) Indicator}
// {Notes: T.A.S.C., October 2008 - "ARSI, The Asymmetrical RSI" by Sylvain Vervoort}
// {vt_ARSI Version 1.0}
//
// UpCount:= sum(if(roc(Price,1,points)>=0,1,0),Period);
// DnCount:= Period-UpCount;
// UpMove:= wilders(if(roc(Price,1,points)>=0,roc(Price,1,points),0),UpCount);
// DnMove:= wilders(if(roc(Price,1,points)<0,abs(roc(Price,1,points)),0),DnCount);
// RS:= UpMove/DnMove;
// ARSI:= 100-(100/(1+RS));

#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Yellow

extern int Length=14;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern double Level1=30.;                       
extern double Level2=70.;

double ARSI[];
double upbuff[], dnbuff[], upcnt[];

int init()
{
 IndicatorShortName("Sylvain Vervoort's Asymmetrical RSI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ARSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,upbuff);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,dnbuff);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,upcnt);
 
 SetLevelValue(0., Level1/Point);
 SetLevelValue(1., Level2/Point);

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
 double Pr0, Pr1;
 double ROC;
 double upmove, dnmove;
 int up, dn;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  ROC=(Pr0-Pr1)/Point;
  
  upbuff[pos]=MathMax(ROC, 0.);
  dnbuff[pos]=MathAbs(MathMin(ROC, 0.));
  
  if (ROC>=0.)
  {
   upcnt[pos]=1.;
  }
  else
  {
   upcnt[pos]=0.;
  }
  
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  up=MathFloor(iMAOnArray(upcnt, 0, Length, 0, MODE_SMA, pos)*Length+0.5);
  dn=Length-up;
  if (up==0)
  {
   upmove=0.;
  }
  else
  {
   if (up==1)
   {
    upmove=upbuff[pos];
   }
   else
   {
    upmove=iMAOnArray(upbuff, 0, 2*Length-1, 0, MODE_EMA, pos);
   }
  }
  
  if (dn==0)
  {
   dnmove=0.;
  }
  else
  {
   if (dn==1)
   {
    dnmove=dnbuff[pos];
   }
   else
   {
    dnmove=iMAOnArray(dnbuff, 0, 2*Length-1, 0, MODE_EMA, pos);
   }
  }
  
  if (dnmove==0.)
  {
   ARSI[pos]=100./Point;
  }
  else
  {
   ARSI[pos]=(100.-100./(1.+upmove/dnmove))/Point;
  }

  pos--;
 }
   
 return(0);
}

