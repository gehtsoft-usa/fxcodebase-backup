// Id: 8838
//+------------------------------------------------------------------+
//|                     The Volatility (Regime) Switch Indicator.mq4 |
//|                                 Copyright 2013, Gehtsoft USA LLC |
//|                                       http://www.fxcodebase.com  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Gehtsoft USA LLC"
#property link      "http://www.fxcodebase.com"

#property indicator_separate_window
//#property indicator_minimum 0.0
//#property indicator_maximum 1.0
#property indicator_buffers 1
#property indicator_color1 Red
//--- input parameters
extern int       Length=21;
extern double    Overbought=0.8;
extern double    Oversold=0.2;
extern color Overbought_Oversold_Color = Gray;
//--- buffers
double VS[];
double Daily[];
double Deviation[];

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


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

  IndicatorBuffers(3);
   IndicatorName = GenerateIndicatorName("VSI");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
  IndicatorDigits(Digits);
   SetIndexBuffer(0,VS);
   SetIndexStyle(0,DRAW_LINE);    
   
  
  
   SetIndexBuffer(1,Daily);
   SetIndexBuffer(2,Deviation);
   
    
   SetIndexStyle(1,DRAW_NONE);   
   SetIndexStyle(2,DRAW_NONE);
   
   
   
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
  
//----
 
   int ExtCountedBars=IndicatorCounted();
	 if (ExtCountedBars<0) return(0);
	 
	int limit=Bars;
	
	
	 if (limit<Length+Length+1) return(0);	
	 
	 int i;  
    for( i=limit-1; i>=0; i--)
   {
    Daily[i] = ( Close[i]- Close[i+1])/(( Close[i]+ Close[i+1])/2);  
	 
   }  
   
   for( i=limit-1-Length; i>=0; i--)
	 {
	 Deviation[i] =  iStdDevOnArray(Daily,0, Length,0,0,i); 
    }

	
   double Count =0;
     for( i=limit-1-Length-Length; i>=0; i--)
   {
   
   Count =0;
           for(int j=Length-1; j>=0; j--)
          {
		   if  (Deviation[i+j] <=  Deviation[i] )
		   {
		   Count= Count+1;   
		   }   
			
		  }
		  
		VS[i]=Count/Length;
		
		
   }
   
  
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
