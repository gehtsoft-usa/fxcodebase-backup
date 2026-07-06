//+------------------------------------------------------------------+
//|                                        Valid Swing HighLow.mq4   |
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

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
extern int  ArrowSize=2;  
                     

double Up[], Dn[];
double Last[];

int init()
{
 IndicatorShortName("Valid Swing HighLow");
 IndicatorDigits(Digits);
 SetIndexBuffer(0,Up);
 SetIndexBuffer(1,Dn); 
 SetIndexStyle(0,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(0,234);
 SetIndexStyle(1,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(1,233);
 SetIndexEmptyValue(0,0.0);
 SetIndexEmptyValue(1,0.0);
 SetIndexLabel(0,"Fractal Up");
 SetIndexLabel(1,"Fractal Down");
 
 SetIndexBuffer(2,Last); 
 SetIndexStyle(2,DRAW_NONE);

 

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
 pos=limit;
 while(pos>=0)
 {
  
  
   int  curr = pos + 2;
	   Last[curr]=0; 		
		
        if (High[curr]  > High[curr -1]  && High[curr] > High[curr -2] &&
            High[curr]  > High[curr + 1] && High[curr]  > High[curr+2])
		{	 
		     Up[pos]=High[pos];
			 Last[curr]= 1;	
			 Previous(pos, 1);
			 
        }  
         if (Low[curr]  < Low[curr -1] && Low[curr] < Low[curr -2] &&
         Low[curr] < Low[curr + 1] && Low[curr] < Low[curr+2])  
		{	
		
		   Dn[pos]=Low[pos];
	       Last[curr]= -1;	
	       Previous(pos, -1);
		 
		 }
        
        
         
		
  pos--;
 } 
 
    
   
 return(0);
}


void Previous(int period, int flag)
{
 int ExtCountedBars=IndicatorCounted();
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int i;
 
     
		for (i= period+1 ; i >=limit ; i++ )
		{
		  
			  if (Last[i]==  flag )
			  {
				  if (flag== 1 && High[i] < High[period])
				  {
				  Last[i]=0;   
				  break;
				  }
				  else if (flag== -1 && Low[i] > Low[period] )
				  {
				  Last[i]=0; 
				  break;  
				  }
			 }
		}
		 
}


