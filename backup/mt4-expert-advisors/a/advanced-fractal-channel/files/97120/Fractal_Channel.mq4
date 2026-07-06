//+------------------------------------------------------------------+
//|                                              Fractal_Channel.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int Frame=5;

double Upper[], Lower[];
int Shift;

int init()
{
 IndicatorShortName("Fractal channel indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Upper);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Lower);
 
 Shift=(Frame-1)/2;

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
 bool UpFr, DnFr;
 int i;
 pos=limit;
 while(pos>=0)
 {
  UpFr=true;
  DnFr=true;
  for (i=1;i<=Shift;i++)
  {
   if (High[pos+Shift]<=High[pos+Shift-i] || High[pos+Shift]<=High[pos+Shift+i])
   {
    UpFr=false;
   }
   if (Low[pos+Shift]>=Low[pos+Shift-i] || Low[pos+Shift]>=Low[pos+Shift+i])
   {
    DnFr=false;
   }
  }
  
  if (UpFr)
  {
   for (i=0;i<=Shift;i++)
   {
    Upper[pos+Shift-i]=High[pos+Shift];
   }
  }
  else
  {
   for (i=0;i<=Shift;i++)
   {
    Upper[pos+Shift-i]=Upper[pos+Shift+1-i];
   }
  }

  if (DnFr)
  {
   for (i=0;i<=Shift;i++)
   {
    Lower[pos+Shift-i]=Low[pos+Shift];
   }
  }
  else
  {
   for (i=0;i<=Shift;i++)
   {
    Lower[pos+Shift-i]=Lower[pos+Shift+1-i];
   }
  }

  pos--;
 } 
 return(0);
}

