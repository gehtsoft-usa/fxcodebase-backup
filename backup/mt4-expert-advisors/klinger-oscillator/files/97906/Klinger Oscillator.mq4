//+------------------------------------------------------------------+
//|                                           Klinger Oscillator.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, Gehtsoft USA LLC"
#property link      "http://www.fxcodebase.com/"

#property indicator_separate_window
//--- input parameters
extern int       FastN=34;
extern int       SlowN=55;
extern int    TrigN=7;
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
 

double  Klinger[];
double Signal[];
double DM[];
double CM[];
double Trend[];
double VF[];
double Typical[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

  IndicatorShortName("Klinger_Oscillator");
  IndicatorDigits(Digits);  
  
   IndicatorBuffers(7);
   
    SetIndexBuffer(0, Klinger);
   SetIndexStyle(0,DRAW_LINE); 
  
   SetIndexBuffer(1,Signal);
   SetIndexStyle(1,DRAW_LINE);
    
    SetIndexBuffer(2, DM);
   SetIndexStyle(2,DRAW_NONE); 
   
     SetIndexBuffer(3, Trend);
   SetIndexStyle(3,DRAW_NONE); 
   
    SetIndexBuffer(4, CM);
   SetIndexStyle(4,DRAW_NONE); 
   
    SetIndexBuffer(5, VF);
   SetIndexStyle(5,DRAW_NONE); 
   
      SetIndexBuffer(6, Typical);
   SetIndexStyle(6,DRAW_NONE); 
   
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
  
  
    int ExtCountedBars=IndicatorCounted();
	 if (ExtCountedBars<0) return(0);
	 
   int    limit=Bars;
   
   
 int pos=limit;
 while(pos>=0)
 {
             Trend[pos] = 0;
             CM[pos] = 0;  
	    	 DM[pos] = High[pos] - Low[pos];
		     Typical[pos] = ( High[pos] + Low[pos]+Close[pos])/3; 
			 
		     
			 Trend[pos] = Trend[pos+1];
			 
		     if (Typical[pos] > Typical[pos+1])
			 {
			  Trend[pos] = 1;
			 }
			 else
			 {
				 if (Typical[pos] < Typical[pos+1])
				 {
				 Trend[pos] = -1;
				 }
			 }
			 
			if ( Trend[pos] == Trend[pos+1])  
			{
            CM[pos] = CM[pos] + DM[pos];
			}
            else
			{
            CM[pos] = DM[pos+1] + DM[pos];
			}
         
		
		
        if (CM[pos] == 0) 
		{
            VF[pos] = 0;
		}	
        else
		{
            VF[pos] = Volume[pos] * MathAbs(2 * DM[pos] / CM[pos]+1) *  Trend[pos] * 100;
        }
		
		
		
             pos--;
 }
 
 
 pos=limit;
 while(pos>=0)
 {
            double Fast = iMAOnArray(VF,0,FastN,0,1,pos);
			double Slow = iMAOnArray(VF,0,SlowN,0,1,pos);
            Klinger[pos]= Fast-Slow;
             pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]= iMAOnArray(Klinger,0,TrigN,0,1,pos);
           pos--;
 }
 
  
   return(0);
  }
//+------------------------------------------------------------------+