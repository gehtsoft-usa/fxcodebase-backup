#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double IntMapBuffer[];


int init()
  {
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,174);
   SetIndexBuffer(2,IntMapBuffer);
   SetIndexStyle(2,DRAW_NONE);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   if (ExtCountedBars>0) ExtCountedBars--;
   int    pos=Bars+1;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>=0)
     {
      if (pos==Bars-1)
      {
       IntMapBuffer[pos]=Time[pos]; 
      }
      else
      {
       IntMapBuffer[pos]=IntMapBuffer[pos+1]; 
       int MA_Period=iBarShift(NULL, 0, IntMapBuffer[pos])-pos+1;
       double Sum=0;
       for (int i=0;i<MA_Period;i++)
       {
        Sum+=Close[pos+i];
       }
       if (MA_Period!=0) ExtMapBuffer1[pos]=Sum/MA_Period;
       if ((ExtMapBuffer1[pos]-Close[pos])*(ExtMapBuffer1[pos+1]-Close[pos+1])<0)
       {
        IntMapBuffer[pos]=Time[pos];
        ExtMapBuffer1[pos]=Close[pos];
        ExtMapBuffer2[pos]=Close[pos];
       }
       else
       {
        ExtMapBuffer2[pos]=EMPTY_VALUE;
       }
      } 

      pos--;
     }
   

   return(0);
  }


