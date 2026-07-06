//+------------------------------------------------------------------+
//|                                 InvestorsVsSpeculators.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green

extern int Period=14;
extern int Method=0;
 

double Speculators[];
double Investors[];
double Delta[];
double Data[];
int init()
  {
   IndicatorBuffers(4);
   IndicatorShortName("InvestorsVsSpeculators");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Delta);
   
    SetIndexBuffer(1,Investors);
	SetIndexBuffer(2,Speculators);
	SetIndexBuffer(3,Data);
	
	 if(! ( Method >= 0 &&  Method <= 1  )  ) 
   {
   Alert("Permitted Methods are 0 and 1");

   return(-1);
   }
   
   return(0);
  }

int deinit()
  {
   return(0);
  }

int start()
 {
  double BarsToCount = 0;
   int bars_counted = IndicatorCounted();
   if(bars_counted < 0)
   {
      return(1);
   }
   else if(bars_counted > 0) 
   {
      bars_counted--;
   }
   int limit = Bars - bars_counted;
   if(BarsToCount>0 && limit>BarsToCount) 
   {
      limit = BarsToCount;
   }
    
   int i;
   double AD=0;	
   double AVG;
   
    for(i=limit-Period; i>=0; i--)
   {
   Data[i]= Volume[i];
   }
   
   
   for(i=limit; i>=0; i--)
   {
 
		  
		 AD=0;
	
	     if (Method == 0 )
          {  
            if (High[i] - Low[i] == 0 )
			{
                AD = 0;
			}	
            else
			{
                AD = ((Close[i] - Low[i]) - (High[i] - Close[i])) / (High[i] - Low[i]) * Volume[i];
            }
         }			
        else
        {    
            if (High[i] - Low[i] == 0) 
			{
                AD = 0;
			}	
            else
			{
                AD = (Close[i] - Open[i]) / (High[i] - Low[i]) * Volume[i];
            }
        }
		
		
		
		AVG= iMAOnArray(Data,0,Period,0,0,i);
		
		if ( Volume[i]> AVG )
		{
		Speculators[i]= Speculators[i+1];
		Investors[i]=Investors[i+1]+AD;
		}
		else
		{
		Investors[i]= Investors[i+1];
		Speculators[i]=Speculators[i+1]+AD;
		}
       
        Delta[i]= Investors[i]-Speculators[i];
	  
  } 
  
   
 

 return(0);
}

