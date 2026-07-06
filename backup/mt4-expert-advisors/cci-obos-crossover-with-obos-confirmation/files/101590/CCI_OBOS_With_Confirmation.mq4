//+------------------------------------------------------------------+
//|                                   CCI_OBOS_With_Confirmation.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Yellow

extern int OBOS_Length=9;
extern int CCI_Length=14;
extern int Arrow_Size=3;

double Up[], Dn[];
double OBOS_H[], OBOS_L[], Buff5[], Buff6[];

int init()
  {
   IndicatorShortName("CCI OBOS With Confirmation");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_ARROW,0,Arrow_Size);
   SetIndexArrow(0,119);
   SetIndexBuffer(0,Up);
   SetIndexStyle(1,DRAW_ARROW,0,Arrow_Size);
   SetIndexArrow(1,119);
   SetIndexBuffer(1,Dn);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,OBOS_H);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,OBOS_L);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,Buff5);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,Buff6);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=OBOS_Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 double Buff1, Buff3, Buff4;
 while(pos>=0)
 {
  Buff1=(High[pos]+Low[pos]+Close[pos]+Close[pos])/4;
  Buff3=iMA(NULL, 0, OBOS_Length, 0, MODE_EMA, PRICE_WEIGHTED, pos);
  Buff4=iStdDev(NULL, 0, OBOS_Length, 0, MODE_EMA, PRICE_WEIGHTED, pos);
  if (Buff4!=0) 
  {
   Buff5[pos]=(Buff1-Buff3)*100/Buff4; 
  } 
  pos--;
 } 
 pos=limit;
 while(pos>=0)
 {
  Buff6[pos]=iMAOnArray(Buff5, 0, OBOS_Length, 0, MODE_EMA, pos);
  pos--;
 }
 pos=limit;
 while(pos>=0)
 {
  OBOS_H[pos]=iMAOnArray(Buff6, 0, OBOS_Length, 0, MODE_EMA, pos);
  pos--;
 }
 pos=limit;
 
 double CCI0, CCI1;
 double OBOS_H0, OBOS_H1, OBOS_L0, OBOS_L1;
 while(pos>=0)
 {
  OBOS_L[pos]=iMAOnArray(OBOS_H, 0, OBOS_Length, 0, MODE_EMA, pos);
  
  CCI0=iCCI(NULL, 0, CCI_Length, PRICE_TYPICAL, pos);
  CCI1=iCCI(NULL, 0, CCI_Length, PRICE_TYPICAL, pos+1);
  
  Up[pos]=EMPTY_VALUE;
  Dn[pos]=EMPTY_VALUE;
  
  OBOS_H0=MathMax(OBOS_H[pos], OBOS_L[pos]);
  OBOS_H1=MathMax(OBOS_H[pos+1], OBOS_L[pos+1]);
  OBOS_L0=MathMin(OBOS_H[pos], OBOS_L[pos]);
  OBOS_L1=MathMin(OBOS_H[pos+1], OBOS_L[pos+1]);
  
  if (CCI1<OBOS_H1 && CCI0>OBOS_H0)
  {
   Up[pos]=Low[pos];
  }
  else
  {
   if (CCI1>OBOS_L1 && CCI0<OBOS_L0)
   {
    Dn[pos]=High[pos];
   }
  }
  
  pos--;
 }

 return(0);
}

