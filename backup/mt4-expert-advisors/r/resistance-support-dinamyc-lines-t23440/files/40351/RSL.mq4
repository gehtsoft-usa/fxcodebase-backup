//+------------------------------------------------------------------+
//|                                                RSL.mq4 |
//|                      Resistance/Support Dinamyc Lines          |
//|                                            
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property  indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Blue     // Color of the 1st line
#property indicator_color2 Blue      // Color of the 2nd line
#property indicator_color3 Green     // Color of the 3st line
#property indicator_color4 Red    // Color of the 4nd line
#property indicator_color5 Gray     // Color of the 5st line
#property indicator_color6 Gray      // Color of the 6nd line
#property indicator_color7 Gray     // Color of the 7st line
#property indicator_color8 Gray      // Color of the 8nd line


extern int P1=14;
extern bool USE = false;

double Buff1[], Buff2[], Buff3[], Buff4[];
double Stream1[], Stream2[], Stream3[], Stream4[];

	int init()                          // Special function init()
  {
   SetIndexBuffer(0,Buff1);         // Assigning an array to a buffer  
   SetIndexBuffer(1,Buff2);         // Assigning an array to a buffer  
   SetIndexBuffer(2,Buff3);         // Assigning an array to a buffer 
   SetIndexBuffer(3,Buff4);         // Assigning an array to a buffer
   SetIndexBuffer(4,Stream1);         // Assigning an array to a buffer  
   SetIndexBuffer(5,Stream2);         // Assigning an array to a buffer  
   SetIndexBuffer(6,Stream3);         // Assigning an array to a buffer 
   SetIndexBuffer(7,Stream4);         // Assigning an array to a buffer
   
   
    SetIndexStyle(0,DRAW_LINE); 
	SetIndexStyle(1,DRAW_LINE);
	SetIndexStyle(2,DRAW_LINE);
	SetIndexStyle(3,DRAW_LINE);
   
   
        if (USE)
  		{
		    SetIndexStyle(4,DRAW_LINE); 
			SetIndexStyle(5,DRAW_LINE);
			SetIndexStyle(6,DRAW_LINE);
			SetIndexStyle(7,DRAW_LINE);		
        
          }
         else 
		 {
                SetIndexStyle(4,DRAW_NONE); 
				SetIndexStyle(5,DRAW_NONE);
				SetIndexStyle(6,DRAW_NONE);
				SetIndexStyle(7,DRAW_NONE);
         }
		 

   
   
   return(0);                          // Exit the special funct. init()
  }
 
     

int deinit()
  {
   return(0);
  }
  
  
int start ()

      {
    
     int ExtCountedBars=IndicatorCounted();
	 if (ExtCountedBars<0) return(0);
	 
	 int limit=Bars;

	//---- main loop
     for(int i=limit; i>=0; i--)
       {
        
		double MAX1 = High[iHighest(NULL,0,MODE_HIGH,P1,i)];        
		double MIN1 = Low[iLowest(NULL,0,MODE_LOW,P1,i)];
        double MAX2 = High[iHighest(NULL,0,MODE_HIGH,P1/2,i)];        
		double MIN2 = Low[iLowest(NULL,0,MODE_LOW,P1/2,i)];
		
		double a1=(MAX1+MIN1+Close[i])/3;
		 
		 
		Stream1[i]=a1*2-MAX1;
		Stream2[i]=a1*2-MIN1;
		Stream3[i]=(MIN2+MAX2+Close[i])/3;
		Stream4[i]=(Stream1[i]+Stream2[i]+Stream3[i])/3;
		
      	 
       }
	   
 
   
    for( i=limit; i>=0; i--)
    {  
	  
	    Buff1[i]=iMAOnArray(Stream1,Bars-P1*2,P1,0,MODE_SMA,i);		 
	 	Buff2[i]=iMAOnArray(Stream2,Bars-P1*2,P1,0,MODE_SMA,i);	
		Buff3[i]=iMAOnArray(Stream3,Bars-P1*2,P1/2,0,MODE_SMA,i);	
		Buff4[i]=iMAOnArray(Stream4,Bars-P1*2,P1,0,MODE_SMA,i);	
	 } 
  //---- done
     return(0);
    }
