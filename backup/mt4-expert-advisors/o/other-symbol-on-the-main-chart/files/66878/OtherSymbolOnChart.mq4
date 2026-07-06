//+------------------------------------------------------------------+
//|                                           OtherSymbolOnChart.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Magenta
#property indicator_color3 Blue
#property indicator_color4 Yellow

extern string Instrument="EURGBP";
extern bool ShowOpen=false;
extern bool ShowHigh=true;
extern bool ShowLow=true;
extern bool ShowClose=false;

double OOpen[], OHigh[], OLow[], OClose[];
int LastFirstBar, LastLastBar;

int init()
  {
   IndicatorShortName("Other symbol on chart ("+Instrument+")");
   if (ShowOpen) SetIndexStyle(0,DRAW_LINE); else SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0, OOpen);
   if (ShowHigh) SetIndexStyle(1,DRAW_LINE); else SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1, OHigh);
   if (ShowLow) SetIndexStyle(2,DRAW_LINE); else SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2, OLow);
   if (ShowClose) SetIndexStyle(3,DRAW_LINE); else SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3, OClose);
   LastFirstBar=0;
   LastLastBar=0;
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=3) return(0);
 int pos;

 int First=WindowFirstVisibleBar();
 int NumberBars=WindowBarsPerChart();
 if (LastFirstBar!=First || LastLastBar!=First-NumberBars+1)
 {
  LastFirstBar=First;
  LastLastBar=First-NumberBars+1;
  if (NumberBars>First) NumberBars=First+1;
  double MaxPrice=iHigh(NULL, 0, iHighest(NULL, 0, MODE_HIGH, NumberBars, First-NumberBars));
  double MinPrice=iLow(NULL, 0, iLowest(NULL, 0, MODE_LOW, NumberBars, First-NumberBars));
  int OFirst=iBarShift(Instrument, 0, Time[First], false);
  int OLast=iBarShift(Instrument, 0, Time[First-NumberBars+1], false);
  double OMaxPrice=iHigh(Instrument, 0, iHighest(Instrument, 0, MODE_HIGH, OFirst-OLast+1, OLast));
  double OMinPrice=iLow(Instrument, 0, iLowest(Instrument, 0, MODE_LOW, OFirst-OLast+1, OLast));
  int index;
  double PriceRange=MaxPrice-MinPrice;
  double OPriceRange=OMaxPrice-OMinPrice;
  if (OPriceRange!=0)
  {
   double RangeRatio=PriceRange/OPriceRange;
   for (pos=Bars;pos>=0;pos--)
   {
    index=iBarShift(Instrument, 0, Time[pos], false);
    OOpen[pos]=(iOpen(Instrument, 0, index)-OMinPrice)*RangeRatio+MinPrice;
    OHigh[pos]=(iHigh(Instrument, 0, index)-OMinPrice)*RangeRatio+MinPrice;
    OLow[pos]=(iLow(Instrument, 0, index)-OMinPrice)*RangeRatio+MinPrice;
    OClose[pos]=(iClose(Instrument, 0, index)-OMinPrice)*RangeRatio+MinPrice;
   }
  } 
  
 } 
 
 return(0);
}

