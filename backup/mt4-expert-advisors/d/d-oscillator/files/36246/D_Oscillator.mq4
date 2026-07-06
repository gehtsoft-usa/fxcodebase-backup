//+------------------------------------------------------------------+
//|                                                 D_Oscillator.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int RSI_Period=13;
extern int D_Period=8;
extern int CCI_Period=8;
extern double CCI_Coeff=0.4;
extern double Smooth=4;

double Buff1[], Buff2[];
double RSI[];
double sk, sk2;

int init()
  {
   IndicatorShortName("D Oscillator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Buff1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Buff2);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,RSI);
   sk=2/(Smooth+1);
   sk2=2/(Smooth*0.8+1);
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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  RSI[pos]=iRSI(NULL, 0, RSI_Period, PRICE_CLOSE, pos);
  pos--;
 } 
 
 pos=limit;
 double MaxRSI, MinRSI;
 double StRSI, StCCI;
 while(pos>=0)
 {
  if (pos!=limit)
  {
   MaxRSI=RSI[ArrayMaximum(RSI, D_Period, pos)];
   MinRSI=RSI[ArrayMinimum(RSI, D_Period, pos)];
  
   if (MaxRSI!=MinRSI)
   {
    StRSI=(RSI[pos]-MinRSI)*200/(MaxRSI-MinRSI)-100;
    StCCI=CCI_Coeff*iCCI(NULL, 0, CCI_Period, PRICE_TYPICAL, pos)+(1-CCI_Coeff)*StRSI;
    Buff1[pos]=sk*StCCI+(1-sk)*Buff1[pos+1];
    Buff2[pos]=sk2*Buff1[pos+1]+(1-sk2)*Buff2[pos+1];
   }
   else
   {
    Buff1[pos]=0;
    Buff2[pos]=0;
   } 
  } 
  
  pos--;
 } 

 return(0);
}

