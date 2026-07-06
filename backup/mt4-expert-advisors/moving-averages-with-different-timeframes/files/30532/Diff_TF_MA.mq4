#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int MA_Period=10;
extern int MA_Timeframe=240;

double ExtMapBuffer1[];
double ExtMapBuffer2[];

int MA_Period2;


int init()
  {
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,174);
   MA_Period2=MA_Period*MA_Timeframe/Period();
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   if(Bars<=MA_Period2) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   if (ExtCountedBars>0) ExtCountedBars--;
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>=0)
     {
      ExtMapBuffer1[pos]=iMA(NULL, 0, MA_Period2, 0, MODE_SMA, PRICE_CLOSE, pos);
      int Pos=iBarShift(NULL, MA_Timeframe, Time[pos], true);
      if (Pos!=-1)
      {
       if (Time[pos]==iTime(NULL, MA_Timeframe, Pos))
       {
        ExtMapBuffer2[pos]=iMA(NULL, MA_Timeframe, MA_Period, 0, MODE_SMA, PRICE_CLOSE, Pos);
       } 
      } 
      pos--;
     }
   

   return(0);
  }


