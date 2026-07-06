//+------------------------------------------------------------------+
//|                                    Percentage_Price_Follower.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern string TypeStr="Type: 1 - One, 2 - Two";
extern int Type=1; // 1 - One, 2 - Two
extern int One_Percentage=10;
extern int Two_Percentage=90;

double PPF[];

int init()
{
 IndicatorShortName("Percentage Price Follower");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PPF);

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
  if (pos>Bars-4)
  {
   PPF[pos]=Close[pos];
  }
  else
  {
   if (Type==1)
   {
    if (PPF[pos+1]<Close[pos])
    {
     PPF[pos]=PPF[pos+1]+(High[pos]-Low[pos])*One_Percentage/100.;
    }
    else
    {
     if (PPF[pos+1]>Close[pos])
     {
      PPF[pos]=PPF[pos+1]-(High[pos]-Low[pos])*One_Percentage/100.;
     }
     else
     {
      PPF[pos]=PPF[pos+1];
     }
    }
   }
   else
   {
    PPF[pos]=PPF[pos+1]+(Close[pos]-Open[pos])*Two_Percentage/100.;
   }
  }

  pos--;
 } 
 return(0);
}

