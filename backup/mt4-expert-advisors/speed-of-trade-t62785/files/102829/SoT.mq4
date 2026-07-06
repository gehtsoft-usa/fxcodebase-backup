//+------------------------------------------------------------------+
//|                                           Weight_Of_Evidence.mq4 |
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
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Blue

extern int Type=0;    // Applied price
                       // 0 - Open/Close
                       // 1 - High/Low
					   
					   
extern int MA_Mode=0;
               
extern int MA_Period=12;
extern double Trigger_Level=2;
extern int Arrow_Size=4;

double SOT[];
double AVG[];
double Up[], Dn[];
int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SOT);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,AVG);
 
 
 SetIndexStyle(2,DRAW_ARROW,0,Arrow_Size);
 SetIndexArrow(2,233);
 SetIndexBuffer(2,Up);
 SetIndexStyle(3,DRAW_ARROW,0,Arrow_Size);
 SetIndexArrow(3,234);
 SetIndexBuffer(3,Dn);
 

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
 int pos;
 
double PipValue = MarketInfo(Symbol(),MODE_POINT); 
  
 pos=limit;  
 while(pos>=0)
 {
  
  
        if (Type == 0)
	    {
        SOT[pos] = ((MathAbs(Open[pos]-Close[pos])) /PipValue)/Volume[pos];
		}
		else
		{
		 SOT[pos] = ((MathAbs(High[pos]-Low[pos])) /PipValue)/Volume[pos];
		}
		
		
   pos--;
  } 
  
  
   pos=limit;  
   while(pos>=0)
 {
  
   AVG[pos]= iMAOnArray(SOT,0,MA_Period=12,0,MA_Mode,pos);
	
    Up[pos]=EMPTY_VALUE;
    Dn[pos]=EMPTY_VALUE;	
	
	 if  (SOT[pos]  > AVG[pos] *Trigger_Level )
	 {
	     if ( Close[pos]> Open[pos])
         {		 
		 Up[pos] = AVG[pos];
		 }
		if (Close[pos]< Open[pos])
             {			 
		       Dn[pos] = AVG[pos];
			  }
	 }
	
   pos--;
      
  } 
 return(0);
}

