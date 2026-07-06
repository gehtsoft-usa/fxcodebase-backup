//+------------------------------------------------------------------+
//|                              Fx Sniper's Ergodic CCI Trigger.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 2

#property indicator_color1  clrLime
#property indicator_width1  1
#property indicator_color2  clrRed
#property indicator_width2  1
#property indicator_levelcolor clrYellow
 
 
enum e_method2{ SMA = 1, EMA = 2, SMMA = 3, LWMA = 4 };
             

extern int       pq  = 4;
extern int       pr  = 8;
extern int       ps = 5;
extern int       trigger = 4;



extern e_method2 MA_Method_Selected  = SMA;


double mtm[];
double absmtm[];
double buff1[];
double buff2[];

double var1[];
double var2[];
double var2a[];
double var2b[];
double var2c[];
double var3[];

   
//+****************************************************************+

int init(){
    
   IndicatorShortName("Fx Sniper's Ergodic CCI Trigger");
   
   IndicatorBuffers(10);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, buff1);
   SetIndexDrawBegin(0,2+ pq+pr+ps);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,buff2);
  SetIndexDrawBegin(1,2+ pq+pr+ps+trigger);
   
   SetIndexBuffer(2,mtm);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexDrawBegin(2,2);
   
   SetIndexBuffer(3,absmtm);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexDrawBegin(3,2);
   
   SetIndexBuffer(4,var1);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexDrawBegin(4,2+ pq);
  
   
   SetIndexBuffer(5,var2);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexDrawBegin(5,2+ pq+pr);
   
   SetIndexBuffer(6,var2a);
   SetIndexStyle(6,DRAW_NONE);
    SetIndexDrawBegin(6,2+ pq);
   
   SetIndexBuffer(7,var2b);
   SetIndexStyle(7,DRAW_NONE);
    SetIndexDrawBegin(7,2+ pq+pr);
   
   SetIndexBuffer(8,var2c);
   SetIndexStyle(8,DRAW_NONE);
     SetIndexDrawBegin(8,2+ pq+pr+ps);
   
   SetIndexBuffer(9,var3);
   SetIndexStyle(9,DRAW_NONE);
     SetIndexDrawBegin(9,2+ pq+pr+ps);
   
 
   
   SetLevelValue(0,0);
   SetLevelStyle(STYLE_DOT,0);
   
   return(0);
  }
  
//+****************************************************************+

  
int start(){
   
 
  
  
    if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int limit=Bars-2;
   int pos;
   int current;
   
   
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   
   pos=limit;
   while(pos>=0)
   {
   
   
    mtm[pos]=Close[pos]-Close[pos+1];
    
   
    pos--;
   } 
   
   
      current=limit;
   while(current>=0)
   {
   
     
        var1[current] = iMAOnArray(mtm,0,pq,0, MA_Method_Selected-1,current);
         
	 
    current--;
   } 
 
 
      current=limit;
   while(current>=0)
   {
   
     
        var2[current] = iMAOnArray(var1,0,pr,0, MA_Method_Selected-1,current);
	
     current--;
   } 
   
      
   current=limit;
   while(current>=0)
   {
   
     
        
         var2c[current] = iMAOnArray(var2,0,ps,0, MA_Method_Selected-1,current);   
	   current--;
   } 
      	 
	
   
    pos=limit;
   while(pos>=0)
   {
   absmtm[pos]=MathAbs(mtm[pos]);
      pos--;
   }  
   
     current=limit;
   while(current>=0)
   {
      var2a[current] = iMAOnArray(absmtm,0,pq,0, MA_Method_Selected-1,current);      
    current--;
   } 
    
   

 current=limit;
   while(current>=0)
   {
   		
        var2b[current] = iMAOnArray(var2a,0,pr,0, MA_Method_Selected-1,current);
	 
    current--;
   } 
   
     current=limit;
   while(current>=0)
   {
   		 
	     var3[current] = iMAOnArray(var2b,0,ps,0, MA_Method_Selected-1,current);
    current--;
   } 
   
   
 
   
   
   pos=limit;
      while(pos>=0)
   {
   
       if ( var3[pos] != 0)
	   {
       buff1[pos]=(500.*var2c[pos])/var3[pos]; 
	   }
      
    pos--;
   } 
   
    pos=limit;
      while(pos>=0)
   {
    
      buff2[pos]= iMAOnArray(buff1,0,trigger,0, MA_Method_Selected-1,pos);   	   
   
    pos--;
   } 
   
   
 
  
   
   return(0);
   
  }
  
 
