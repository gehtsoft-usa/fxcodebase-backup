// Id: 8835
//+------------------------------------------------------------------+
//|                                                          CVI.mq4 |
//|                                 Copyright 2013, Gehtsoft USA LLC |
//|                                       http://www.fxcodebase.com/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Gehtsoft USA LLC"
#property link      "http://www.fxcodebase.com/"
#property indicator_buffers 1
#property indicator_separate_window
#property indicator_color1 Red
//--- input parameters
extern int       CVI_Period=14;
extern int       MA_Method=0;
extern int       Price_Method=4;
extern bool Modified_Algorithm = true;  

extern double    Overbought=0.5;
extern double    Oversold= -0.5;
extern color Overbought_Oversold_Color = Gray;


double CVI[];
 
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
  IndicatorName = GenerateIndicatorName("CVI");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
  IndicatorDigits(Digits);  
   IndicatorBuffers(1);
   
   
    SetIndexBuffer(0,CVI);
   SetIndexStyle(0,DRAW_LINE); 
  
   
  
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
 if (limit<CVI_Period) return(0);	
 
 int i;
 
 
          for( i=limit-CVI_Period+1; i>=0; i--)
		   {
		   
		     double MA=iMA(NULL,0,CVI_Period,0,MA_Method,Price_Method,i);
			double ATR= iATR(	NULL,0, CVI_Period, i);

			
					if (Modified_Algorithm) 
					 {        
					 if (ATR!=0) CVI[i]=(Close[i]-MA)/( ATR* MathSqrt(CVI_Period));
					}else
					{			
					 if (ATR!=0)  CVI[i]=(Close[i]-MA)/ ATR;
					}	
			
			
           }			
   

   
 
   
 
   ObjectCreate(IndicatorObjPrefix+"OB",OBJ_HLINE,0,0,Overbought);
   ObjectCreate(IndicatorObjPrefix+"OS",OBJ_HLINE,0,0,Oversold);
   
   ObjectSet(IndicatorObjPrefix+"OB",OBJPROP_COLOR,Overbought_Oversold_Color);
   ObjectSet(IndicatorObjPrefix+"OB",OBJPROP_WIDTH,3);
   
    ObjectSet(IndicatorObjPrefix+"OS",OBJPROP_COLOR,Overbought_Oversold_Color);
   ObjectSet(IndicatorObjPrefix+"OS",OBJPROP_WIDTH,3);
 
   WindowRedraw();        
//----
   return(0);
  }
//+------------------------------------------------------------------+