//+------------------------------------------------------------------+
//|                                                          EMV.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Signal_Length=10;
extern int Signal_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA

double EMV[], Signal[];

int init()
{
 IndicatorShortName("Arm's Ease of Movement Value");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,EMV);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);

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
 double H0, L0, H1, L1, V;
 double HL0, HL1;
 pos=limit;
 while(pos>=0)
 {
  H0=High[pos];
  L0=Low[pos];
  H1=High[pos+1];
  L1=Low[pos+1];
  V=Volume[pos];
  HL0=(H0+L0)/(2.*Point);
  HL1=(H1+L1)/(2.*Point);
  EMV[pos]=(HL0-HL1)*(H0-L0)/V;
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(EMV, 0, Signal_Length, 0, Signal_Method, pos);
  
  pos--;
 }
   
 return(0);
}

