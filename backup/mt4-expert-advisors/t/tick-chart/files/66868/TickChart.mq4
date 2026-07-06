//+------------------------------------------------------------------+
//|                                                    TickChart.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern bool ShowBid=true;
extern bool ShowAsk=true;

double BidBuff[], AskBuff[];
datetime LastTime;

int init()
  {
   IndicatorShortName("TickChart");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, BidBuff);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1, AskBuff);
   LastTime=Time[0];
   return(0);
  }

int deinit()
  {

   return(0);
  }
  
void ShiftChart()
{
 int i;
 for (i=Bars;i>=1;i--)
 {
  BidBuff[i]=BidBuff[i-1];
  AskBuff[i]=AskBuff[i-1];
 }
 return ;
}  

int start()
  {
   if (LastTime==Time[0])
   {
    ShiftChart();
   }
   else
   {
    LastTime=Time[0];
   }
   if (ShowBid)
   {
    BidBuff[0]=Bid;
   }
   if (ShowAsk)
   {
    AskBuff[0]=Ask;
   }
   
   

   return(0);
  }

