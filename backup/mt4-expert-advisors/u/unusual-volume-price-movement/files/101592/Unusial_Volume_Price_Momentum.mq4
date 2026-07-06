//+------------------------------------------------------------------+
//|                                Unusial_Volume_Price_Momentum.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Yellow

extern int Average_Length=25;
extern double Volume_Multiplier=2.;
extern string Method_Str="Method: 0 - Pips, 1 - Percentage";
extern int Method=0;   // 0 - Pips, 1 - Percentage
extern int Price_Length=25;
extern double Value=0.;
extern int Arrow_Size=3;

double Up[], Dn[];
double Vol[];

int init()
{
 IndicatorShortName("Unusial Volume Price Momentum");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,Arrow_Size);
 SetIndexArrow(0,233);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_ARROW,0,Arrow_Size);
 SetIndexArrow(1,234);
 SetIndexBuffer(1,Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Vol);

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
 pos=limit;
 while(pos>=0)
 {
  Vol[pos]=Volume[pos];

  pos--;
 } 
 
 double Avg_Vol;
 double Bottom, Top;
 pos=limit;
 while(pos>=0)
 {
  Avg_Vol=iMAOnArray(Vol, 0, Average_Length, 0, MODE_SMA, pos);
  if (Volume[pos]<Avg_Vol*Volume_Multiplier)
  {
   Up[pos]=EMPTY_VALUE;
   Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   Bottom=Low[iLowest(NULL, 0, MODE_LOW, Price_Length, pos+1)];
   Top=High[iHighest(NULL, 0, MODE_HIGH, Price_Length, pos+1)];
   
   if (Method==0)
   {
    Top=Top+Value*Point;
    Bottom=Bottom-Value*Point;
   }
   else
   {
    Top=Top+Top*Value/100.;
    Bottom=Bottom-Bottom*Value/100.;
   }
   
   if (Close[pos]>Top)
   {
    Up[pos]=Low[pos];
    Dn[pos]=EMPTY_VALUE;
   }
   else
   {
    if (Close[pos]<Bottom)
    {
     Up[pos]=EMPTY_VALUE;
     Dn[pos]=High[pos];
    }
    else
    {
     Up[pos]=EMPTY_VALUE;
     Dn[pos]=EMPTY_VALUE;
    }
   }
  }

  pos--;
 }
   
 return(0);
}

