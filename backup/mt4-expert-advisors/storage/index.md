# Storage

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=21111  
> Forum: 38 · Topic 21111 · 1 post(s)


---

## Storage

**Alexander.Gettinger** · Tue Jul 17, 2012 5:22 pm

Sometimes the indicator or expert advisor needs to save some of the values ​​for later use. Using global variables can only store a numeric value. This library allows you to save any value as a string.

Before using the library must be placed in the directory /experts/include of MT4.
To connect the library, use the command "#include <Storage.mqh>" in indicator/EA.
The library contains four functions:

**void openDB(string _DBname)**
Opens the database named _DBname. As the name may be used the name of the indicator or whatever.

**void put(string name, string value)**
Save the value with [name].

**string get(string name, string default_value)**
Return a value [name].
If no value is found in the database will be returned default value.

**void closeDB()**
Close the database and save all changes.
Until the function is called, all changes in the database are not saved.

Example of use:

Code: [Select all](https://fxcodebase.com/code/)
`#include <Storage.mqh>

int start()
{
 openDB("Test");
 put("val2","1000");
 Print(get("val2",1));
 Print(get("val1",1));
 closeDB();
 return(0);
}`

Download:

 [Storage.mqh](files/36989/Storage.mqh)
