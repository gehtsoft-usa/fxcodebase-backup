// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=59355

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

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow


#property indicator_level1 50
      
#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT

extern int Length=8;
extern int Movement_Index_Period=8;

 
double Line[];
int init()
{
 IndicatorShortName("Movement Index");
 IndicatorDigits(Digits);
 IndicatorBuffers(1);

  SetIndexBuffer(0,Line);
  SetIndexStyle(0,DRAW_LINE);
  
 
 

 	double temp = iCustom(NULL, 0, "LWPI", 0, 0);
				if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
				{
				   Alert("Please, install the 'LWPI' indicator: http://fxcodebase.com/code/viewtopic.php?f=38&t=59355");
				   return INIT_FAILED;
				}
  

 SetLevelValue(0, 50);
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 
 int pos; 
 double Indicator0;
 double Indicator1;
 pos=limit;
 while(pos>=0)
 {
   
   Indicator0 = iCustom(NULL, 0, "LWPI", Length   ,0,pos);
   Indicator1= iCustom(NULL, 0, "LWPI", Length   ,0,pos+Movement_Index_Period);
   Line[pos]=Indicator0-Indicator1;
   
  pos--;
 }  
 
 
 
 
 return(0);
}

