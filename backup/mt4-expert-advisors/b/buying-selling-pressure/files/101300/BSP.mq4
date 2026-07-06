//+------------------------------------------------------------------+
//|                                       Buying Selling Pressure.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|------------------------------------------------------------------|
//|                                     Paypal: http://goo.gl/cEP5h5 |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Gray
#property indicator_color5 Lime
#property indicator_color6 Tomato


extern int Length=14;
extern int Smoothing_Mode=0;
extern int Smoothing_Period=4;

extern int Type1 = 3;
extern int Type2 = 2;


double BP[];
double SP[];
double PT[];
double PS[];
double SBP[];
double SSP[];
int init()
  {
   IndicatorShortName("Buying Selling Pressure");
   IndicatorDigits(Digits);
   
   
    if(! (Smoothing_Mode >= 0 && Smoothing_Mode <= 3  )  ) 
   {
   Alert("Permitted MA_Modes are between 0 and 3");

   return(-1);
   }
   
    if(! (Type1 >= 0 && Type1 <= 3  )  ) 
   {
   Alert("Type1 are between 0 and 3");

   return(-1);
   }
   
   if(! (Type2 >= 0 && Type2 <= 2  )  ) 
   {
   Alert("Type2 are between 0 and 2");

   return(-1);
   }
   
   
   if (Type1 == 1 || Type1 == 0 )
   {
	   if (Type2 == 1 || Type2 == 0) 
	   {
	   SetIndexStyle(0,DRAW_LINE);
	   SetIndexBuffer(0,BP); 
	   }
	   else
	   {
	    SetIndexStyle(0,DRAW_NONE);
        SetIndexBuffer(0,BP); 
	   }
	 
       if (Type2 == 2 || Type2 == 0)  
	   {	
	   SetIndexStyle(4,DRAW_LINE);
	   SetIndexBuffer(4,SBP); 
	   }
	   else
	   {
	    SetIndexStyle(0,DRAW_NONE);
        SetIndexBuffer(0,SBP); 
	   }
   }
   else
   {
    SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,BP);   
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,SBP); 
   }
   
   
    if (Type1 == 2 || Type1 == 0)
  {
		if (Type2 == 1 || Type2 == 0) 
		{	
	   SetIndexStyle(1,DRAW_LINE);
	   SetIndexBuffer(1,SP);
	   }
	   else
	   {
	    SetIndexStyle(1,DRAW_NONE);
	   SetIndexBuffer(1,SP);
	   }
		if (Type2 == 2 || Type2 == 0) 
	   {	
	   SetIndexStyle(5,DRAW_LINE);
	   SetIndexBuffer(5,SSP);	   
	   }
	    else
	  {
	    SetIndexStyle(5,DRAW_NONE);
	   SetIndexBuffer(5,SSP);
      }	 
	}
	else
   {	
    SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,SP);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,SSP);
  }
  
   if (Type1 == 3 || Type1 == 0)
   {
   
        if (Type2 == 1 || Type2 == 0) 
		{	
        SetIndexStyle(2,DRAW_LINE);
       SetIndexBuffer(2,PT); 
       }
       else
       {
	    SetIndexStyle(2,DRAW_NONE);
       SetIndexBuffer(2,PT); 
       }	   
	   if (Type2 == 2 || Type2 == 0) 
		{	 
        SetIndexStyle(3,DRAW_LINE);
        SetIndexBuffer(3,PS);
		}
		else
		{
		SetIndexStyle(3,DRAW_NONE);
        SetIndexBuffer(3,PS);
		}
   }
   else
   {
    SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,PT);   
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,PS);
   }
   
  
    
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos=limit;
 while(pos>=0)
 { 
        BP[pos] = High[pos]-Open[pos];		
        SP[pos] = Open[pos]-Low[pos];	
		
		if  (BP[pos] >  SP[pos])
		{
		PT[pos]= BP[pos];
		}
		else
		{
		PT[pos]= SP[pos];
		}
		 
 
 
			SBP[pos]= iMAOnArray(BP,0,Smoothing_Period,0,Smoothing_Mode,pos); 
			SSP[pos]= iMAOnArray(SP,0,Smoothing_Period,0,Smoothing_Mode,pos);
		 
		
		
				 
					if ( SBP[pos] >  SSP[pos] )
					{
					PS[pos]= SBP[pos];
					}
					else
					{
					PS[pos]= SSP[pos];
					}
					
		     
  pos--;
 } 
 
 
 
 

 return(0);
}

