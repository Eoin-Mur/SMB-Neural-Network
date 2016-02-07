import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Scanner;
import java.io.File;
import java.io.PrintWriter;
import java.util.ArrayList;

class PreProcess_Exemplars
{

	public static String countDistinctExemplars(String file)
	{
		HashMap<String, Integer> count = new HashMap<String, Integer>();

		Scanner sc = null;
		try
		{
			sc = new Scanner(new File("../Exemplar_Files/"+file+".dat"));
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
			pw = new PrintWriter(file+"-Count.dat");
		}
		catch(Exception e)
		{
			System.out.println("Error creating file");
		}

		for(String key : count.keySet())
		{
			pw.println(key+" | count: "+count.get(key));
		}
		pw.close();

		return file+"-Count";
	}

	public static String removeDublicateExemplars(String file)
	{

		ArrayList<String> nonDupExemplars = new ArrayList<String>();

		Scanner sc = null;
		try
		{
			sc = new Scanner(new File("../Exemplar_Files/"+file+".dat"));
		}
		catch(Exception e)
		{
			System.out.println("File "+file+" not found!");
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
			pw = new PrintWriter(file+"_ND.dat");
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

		return file+"_ND";
	}


	public static String sameInputDiffOutput(String file)
	{
		LinkedHashMap<String,String> exemplars = new LinkedHashMap<String,String>();

		Scanner sc = null;
		try
		{
			sc = new Scanner(new File(file+".dat"));
		}
		catch(Exception e)
		{
			System.out.println("File "+file+" not found!");
		}

		while(sc.hasNextLine())
		{
			String line = sc.nextLine();
			String input = line.substring(0,line.indexOf(";"));
			String output = line.substring(line.indexOf(";")+1, line.length());

			if(exemplars.get(input) == null)
			{
				exemplars.put(input,output);
			}
			else
			{
				if(numOnOutputs(output) > numOnOutputs(exemplars.get(input)))
					exemplars.put(input,output);
			}
		}

		PrintWriter pw = null;
		try
		{
			pw = new PrintWriter(file+"_HOOC.dat");
		}
		catch(Exception e)
		{
			System.out.println("Error creating file");
		}

		for(String key : exemplars.keySet())
		{

			pw.println(key+";"+exemplars.get(key));

		}
		pw.close();
		return file+"_HOOC";
	}

	public static int numOnOutputs(String output)
	{
		int count = 0;
		for(String out : output.split("\\|"))
		{
			if(Integer.parseInt(out) == 1)
				count++;
		}
		return count;
	}

	public static void main(String [] args)
	{

		//String exemplarFile = "../Exemplar_Files/exemplars_no_dupes_best_exemplar_file.dat";

		if(args.length != 1)
		{
			System.out.println("Usage: \n\tjava PreProcess_Exemplars 'exemplarFileName'");
		}
		else
		{
				System.out.println("Examining: "+args[0]);
			//countDistinctExemplars(exemplarFile);

			//removeDublicateExemplars(exemplarFile);

			sameInputDiffOutput(removeDublicateExemplars(args[0]));

			System.out.println("Done!");
		}
			
	}

}