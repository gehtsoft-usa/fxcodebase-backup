//+------------------------------------------------------------------+
//|                                                 Reverse_MACD.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green

extern int Short_Length=12;
extern int Long_Length=26;
extern int Signal_Length=9;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted 

double MACD[], Signal[], Hist[];
double cmacd[], xMA[], yMA[], Pr[];

double ax, ay, az;

int init()
{
 IndicatorShortName("Reverse MACD");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MACD);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Hist);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,cmacd);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,xMA);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,yMA);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,Pr);
 
 ax=2./(1.+Short_Length);
 ay=2./(1.+Long_Length);
 az=2./(1.+Signal_Length);

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
 double zMA;
 
 if (Method==0)
 {
  pos=limit;
  while(pos>=0)
  {
   xMA[pos]=iMA(NULL, 0, Short_Length, 0, MODE_SMA, Price, pos);
   yMA[pos]=iMA(NULL, 0, Long_Length, 0, MODE_SMA, Price, pos);
   Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
   
   cmacd[pos]=xMA[pos]-yMA[pos];
  
   pos--;
  } 
  
  pos=limit;
  while(pos>=0)
  {
   zMA=iMAOnArray(cmacd, 0, Signal_Length, 0, MODE_SMA, pos);
   
   MACD[pos]=(Short_Length*Pr[pos+Long_Length-1]-Long_Length*Pr[pos+Short_Length-1])/(Short_Length-Long_Length);
   Signal[pos]=(Short_Length*Long_Length*(xMA[pos]-yMA[pos])+Short_Length*Pr[pos+Long_Length-1]-Long_Length*Pr[pos+Short_Length-1])/(Short_Length-Long_Length);
   Hist[pos]=((Short_Length*Long_Length*Signal_Length-Short_Length*Long_Length)*cmacd[pos]-Short_Length*Long_Length*Signal_Length*zMA-(Long_Length*Signal_Length-Long_Length)*Pr[pos+Short_Length-1]+(Short_Length*Signal_Length-Short_Length)*Pr[pos+Long_Length-1]+Short_Length*Long_Length*cmacd[pos+Signal_Length-1])/(Short_Length*Signal_Length-Long_Length*Signal_Length-Short_Length+Long_Length);

   pos--;
  }   
 }
 else
 {
  pos=limit;
  while(pos>=0)
  {
   xMA[pos]=iMA(NULL, 0, Short_Length, 0, MODE_EMA, Price, pos);
   yMA[pos]=iMA(NULL, 0, Long_Length, 0, MODE_EMA, Price, pos);
   
   cmacd[pos]=xMA[pos]-yMA[pos];
  
   pos--;
  } 
  
  pos=limit;
  while(pos>=0)
  {
   zMA=iMAOnArray(cmacd, 0, Signal_Length, 0, MODE_EMA, pos);
   
   MACD[pos]=(ax*xMA[pos]-ay*yMA[pos])/(ax-ay);
   Signal[pos]=((1.-ay)*yMA[pos]-(1.-ax)*xMA[pos])/(ax-ay);
   Hist[pos]=(zMA-(1.-ax)*xMA[pos]+(1.-ay)*yMA[pos])/(ax-ay);

   pos--;
  }   
 } 
 return(0);
}

