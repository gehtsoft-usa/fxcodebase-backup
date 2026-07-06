// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70017

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property	copyright		"Copyright © 2020, Gehtsoft USA LLC"
#property	link				"http://fxcodebase.com"
#property	version			"1.00"


#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 LightGray
#property indicator_color3 LightGray
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_DOT
#property indicator_style3 STYLE_DOT
//---- input parameters
extern int STOKPeriod=5;
extern int STODPeriod=3;
extern int STOSlowing=3;
extern int STOMethod=0;
extern int STOMode=0;
extern int ApplyTo=0;
extern bool AlertMode=true;
extern int OverBought=70;
extern int OverSold=30;
//---- buffers
double STOBuffer[];
double STOOBBuffer[];
double STOOSBuffer[];

int TimeFrame;
string TF;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator lines
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,STOBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,STOOBBuffer);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,STOOSBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="STO-Alert("+STOKPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"OverBought");
   SetIndexLabel(2,"OverSold");
//----
   SetIndexDrawBegin(0,STOKPeriod);
   
    
   	   	switch(TimeFrame)
	{
		case 1:		TF="M1";  break;
		case 5:		TF="M5";  break;
		case 15:		TF="M15"; break;
		case 30:		TF="M30"; break;
		case 60:		TF="H1";  break;
		case 240:	TF="H4";  break;
		case 1440:	TF="D1";  break;
		case 10080:	TF="W1";  break;
		case 43200:	TF="MN1"; break;
		default:	  {TimeFrame = Period(); init(); return(0);}
	}
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
int start()
  {
   int    i,counted_bars=IndicatorCounted();
//----
   if(Bars<=STOKPeriod) return(0);
//----
   i=Bars-STOKPeriod-1;

 
   if(counted_bars>=STOKPeriod) i=Bars-counted_bars-1;
   while(i>=0)
   {
      STOBuffer[i]=iStochastic(NULL,0,STOKPeriod,STODPeriod,STOSlowing,STOMethod,STOMode,ApplyTo,i);
      STOOBBuffer[i]=OverBought;
      STOOSBuffer[i]=OverSold;
      i--;
   }
   
   if(AlertMode)
   {
      if(STOBuffer[1]<OverBought && STOBuffer[0]>=OverBought)
         Alert(Symbol()+" [ "+TF+" ] STO Overbought @ level "+OverBought);
      else if(STOBuffer[1]>OverSold && STOBuffer[0]<=OverSold)
         Alert(Symbol()+" [ "+TF+" ] STO Oversold @ level "+OverSold);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+