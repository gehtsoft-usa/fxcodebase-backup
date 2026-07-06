// Id: 8840
//+------------------------------------------------------------------+
//|                                               DMI Stochastic.mq4 |
//|                                 Copyright 2013, Gehtsoft USA LLC |
//|                                       http://www.fxcodebase.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Gehtsoft USA LLC"
#property link      "http://www.fxcodebase.com/"
#property indicator_buffers 2
#property indicator_separate_window
#property indicator_color1 Green
#property indicator_color2 Red
//--- input parameters
extern int       DMI_Period=14;
extern int       DMI_Price_Method=0;
extern int       Stoch_K=5;
extern int       Stoch_D=3;
extern int       Stoch_Slowing=3;
extern int       Stoch_Method=0;

extern double    Overbought=80;
extern double    Oversold= 20;
extern color Overbought_Oversold_Color = Gray;

double FastK[];
double K[];
double D[];
double DMIO[];

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
   IndicatorName = GenerateIndicatorName("DMIS");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
  IndicatorDigits(Digits);  
   IndicatorBuffers(4);
   
   
   
       SetIndexBuffer(0,K);
   SetIndexStyle(0,DRAW_LINE); 
  
  SetIndexBuffer(1,D);
   SetIndexStyle(1,DRAW_LINE); 
   
    SetIndexBuffer(2,DMIO);
     SetIndexStyle(2,DRAW_NONE);   
	SetIndexBuffer(3,FastK);
	 SetIndexStyle(3,DRAW_NONE);   

   
   
   
 
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
 if (limit<DMI_Period) return(0);	
 
 int i;
 double DIP;
 double DIM;
 
          for( i=limit-DMI_Period+1; i>=0; i--)
		   {
		    DIP = iADX(NULL,0,DMI_Period,DMI_Price_Method,1,i);
			DIM = iADX(NULL,0,DMI_Period,DMI_Price_Method,2,i);
			
		   DMIO[i]=DIP-DIM;
		   }
		   
		    
		    if (limit<DMI_Period+Stoch_K) return(0);	
		    for( i=limit-DMI_Period+1-Stoch_K; i>=0; i--)
		   {
		    FastK[i] = CalculateStochOnArray( DMIO, i);
					  
		   }
		   
		    if (limit<DMI_Period+Stoch_K+Stoch_Slowing) return(0);	
			
		      for( i=limit-DMI_Period+1; i>=0; i--)
		   {
		    K[i] = iMAOnArray(FastK,0,Stoch_Slowing,0,Stoch_Method,i);	
		  
		   }
		   
		   if (limit<DMI_Period+Stoch_K+Stoch_Slowing+Stoch_D) return(0);	
		       for( i=limit-DMI_Period+1; i>=0; i--)
		   {
		    D[i] = iMAOnArray(K,0,Stoch_D,0,Stoch_Method,i);	
		  
		   }
		   
		   
		   			 
			   ObjectCreate(IndicatorObjPrefix + "OB",OBJ_HLINE,0,0,Overbought);
			   ObjectCreate(IndicatorObjPrefix + "OS",OBJ_HLINE,0,0,Oversold);
			   
			   ObjectSet(IndicatorObjPrefix + "OB",OBJPROP_COLOR,Overbought_Oversold_Color);
			   ObjectSet(IndicatorObjPrefix + "OB",OBJPROP_WIDTH,3);
			   
				ObjectSet(IndicatorObjPrefix + "OS",OBJPROP_COLOR,Overbought_Oversold_Color);
			   ObjectSet(IndicatorObjPrefix + "OS",OBJPROP_WIDTH,3);
			 
			   WindowRedraw();        
  
   return(0);
  }
//+------------------------------------------------------------------+


//calculates Stochastics fast %k. takes the array holding our values and current index we are iterating through
double CalculateStochOnArray(double TheArray[], int i)
{
  double 
      SmallestBuffer[],       //buffer to hold the smallest value
      LargestBuffer[],        //buffer to hold the largest value
      StochFastK,             //Stochastic Fast %K
      top,                    //holds top half of calculation
      bottom;                 //holds bottom half of calculation
      
   int 
      position=0;             //place in SmallestBuffer/Largestbuffer for our largest or smallest value
   
   ArrayResize(SmallestBuffer, ArraySize(TheArray));              //size our array accordingly
   ArrayResize(LargestBuffer, ArraySize(TheArray));  
   
   position = ArrayMinimum(TheArray, Stoch_K, i);          //find the smallest value that starts at index i and is of StochasticPeriod length
   SmallestBuffer[i] = TheArray[position];
 
   position = ArrayMaximum(TheArray, Stoch_K, i);          //find the largest value that starts at index i and is of StochasticPeriod length
   LargestBuffer[i] = TheArray[position];
 
   top = TheArray[i]-SmallestBuffer[i];                            //holds top half of StochFastK calculation
   bottom = MathMax(0.0001, LargestBuffer[i] - SmallestBuffer[i]); //holds bottom half of StochFastK calculation. Use MathMax to prevent divide by zero errors
      
   StochFastK = (top/bottom)*100;
   
   return(StochFastK);
}