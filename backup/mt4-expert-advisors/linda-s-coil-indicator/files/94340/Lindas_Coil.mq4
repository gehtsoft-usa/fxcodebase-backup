//+------------------------------------------------------------------+
//|                                                  Lindas_Coil.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=3;
extern string _Method="0 - Engulfed or Equal, 1 - Engulfed";
extern int Method=0;
extern string _Type="0 - Previous, 1 - Starting";
extern int Type=0;
extern int Label_Size=3;

double LC[];

int init()
{
 IndicatorShortName("Linda's Coil");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,Label_Size);
 SetIndexArrow(0,254);
 SetIndexBuffer(0,LC);

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
 int Start, i;
 bool Flag;
 pos=limit;
 while(pos>=0)
 {
  Start=pos+Length-1;
  Flag=true;
  for (i=Start-1;i>=pos;i--)
  {
   if (Type==0)
   {
    if ((((High[i]>=High[i+1]) || (Low[i]<=Low[i+1])) && Method==1) || (((High[i]>High[i+1]) || (Low[i]<Low[i+1])) && Method==0))
    {
     Flag=false;
    }
   }
   else
   {
    if ((((High[i]>=High[Start]) || (Low[i]<=Low[Start])) && Method==1) || (((High[i]>High[Start]) || (Low[i]<Low[Start])) && Method==0))
    {
     Flag=false;
    }
   }
  }
  
  if (Flag)
  {
   LC[pos]=Low[pos];
  }
  else
  {
   LC[pos]=EMPTY_VALUE;
  }
 
  pos--;
 } 
 return(0);
}

