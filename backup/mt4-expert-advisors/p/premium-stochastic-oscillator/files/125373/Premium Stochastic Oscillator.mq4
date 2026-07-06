// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68181

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
#property indicator_buffers 5
#property indicator_color1 clrBlue


#property indicator_color2 clrDarkGreen
#property indicator_color3 clrGreen
 

#property indicator_color4 clrRed
#property indicator_color5 clrMaroon
 
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 1 
#property indicator_width4 1
#property indicator_width5 1

#property indicator_levelcolor clrYellow
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT
 
 
extern int inpPeriod       =  32;
extern int inpSmoothPeriod =   5;

extern double inpLevel1       = 0.9;
extern double inpLevel2       = 0.2;
 
 
 

extern string Custom_Indicator = "Premium Stochastic Oscillator";
 
double Data1[]; 
double Data2[]; 
double val[];

double Level__1[];
double Level__2[];
double Level__3[];
double Level__4[];
double Level__5[];
double Level__6[];


double alpha;
double Level_Max;
double Level_Min;
int init() {
 
 
   IndicatorBuffers(7);
	
  
    SetIndexBuffer(0, val); 
   SetIndexStyle(0, DRAW_LINE); 
   
   SetIndexBuffer(1, Level__1); 
   SetIndexStyle(1, DRAW_LINE); 
   
   SetIndexBuffer(2, Level__2); 
   SetIndexStyle(2, DRAW_LINE); 
   
  

   SetIndexBuffer(3, Level__3); 
   SetIndexStyle(3, DRAW_LINE); 

   SetIndexBuffer(4, Level__4); 
   SetIndexStyle(4, DRAW_LINE);  
   
   
   SetIndexBuffer(5, Data1); 
   SetIndexStyle(5, DRAW_NONE); 
   
   SetIndexBuffer(6, Data2); 
   SetIndexStyle(6, DRAW_NONE);
   
  
    
   
   alpha    = 2.0/(1.0+inpSmoothPeriod);
   
   Level_Max = MathAbs(MathMax(inpLevel1,inpLevel2));
   Level_Min = MathAbs(MathMin(inpLevel1,inpLevel2)); 
   
   SetLevelValue(1,Level_Max);
   SetLevelValue(2,Level_Min);
   SetLevelValue(3,-Level_Min);
   SetLevelValue(4,-Level_Max);
   SetLevelValue(5,0);
 
   
   return (0);
}

int deinit() {
   return (0);
}

int start() {
 
 
   if (Bars <= 10) return (0);
   double gi_116 = IndicatorCounted();
   if (gi_116 < 0) return (-1);
   if (gi_116 > 0) gi_116--;
 
   int pos;
   int min_val_index;
   int max_val_index;
   double min,max;
   double sto;
   double Exp;
   
   for (pos = Bars - gi_116 - 1; pos >= 0; pos--) {
     
	min_val_index= iLowest(NULL,0,MODE_LOW,inpPeriod,pos);
	max_val_index= iHighest(NULL,0,MODE_HIGH,inpPeriod,pos);
    
	min=Low[min_val_index]; 
	max=High[max_val_index]; 
	
	 sto   = 10.0*((Close[pos]-min)/(max-min)-0.5);
	 Data1[pos]=Data1[pos+1]+alpha*(sto-Data1[pos+1]);
	 Data2[pos]=Data2[pos+1]+alpha*(Data1[pos]-Data2[pos+1]);
	 
	 Exp = MathExp(Data2[pos]);
	 
	 val[pos]=(Exp-1.0)/(Exp+1.0);
	 
	 
 
	//EMPTY_VALUE
	Level__1[pos]=EMPTY_VALUE;
	Level__2[pos]=EMPTY_VALUE; 
	Level__3[pos]=EMPTY_VALUE;
	Level__4[pos]=EMPTY_VALUE;
	
	//Level_Max
	//Level_Min
	
 
			if (val[pos] >Level_Max )
			{
			Level__1[pos]=val[pos];
			
			}
			else if (val[pos] <-Level_Max )
			{
			Level__4[pos]=val[pos];
			}
			
			else
			{
			
			
					if (val[pos] >Level_Min )
					{
					Level__2[pos]=val[pos];
					
					}
					else if (val[pos] <-Level_Min )
					{
					Level__3[pos]=val[pos];
					}
			       
			}
	
  
   }
   
   return (0);
}
  