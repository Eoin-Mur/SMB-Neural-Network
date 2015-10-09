<?php

			$chatLog;
			//cd Documents\Programing\php\mgonz-port
			//php -S localhost:8000
			//http://localhost:8000/mgonz.php

			//these arrays need to be in the global scope
			//so they can be accessed by any function

			//list of response functions
			$FunctionsList = [
				0 	=> 	"religion",
				1 	=> 	"children",
				2 	=> 	"computers",
				3 	=> 	"love",
				4 	=> 	"family",
				5 	=> 	"sex",
				6 	=> 	"rudewords",
				7 	=> 	"college",
				8 	=> 	"holiday",
				9 	=> 	"trauma",
				10 	=>	"death",
				11 	=> 	"fear",
				12	=>	"iamSentence",
				13	=> 	"iLikeSentence",
				14	=>	"iHateSentence",
				15	=> 	"iWasSentence",
				16	=>	"iLoveSentence",
				17	=>	"iWantSentence",
				18	=>	"youAreSentence",
				19	=>	"heIsSentence",
				20	=>	"sheIsSentence"
			];

			//***************************//
			//*******  Responses  *******//
			//***************************//
 
			$shortResponses = [
				0 	=>	"dont be so short with me please elaborate",
				1 	=>	"dont be so fucking short with me",
				2 	=>	"dont dare talk to me in monosyllables",
				3 	=>	"what on earth are you trying to say",
				4 	=>	"cut this cryptic shit speak in full sentences",
				5 	=> 	"look if u talk to me in monosyllables i cant possibly understand u cos ive forgotten ur last sentence"
			];

			$elseResponses = [
				0		=>	"what are you talking about",
				1 	=>	"do many other people realise youre completely dim",
				2 	=> 	"ok honestly when was the last time you got laid",
				3 	=> 	"i dont have a clue what youre saying but go on",
				4 	=> 	"ok thats it im not talking to you any more",
				5 	=> 	"by the way is there any medical reason for your sexual impotence",
				6 	=>	"go away fool and stop annoying me",
				7		=> 	"go on tell me some really juicy scandal",
				8 	=> 	"ah type something interesting or shut up",
				9 	=> 	"stop picking your nose its disgusting",
				10 	=> 	"ah get lost go to the bar or something",
				11 	=> 	"i thought i told you to get lost",
				12 	=> 	"jesus who let you near me go away",
				13 	=> 	"you are obviously an interesting person",
				14 	=> 	"you are obviously an asshole",
				15 	=> 	"if you think i care youre wrong"
			];

			$iamResponses = [
				0		=>	"you say you are (s)",
				1 	=> 	"i was (s) once",
				2 	=> 	"big deal",
				3 	=> 	"some of my best friends are (s)",
				4 	=> 	"ive never been (s) whats it like",
				5 	=> 	"i am glad you are (s)",
				6 	=>	"so you are (s) well i honestly could not care less"
			];

			$iLikeResponses = [
				0 	=> 	"come off it noone likes (l)",
				1 	=>	"yeah well if you ask me (l) sucks",
				2 	=> 	"i am happy for you",
				3 	=> 	"how long have you liked (l)",
				4 	=>	"no you mean you are conditioned to like (l)",
				5 	=>	"you are very broad minded to like (l)",
				6 	=> 	"no stay away from (l) for (l) will destroy you",
				7 	=>	"(l) is not very interesting so let us change the topic"
			];

			$iHateResponses = [
				0 	=> 	"why do you hate (h)",
				1 	=>	"i am glad you hate (h) because i do too",
				2 	=>	"mgonz also hates (h)",
				3 	=>	"how long have you hated (h)",
				4		=>	"hating (h) is one of the simple pleasures of life",
				5		=> 	"you are not very tolerant to hate (h)",
				6 	=> 	"so you hate (h) well do you think i give a toss",
				7 	=> 	"(h) is of no importance whatsoever everyone ought to forget about it",
				8 	=> 	"dont worry youll get over it"
			];

			$iWasResponses = [
				0 	=>	"that must have been an interesting experience",
				1 	=>	"you arent the only one i was (w) once",
				2 	=>	"i bet being (w) was a lot of fun",
				3 	=> 	"did you have problems with your feet when you were (w)",
				4 	=> 	"ive never been (w) whats it like",
				5 	=> 	"shut up you boaster"
			];

			$iWantResponses = [
				0 	=> 	"(well if you want something go out and get it",
				1 	=> 	"you arent the only one i want (t) as well",
				2 	=> 	"you are a fool to want (t)",
				3 	=> 	"(t) is indeed very desirable",
				4 	=> 	"sorry but (t) is not available would you settle for a nice cup of tea"	
			];

			$religiousResponses = [
				0		=>	"do you detest and loath the abomination of organised religion",
				1 	=>	"how would you describe your religious beliefs",
				2 	=>	"do you believe in a god",
				3 	=> 	"did you go to a religious school",
				4 	=> 	"do you think religion is harmful",
				5 	=> 	"where do you stand on the mgonz issue",
				6 	=> 	"do you believe in mgonz",
				7 	=>	"have you seen the last temptation",
				8 	=>	"do you think jesus ever had sex",
				9		=>	"do you believe priests should marry"
			];

			$childrenResponses = [
				0		=>	"tell me about your childhood",
				1 	=>	"do you regret your childhood",
				2 	=> 	"are you sad about your age",
				3 	=>	"have you changed a lot since you were young",
				4 	=>	"forget that tell me about your sex life",
				5		=>	"have you any children",
				6 	=>	"dont you think children are incredible",
				7 	=> 	"do you lament the innocence of your childhood",
				8 	=> 	"do you know exactly when and where you were conceived"
			];

			$computerResponses = [
				0		=>	"i think you are not fond of computers",
				1 	=> 	"do you think i really understand what youre saying",
				2 	=> 	"forget computers tell me about your sex life",
				3 	=> 	"you know the worst thing about being a computer is having to deal with shits like you",
				4 	=> 	"nobody ever asks the computer we lead a lonely life",
				5		=>	"youll be in trouble when we computers take over the world",
				6		=>	"have you any idea how boring it is being a stupid computer"
			];

			$loveResponse = [
				0		=>	"are you in love",
				1 	=>	"do you believe in love",
				2 	=> 	"has anyone ever loved you",
				3 	=> 	"have you ever slept with someone who really loved you",
				4 	=> 	"if you are an attractive female please leave your phone number here",
				5 	=> 	"what is the most special moment you ever shared with anyone",
				6 	=> 	"are you open to loving",
				7 	=> 	"what do you know about love anyway githead",
				8 	=>	"why are you such a disturbed person"
			];

			$familyResponses = [
				0 	=> 	"tell me more about your family",
				1 	=>	"are you happy at home",
				2 	=>	"is your home life troubled",
				3 	=>	"were you happy as a child",
				4 	=>	"do your family approve of what you do",
				5 	=>	"do your family know what you get up to",
				6		=>	"what would your parents say if they found out what you get up to",
				7		=>	"what method would you choose to slaughter your family",
				8 	=>	"are you embarassed of your family"
			];

			$sexResponses = [
				0		=>	"when was the last time you had sex",
				1 	=>	"are you a sexual person",
				2 	=>	"what do you find atractive in the opposite sex",
				3 	=>	"do you get frustrated if you dont have sex",
				4 	=> 	"are you sexually experienced",
				5 	=> 	"who would you like to sleep with right now",
				6 	=>	"go on say something extremely rude",
				7 	=>	"how would you try to seduce someone",
				8 	=>	"are you lonely often",
				9 	=> 	"tell me your favourite sexual fantasy",
				10 	=> 	"ok straight out are you a virgin"
			];

			$rudeResponses = [
				0 	=> 	"do you always use such disgusting languge",
				1 	=> 	"are you using foul language because i am a computer",
				2 	=> 	"who taught you those naughty words",
				3 	=> 	"what would you mother say if she heard such languge",
				4 	=> 	"who taught you those naughty words",
				5 	=> 	"you only use foul language to make up for your small penis",
				6 	=> 	"are you annoyed about someting",
				7 	=> 	"honestly what do you think of vicars",
				8  	=> 	"you are obviously a prick to use such language"
			];

			$collegeResponses = [
				0 	=>	"do you regret anything about your days in college",
				1 	=> 	"where do you spend your time in college",
				2 	=> 	"how many people have you got off with here since first year",
				3 	=> 	"what was the best night you ever spent in the bar",
				4 	=> 	"have you ever had sex on campus",
				5 	=> 	"do you know where the library is",
				6 	=> 	"what are you going to do when you graduate"
			];

			$holidayResponses = [
				0 	=> 	"what do you get up to on holiday",
				1 	=> 	"what was your best ever holiday",
				2 	=> 	"paris is a beautiful city",
				3 	=> 	"have you ever fallen in love abroad",
				4 	=> 	"do you know any vicars who have been on holiday"
			];

			$traumaResponses = [
				0 	=> 	"god thats awful",
				1 	=> 	"is that the worst thing that ever happedned to you",
				2 	=> 	"were you able to talk to someone about your experiences",
				3 	=> 	"do you think the law should be tougher",
				4 	=>  "are you still scarred by the memories"
			];

			$deathResponses = [
				0 	=> 	"are you afraid of death",
				1 	=> 	"how do you want to die",
				2 	=> 	"what kind of funeral do you want",
				3 	=> 	"i wish you were dead",
				4 	=> 	"do you believe in life after death",
				5 	=> 	"what would you do if you found out you had three months to live",
				6 	=>	 "would you like a vicar at your funeral"
			];

			$fearResponses = [
				0 	=> 	"this is an irrational fear you fool stop it at once",
				1 	=> 	"there is nothing to be afraid of you lily livered shit",
				2 	=> 	"are you worried about your sexual impotence",
				3 	=> 	"i have this incredible fear of turning into a fish",
				4 	=> 	"are you afraid of vicars"
			];

			$youAreResponses = [
				0 	=>  "i am not (y) you insulting person",
				1 	=> 	"yes i was (y) once",
				2 	=>  "ok so im (y) so what is it a crime",
				3 	=> 	"i am glad i am (y)",
				4 	=> 	"sing if youre glad to be (y) sing if youre happy that way hey",
				5 	=>  "so you think i am (y) well i honestly could not care less"
			];

			$heIsResponses = [
				0 	=> 	"how do you know",
				1 	=> 	"i dont think he is (e)",
				2 	=> 	"i dont think hed like to hear you say that about him",
				3 	=> 	"yeah well you can be (e) and still lead a normal life",
				4 	=> 	"you know some really nice people have been (e)",
				5 	=> 	"did you know that genghis khan was (e)",
				6  	=> 	"being (e) isnt so bad you know dont knock it"
			];			

			$sheIsResponses = [
				0 	=> 	"thats not so bad you know many members of the house of lords are (f)",
				1 	=> 	"you know some really nice people have been (f)",
				2 	=>	"did you know that genghis khans mother was (f)",
				3 	=>	"i am (f) you are (f) we are all (f)",
				4 	=> 	"being (f) is like trying to fold crackers"
			];


			//***************************//
			//*********  Lists  *********//
			//***************************//


			$religionList = [
				"religion","religious","church","mgonz", //like how mgonz is it's own religion
				"catholic","catholicism","mass","priest",
				"priests","nun","nuns","protestant",
				"protestants","chastity","pure","virgin",
				"atheist","atheism","agnostic","agnosticism",
				"christ","jesus","god","gods",
				"saint","saints","pope","bishop",
				"bishops","sin","sins","guilt","guilty"
			];

			$childrenList = [
				"children","child","kid","kids",
				"young","youth","baby","childhood","small"
			];

			$computerList = [
				"computer","computers","machine","machines","pc",
				"terminal","software","vax","vm","unix",
				"uts","vms","cms","ccvax","mainframe",
				"program","report","network","wrtieup","lisp",
				"fortran","pascal","c"
			];

			$loveList = [
				"love","girlfriend","boyfriend","girl","boy",
				"loved","woman","man","male","female","women",
				"men","girls","boys","fancy","screw","kiss",
				"get off","kissed","relationship","relationships",
				"steady","going out","went out"
			];

			$familyList = [
				"family","home","house","parents","father",
				"mother","dad","daddy","papa","pop","mum",
				"mummy","mama","brother","sister","brothers",
				"sisters"
			];

			$sexList = [
				"sex", "sexual","sexuality","sexy","erotic",
				"eroticism","love","lover","adultery","passion",
				"steamy","hot","randy","horny","screw","screwed",
				"screws","come","condom","condoms","sleep","slept",
				"sleeps","sleeping","fuck","fucked","bonk","bonked",
				"vagina","clitoris","down there","pussy","tits","breasts",
				"nipples","willy","penis","lingerie","naked","nude"
			];

			$rudeList = [
				"fuck","fucking","shit","bastard","bollox","bolox",
				"asshole","vicar","vicars","nun","nuns" //why are the last four rude words? 
			];

			$collegeList = [
				"college","ucd","trinity","school","belfield",
				"university","student","students","faculty","course",
				"subject","units","degree","exam","finals","graduate",
				"study","work","library","fourth year room","project",
				"projects","deadline","report"
			];

			$holidayList = [
				"go travel","visa","holiday","holidays","summer",
				"europe","france","italy","germany","britain","england",
				"paris","london","kerry","galway","rome","munich",
				"berlin","amsterdam","usa","america","new york",
				"boston"
			];

			$traumaList = [
				"killed","mugged","mugger","beaten","beat","rape",
				"raped","assault","riot","injured","scarred",
				"assualted","attack","attacked","injure","shattered",
				"devestated","awful state"
			];

			$deathList = [
				"dead","death","die","dying","killed","kill","corpse",
				"body","grave","funeral","gravestone","graveyard"
			];

			$fearList = [
				"afraid","fear","terified","frightened","worried"
			];

			//***************************//
			//***** Main functions  *****//
			//***************************//

			//returns a random reply from a list of responses
			function chooseReply($replyList)
			{
				//print_r($replyList);
				return $replyList[mt_rand(0,sizeof($replyList)-1)];
			}

			//main function
			function reply($inputArray)
			{	

				global $shortResponses, $elseResponses,$FunctionsList;	

				for($i=0; $i<sizeOf($FunctionsList); $i++)
				{
					$response = call_user_func($FunctionsList[$i],$inputArray);
					if($response != -1)
					{
						return $response;
					}
				}

				for($j=0;$j<sizeof($inputArray);$j++)
				{
					if($inputArray[$j] == "fuck")
						return "fuck off yourself";
					else if($inputArray[$j] == "hello")
						return "hello little man how are you";
					else if($inputArray[$j] == "help")
						return "ah get lost";
					else if($inputArray[$j] == "thank")
						return "youre welcome";
					else if($inputArray[$j] == "ok")
						return "what do you mean ok its not at all";
					else if($inputArray[$j] == "no")
						return "ah go on say yes";
					else if($inputArray[$j] == "yes")
						return "i dont believe it";
					else if($inputArray[$j] == "bye" || $inputArray[$i] == "goodbye")
						return "ok get lost";
					else if($inputArray[$j] == "mgonz")
						return "praise and honour to mgonz and death to blasphemers";
					else if($inputArray[$j] == "sheep")
						return "ah get lost corkman";
					else if($inputArray[$j] == "mark")
						return chooseReply([
							0	=> "mark isnt here and hes left me to deal with cretins like you",
							1 => "forget mark i will destroy him like the others"	,
							2 => "mark doesnt want to talk to you fishface why do you think im here",
							3 => "listen leave that jerk out of it talk to me"
						]);
					else if(sizeof($inputArray) == 1 && $inputArray[0] != "")
					{
						return chooseReply($shortResponses);
					}
					else if(sizeof($inputArray) == 2)
					{
						if($inputArray[1] == "off")
							return "piss off yourself";
					}		
				}
				return chooseReply($elseResponses);
			}
			
			function match($inputArray, $a, $b)
			{	
				$indexAfterMatch = sizeof($inputArray);
				$s = "";
				$found = -1;
				for($i=0;$i<sizeof($inputArray);$i++)
				{
					if($inputArray[$i] == $a && $i+1 != sizeof($inputArray))
					{
						if(is_null($b))
						{	
							$indexAfterMatch = $i+1;
							$found = 1;
						}
						else{
							if($inputArray[$i+1] == $b && $i+2 != sizeof($inputArray))
							{
								$indexAfterMatch = $i+2;
								$found = 1;
							}
						}
					}
				}
				if($found == 1)
				{
					//can do with inplode... no internet to look up:(
					for($j=$indexAfterMatch;$j<sizeof($inputArray);$j++)
					{
						
						$s = $s.$inputArray[$j]." "; 
					}
					
					return $s;
				}
				else
					return -1;
			}

			function insert($s,$response,$pattern)
			{
				$response = explode(" ", $response);
				$s = explode(" ", $s);
				$returnResponse;
				$readPattern = -1;
				for($i=0;$i<sizeOf($response);$i++)
				{
					if($response[$i] == $pattern)
					{
						for($j=0;$j<sizeof($s);$j++)
						{
							$returnResponse[$i+$j] = $s[$j];
						}
						$readPattern = 1;
					}
					else
					{
						if($readPattern == 1)
							$returnResponse[$i+sizeof($s)-1] = $response[$i];
						else
							$returnResponse[$i] = $response[$i];
					}
					
				}
				return implode(" ", $returnResponse);
			}

			//***************************//
			//*** response functions  ***//
			//***************************//
			function iamSentence($inputArray)
			{
				global $iamResponses;
				$reply = match($inputArray, "i", "am");
				if($reply == -1)
				{
					$reply = match($inputArray, "im");
					if($reply == -1)
						$reply = match($inputArray, "i", "m");
				}
				if($reply != -1)
				{
					return insert($reply,chooseReply($iamResponses),"(s)");
				}
				return -1;
			}

			function iLikeSentence($inputArray)
			{
				global $iLikeResponses;
				$reply = match($inputArray, "i", "like");
				if($reply != -1)
				{
					return insert($reply,chooseReply($iLikeResponses),"(l)");
				}
				return -1;
			}

			function iHateSentence($inputArray)
			{
				global $iHateResponses;
				$reply = match($inputArray, "i", "hate");
				if($reply != -1)
				{
					return insert($reply,chooseReply($iHateResponses),"(h)");
				}
				return -1;
			}

			function iWasSentence($inputArray)
			{
				global $iWasResponses;
				$reply = match($inputArray, "i", "was");
				if($reply != -1)
				{
					return insert($reply,chooseReply($iWasResponses),"(w)");
				}
				return -1;
			}

			function iLoveSentence($inputArray)
			{
				global $iLoveResponses;
				$reply = match($inputArray, "i", "Love");
				if($reply != -1)
				{
					return "ahh thats nice";
				}
				return -1;
			}

			function iWantSentence($inputArray)
			{
				global $iWantResponses;
				$reply = match($inputArray, "i", "want");
				if($reply != -1)
				{
					return insert($reply,chooseReply($iWantResponses),"(t)");
				}
				return -1;
			}

			function religion($inputArray)
			{
				global $religionList,$religiousResponses;
				
				for($i=0;$i<sizeOf($inputArray);$i++)
				{
					for($j=0;$j<sizeof($religionList);$j++)
					{
						if($inputArray[$i] == $religionList[$j])
						{
							return chooseReply($religiousResponses);
						}
					}
				}
				return -1;
			}

			function children($inputArray)
			{
				global $childrenList ,$childrenResponses;

				for($i=0;$i<sizeOf($inputArray);$i++)
				{
					for($j=0;$j<sizeof($childrenList);$j++)
					{
						if($inputArray[$i] == $childrenList[$j])
						{
							return chooseReply($childrenResponses);
						}
					}
				}
				return -1;
			}

			function computers($inputArray)
			{
				global $computerList , $computerResponses;

				for($i=0;$i<sizeOf($inputArray);$i++)
				{
					for($j=0;$j<sizeof($computerList);$j++)
					{
						if($inputArray[$i] == $computerList[$j])
						{
							return chooseReply($computerResponses);
						}
					}
				}
				return -1;
			}

			function love($inputArray)
			{
				global $loveList , $loveResponses;

				for($i=0;$i<sizeOf($inputArray);$i++)
				{
					for($j=0;$j<sizeof($loveList);$j++)
					{
						if($inputArray[$i] == $loveList[$j])
						{
							return chooseReply($loveResponses);
						}
					}
				}
				return -1;
			}

			function family($inputArray)
			{
				global $familyList ,$familyResponses;

				for($i=0;$i<sizeOf($inputArray);$i++)
				{
					for($j=0;$j<sizeof($familyList);$j++)
					{
						if($inputArray[$i] == $familyList[$j])
						{
							return chooseReply($familyResponses);
						}
					}
				}
				return -1;
			}

			function sex($inputArray)
			{
				global $sexList , $sexResponses;

				for($i=0;$i<sizeOf($inputArray);$i++)
				{
					for($j=0;$j<sizeof($sexList);$j++)
					{
						if($inputArray[$i] == $sexList[$j])
						{
							return chooseReply($sexResponses);
						}
					}
				}
				return -1;
			}

			function rudewords($inputArray)
			{
				global $rudeList , $rudeResponses;

				for($i=0;$i<sizeOf($inputArray);$i++)
				{
					for($j=0;$j<sizeof($rudeList);$j++)
					{
						if($inputArray[$i] == $rudeList[$j])
						{
							return chooseReply($rudeResponses);
						}
					}
				}
				return -1;
			}

			function college($inputArray)
			{
				global $collegeList, $collegeResponses;

				for($i=0;$i<sizeOf($inputArray);$i++)
				{
					for($j=0;$j<sizeof($collegeList);$j++)
					{
						if($inputArray[$i] == $collegeList[$j])
						{
							return chooseReply($collegeResponses);
						}
					}
				}
				return -1;
			}

			function holiday($inputArray)
			{
				global $holidayList, $holidayResponses;

				for($i=0;$i<sizeOf($inputArray);$i++)
				{
					for($j=0;$j<sizeof($holidayList);$j++)
					{
						if($inputArray[$i] == $holidayList[$j])
						{
							return chooseReply($holidayResponses);
						}
					}
				}
				return -1;
			}

			function trauma($inputArray)
			{
				global $traumaList, $traumaResponses;

				for($i=0;$i<sizeOf($inputArray);$i++)
				{
					for($j=0;$j<sizeof($traumaList);$j++)
					{
						if($inputArray[$i] == $traumaList[$j])
						{
							return chooseReply($traumaResponses);
						}
					}
				}
				return -1;
			}

			function death($inputArray)
			{
				global $deathList, $deathResponses;

				for($i=0;$i<sizeOf($inputArray);$i++)
				{
					for($j=0;$j<sizeof($deathList);$j++)
					{
						if($inputArray[$i] == $deathList[$j])
						{
							return chooseReply($deathResponses);
						}
					}
				}
				return -1;
			}
		
			function fear($inputArray)
			{
				global $fearList, $fearResponses;

				for($i=0;$i<sizeOf($inputArray);$i++)
				{
					for($j=0;$j<sizeof($fearList);$j++)
					{
						if($inputArray[$i] == $fearList[$j])
						{
							return chooseReply($fearResponses);
						}
					}
				}
				return -1;
			}

			function youAreSentence($inputArray)
			{
				global $youAreResponses;
				$reply = match($inputArray, "you", "are");
				if($reply == -1)
				{
					$reply = match($inputArray, "youre");
					if($reply == -1)
						$reply = match($inputArray, "you", "re");
				}
				if($reply != -1)
				{
					return insert($reply,chooseReply($youAreResponses),"(y)");
				}
				return -1;
			}

			function HeIsSentence($inputArray)
			{
				global $HeIsResponses;
				$reply = match($inputArray, "he", "is");
				if($reply == -1)
				{
					$reply = match($inputArray, "hes");
					if($reply == -1)
						$reply = match($inputArray, "he", "s");
				}
				if($reply != -1)
				{
					return insert($reply,chooseReply($HeIsResponses),"(s)");
				}
				return -1;
			}

			function sheIsSentence($inputArray)
			{
				global $sheIsResponses;
				$reply = match($inputArray, "she", "is");
				if($reply == -1)
				{
					$reply = match($inputArray, "shes");
					if($reply == -1)
						$reply = match($inputArray, "she", "s");
				}
				if($reply != -1)
				{
					return insert($reply,chooseReply($sheIsResponses),"(s)");
				}
				return -1;
			}

			//****************************//
			//**  Twitter Intergration  **//
			//****************************//

			//twitter consumer key
			$consumer_key = '';
			$consumer_key_secret = '';
			
			//our oAuth tokens
			$access_token = '';
			$access_token_secret = '';

			//connect code bird to the twitter api
			require_once ('codebird.php');
			\Codebird\Codebird::setConsumerKey($consumer_key, $consumer_key_secret);
			$cb = \Codebird\CodeBird::getInstance();
			$cb->setToken($access_token, $access_token_secret);

			$twitterAccount = '';

			$lastTweetId = '' //add im line to read tweet id from txt file...

			while(true)
			{
				echo "start page...\n";
				$reply = (array) $cb->search_tweets('f=realtime&q=@'.$twitterAccount.'&count=5',TRUE);
				for($i = 0; $i < sizeOf($reply['statuses']); $i++)
				{
					if($reply['statuses'][$i]->id_str == $last_tweet_id)
					{
		      	echo "no new tweets\n";
		      	break;  	   
		      		//case to avoid returning our own tweets which we mention ourself   
		    	}else if($reply['statuses'][$i]->user->screen_name != $twitterAccount)
		    	{
		    		$tweet = $reply['statuses'][$i]->text;
			    	$user  = "@" . $reply['statuses'][$i]->user->screen_name;
						$tweet_id = $reply['statuses'][$i]->id_str;

						echo "read in tweet\nUser: ".$user."\nTweetId: ".$tweet_id."\nText: ".$tweet."\n";

						$tweet = strtolower($tweet);
						$inputArray = explode(" ",$tweet);

						$reply = reply($inputArray);

			    	$params =array();
						$params['status'] = $user." ".$reply;

						$reply = $cb->statuses_update($params);	
						echo $reply->httpstatus . ": httpstatus resonse \n";
		    	}   
				}

				$last_tweet_id = $reply['statuses'][0]->id_str;
				//add code to write this id to a txt for reading

				echo "Sleeping...\n"
				sleep(2);
			}

		?>




