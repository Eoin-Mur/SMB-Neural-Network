import java.util.ArrayList;
import java.io.File;
import java.util.Scanner;
import java.io.PrintWriter;

public class ReduceInputs
{

	public static int FULL_RAIDUS = 7;

	public static int reduce(int newRadius,String file)
	{

		if(newRadius == FULL_RAIDUS)
			return 1;

		ArrayList<String> exemplars = new ArrayList<String>();

		Scanner sc = null;
		try
		{
			sc = new Scanner(new File("../Exemplar_Files/"+file+".dat"));
		}
		catch(Exception e)
		{
			try
			{
				sc = new Scanner(new File("../Pre-processing/"+file+".dat"));
			}
			catch(Exception ex)
			{
				System.out.println("File "+file+" not found!");
				return -1;
			}
		}

		while(sc.hasNextLine())
		{
			String line = sc.nextLine();
			String input = line.substring(0,line.indexOf(";"));
			String output = line.substring(line.indexOf(";")+1,line.length());

			String[] inputArray = input.split("\\|");
			int inputArrayIndex = 0;
			String newInput = "";
			int currentRow = 1;
			int offset = 0;

			
			for(int i = 1; i< inputArray.length+1;i++)
			{
				if(i % (FULL_RAIDUS * 2 + 1)  == 0 && i != 1)
				{
					currentRow++;
				}
				else if(currentRow > (FULL_RAIDUS - newRadius)
					&& currentRow <= ( (newRadius * 2 + 1) + ( FULL_RAIDUS - newRadius ) ) )
				{ 
					if(i % (FULL_RAIDUS * 2 + 1) > ( FULL_RAIDUS - newRadius ) 
						&& i % (FULL_RAIDUS * 2 +1 ) <= ( (newRadius * 2 + 1) + ( FULL_RAIDUS - newRadius ) ) )
					{
						newInput = newInput + inputArray[i-1] + "|";
					}
				}
			}

			exemplars.add(newInput.substring(0,newInput.length()-1)+";"+output);
			newInput = "";

		}

		PrintWriter pw = null;
		try
		{
			pw = new PrintWriter(file+"-Reduced-Inputs_"+newRadius+".dat");
		}
		catch(Exception e)
		{
			System.out.println("Error creating file");
			return -1;
		}

		for(int i = 0; i < exemplars.size(); i++)
		{
			pw.println(exemplars.get(i));
		}

		pw.close();

		return 1;
	}


	public static String[] reduceArray(String[] a, int r)
	{
		String x[] = new String[a.length - r];
		int j = 0;
		for(int i = r; i < a.length; i++)
		{
			x[j] = a[i];
			j++;
		}	
		return x;
	}

	public static void main(String [] args)
	{
		if(args.length != 1)
			System.out.println("Usage:\n\tjava ReduceInputs ");
		else
		{
			System.out.println("Reducing to 1 radius \n\tStatus: "+reduce(1,args[0]));
			System.out.println("Reducing to 2 radius \n\tStatus: "+reduce(2,args[0]));
			System.out.println("Reducing to 3 radius \n\tStatus: "+reduce(3,args[0]));
			System.out.println("Reducing to 4 radius \n\tStatus: "+reduce(4,args[0]));
			System.out.println("Reducing to 5 radius \n\tStatus: "+reduce(5,args[0]));
			System.out.println("Reducing to 6 radius \n\tStatus: "+reduce(6,args[0]));
			System.out.println("Reducing to 7 radius \n\tStatus: "+reduce(7,args[0]));
		}
	}
}