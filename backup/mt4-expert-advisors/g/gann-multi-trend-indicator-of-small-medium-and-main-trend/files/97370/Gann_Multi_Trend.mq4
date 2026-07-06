//+------------------------------------------------------------------+
//|                                             Gann_Multi_Trend.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Green
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 Red
#property indicator_color6 Red
#property indicator_width1 1
#property indicator_width2 2
#property indicator_width3 3
#property indicator_width4 1
#property indicator_width5 2
#property indicator_width6 3

extern int Length1=1;
extern int Length2=2;
extern int Length3=3;

double Up1[], Up2[], Up3[], Dn1[], Dn2[], Dn3[];

int init()
{
 IndicatorShortName("Gann multi trend indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Up1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Up2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Up3);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,Dn1);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,Dn2);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,Dn3);

 return(0);
}

int deinit()
{

 return(0);
}

void CalcData(int index, int Length, double& Up, double& Dn, double& Up_1, double& Dn_1)
{
 double Max, Min;
 Max=High[iHighest(NULL, 0, MODE_HIGH, Length, index+Length)];
 Min=Low[iLowest(NULL, 0, MODE_LOW, Length, index+Length)];
 
 if (High[index]>Max && Low[index]>Min)
 {
  Up=High[index];
  Dn=EMPTY_VALUE;
  Up_1=High[index+1];
  Dn_1=Dn_1;
 }
 else
 {
  if (High[index]<Max && Low[index]<Min)
  {
   Up=EMPTY_VALUE;
   Dn=Low[index];
   Up_1=Up_1;
   Dn_1=Low[index+1];
  }
  else
  {
   if (High[index]<Max && Low[index]>Min)
   {
    Up=Up_1;
    Dn=Dn_1;
    Up_1=Up_1;
    Dn_1=Dn_1;
   }
   else
   {
    Up=EMPTY_VALUE;
    Dn=EMPTY_VALUE;
    Up_1=EMPTY_VALUE;
    Dn_1=EMPTY_VALUE;
   }
  }
 }
 return;
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
  CalcData(pos, Length1, Up1[pos], Dn1[pos], Up1[pos+1], Dn1[pos+1]);
  CalcData(pos, Length2, Up2[pos], Dn2[pos], Up2[pos+1], Dn2[pos+1]);
  CalcData(pos, Length3, Up3[pos], Dn3[pos], Up3[pos+1], Dn3[pos+1]);

  pos--;
 } 
 return(0);
}

