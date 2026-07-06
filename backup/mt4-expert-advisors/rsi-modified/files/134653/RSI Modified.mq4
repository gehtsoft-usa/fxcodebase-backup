// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69976

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"


#property version "1.0"
#property indicator_separate_window

#property indicator_minimum 100
#property indicator_maximum 0

//H+L+2*C)/4

#property indicator_buffers 1

#property indicator_color1 Red

#property indicator_levelcolor clrYellow

#property indicator_level1 70
#property indicator_level2 30
 
extern int RSI_Period=14;
extern int Number_Of_Close=2;
extern int Number_Of_High=1;
extern int Number_Of_Low=1;
extern int Number_Of_Open=0;

double Price[];
double RSI[];
double pos[];  
double neg[];    
  
int init()
  {
   
   
   IndicatorDigits(Digits+1);
    IndicatorBuffers(4);
	
   SetIndexBuffer(0,RSI);
   SetIndexStyle(0,DRAW_LINE);
   
   SetIndexBuffer(1,pos);
   SetIndexStyle(1,DRAW_NONE);   
    SetIndexBuffer(2, neg);
   SetIndexStyle(2,DRAW_NONE); 
   
   SetIndexBuffer(3, Price);
   SetIndexStyle(3,DRAW_NONE); 
 
   SetIndexLabel(0,"RSI");
 
   
 
   
   SetLevelValue(0,indicator_level1);
   SetLevelValue(1,indicator_level2);

   return(0);
  }



int start()
  {
  
  

     
	 int ExtCountedBars=IndicatorCounted();
	 if (ExtCountedBars<0) return(-1);
	 int limit=Bars-2; 
	 int i = limit;
      
	 
	
	  
   while(i>=0)
     {
	 
	    
        double sump = 0;
        double sumn = 0;
        double positive = 0;
        double negative = 0;
        double diff = 0;
		int loop_index;
       
	 

     
	   
	   Price[i]=( Number_Of_Close*iClose( NULL, 0, i) 
	   + Number_Of_Open*iOpen( NULL, 0, i) 
	   + Number_Of_High*iHigh( NULL, 0, i) 
	    + Number_Of_Low*iLow( NULL, 0, i) )
		/ (Number_Of_Close + Number_Of_Open + Number_Of_High + Number_Of_Low);
 
	    double Price_0 = Price[i];
	   double Price_1 =Price[i+1];
	   
        
	  if (i== limit)
	  {
	  
	      
		  loop_index=i +RSI_Period-1;
		  while(loop_index>=i)
		  {
                diff = Price_0 - Price_1;
                if (diff >= 0) 
				{
                    sump = sump + diff;
				}
                else
				{
                    sumn = sumn - diff;
                }
				
				loop_index--;
	       
            }
			
		 
            pos[i] = sump / RSI_Period;
            neg[i] = sumn / RSI_Period;
	 
			
			
	  }
	  else
	  {
	  
	      diff = Price_0 - Price_1;
            if (diff > 0)
		      {   
                sump = diff;
		      }
            else
			{
                sumn = -diff;
             }
			 
			 
             positive = (pos[i + 1] * (RSI_Period - 1) + sump) / RSI_Period;
             negative = (neg[i + 1] * (RSI_Period - 1) + sumn) / RSI_Period;
			 
			 
			 
			  pos[i] = positive;
              neg[i] = negative;
		   
	  }
	  
	   

      i--;
     }
	 
	 
	 i = limit;
	 
	
	  
   while(i>=0)
     {
	    
        if (neg[i] == 0)
		{
            RSI[i] = 0;
        }
		else
		{
            RSI[i] = 100 - (100 / (1 + pos[i] / neg[i]));
        }
		
		
		 i--;
     }
	 


   return(0);
  }

 
 
 
 