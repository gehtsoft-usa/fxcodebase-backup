//+------------------------------------------------------------------+
//|                                              Range Histogram.mq4 |
//|                                                                  |
//|                               Copyright © 2012, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"


#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 White

extern int Type=0; 
extern bool Smoothing = TRUE;
extern int Period=14; 
 extern int  Method=0;
//---- buffers
double Range[];
double Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

    IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Range);
   
    SetIndexBuffer(1,Buffer);
	SetIndexStyle(1,DRAW_NONE);
	
   string short_name = "Range Histogram";
   IndicatorShortName(short_name);
   
   
    if(! (Type >= 0 && Type <= 1  )  ) 
   {
   Alert("Permitted Type are 1 & 2 ");

   return(-1);
   }
   
    if(! (Method >= 0 && Method <= 3  )  ) 
   {
   Alert("Permitted MA_Modes are between 0 and 3");

   return(-1);
   }
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
//---- check for possible errors
   if (counted_bars<0) return(-1);
//---- last counted bar will be recounted
   if (counted_bars>0) counted_bars--;
   int pos=Bars-counted_bars;

//---- main calculation loop
   while(pos>=0)
      {
         
		 if (Type== 1) 
		 {
         Buffer[pos]= High[pos]-Low[pos] ;
		 }
		 else
		 {
		 Buffer[pos]= MathAbs(Open[pos]-Close[pos]) ;
		 }
         pos--;
      }
   
   
    pos=Bars-counted_bars;
	
	
	  while(pos-Period>=0)
      {
	  
					   
					   if (Smoothing )
					   {
					   Range[pos]=  iMAOnArray(Buffer,0,Period,0,Method,pos);
						 
					   }
					   else
					   {
					   
					   Range[pos]=Buffer[pos];
					   
					   }
					   
   
     pos--;
      }
//----
   return(0);
  }
//+------------------------------------------------------------------+