//+------------------------------------------------------------------+
//|                                                 Demand_Index.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Yellow

extern int Length=5;

double DI[];
double Vol[], BuyPres[], SellPres[], TR[], VolAvg[], WghtClose[];

int init()
{
 IndicatorShortName("Demand Index by James Sibbet");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,DI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,BuyPres);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,SellPres);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,TR);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,VolAvg);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,WghtClose);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,Vol);

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
  Vol[pos]=Volume[pos];
  WghtClose[pos]=(2.*Close[pos]+High[pos]+Low[pos])/4.;
  TR[pos]=MathMax(High[pos], High[pos+1])-MathMin(Low[pos], Low[pos+1]);

  pos--;
 } 
 
 double AvgTR;
 double WtCRatio, VolRatio, Constant;
 double BuyP, SellP;
 double TempDI, Sign;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2-Length)
  {
   VolAvg[pos]=iMAOnArray(Vol, 0, Length, 0, MODE_SMA, pos);
  }
  else
  {
   VolAvg[pos]=(VolAvg[pos+1]*(Length-1.)+Volume[pos])/Length;
  }
  
  AvgTR=iMAOnArray(TR, 0, Length, 0, MODE_SMA, pos);
  
  if (WghtClose[pos]!=0. && WghtClose[pos+1]!=0. && AvgTR!=0. && VolAvg[pos]!=0.)
  {
   WtCRatio=(WghtClose[pos]-WghtClose[pos+1])/MathMin(WghtClose[pos], WghtClose[pos+1]);
   VolRatio=Volume[pos]/VolAvg[pos];
   Constant=3.*MathAbs(WtCRatio)*WghtClose[pos]/AvgTR;
   Constant=MathMin(Constant, 88.);
   Constant=VolRatio/MathExp(Constant);
   
   if (WtCRatio>0.)
   {
    BuyP=VolRatio;
    SellP=Constant;
   }
   else
   {
    BuyP=Constant;
    SellP=VolRatio;
   }
   
   BuyPres[pos]=(BuyPres[pos+1]*(Length-1.)+BuyP)/Length;
   SellPres[pos]=(SellPres[pos+1]*(Length-1.)+SellP)/Length;
   
   TempDI=1.;
   if (SellPres[pos]>BuyPres[pos])
   {
    Sign=-1.;
    if (SellPres[pos]!=0.)
    {
     TempDI=BuyPres[pos]/SellPres[pos];
    }
   }
   else
   {
    Sign=1.;
    if (BuyPres[pos]!=0.)
    {
     TempDI=SellPres[pos]/BuyPres[pos];
    }
   }
   
   TempDI=TempDI*Sign;
   
   if (TempDI<0.)
   {
    DI[pos]=(-1.-TempDI)/Point;
   }
   else
   {
    DI[pos]=(1.-TempDI)/Point;
   }
  }
  

  pos--;
 }
   
 return(0);
}

