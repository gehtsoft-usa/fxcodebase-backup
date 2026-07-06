//+------------------------------------------------------------------+
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Green
 
 
double SignalDown[];
double SignalUp[];
double Down[];
double Up[];


int init()
{
IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
 IndicatorBuffers(4);

   SetIndexBuffer(0,Up);
   SetIndexStyle(0,DRAW_LINE);
   
     SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Down); 

   SetIndexLabel(0,"Up");
   SetIndexLabel(1,"Down");   
   
    SetIndexBuffer(2,SignalDown);
	SetIndexBuffer(3,SignalUp);
    SetIndexStyle(2,DRAW_NONE);
    SetIndexStyle(3,DRAW_NONE);
	
	SetIndexDrawBegin(0,5);
	SetIndexDrawBegin(1,5);
   
   return(0);
   
}

int deinit()
  {

   return(0);
  }

int start()
  {
  
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   int pos =limit;
 
 
   double curr;
   while(pos>=0)
     {
      
	    SignalUp[pos+2]=SignalUp[pos+3]+1;
		SignalDown[pos+2]=SignalDown[pos+3]+1;
      
       curr = High[pos + 2];
        if (curr > High[pos + 4] && curr > High[pos + 3] &&
            curr > High[pos + 1] && curr > High[pos])
			{
            SignalUp[pos+2]=1;        
            }
		 
			
        curr = Low[pos + 2];
            if (curr < Low[pos + 4] && curr < Low[pos + 3] &&
            curr < Low[pos + 1] && curr < Low[pos]) 
            {
            SignalDown[pos+2]=1;
            }
		 
			
           
		   Down[pos+2]=SignalDown[pos+2];
		   Up[pos+2]=SignalUp[pos+2];
		   
		   Down[pos+1]=Down[pos+2]+1;
		   Up[pos+1]=Up[pos+2]+1;
		   
		   Down[pos]=Down[pos+1]+1;
		   Up[pos]=Up[pos+1]+1;
		   
	  pos--;
	 }
	  
   

   return(0);
  }
  