//+------------------------------------------------------------------+
//|                                Modified_Advance_Decline_Line.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=14;

double MAD[];
double Vol[];

int init()
{
 IndicatorShortName("Modified advance decline line");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MAD);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Vol);

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
  Vol[pos]=-Volume[pos];

  pos--;
 } 
 
 double MA;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   MAD[pos]=0.;
  }
  else
  {
   MA=iMAOnArray(Vol, 0, Length, 0, MODE_SMA, pos);
  
   if (High[pos]-Low[pos]==0.)
   {
    MAD[pos]=MAD[pos+1];
   }
   else
   {
    MAD[pos]=MAD[pos+1]+(2.*Close[pos]-High[pos]-Low[pos])/(High[pos]-Low[pos])*(Volume[pos]+MA);
   }
  } 

  pos--;
 }
   
 return(0);
}

