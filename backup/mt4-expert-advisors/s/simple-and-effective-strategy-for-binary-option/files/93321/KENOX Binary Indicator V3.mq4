//+------------------------------------------------------------------+
//|                                       KENOX Binary Indicator.mq4 |
//|                                                         KENOX PC |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "KENOX PC"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_color1 DarkGreen
#property indicator_color2 Red
#property indicator_color3 DarkGreen
#property indicator_color4 Red
#property indicator_color5 DarkGreen
#property indicator_color6 Red
#include <WinUser32.mqh>
extern int arrowSizeADX = 2;
extern int arrowSize = 1;
extern int ADXPeriod = 13;
extern color timeColor = Black;
extern bool  clockMoving =true;
extern bool  clockCorner =true;
extern int   Clock_Size  =12;
extern color Clock_Color = Black;
string Clock_Font = "Comic Sans MS";

extern int   TimeFrame=0; //15|30|60|240|1440|10080|43200|0 : current TimeFrame.

datetime LastAlertTime;

//--- input parameters
input string   AlarmSound=("Alert.wav");
input int      FastEMA=12;
input int      SlowEMA=26;
input int      SignalSMA=9;
input int      PeriodeWPR=5;
input int      PeriodMASlow=120;
input int      PeriodMAFast=65;
input double   LowCeilWPR=-83;
input double   HighCeilWPR=-17;
input double   CeilADX=65;

input bool     EnableOsMAWPR=true;
input bool     EnableSMAWPR=false;
input bool     EnableADX=true;
input bool     EnableSound=false;




double GoodTrade[],BadTrade[];
double upArrow[], dnArrow[], ADXup[], ADXdown[];
double Dir[],Dir2[],Dir3[];
double s1[];

int init() {
	IndicatorBuffers(7);
	SetIndexBuffer(0,upArrow);
	SetIndexBuffer(1,dnArrow);
	SetIndexBuffer(2,ADXup);
	SetIndexBuffer(3,ADXdown);
	SetIndexBuffer(4,GoodTrade);
   SetIndexBuffer(5,BadTrade);
   SetIndexBuffer(6,Dir);
	SetIndexBuffer(7,Dir2);
	SetIndexBuffer(8,Dir3);


	SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,arrowSize);
	SetIndexLabel(0,"Buy Arrow");
	SetIndexArrow(0,236);
	SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,arrowSize);
	SetIndexLabel(1,"Sell Arrow");
	SetIndexArrow(1,238);
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,arrowSizeADX);
   SetIndexLabel(2,"Buy dot");
   SetIndexArrow(2,172);
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,arrowSizeADX);
	SetIndexLabel(3,"Sell Dot");
	SetIndexArrow(3,172);
	SetIndexLabel(6,NULL );
	SetIndexLabel(7,NULL );
	SetIndexLabel(8,NULL );
	SetIndexStyle(4,DRAW_ARROW,STYLE_SOLID,arrowSize);
	SetIndexLabel(4,"Win");
	SetIndexArrow(4,74);
	SetIndexStyle(5,DRAW_ARROW,STYLE_SOLID,arrowSize);
	SetIndexLabel(5,"Lose");
	SetIndexArrow(5,76);
	
   LastAlertTime = TimeCurrent();

	return(0);
}

