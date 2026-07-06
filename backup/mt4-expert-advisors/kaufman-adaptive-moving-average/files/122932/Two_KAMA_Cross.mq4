// Id: 23417
//+------------------------------------------------------------------+
//|                                               Two_KAMA_Cross.mq4 |
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Yellow
#property indicator_color4 Cyan


extern int TF1=5;         // TF of KAMA1
extern int Period1=100;   // Period of KAMA1
extern int Price1=0;      // Price of KAMA1
extern int TF2=60;        // TF of KAMA2
extern int Period2=60;    // Period of KAMA2
extern int Price2=0;      // Price of KAMA2

extern bool Send_Email=false;
extern bool Snow_Alert=true;

double KAMA1[], KAMA2[], UP[], DN[];
datetime LastAlertTime;

int init()
  {
       double temp = iCustom(NULL, 0, "KAMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'KAMA' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Two MA cross");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,KAMA1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,KAMA2);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexBuffer(2,UP);
   SetIndexArrow(2,233);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexBuffer(3,DN);
   SetIndexArrow(3,234);
   return(0);
  }

int deinit()
  {

   return(0);
  }

void CallAlert(string Msg)
{
 if (Send_Email)
 {
  SendMail("Two KAMA cross indicator Alert", Msg);
 }

 if (Snow_Alert)
 {
  Alert(Msg);
 }
 
}

int start()
  {
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>=0)
   {
    KAMA1[pos]=iCustom(NULL, TF1, "KAMA", Period1, Price1, 0, pos);
    KAMA2[pos]=iCustom(NULL, TF2, "KAMA", Period2, Price2, 0, pos);
    if (KAMA1[pos+1]<KAMA2[pos+1] && KAMA1[pos]>KAMA2[pos])
    {
     UP[pos]=KAMA2[pos];
    }
    else
    {
     UP[pos]=EMPTY_VALUE;
    }
    if (KAMA1[pos+1]>KAMA2[pos+1] && KAMA1[pos]<KAMA2[pos])
    {
     DN[pos]=KAMA2[pos];
    }
    else
    {
     DN[pos]=EMPTY_VALUE;
    }

    if (KAMA1[pos+1]>=KAMA2[pos+1] && KAMA1[pos]<KAMA2[pos])
    {
     if (pos==0 && LastAlertTime!=Time[0])
     {
      LastAlertTime=Time[0];
      CallAlert("Two KAMA cross indicator direction changed");
     }
    }

    if (KAMA1[pos+1]<=KAMA2[pos+1] && KAMA1[pos]>KAMA2[pos])
    {
     if (pos==0 && LastAlertTime!=Time[0])
     {
      LastAlertTime=Time[0];
      CallAlert("Two KAMA cross indicator direction changed");
     }
    }

    pos--;
   }

   return(0);
  }


