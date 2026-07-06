
#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 CLR_NONE
#property indicator_color2 Magenta
#property indicator_color3 DodgerBlue

extern int ADX_Period = 14;
extern int DeltaAdx = 3;
extern int Smoothing = 3;
extern int SignalGap = 10;

double b1[];
double b2[];
double b3[];

int init()  {
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,1);
   SetIndexArrow(2,233);
   SetIndexArrow(1,234);
   SetIndexBuffer(0,b1);
   SetIndexBuffer(1,b2);
   SetIndexBuffer(2,b3);
   SetIndexEmptyValue(1,0);
   SetIndexEmptyValue(2,0);
   return(0);
}
int start() {
   int counted_bars=IndicatorCounted();
   int i,limit;
   double Delta,Signal;
   
   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
   limit=Bars-1;
   if(counted_bars>=1) limit=Bars-counted_bars-1;
   if (limit<0) limit=0;
   
   for(i=0; i<limit; i++) {
     b1[i]=iADX(NULL,0,ADX_Period,PRICE_CLOSE,MODE_MAIN,i);
   }

   for (i=limit;i>=0;i--)   {
      Delta = iMAOnArray(b1,0,Smoothing,0,MODE_SMA,i-1)-iMAOnArray(b1,0,Smoothing,0,MODE_SMA,i);
      Signal = iADX(NULL,0,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,i)-iADX(NULL,0,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,i);
      
      if (Delta>DeltaAdx && Signal<0)
         b2[i]=High[i]+SignalGap*Point;
      if (Delta>DeltaAdx && Signal>0)
         b3[i]=Low[i]-SignalGap*Point;
   }
   return(0);
}