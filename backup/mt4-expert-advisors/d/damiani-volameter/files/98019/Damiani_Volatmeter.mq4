//+------------------------------------------------------------------+
//|                                           Damiani_Volatmeter.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Viscosity=7;
extern int Sedimentation=50;
extern double Threshold_Level=1.1;
extern bool Lag_Suppressor=true;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Pbuff[], Mbuff[];
double ClBuff[];

int init()
{
 IndicatorShortName("Damiani volatmeter oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Pbuff);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Mbuff);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,ClBuff);

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
 double ATR_V, ATR_S;
 double StdDev_V, StdDev_S;
 double s1, s3;
 double vol, t;
 pos=limit;
 while(pos>=0)
 {
  ATR_V=iATR(NULL, 0, Viscosity, pos);
  ATR_S=iATR(NULL, 0, Sedimentation, pos);
  
  StdDev_V=iStdDev(NULL, 0, Viscosity, 0, MODE_LWMA, Price, pos);
  StdDev_S=iStdDev(NULL, 0, Sedimentation, 0, MODE_LWMA, Price, pos);
  
  if (ATR_S!=0. && StdDev_S!=0.)
  {
   s1=ClBuff[pos+1];
   s3=ClBuff[pos+3];
  
   if (Lag_Suppressor)
   {
    vol=ATR_V/ATR_S+(s1-s3)/2.;
   }
   else
   {
    vol=ATR_V/ATR_S;
   }
   
   t=Threshold_Level-StdDev_V/StdDev_S;
   
   ClBuff[pos]=vol;
   
   Pbuff[pos]=vol;
   Mbuff[pos]=t;
  } 

  pos--;
 } 
 return(0);
}

