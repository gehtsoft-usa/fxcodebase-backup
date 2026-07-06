// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69489
 

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 LightSeaGreen
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_level1 80
#property indicator_level2 20
#property indicator_maximum 100
#property indicator_minimum 0

//---- input parameters
/*************************************************************************
PERIOD_M1   1
PERIOD_M5   5
PERIOD_M15  15
PERIOD_M30  30 
PERIOD_H1   60
PERIOD_H4   240
PERIOD_D1   1440
PERIOD_W1   10080
PERIOD_MN1  43200
You must use the numeric value of the timeframe that you want to use
when you set the TimeFrame' value with the indicator inputs.
---------------------------------------
MODE_SMA    0 Simple moving average, 
MODE_EMA    1 Exponential moving average, 
MODE_SMMA   2 Smoothed moving average, 
MODE_LWMA   3 Linear weighted moving average. 
You must use the numeric value of the MA Method that you want to use
when you set the 'ma_method' value with the indicator inputs.

**************************************************************************/
extern int TimeFrame=240;
extern int KPeriod=5;
extern int DPeriod=3;
extern int Slowing=3;
extern int MAMethod=0;
extern int PriceField=0;// PriceField:  0=Hi/Low   1=Close/Close
input bool Disable_alerts = false; // Disable alerts

extern string note_TimeFrames = "M1;5,15,30,60H1;240H4;1440D1;10080W1;43200MN";
extern string __MA_Method = "SMA0 EMA1 SMMA2 LWMA3";
extern string __PriceField = "0=Hi/Low   1=Close/Close";
//extern string __Price = "0O,1C 2H3L,4Md 5Tp 6WghC: Md(HL/2)4,Tp(HLC/3)5,Wgh(HLCC/4)6";


double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];

datetime last_t=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator line
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT);
   SetIndexLabel(0,  "MTF_Stochastic("+KPeriod+","+DPeriod+","+Slowing+")TF"+TimeFrame+"");
   SetIndexLabel(1,"MTF_Stochastic("+KPeriod+","+DPeriod+","+Slowing+")TF"+TimeFrame+"");
   SetIndexBuffer(2,ExtMapBuffer3);
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexArrow(2,233);
   SetIndexBuffer(3,ExtMapBuffer4);
   SetIndexStyle(3,DRAW_ARROW);
   SetIndexArrow(3,234);

//---- name for DataWindow and indicator subwindow label   
   switch(TimeFrame)
   {
      case 1 : string TimeFrameStr="Period_M1"; break;
      case 5 : TimeFrameStr="Period_M5"; break;
      case 15 : TimeFrameStr="Period_M15"; break;
      case 30 : TimeFrameStr="Period_M30"; break;
      case 60 : TimeFrameStr="Period_H1"; break;
      case 240 : TimeFrameStr="Period_H4"; break;
      case 1440 : TimeFrameStr="Period_D1"; break;
      case 10080 : TimeFrameStr="Period_W1"; break;
      case 43200 : TimeFrameStr="Period_MN1"; break;
      default : TimeFrameStr="Current Timeframe";
   } 
   IndicatorShortName("MTF_Stochastic("+KPeriod+","+DPeriod+","+Slowing+") "+TimeFrameStr);  
   start();
   return(0);
  }
//----
   
 
//+------------------------------------------------------------------+
//| MTF Stochastic                                                   |
//+------------------------------------------------------------------+
int deinit()
{
   for (int i=Bars;i>=0;i--)
   {
      ObjectDelete("st"+Symbol()+Period()+DoubleToStr(KPeriod+DPeriod+Slowing,0)+DoubleToStr(i,0));
   }
   return(0);
}

