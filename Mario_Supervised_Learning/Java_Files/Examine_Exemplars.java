import java.util.HashMap;
import java.util.Scanner;
import java.io.File;
import java.io.PrintWriter;
import java.util.ArrayList;

class Examine_Exemplars
{

	public static void countDistinctExemplars(String file)
	{
		HashMap<String, Integer> count = new HashMap<String, Integer>();

		Scanner sc = null;
		try
		{
			sc = new Scanner(new File(file));
		}
		catch(Exception e)
		{
			System.out.println("File "+file+" not found!");
		}

		while(sc.hasNextLine())
		{
			String line = sc.nextLine();
			String exemplar = line.substring(0,line.indexOf(";"));

			if(count.containsKey(exemplar))
			{
				count.put(exemplar,count.get(exemplar)+1);
			}
			else
			{
				count.put(exemplar,1);
			}

		}

		PrintWriter pw = null;
		try
		{
			pw = new PrintWriter("exemplar-Count.dat");
		}
		catch(Exception e)
		{
			System.out.println("File "+file+" not found!");
		}

		for(String key : count.keySet())
		{
			pw.println(key+" | count: "+count.get(key));
		}
		pw.close();
	}

	public static void removeDublicateExemplars(String file)
	{

		ArrayList<String> nonDupExemplars = new ArrayList<String>();

		Scanner sc = null;
		try
		{
			sc = new Scanner(new File(file));
		}
		catch(Exception e)
		{
			System.out.println("Error creating file");
		}

		while(sc.hasNextLine())
		{
			String line = sc.nextLine();

			if(!nonDupExemplars.contains(line))
				nonDupExemplars.add(line);
		}

		PrintWriter pw = null;
		try
		{
			pw = new PrintWriter("exemplars_no_dupes.dat");
		}
		catch(Exception e)
		{
			System.out.println("Error creating file");
		}

		for(int i = 0; i<nonDupExemplars.size(); i++)
		{
			pw.println(nonDupExemplars.get(i));
		}
		pw.close();
	}


	public static void main(String [] args)
	{
		String exemplarFile = "../Exemplar_Files/exemplars_Feb_04_14_30_49.dat";

		System.out.println("Examining: "+exemplarFile);
		countDistinctExemplars(exemplarFile);

		removeDublicateExemplars(exemplarFile);
	}

}