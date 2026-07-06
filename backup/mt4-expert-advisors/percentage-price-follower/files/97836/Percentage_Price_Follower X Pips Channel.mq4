// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=61628

//+------------------------------------------------------------------+
//|                     Percentage_Price_Follower X Pips Channel.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Blue
#property indicator_color3 Red

extern string TypeStr="Type: 1 - One, 2 - Two";
extern int Type=1; // 1 - One, 2 - Two
extern int One_Percentage=10;
extern int Two_Percentage=90;
extern double Channel_Delta_In_Pips=10;

double PPF[];
double Top[];
double Bottom[];
int init()
{
 IndicatorShortName("Percentage Price Follower");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PPF);
 
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Top);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Bottom);

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
  
  double vpoint  = MarketInfo(Symbol(),MODE_POINT);
  Top[pos]=PPF[pos]+ Channel_Delta_In_Pips*vpoint;
  Bottom[pos]=PPF[pos]- Channel_Delta_In_Pips*vpoint;

  pos--;
 } 
 return(0);
}

