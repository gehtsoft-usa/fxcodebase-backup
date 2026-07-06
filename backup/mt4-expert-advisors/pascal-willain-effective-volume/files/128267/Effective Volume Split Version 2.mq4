// More information about this indicator can be found at:
// http://fxcodebase.com/


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
#property strict

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_label1 "Large"

#property indicator_color2 Red
#property indicator_label2 "Small"
 
input double PI = 0; 
input int Period = 14;  
input bool Cumulative = true;

double PlotL[];
double PlotS[];
double Plot1[];
double Plot2[];
double Raw[];
string IndicatorName;
string IndicatorObjPrefix;
double array[];
int Length;
int    mid;
double median[];

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
   IndicatorName = GenerateIndicatorName("Effective Volume Split");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorBuffers(6);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, PlotL);
   
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, PlotS);
  
   SetIndexBuffer(2, Raw);
   SetIndexBuffer(3,median);
   
   SetIndexBuffer(4,Plot1);
   SetIndexBuffer(5,Plot2);
   
   
   Length = MathMax(Period,2);
   
   ArrayResize(array,Length); 
   
   
   
  
    mid = MathFloor(Length/2);
     

   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;


   int limit = Bars - 2;
   int i = limit;
 
   double HighPrice;
   double LowPrice;
 
   while (i >= 0)
   { 

    HighPrice=MathMax(High[i],Close[i+1]);
    LowPrice=MathMin(Low[i],Close[i+1]);   
   
   
      if((HighPrice-LowPrice)!= 0)
	  {
      Raw[i]=  ((Close[i]-Close[i+1] +PI)/(HighPrice-LowPrice +PI )) *Volume[i];
	  }
	  else
	  {
	  Raw[i]=0;
	  }
	
	     i--;
   } 
   
   
   i = limit;
   int k;
   
   while (i >= 0)
   { 
     
        for (k=0; k<Length; k++)	
        {		
		array[k]  = iMAOnArray(Raw,0,1,0,MODE_SMA,i+k);
		}
	 
        ArraySort(array);
		
         median[i] = (array[mid]);
   
       
      i--;
   } 
   
   i = limit;
   
   while (i >= 0)
   { 
     

	 
     
     
	   if (Raw[i]> median[i])
	   {
	   
	   
		Plot1[i]=    Raw[i];
		Plot2[i]=    0;
		 
	   }
	   else
	   { 
	        Plot1[i]= 0; 
			Plot2[i]=   Raw[i];
	    }
	  
      
	 
      i--;
   } 
   
   
 
   i = limit;
   
   while (i >= 0)
   { 
     
	 
	   if (Cumulative)
		{
		
	 
				
			PlotL[i]=iMAOnArray(Plot1,0,Length,0,MODE_SMA,i)*Length;
 			PlotS[i]=iMAOnArray(Plot2,0,Length,0,MODE_SMA,i)*Length;
		}
		else
		{
		PlotL[i]=   Plot1[i];
		PlotS[i]=   Plot2[i];
		}
		
		
		 
      i--;
   }  
	 
   return 0;
}

 