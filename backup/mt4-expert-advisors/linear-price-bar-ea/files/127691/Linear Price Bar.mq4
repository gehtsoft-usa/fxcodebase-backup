 
 
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
 
 
//---- buffers
 
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,3);
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(3,DRAW_HISTOGRAM,EMPTY,3);
   SetIndexBuffer(3,ExtMapBuffer4);
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
      
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   int i;
   int UpDays, DownDays, NeutralDays;
   double BarH, BarL, BarC;
 
//---- 
   for(i=0; i<Bars; i++)
      {
      BarH = High[i]-Open[i];
      BarL = Low[i]-Open[i];
      BarC = Close[i]-Open[i];
      if(BarC>0) UpDays += 1;
         else if(BarC<0) DownDays +=1;
         else if(BarC==0) NeutralDays +=1;
 
      
      
      ExtMapBuffer1[i] = BarH;
      ExtMapBuffer2[i] = BarL;
//      SortBuffer1[i] = BarH;
//      SortBuffer2[i] = BarL;
      if(Close[i]>Open[i])
         {
         ExtMapBuffer3[i] = BarC;
         ExtMapBuffer4[i] = 0;
         }
         else
         {
         ExtMapBuffer3[i] = 0;
         ExtMapBuffer4[i] = BarC;
         }
         
 
      }
 
//----
   return(0);
  }
//+------------------------------------------------------------------+