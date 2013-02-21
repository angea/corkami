// Hello World and various forms of string substitution

// javac substs.java
// java substs

// Ange Albertini, BSD Licence 2011

public class substs
{
  public static void main(String[] args)
  {
  String a;

  System.out.println("Hello World!");
// getstatic PrintStream System.out
// ldc String Constant "Hello World!"
// invokevirtual void PrintStream.println(String)
  a = "**********************************";

  a = "Hello World!";
  System.out.println(a);
// ldc String Constant "Hello World!"
// astore_1
// getstatic PrintStream System.out
// aload_1 1
// invokevirtual void PrintStream.println(String)
  a = "**********************************";
  
  a = "0123Hello World!789";
  String b = a.substring(4, 4 + 12);
  System.out.println(b);

// astore_1
// ldc String Constant "0123Hello World!789"
// astore_1
// aload_1 1
// iconst_4 4
// bipush 16
// invokevirtual String String.substring(int, int)
// astore_2
// getstatic PrintStream System.out
// aload_2 2
// invokevirtual void PrintStream.println(String)
  a = "**********************************";

  System.out.println("Hello12345689".substring(0,4) + "o World!");
// getstatic PrintStream System.out
// new StringBuilder
// dup
// invokespecial void StringBuilder.<init>()
// ldc String Constant "Hello12345689"
// iconst_0 0
// iconst_4 4
// invokevirtual String String.substring(int, int)
// invokevirtual StringBuilder StringBuilder.append(String)
// ldc String Constant "o World!"
// invokevirtual StringBuilder StringBuilder.append(String)
// invokevirtual String StringBuilder.toString()
// invokevirtual void PrintStream.println(String)
  a = "**********************************";

  System.out.println("H*e*l***lo ****Wo*r*l*d!".replace("*", ""));
// getstatic PrintStream System.out
// ldc String Constant "H*e*l***lo ****Wo*r*l*d!"
// ldc String Constant "*"
// ldc String Constant ""
// invokevirtual String String.replace(CharSequence, CharSequence)
// invokevirtual void PrintStream.println(String)
     a = "**********************************";

  }
}