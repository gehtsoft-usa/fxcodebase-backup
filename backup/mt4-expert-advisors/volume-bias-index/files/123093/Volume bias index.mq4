// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67222

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
 
#property indicator_level1 30
#property indicator_level2 70

#property indicator_level3 45
#property indicator_level4 55
      
#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT
 

#property indicator_label1 "Volume bias index" 

extern int Volume_Period       = 34;
extern int Volume_Method = MODE_SMA;


extern int Smoothing_Period       = 1;
extern int Smoothing_Method = MODE_EMA;

extern int Trigger_Period       = 1;
extern int Trigger_Method = MODE_EMA;
 
 
double Bias[];
double Smoothing[];
double Trigger[];

double Up[];
double Down[];

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
  

   IndicatorName = GenerateIndicatorName("Volume bias index");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorBuffers(5);
   
   
   IndicatorDigits(Digits);
   
    
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Bias);
   SetIndexLabel(0,"Bias");
   
   
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Smoothing);
   SetIndexLabel(1,"Smoothing");
   
   
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Trigger);
   SetIndexLabel(2,"Trigger");
 
   
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, Up);
   
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, Down);
 
    
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   int limit = Bars - 2;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
   int pos = limit;
 
   while (pos >= 0)
   {
   
   
 
			if( Close[pos]>= Close[pos+1])
			{
			Up[pos]= Volume[pos];
			Down[pos]=0;			
			}
			else
			{
			Down[pos]= Volume[pos];
			Up[pos]=0;
			}
			
			
                
		 
	  
      pos--;
   } 
   
 
 
 
    pos = limit;
    double MA1;
	double MA2;
	
   while (pos >= 0)
   {
     
	 
	        MA1=iMAOnArray(Up,0,Volume_Period,0,Volume_Method,pos);
			MA2=iMAOnArray(Down,0,Volume_Period,0,Volume_Method,pos);
             
			 
			
			if (MA2!=0)
			{
   			Bias[pos]=100-(100/(1+(MA1/MA2)));
	        }
			else
			{
			Bias[pos]=0;
			
			}

       
	  
      pos--;
   } 
   
    pos = limit;
 
	
   while (pos >= 0)
   {
     
	 
	        Smoothing[pos]=iMAOnArray(Bias,0,Smoothing_Period,0,Smoothing_Method,pos);
            
			 
	  
      pos--;
   } 
   
   
       pos = limit;
 
	
   while (pos >= 0)
   {
     
	 
	        Trigger[pos]=iMAOnArray(Smoothing,0,Trigger_Period,0,Trigger_Method,pos);
            
			 
	  
      pos--;
   } 
   
   
 
   return(0);
}


 