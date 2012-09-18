
package edu.ucdenver.ccp.util;

/**
 *  <br> Authors:  Philip V. Ogren
 *  <br>  Created: July 12, 2002
 *  <br>  Description:  
 *      This class is essentially a marker class that tells the programmer that 
 *      a given member variable of another class is a property name.  For 
 *      example, the PropertiesConnection class in the sql package has a method
 *      that takes a Properties object.  The PropertiesConnection class has 
 *      several static member variables that are of type PropertyName - this 
 *      helps the programmer know that what properties need to be present in the
 *      properties object that is passed to getConnection.
 *      
 *   <br> Changes:
 *   <br> Todo:  
 */


public class PropertyName 
{
    private String name;
    
    public PropertyName(String name) 
    {
        this.name = name;
    }
    
    public String getName()
    {
        return name;
    }
    
    public String toString()
    {
        return name;
    }
}
