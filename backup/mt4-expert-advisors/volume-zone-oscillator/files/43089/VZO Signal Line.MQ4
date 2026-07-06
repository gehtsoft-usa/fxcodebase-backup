// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=25075


//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_minimum -100
#property indicator_maximum 100

#property indicator_buffers 4
#property indicator_color1 clrSilver
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 Blue

#property indicator_levelcolor clrYellow
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT

#property indicator_level1 40
#property indicator_level2 -40

extern int Period1=6;
 


extern int MA_Period=6;
extern int MA_Method=0;

double VZO[];
double Up[];
double Down[];
double VPA[];
double VA[];
double VP[];
double VOL[];
double Signal[];



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


int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}


int init()
  {
  
    IndicatorBuffers(8);
	
   IndicatorName = GenerateIndicatorName("VZO");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   
   
   IndicatorDigits(Digits);
   
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, VZO);
   SetIndexLabel(0,"VZO");
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1, Up);
   SetIndexLabel(1,"Up");
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2, Down);
   SetIndexLabel(2,"Down");
   
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3, Signal);
   SetIndexLabel(3,"Signal");
   
 
   SetIndexBuffer(4,VPA);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(5,VA);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(6,VP);   
   SetIndexStyle(6, DRAW_NONE);
   SetIndexBuffer(7,VOL);
   SetIndexStyle(7, DRAW_NONE);
   
   
   
    
   
   
   return(0);
  }


int start()
 {
     int ExtCountedBars=IndicatorCounted();
	 if (ExtCountedBars<0) return(0);
	 
	 int limit=Bars;
	
     int i;
	 
	 
	  for( i=limit ; i>=0; i--)
	   {
	   
	   VOL[i]= Volume[i];
	   }
	 
	
	   for( i=limit ; i>=0; i--)
	   {
	        if (Close[i]>Close[i+1])
			{
			VP[i]=Volume[i];
			}
			else
			{
			VP[i]=-Volume[i];
			}			
	  } 
	  
	     for( i=limit ; i>=0; i--)
	   {
	   
	     VPA[i] = iMAOnArray(VP,0,Period1,0,1,i);
	       
	  } 
	  
	     for( i=limit ; i>=0; i--)
	   {
	   
	    VA[i] = iMAOnArray(VOL,0,Period1,0,1,i);
	       
	  } 
	  
	  
	  
  
	   for(i=limit  ; i>=0; i--)
	    {	  
			if (VA[i]!=0)
			{
			VZO[i]=(VPA[i]/VA[i])*100;
			}
			else
			{
			VZO[i]=0;
			}
		
		
		    if (VZO[i] > 0)
			{
			Up[i]=VZO[i];
			Down[i]==NULL;
			}
			else
			{
			Down[i]=VZO[i];
			Up[i]==NULL;
			}
		}
		
		
		  for(i=limit ; i>=0; i--)
	    {	  
		
		Signal[i] = iMAOnArray(VZO,0,MA_Period,0,MA_Method,i);
		}
		
		 
 

 return(0);
}

