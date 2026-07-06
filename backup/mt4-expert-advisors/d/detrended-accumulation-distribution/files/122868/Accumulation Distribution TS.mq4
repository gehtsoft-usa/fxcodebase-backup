// More information about this indicator can be found at:
// http://fxcodebase.com/code/posting.php?mode=edit&f=38&p=122868

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
#property indicator_buffers 1
#property indicator_color1 Green

#property indicator_level1 0
      
#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT
 

#property indicator_label1 "Accumulation Distribution" 
 
enum e_method {Classic=1, ClassicIncremental=2, TradeStation=3 };

 
extern e_method Calculation_Method = Classic;
 
 
double AD[];
double Delta[];

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
  

   IndicatorName = GenerateIndicatorName("Accumulation Distribution");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorBuffers(2);
   
   
   IndicatorDigits(Digits);
   
    
   
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, AD);
   SetIndexLabel(0,"AD");
   SetIndexDrawBegin(0,0);
   
   SetIndexStyle(1, DRAW_NONE);
   SetIndexBuffer(1, Delta);
 
 
    
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
   int limit = Bars - 1;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
   int pos = limit;
 
   while (pos >= 0)
   {
   
   
   
   
      if ( Calculation_Method == 1  || Calculation_Method == 2)
	  {
            
            if (High[pos] - Low[pos] == 0 )
			{
                Delta[pos] = 0;
            }
			else
            {            
			Delta[pos] = ((Close[pos] - Low[pos]) - (High[pos] - Close[pos])) / (High[pos] - Low[pos]) * Volume[pos];
            }
	  }	 	
      else
      { 
	  
	        if ( High[pos] - Low[pos] == 0 )
			{
                Delta[pos] = 0;
            }
			else
            {
			 Delta[pos] = (Close[pos] - Open[pos]) / (High[pos] - Low[pos]) * Volume[pos];
            }
      }
	  
	  
	           		 
		 
              
		 
	  
      pos--;
   } 
   
 
 
 
    pos = limit;
 
   while (pos >= 0)
   {
   
   
   			AD[pos]=Summation(pos);
	     

       
	  
      pos--;
   } 
   
 
   return(0);
}



double Summation(int pos)
{

  
  double Sum=0;
  int i; 
 
  int limit = Bars  - 1;
  
  for(i=pos;i<=(limit); i++)
  {
  Sum=Sum+ Delta[i];
  }
  
  
  
  

               if  ( Calculation_Method == 2  || Calculation_Method == 3)
				{  
					    return (Sum);
				}
				else
				{
				       return (Delta[pos]);
				}
				
				
			
 return (Sum);
 
 }