int start() {
   int    limit;
   int    counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   if(counted_bars<1) ArrayInitialize(Dir,0);
   limit=Bars-counted_bars;   
   for(int i=limit; i>0; i--) {
   		int Order = 0;
   		int Order2 = 0;
   		int Order3 = 0;

   		 Dir[i] = 0;
   		 Dir2[i] = 0;   	
   		 Dir3[i] = 0;

   		//if(Volume[0] != 1) return(0) ;
		double Indic1_WPR=iWPR(Symbol(), 0, PeriodeWPR, i);
      double Indic2_OsMA=iOsMA(Symbol(), 0, FastEMA, SlowEMA, SignalSMA, 0, i);
      double Indic3_MASlow=iMA(Symbol(),0,PeriodMASlow,0,MODE_SMA,PRICE_CLOSE,i);
      double Indic4_MAFast=iMA(Symbol(),0,PeriodMAFast,0,MODE_SMA,PRICE_CLOSE,i);
      double Indic5_ADX=iADX(Symbol(), 0, ADXPeriod, PRICE_CLOSE, MODE_MAIN, i);
      double PlusDI_ADX=iADX(Symbol(), 0, ADXPeriod, PRICE_CLOSE, MODE_PLUSDI, i);
      double MinusDI_ADX=iADX(Symbol(), 0, ADXPeriod, PRICE_CLOSE, MODE_MINUSDI, i);
      
      //double ClosePrice=Close[i];
      bool Condition1=(Indic1_WPR >= HighCeilWPR) && (Indic2_OsMA <= 0);
      bool Condition2=(Indic1_WPR <= LowCeilWPR) && (Indic2_OsMA >= 0);
      bool Condition3=(Close[i]>Indic3_MASlow) && (Indic1_WPR <= LowCeilWPR)&&(Close[i]>Indic4_MAFast);
   	bool Condition4=(Close[i]<Indic3_MASlow) && (Indic1_WPR > HighCeilWPR)&&(Close[i]<Indic4_MAFast);
      bool Condition5=(Indic5_ADX>CeilADX)&& (PlusDI_ADX>MinusDI_ADX);
      bool Condition6=(Indic5_ADX>CeilADX)&& (PlusDI_ADX<MinusDI_ADX);
      
   		if ((Condition1==true)&& (EnableOsMAWPR==true)) Order = 1;
   		if ((Condition2==true)&& (EnableOsMAWPR==true))Order = -1;
   		if(Order==0) Dir[i] = Dir[i+1];
   		else Dir[i] = Order;
   		if(Dir[i]!=Dir[i+1]){
   			if(Dir[i]==1)
   			{
   		 		dnArrow[i] = High[i]+0.00009;
   		 	
   				   if (LastAlertTime < Time[0])
                  {
                     MessageBox("Sell"+Symbol()+ "above or at"+Close[i],"Sell"+Symbol(),MB_OK);
   		 		      if (EnableSound==true) PlaySound(AlarmSound);
                     LastAlertTime = Time[0];
                  }
   				Dir[i] = 0;
 		 		
   		 	}
   		 	else if(Dir[i]==-1)
   		 	{
   				upArrow[i] = Low[i]-0.00009;
   				   if (LastAlertTime < Time[0])
                  {
                     MessageBox("Buy"+Symbol()+ "below or at"+Close[i],"Buy"+Symbol(),MB_OK);
   		 		      if (EnableSound==true) PlaySound(AlarmSound);
                     LastAlertTime = Time[0];
                  }

               Dir[i] = 0;

   				}

   		}
   		
   		if ((Condition3==true)&& (EnableSMAWPR==true)) Order3 = 1;
   		if ((Condition4==true)&& (EnableSMAWPR==true)) Order3 = -1;
   		if(Order3==0) Dir3[i] = Dir3[i+1];
   		else Dir3[i] = Order3;
   		if(Dir3[i]!=Dir3[i+1]){
   			if(Dir3[i]==-1)
   			{
   		 		dnArrow[i] = High[i]+0.00009;
   				   if (LastAlertTime < Time[0])
                  {
                     MessageBox("Sell"+Symbol()+ "above or at"+Close[i],"Sell"+Symbol(),MB_OK);
   		 		      if (EnableSound==true) PlaySound(AlarmSound);
                     LastAlertTime = Time[0];
                  }
               Dir3[i] = 0;
 		 		
   		 	}
   		 	else if(Dir3[i]==1)
   		 	{
   				upArrow[i] = Low[i]-0.00009;
   				   if (LastAlertTime < Time[0])
                  {
                     MessageBox("Buy"+Symbol()+ "below or at"+Close[i],"Buy"+Symbol(),MB_OK);
   		 		      if (EnableSound==true) PlaySound(AlarmSound);
                     LastAlertTime = Time[0];
                  }
               Dir3[i] = 0;

   				}

   		}

   		if ((Condition5==true)&& (EnableADX==true)) Order2 = 1;
   		if ((Condition6==true)&& (EnableADX==true)) Order2 = -1;
   		if(Order2==0) Dir2[i] = Dir2[i+1];
   		else Dir2[i] = Order2;
   		if(Dir2[i]!=Dir2[i+1]){
   			if(Dir2[i]==1)
   			{
   		 		ADXdown[i] = High[i]+0.00025;
   				   if (LastAlertTime < Time[0])
                  {
                     MessageBox("CAUTION !!! Weakening UpTrend!!",Symbol(),MB_OK);
   		 		      if (EnableSound==true) PlaySound(AlarmSound);
                     LastAlertTime = Time[0];
                  }
                
               Dir2[i] = 0;
 		 		
   		 	}
   		 	else if(Dir2[i]==-1)
   		 	{
   				ADXup[i] = Low[i]-0.00025;
   				   if (LastAlertTime < Time[0])
                  {   				
                  
                  MessageBox("CAUTION !!! Weakening DownTrend!!",Symbol(),MB_OK);
   		 		      if (EnableSound==true) PlaySound(AlarmSound);
                     LastAlertTime = Time[0];
                  }
             
               Dir2[i] = 0;

   	}}}
   //datetime    objtime;   
	double y;
   int h,m,s,k;
   if (TimeFrame ==0)TimeFrame=Period();
   m=iTime(NULL,TimeFrame,0)+TimeFrame*60 - TimeCurrent();
   y=m/60.0;
   s=m%60;
   m=(m-m%60)/60;
   h=y/60;
   k=m-(h*60); 
  if (clockMoving==true) { // on/off show  
	
	
   ObjectDelete("time");
   
   if(ObjectFind("time") != 0)
   {
   ObjectCreate("time", OBJ_TEXT, 0, Time[0], Close[0]);
   if(s>=10)
   ObjectSetText("time", "                   " +h+"h"+k+"mn"+s+"s", Clock_Size, Clock_Font, Clock_Color);
   }

   //else
   //ObjectSetText("time", "                    "+m+"mn 0"+s+"s", 9, "Arial Black", timeColor);

   }
   else
   {
   ObjectMove("time", 0, Time[0], Close[0]);
   }
 //Comment( "Local time: ", TimeToStr(LocalTime(), TIME_DATE|TIME_MINUTES) );

   return(0);
}
//+------------------------------------------------------------------+