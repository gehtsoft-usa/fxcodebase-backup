//+------------------------------------------------------------------+
//|                         Keep On Trading  KOT.mq4                 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Blue


extern int ATRPeriod=10;
extern int MAPeriod=3;
extern int Mode=3;
extern double Multiplier=0.1;

double KOT[];


int init()
  { 
   IndicatorShortName("KOT");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,KOT);
      
   return(0);
  }

int deinit()
  {
   return(0);
  }

int start()
 {
  
	 int ExtCountedBars=IndicatorCounted();
	 if (ExtCountedBars<0) return(0);
	 
	 int limit=Bars;
    
   int MAX;
   MAX= MathMax( ATRPeriod,MAPeriod);   
   for(int i=limit- MAX; i>=0; i--)
   {
   
         double HI;
         double LO;
		 int FLAG;
 
		  HI=iMA (NULL,0,MAPeriod,0,Mode,2,i);
		  LO=iMA (NULL,0,MAPeriod,0,Mode,3,i);
		  
		  if(Close[i] < Low[i+1] && Close[i] < Low[i+2]) 
		  {
		  FLAG=-1;
		  }
		  
		   if(Close[i] > High[i+1] && Close[i] > High[i+2])
		  {
		  FLAG=1;
		  }
		  double ATR;
		  
		  ATR=iATR(NULL,0,ATRPeriod,i);
		  
		  double KOTH;
		  KOTH=HI +Multiplier* ATR;
		  
          double KOTL;
		  KOTL=LO - Multiplier* ATR;
		   
		  
		     if (FLAG==1)
			 {
			  KOT[i] = KOTL; 
			 }
			
		 
		     if (FLAG==-1 )
			 {
		      KOT[i] = KOTH;	
             }		
			 
			 
  } 
  
    
 return(0);
}

