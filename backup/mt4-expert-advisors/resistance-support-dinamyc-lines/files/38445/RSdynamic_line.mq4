//+------------------------------------------------------------------+
//|                                               RSdynamic_line.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Magenta

extern int Length=14;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low

double Stream1[], Stream2[], Stream3[];
double Buff1[], Buff2[], Buff3[], Buff4[];
int PriceType;

int init()
  {
   IndicatorShortName("RS dynamic line indicator");
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
   SetIndexBuffer(4,Stream1);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,Stream2);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,Stream3);
   
   if (Price==PRICE_CLOSE) PriceType=MODE_CLOSE;
   if (Price==PRICE_OPEN) PriceType=MODE_OPEN;
   if (Price==PRICE_HIGH) PriceType=MODE_HIGH;
   if (Price==PRICE_LOW) PriceType=MODE_LOW;

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 double HHV, LLV, HHV2, LLV2;
 int HHVindex, LLVindex, HHV2index, LLV2index;
 double a1;
 pos=limit;
 while(pos>=0)
 {
  HHVindex=iHighest(NULL, 0, PriceType, Length, pos);
  LLVindex=iLowest(NULL, 0, PriceType, Length, pos);
  HHV2index=iHighest(NULL, 0, PriceType, Length/2, pos);
  LLV2index=iLowest(NULL, 0, PriceType, Length/2, pos);
  HHV=iMA(NULL, 0, 1, 0, MODE_SMA, Price, HHVindex);
  LLV=iMA(NULL, 0, 1, 0, MODE_SMA, Price, LLVindex);
  HHV2=iMA(NULL, 0, 1, 0, MODE_SMA, Price, HHV2index);
  LLV2=iMA(NULL, 0, 1, 0, MODE_SMA, Price, LLV2index);
  a1=(HHV+LLV+iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos))/3;
  Stream1[pos]=2*a1-HHV;
  Stream2[pos]=2*a1-LLV;
  Stream3[pos]=(HHV2+LLV2+iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos))/3;
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  Buff1[pos]=iMAOnArray(Stream1, 0, Length, 0, MODE_SMA, pos);
  Buff2[pos]=iMAOnArray(Stream2, 0, Length, 0, MODE_SMA, pos);
  Buff3[pos]=iMAOnArray(Stream3, 0, Length/2, 0, MODE_SMA, pos);
  Buff4[pos]=(Buff1[pos]+Buff2[pos]+Buff3[pos])/3;
  pos--;
 } 

 return(0);
}

