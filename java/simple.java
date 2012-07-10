// simple java class to be dissected

// thanks to Sami Koivu advices

// Ange Albertini, BSD licence 2012

import java.io.Serializable;

public class simple extends Thread implements Serializable
{
    public String field1;

    public static void main(String[] args)
    {
        try
        {
            throw new Exception();
        }
        catch (Exception e)
        {
            System.out.println("Hello World!");
        }
    }
}