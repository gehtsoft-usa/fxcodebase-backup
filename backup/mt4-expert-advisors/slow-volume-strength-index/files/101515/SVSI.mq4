//+------------------------------------------------------------------+
//|                                                         SVSI.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int EMA_Length=6;
extern int Smooth_Length=14;
extern double Overbought_Level=80.;
extern double Oversold_Level=20.;
extern double Middle_Line=50.;

double SVSI[];
double PosVolume[], NegVolume[];

int init()
{
 IndicatorShortName("Slow Volume Strength Index oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SVSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,PosVolume);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,NegVolume);
 
 SetLevelValue(0, Overbought_Level);
 SetLevelValue(1, Oversold_Level);
 SetLevelValue(2, Middle_Line);

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
 double EMA;
 pos=limit;
 while(pos>=0)
 {
  EMA=iMA(NULL, 0, EMA_Length, 0, MODE_EMA, PRICE_CLOSE, pos);
  if (Close[pos]>EMA)
  {
   PosVolume[pos]=Volume[pos]/1000000.;
   NegVolume[pos]=0.;
  }
  else
  {
   if (Close[pos]<EMA)
   {
    PosVolume[pos]=0.;
    NegVolume[pos]=Volume[pos]/1000000.;
   }
   else
   {
    PosVolume[pos]=0.;
    NegVolume[pos]=0.;
   }
  }

  pos--;
 } 
 
 double AvgPosVol, AvgNegVol;
 double SVS;
 pos=limit;
 while(pos>=0)
 {
  AvgPosVol=iMAOnArray(PosVolume, 0, Smooth_Length, 0, MODE_SMA, pos);
  AvgNegVol=iMAOnArray(NegVolume, 0, Smooth_Length, 0, MODE_SMA, pos);
  
  if (AvgNegVol!=0.)
  {
   SVS=AvgPosVol/AvgNegVol;
  }
  else
  {
   SVS=100.;
  }
  
  if (SVS!=0.)
  {
   SVSI[pos]=100.-100./(1.+SVS);
  }

  pos--;
 }
   
 return(0);
}