bool up_a=false;
bool dn_a=false;
int start()
{
   datetime TimeArray[];
   ArrayResize(TimeArray,Bars);
   int    i,limit,y=0,counted_bars=IndicatorCounted();
    
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame); 
   limit=Bars-1;
   limit=MathMax(limit,TimeFrame/Period());
   for(i=0,y=0;i<limit;i++)
   {
      if (Time[i]<TimeArray[y]) y++; 
      
   /***********************************************************   
      Add your main indicator loop below.  You can reference an existing
         indicator with its iName  or iCustom.
      Rule 1:  Add extern inputs above for all neccesary values   
      Rule 2:  Use 'TimeFrame' for the indicator timeframe
      Rule 3:  Use 'y' for the indicator's shift value
   **********************************************************/  
      ExtMapBuffer3[i]=EMPTY_VALUE;  
      ExtMapBuffer4[i]=EMPTY_VALUE;
      ExtMapBuffer1[i]=EMPTY_VALUE;  
      ExtMapBuffer2[i]=EMPTY_VALUE;

      ExtMapBuffer1[i]=iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,MAMethod,PriceField,0,y);
      ExtMapBuffer2[i]=iStochastic(NULL,TimeFrame,KPeriod,DPeriod,Slowing,MAMethod,PriceField,1,y);
      ObjectDelete("st"+Symbol()+Period()+DoubleToStr(KPeriod+DPeriod+Slowing,0)+DoubleToStr(i,0));   

      if (NormalizeDouble(ExtMapBuffer1[i],Digits)>NormalizeDouble(ExtMapBuffer2[i],Digits) && NormalizeDouble(ExtMapBuffer1[i+1],Digits)<=NormalizeDouble(ExtMapBuffer2[i+1],Digits)  && NormalizeDouble(ExtMapBuffer1[i+1],Digits)!=NormalizeDouble(ExtMapBuffer1[i],Digits) )
      {
         ExtMapBuffer3[i]=ExtMapBuffer1[i];
         if (!Disable_alerts)
         {
            ObjectDelete("st"+Symbol()+Period()+DoubleToStr(KPeriod+DPeriod+Slowing,0)+DoubleToStr(i,0));
            ObjectCreate("st"+Symbol()+Period()+DoubleToStr(KPeriod+DPeriod+Slowing,0)+DoubleToStr(i,0),22,0,Time[i],Low[i]-5*Point);
            ObjectSet("st"+Symbol()+Period()+DoubleToStr(KPeriod+DPeriod+Slowing,0)+DoubleToStr(i,0),6,Blue);
            ObjectSet("st"+Symbol()+Period()+DoubleToStr(KPeriod+DPeriod+Slowing,0)+DoubleToStr(i,0),14,233);      
         }
      }
      if (NormalizeDouble(ExtMapBuffer1[i],Digits)<NormalizeDouble(ExtMapBuffer2[i],Digits) && NormalizeDouble(ExtMapBuffer1[i+1],Digits)>=NormalizeDouble(ExtMapBuffer2[i+1],Digits)  && NormalizeDouble(ExtMapBuffer1[i+1],Digits)!=NormalizeDouble(ExtMapBuffer1[i],Digits))
      {
         ExtMapBuffer4[i]=ExtMapBuffer1[i];
         if (!Disable_alerts)
         {
            ObjectDelete("st"+Symbol()+Period()+DoubleToStr(KPeriod+DPeriod+Slowing,0)+DoubleToStr(i,0));
            ObjectCreate("st"+Symbol()+Period()+DoubleToStr(KPeriod+DPeriod+Slowing,0)+DoubleToStr(i,0),22,0,Time[i],High[i]+5*Point);
            ObjectSet("st"+Symbol()+Period()+DoubleToStr(KPeriod+DPeriod+Slowing,0)+DoubleToStr(i,0),6,Red);
            ObjectSet("st"+Symbol()+Period()+DoubleToStr(KPeriod+DPeriod+Slowing,0)+DoubleToStr(i,0),14,234);      
         }
      }
   }  
     
//
   //----  Refresh buffers ++++++++++++++ 
   if (TimeFrame < Period()) TimeFrame = Period();
   if (TimeFrame>Period()) {
     int PerINT=TimeFrame/Period()+1;
     datetime TimeArr[]; ArrayResize(TimeArr,PerINT);
     ArrayCopySeries(TimeArr,MODE_TIME,Symbol(),Period()); 
     for(i=0;i<PerINT+1;i++) {if (TimeArr[i]>=TimeArray[0]) {
 /********************************************************     
    Refresh buffers:         buffer[i] = buffer[0];
 ************************************************************/  

   ExtMapBuffer1[i]=ExtMapBuffer1[0];
   ExtMapBuffer2[i]=ExtMapBuffer2[0];

   } } }
//+++++++++++++++++++++++++++++++++++++++++++++++++++++   Raff 

   if (ExtMapBuffer3[0]!=EMPTY_VALUE && !up_a && !Disable_alerts){
      up_a=true;
      dn_a=false;    
      Alert("MTF Stochastic Long cross Signal on "+Symbol());
   }
   if (ExtMapBuffer4[0]!=EMPTY_VALUE && !dn_a && !Disable_alerts){
      dn_a=true;
      up_a=false;    
      Alert("MTF Stochastic Short cross Signal on "+Symbol());
   }

   return(0);
  }
//+------------------------------------------------------------------+