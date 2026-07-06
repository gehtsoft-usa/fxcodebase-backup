// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=61392

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
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
#property indicator_buffers 5
#property indicator_color1 Silver
#property indicator_color2 Silver
#property indicator_color3 Silver
#property indicator_color4 Green
#property indicator_color5 Red


extern int    TMA_Period       = 56;
extern int    ATR_Period        = 100;
extern double    ATR_Mult       = 2;
extern double    TrendThreshold       = 0.5;
extern bool Redraw = True; 


enum Calculation_Types{ Absolute=1,  Relative=2  };
 
input  Calculation_Types Calulation_Method = Absolute;

 

#property indicator_level1 0
#property indicator_level2 100
#property indicator_level3 -100
      
#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT
 

#property indicator_label1 "Extreme_TMA_Line_Oscillator" 
 
 
 
double Oscillator[];
double Upper[];
double Lower[];
double TMA[];
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
  

   IndicatorName = GenerateIndicatorName("Extreme_TMA_Line_Oscillator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorBuffers(6);
   
   
   IndicatorDigits(Digits);
   
    
   
   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, Oscillator);
   SetIndexLabel(0,"Oscillator");
 
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Upper);
   SetIndexLabel(1,"Upper");
   
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Lower);
   SetIndexLabel(2,"Lower");
   
   
   SetIndexStyle(3, DRAW_HISTOGRAM);
   SetIndexBuffer(3, Up);
   
   SetIndexStyle(4, DRAW_HISTOGRAM);
   SetIndexBuffer(4, Down);
 
   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, TMA);
   
   
 
 
 
    
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{ 

       int limit;  
	   int    nCountedBars=IndicatorCounted();

	   if(nCountedBars<=ATR_Period*2)
		  limit=Bars-(ATR_Period*2);
	   else
		  limit=Bars-nCountedBars-1;
	
   

  
 
  	double Sum, SumW,ATR,range;
   int ii,i,j;
   bool LastPeriod;
		
   for(i=limit ; i>=0; i--)
     {
			    ii=TMA_Period;
				
				if  (i==0) 
				{
				 LastPeriod=True;
				} 
				else
				{
				 LastPeriod=False;
				} 
		
		
				while (ii>0) 
				{
					 if  (LastPeriod == False ) 
					 {
					 ii=0;
					 }
					else
					{
					 ii=ii-1; 
					}
					
				Sum=0;
                SumW=(TMA_Period+2)*(TMA_Period+1)/2;
				
				  for(j=0; j<=TMA_Period; j++)   
				   {
				   Sum=Sum+(TMA_Period-j+1)*Close[i+j];
						 if (Redraw== True) 
						 {
						   if  (i-j>0) // (j<=nLimiti && j>0)
						   {
						   Sum=Sum+(TMA_Period-j+1)*Close[i-j];
						   SumW=SumW+(TMA_Period-j+1);				 
						  }
						}
				
			    	}
	
         
				 if (SumW != 0)
				 {
				 TMA[i]=Sum/SumW;
				 
				 }
				 
				 
			     
	            
              } 
	         
    }		
    
	 
    double Slope;
	
     for(i=limit ; i>=0; i--)
     {
     ATR=iATR(NULL,0,ATR_Period,i);
				  range=ATR_Mult*ATR;
				  
				  if (Calulation_Method == 2) 
				  {
						  
						  
						  Oscillator[i]=(Close[i]-TMA[i]) ;
						  
						  Upper[i]=range;
						  Lower[i]=-range;
						  
				  }
				  else
				  { 
				        if (range!= 0) 
						{
				        Oscillator[i]=(Close[i]-TMA[i]) / (range/100);
						}
						Upper[i]=100;
						Lower[i]=-100;
				  }
      
	  
	  
	  Slope=(TMA[i]-TMA[i+1])/(0.1*ATR);
      if (Slope>TrendThreshold)
	  {
	  
	             Up[i]=Oscillator[i];
				 Down[i]= EMPTY_VALUE;
				 
	  }
	  
	  else if ( Slope<-TrendThreshold )
	  {
	              Down[i]=Oscillator[i];
				  Up[i]= EMPTY_VALUE;
	  }
	  
    }
  
 
   return(0);
}


 
