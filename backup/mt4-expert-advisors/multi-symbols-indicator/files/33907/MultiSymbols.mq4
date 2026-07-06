//+------------------------------------------------------------------+
//|                                                 MultiSymbols.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Navy
#property indicator_color5 Cyan
#property indicator_color6 Magenta
#property indicator_color7 Gold
#property indicator_color8 Tomato

extern string Symbol1="EURUSD";
extern string Symbol2="EURJPY";
extern string Symbol3="USDJPY";
extern string Symbol4="EURGBP";
extern string Symbol5="GBPUSD";
extern string Symbol6="EURCHF";
extern string Symbol7="USDCHF";
extern string Symbol8="USDCAD";
extern int Price=0;
extern int MA_Period=1;
extern int MA_Method=0;
extern int Shift=1000;

double Buff1[], Buff2[], Buff3[], Buff4[], Buff5[], Buff6[], Buff7[], Buff8[];
double Point1, Point2, Point3, Point4, Point5, Point6, Point7, Point8;

int init()
  {
   IndicatorShortName("Multi symbols");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Buff1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Buff2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Buff3);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Buff4);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Buff5);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,Buff6);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,Buff7);
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,Buff8);
   
   Point1=MarketInfo(Symbol1, MODE_POINT);
   Point2=MarketInfo(Symbol2, MODE_POINT);
   Point3=MarketInfo(Symbol3, MODE_POINT);
   Point4=MarketInfo(Symbol4, MODE_POINT);
   Point5=MarketInfo(Symbol5, MODE_POINT);
   Point6=MarketInfo(Symbol6, MODE_POINT);
   Point7=MarketInfo(Symbol7, MODE_POINT);
   Point8=MarketInfo(Symbol8, MODE_POINT);

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
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>=0)
   {
    if (Point1!=0) Buff1[pos]=(iMA(Symbol1, 0, MA_Period, 0, MA_Method, Price, pos)-iMA(Symbol1, 0, MA_Period, 0, MA_Method, Price, pos+1))/Point1;
    if (Point2!=0) Buff2[pos]=(iMA(Symbol2, 0, MA_Period, 0, MA_Method, Price, pos)-iMA(Symbol2, 0, MA_Period, 0, MA_Method, Price, pos+1))/Point2-Shift;
    if (Point3!=0) Buff3[pos]=(iMA(Symbol3, 0, MA_Period, 0, MA_Method, Price, pos)-iMA(Symbol3, 0, MA_Period, 0, MA_Method, Price, pos+1))/Point3-2*Shift;
    if (Point4!=0) Buff4[pos]=(iMA(Symbol4, 0, MA_Period, 0, MA_Method, Price, pos)-iMA(Symbol4, 0, MA_Period, 0, MA_Method, Price, pos+1))/Point4-3*Shift;
    if (Point5!=0) Buff5[pos]=(iMA(Symbol5, 0, MA_Period, 0, MA_Method, Price, pos)-iMA(Symbol5, 0, MA_Period, 0, MA_Method, Price, pos+1))/Point5-4*Shift;
    if (Point6!=0) Buff6[pos]=(iMA(Symbol6, 0, MA_Period, 0, MA_Method, Price, pos)-iMA(Symbol6, 0, MA_Period, 0, MA_Method, Price, pos+1))/Point6-5*Shift;
    if (Point7!=0) Buff7[pos]=(iMA(Symbol7, 0, MA_Period, 0, MA_Method, Price, pos)-iMA(Symbol7, 0, MA_Period, 0, MA_Method, Price, pos+1))/Point7-6*Shift;
    if (Point8!=0) Buff8[pos]=(iMA(Symbol8, 0, MA_Period, 0, MA_Method, Price, pos)-iMA(Symbol8, 0, MA_Period, 0, MA_Method, Price, pos+1))/Point8-7*Shift;
    pos--;
   }

   return(0);
  }

