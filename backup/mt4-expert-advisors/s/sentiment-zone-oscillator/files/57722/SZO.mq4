// Id: 8833
//+------------------------------------------------------------------+
//|                                    Sentiment Zone Oscillator.mq4 |
//|                                 Copyright 2013, Gehtsoft USA LLC |
//|                                       http://www.fxcodebase.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Gehtsoft USA LLC"
#property link      "http://www.fxcodebase.com/"

#property indicator_separate_window
//--- input parameters
extern int       SZO_Period=14;
extern int       Dynamic_Levels_Period=30;
extern double    Dynamic_Levels_Percent=95.0;
extern double    Overbought=7;
extern double    Oversold=-7;
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Blue
extern bool Show_Dynamic_Levels = true;  

double SZO[];
double Top[];
double Bottom[];
double R[];
double EMA1[];
double EMA2[];
double EMA3[];

extern color Overbought_Oversold_Color = Gray;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int init()
  {
//---- indicators

  IndicatorName = GenerateIndicatorName("SZO");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
  IndicatorDigits(Digits);  
  
   IndicatorBuffers(7);
   
    SetIndexBuffer(0,SZO);
   SetIndexStyle(0,DRAW_LINE); 
  
   SetIndexBuffer(1,Top);
   SetIndexStyle(1,DRAW_LINE);
   
    SetIndexBuffer(2,Bottom);
   SetIndexStyle(2,DRAW_LINE);   
   
   SetIndexBuffer(3,R);
    SetIndexStyle(3,DRAW_NONE);
	
	   SetIndexBuffer(4,EMA1);
    SetIndexStyle(4,DRAW_NONE);
	
	   SetIndexBuffer(5,EMA2);
    SetIndexStyle(5,DRAW_NONE);
	
	   SetIndexBuffer(6,EMA3);
    SetIndexStyle(6,DRAW_NONE);
   
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  
  
    int ExtCountedBars=IndicatorCounted();
	 if (ExtCountedBars<0) return(0);
	 
   int    limit=Bars;
   
   
//----
 if (limit<1) return(0);	
 
 int i;

 for( i=limit-1; i>=0; i--)
   {
   if (Close[i]> Close[i+1] )
    {
	R[i]= 1;
	}else                              
    {
	R[i]= -1;
	}
   }
   
   
   if (limit<SZO_Period+1) return(0);	
   
   
   for( i=limit-1-SZO_Period; i>=0; i--)
   {
   EMA1[i]= iMAOnArray(R,0,SZO_Period,0,1,i);
   }
   
   if (limit< 2*SZO_Period+1) return(0);	
   
   
   for( i=limit-1-2*SZO_Period; i>=0; i--)
   {
   EMA2[i]= iMAOnArray(EMA1,0,SZO_Period,0,1,i);
   }
   
   
   if (limit< 3*SZO_Period+1) return(0);	
   
   
   for( i=limit-1-3*SZO_Period; i>=0; i--)
   {
   EMA3[i]= iMAOnArray(EMA2,0,SZO_Period,0,1,i);
   }
   
   for( i=limit-1-3*SZO_Period; i>=0; i--)
   {
   
   double SP =  3 * EMA1[i] - 3 * EMA2[i] + EMA3[i];
   SZO[i]= 100 * (SP/ SZO_Period);
   }
   
   
   if (Show_Dynamic_Levels) 
   {   
				if (limit< 3*SZO_Period+1+Dynamic_Levels_Period) return(0);	
				
				double HLP;
				double LLP;
				
				int j;
				 for( i=limit-1-3*SZO_Period+Dynamic_Levels_Period; i>=0; i--)
			   { 
			   
			   HLP= SZO[i];
			   LLP= SZO[i];
			   
				for( j= Dynamic_Levels_Period-1; j>=0; j--)
			   { 
				  if (HLP< SZO[i+j]) 
				  {
				  HLP= SZO[i+j];
				  }
				   if (LLP >  SZO[i+j]) 
				  {
				  LLP =  SZO[i+j];
				  }
				  
			   
			   }
			   
			 

				 double Range= HLP - LLP;
				double Prange= Range *(Dynamic_Levels_Percent/100);
				Top[i]= LLP + Prange;
				Bottom[i]= HLP - Prange;
			   
			   }
   }
   
//------------------------------------------------------------------------
      int windowIndex=WindowFind(IndicatorName);
   // finding the window number of our indicator
   
   if(windowIndex<0)
   {
      // if the number is -1, there is an error
      Print("Can\'t find window");
      return(0);
   }  
 
   ObjectCreate(IndicatorObjPrefix + "OB",OBJ_HLINE,windowIndex,0,Overbought);
   ObjectCreate(IndicatorObjPrefix + "OS",OBJ_HLINE,windowIndex,0,Oversold);
   
   ObjectSet(IndicatorObjPrefix + "OB",OBJPROP_COLOR,Overbought_Oversold_Color);
   ObjectSet(IndicatorObjPrefix + "OB",OBJPROP_WIDTH,3);
   
    ObjectSet(IndicatorObjPrefix + "OS",OBJPROP_COLOR,Overbought_Oversold_Color);
   ObjectSet(IndicatorObjPrefix + "OS",OBJPROP_WIDTH,3);
 
   WindowRedraw();        
//----
   return(0);
  }
//+------------------------------------------------------------------+