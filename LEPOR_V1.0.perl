#!/usr/bin/perl -w  
########################################################################################################################################################################################
##    For a detailed description of this evaluation metric and source code, please read:                                                                                           #####
##    This code is to implement the Machine Translation Evaluation metric LEPOR                                                                                                    #####
##    LEPOR evaluation metric is proposed by Aaron Li-Feng Han, Derek Fai Wong, and Lidia Sam Chao in University of Macau                                                          #####
##    This perl code is  written by Aaron Li-Feng Han in university of macau, 2012.03                                                                                              #####
##    All Copyright (c) preserved by the authors. Corresponding author: Aaron Li-Feng Han < hanlifengaaron@gmail.com >                                                             #####
##    Please cite paper below if you use the metric or source code in your research work                                                                                           #####
##    "LEPOR: A Robust Evaluation Metric for Machine Translation with Augmented Factors". 2012. Aaron Li-Feng Han, Derek F. Wong and Lidia S. Chao. Proceedings of the             #####
##    24th International Conference on Computational Linguistics (COLING 2012): Posters, pages 441–450, Mumbai, December 2012. Association for Computational LinguisticsDecember   #####
##    Source code website:https://github.com/aaronlifenghan/aaron-project-lepor https://code.google.com/p/aaron-project-lepor/                                                     #####
##     online paper: http://aclweb.org/anthology-new/C/C12/C12-2044.pdf                                                                                                            #####
########################################################################################################################################################################################
##    How to use this Perl code and how to assign the parameter weights of Precision and Recall:                                                                                   #####
##    1. Your system output translation documents and the reference translation document should contain the plain text only, each line containing one sentence.                    #####
##    2. Put you system output translation documents under the address in Line 24, 52, 54 of this Perl code.                                                                       #####
##    3. Put you reference translation document under the address in Line 28 of this Perl code.                                                                                    #####
##    4. Tune the Precision and Recall weights of LEPOR by the parameter value of a under the address in Line 163 of this Perl code.                                               #####
##    5. The document containing evaluation score of LEPOR will be shown under the address in Line 55 of this Perl code.                                                           #####
##                                                                                                                                                                                 #####
########################################################################################################################################################################################


opendir (DIR, "D:\\call Papers\\paper\\AMTA201206.4\\program\\new adjustment corpora\\cz-en2.7\\output_cz-en\\segmented_cz-en") || die "can not open f:\\dealfiles!"; ## this file address puts your system output translation documents
@filename=readdir(DIR);

closedir (DIR);
open REF,"<:encoding(utf8)","D:\\call Papers\\paper\\AMTA201206.4\\program\\new adjustment corpora\\cz-en2.7\\segmented2.7_newstest2011-ref.en.txt" or die "can't open reference file\n"; ## this file address puts reference translation document##
		$j=0;
		$str1="";
		@arry_r1=();
		@arry_ref_length= ();
		@arrytwo_ref_translation=();
		$num_of_ref_sentence=0;
		while($str1=<REF>)               #### put the reference translation into a two dimension array @arrytwo_ref_translation
			{
				chomp($str1);
				$str1= lc ($str1);   ### when doing the matching, lower and upper case is concidered the same
				@arry_r1= split(/\s+/,$str1);
				$arry_ref_length[$j]=scalar(@arry_r1);             #### @arry_ref_length store the lengths of every sentence(line) of the reference translation.
				$j++;
				push @arrytwo_ref_translation, [@arry_r1];
				@arry_r1= ();
			}
		$num_of_ref_sentence=$j;
close REF;



foreach $file (@filename)     ## go through all the system output translation documents 
	{
		if(!(-d "D:\\call Papers\\paper\\AMTA201206.4\\program\\new adjustment corpora\\cz-en2.7\\output_cz-en\\segmented_cz-en\\$file"))  ## this file address puts your system output translation documents
			{
				open (TEST,"<:encoding(utf8)","D:\\call Papers\\paper\\AMTA201206.4\\program\\new adjustment corpora\\cz-en2.7\\output_cz-en\\segmented_cz-en\\$file") || die "can not open system output file: $!";
				open (RESULT,">D:\\call Papers\\paper\\AMTA201206.4\\program\\new adjustment corpora\\cz-en2.7\\output_cz-en\\segmented_cz-en\\LEPOR1P9R_$file.txt") || die "$!";  ## put the evaluation score in this file address
				
				$i=0;
				$str0="";
				@arry_1= ();
				@arry_sys_length= ();
				@arrytwo_sys_translation= ();
				$sentence_num=0;
				while($str0=<TEST>)                       #### put the system output translation into a two dimension array @arrytwo_sys_translation
					{
						chomp($str0);
						$str0= lc ($str0);   ###  system output translation is turned into lowwer case, too
						@arry_1= split(/\s+/,$str0);
						$arry_sys_length[$i]=scalar(@arry_1);       #### @arry_sys_length store the lengths of every sentence(line) of the system translation.
						$i++;
						push @arrytwo_sys_translation, [@arry_1];
						@arry_1= ();
					}
				$sentence_num=$i;
				close TEST;
				print RESULT 'length of sysoutput:',"\n","@arry_sys_length","\n",$sentence_num,"\n";

				print RESULT 'length of reference:',"\n","@arry_ref_length","\n",$num_of_ref_sentence,"\n";

				@LP= ();
				for($k=0;$k<$sentence_num;$k++)               ##### @LP store the longth penalty coefficient of every LP[i]
					{
						if($arry_sys_length[$k]>$arry_ref_length[$k])
							{
								$LP[$k]=exp(1-($arry_sys_length[$k]/$arry_ref_length[$k]));
							}
						else
							{
								if($arry_sys_length[$k]==0)
									{
										$LP[$k]=0;
									}
								elsif($arry_sys_length[$k]>0)
									{
										$LP[$k]=exp(1-($arry_ref_length[$k]/$arry_sys_length[$k]));
									}
								#$LP[$k]=exp(1-($arry_ref_length[$k]/$arry_sys_length[$k]));
							}
					}
				print RESULT 'length penalty with longer or shorter:',"\n","@LP","\n",$k,"\n";
				$Mean_LP= 0;
				for($k=0;$k<$sentence_num;$k++)
					{
						$Mean_LP= $Mean_LP+$LP[$k];
					}
				$Mean_LP= $Mean_LP/$sentence_num;
				##$Mean_LP= $Mean_LP/2051;
				print RESULT 'mean of length penalty with longer or shorter:',"\n","$Mean_LP","\n",$k,"\n";

				@common_num=();
				for($i=0;$i<$sentence_num;$i++)        #####  store the common number between sys and ref into @common_num 
					{
						$m=0;@record_position=();    ####everytime,select one sentence from the sys, clear the record array
						for($j=0;$j<$arry_sys_length[$i];$j++)
							{
								for($k=0;$k<$arry_ref_length[$i];$k++)
									{
										if($arrytwo_sys_translation[$i][$j] eq $arrytwo_ref_translation[$i][$k])
											{
												#if(!( any(@record_position) eq $k )) ####every word in the reference use not more than once to matched
												if(!( grep(/^$k/,@record_position) )) ####every word in the reference use not more than once to matched
													{
														$common_num[$i]++;
														$record_position[$m]=$k; $m++; ####record the position in the reference already matched
														last;         #### every word of the sys only match the reference once
													}
												
											}
									}
							}
					}
				print RESULT 'common number between sys and ref:',"\n","@common_num","\n",$i,"\n";

				@P= ();
				@R= ();
				for($i=0;$i<$sentence_num;$i++)            #####calculate the precision and recall into @P and @R
					{
						if(($common_num[$i])!= 0)
							{
								$P[$i]=$common_num[$i]/$arry_sys_length[$i];
								$R[$i]=$common_num[$i]/$arry_ref_length[$i];
							}
						else
							{
								$P[$i]=0;
								$R[$i]=0;
							}
					}
				print RESULT 'precision of sys:',"\n","@P","\n",$i,"\n";
				print RESULT 'recall of sys:',"\n","@R","\n",$i,"\n";
				
				$Mean_precision=0;
				$Mean_recall=0;
				for($i=0;$i<$sentence_num;$i++)
					{
						$Mean_precision= $Mean_precision+$P[$i];
						$Mean_recall= $Mean_recall+$R[$i];
					}
				$Mean_precision= $Mean_precision/$sentence_num;
				$Mean_recall= $Mean_recall/$sentence_num;
				print RESULT 'mean precision of sys:',"\n","$Mean_precision","\n",$i,"\n";
				print RESULT 'mean recall of sys:',"\n","$Mean_recall","\n",$i,"\n";

				$a=9;   ##### $a is a varerble to be changed according to different language envirenment #### H(9R,P)
				#$a=1/9;   ##### $a is a varerble to be changed according to different language envirenment#### H(9P,R)
				#$a=1;   ##### $a is a varerble to be changed according to different language envirenment#### H(P,R)

				@Harmonic_mean_PR=();
				for($i=0;$i<$sentence_num;$i++)    ####calculate the harmonic mean of P and a*R
					{
						if($P[$i]!=0 || $R[$i]!=0)
							{
								$Harmonic_mean_PR[$i]=((1+$a)*$P[$i]*$R[$i])/($R[$i]+$a*$P[$i]);
							}
						else
							{
								$Harmonic_mean_PR[$i]=0;
							}
					}
				print RESULT 'harmonic of precision and recall:',"\n","@Harmonic_mean_PR","\n",$i,"\n";
				
				$Mean_HarmonicMean=0;
				for($i=0;$i<$sentence_num;$i++)
					{
						$Mean_HarmonicMean= $Mean_HarmonicMean+ $Harmonic_mean_PR[$i];
					}
				$Mean_HarmonicMean= $Mean_HarmonicMean/$sentence_num;
				print RESULT 'mean of every sentences harmonic-mean of precision and recall:',"\n","$Mean_HarmonicMean","\n",$i,"\n";


				@pos_dif=();
				@pos_dif_record= ();
				@pos_dif_record_flag= ();
				@pos_dif_record_ref_flag= ();
				for($i=0;$i<$sentence_num;$i++)        #####  store the position-different value between sys and ref into @pos_dif 
					{
						for($j=0;$j<$arry_sys_length[$i];$j++)
							{
								$pos_dif_record_flag[$i][$j]= "none_match"; ##firstly make every system translation word's flag equal to none
								#$store_ref_pos=-1000;
								for($k=0;$k<$arry_ref_length[$i];$k++)
									{
										$pos_dif_record_ref_flag[$i][$k]= "un_confirmed";
										if($arrytwo_sys_translation[$i][$j] eq $arrytwo_ref_translation[$i][$k])
											{
												$pos_dif_record_flag[$i][$j]= "exist_match"; ##if there is match,then change the flag as exist_match
												$flag_confirm=0;
												if ($j eq 0)  ###this word is in the begining of sys-output sentence,then check its next word match-condition
													{
														$condition=0;
														for($count_num_sys=1;$count_num_sys<=2;$count_num_sys++) ##check the following two words' match
															{
																for($count_num_ref=1;$count_num_ref<=2;$count_num_ref++)##to match the reference following two words
																	{
																		if($arrytwo_sys_translation[$i][$j+$count_num_sys] eq $arrytwo_ref_translation[$i][$k+$count_num_ref])
																			{
																				$pos_dif_record_flag[$i][$j]= "confirm_match"; ##if the context is also matched then confirm this match
																				$pos_dif_record_ref_flag[$i][$k]= "is_confirmed";
																				$pos_dif_record[$i][$j]= $k; ####record the matched position
																				$flag_confirm=1;
																				$condition=1;
																				last;
																			}
																			
																	}
																if($condition==1) ##check whether it is matched in last loop 
																	{
																		last;
																	}
															}
													}
												elsif (($j eq ($arry_sys_length[$i]-1))|| ($j eq ($arry_sys_length[$i]-2))) ##this word is '.' or a word in the end of the sys-output sentence
													{
														$condition=0;
														for($count_num_sys=1;$count_num_sys<=2;$count_num_sys++) ##check the before two words' match
															{
																for($count_num_ref=1;$count_num_ref<=2;$count_num_ref++)##to match the reference before two words
																	{
																		if($arrytwo_sys_translation[$i][$j-$count_num_sys] eq $arrytwo_ref_translation[$i][$k-$count_num_ref])
																			{
																				$pos_dif_record_flag[$i][$j]= "confirm_match"; ##if the context is also matched then confirm this match
																				$pos_dif_record_ref_flag[$i][$k]= "is_confirmed";
																				$pos_dif_record[$i][$j]= $k;###record the matched position
																				$flag_confirm=1;
																				$condition=1;
																				last;
																			}
																			
																	}
																if($condition==1) ##check whether it is matched in last loop 
																	{
																		last;
																	}
															}
													}
												else ### this word is in the middle of sys-output sentence,not beginnin and not end
													{
														$condition=0;
														for($count_num_sys=-2;$count_num_sys<2;$count_num_sys++) ##check the former and back two words' match
															{
																for($count_num_ref=-2;$count_num_ref<=2;$count_num_ref++)##to match the former and back two words' match
																	{
																		if($arrytwo_sys_translation[$i][$j+$count_num_sys] eq $arrytwo_ref_translation[$i][$k+$count_num_ref])
																			{
																				$pos_dif_record_flag[$i][$j]= "confirm_match"; ##if the context is also matched then confirm this match
																				$pos_dif_record_ref_flag[$i][$k]= "is_confirmed";
																				$pos_dif_record[$i][$j]= $k;###record the matched position
																				$flag_confirm=1;
																				$condition=1;
																				last;
																			}
																			
																	}
																if($condition==1) ##check whether it is matched in last loop 
																	{
																		last;
																	}
															}
													}
												
												if($flag_confirm==1)##if confirm_match has been down,then the following words in ref neednot go through to match again
													{
														last;
													}
											}
									}
							}
						for($j=0;$j<$arry_sys_length[$i];$j++)###after all the confirm_match has done,then deal with the exist but not confirmed match,using nearest-match
							{
								$store_ref_unconfirm_pos=-10000;
								for($k=0;$k<$arry_ref_length[$i];$k++)
									{
										if($pos_dif_record_flag[$i][$j] eq "exist_match") #deal with the existed but not confirmed word in sys-output
											{
												if($arrytwo_sys_translation[$i][$j] eq $arrytwo_ref_translation[$i][$k])
													{
														#if(!( grep(/^$k/,@record_position) )) ####every word in the reference use not more than once to matched
														#if(!(grep(/^$k/,@)))##check whether position k has been confirmed
														if($pos_dif_record_ref_flag[$i][$k] eq "un_confirmed")##this ref-word has not been confirmed
															{
																if( abs($k-$j) < abs($store_ref_unconfirm_pos-$j)) ##select the nearest word from ref to match sys-word
																	{
																		$store_ref_unconfirm_pos=$k;
																	}
															}
													}
											}
									}
								if($store_ref_unconfirm_pos>=0)
									{
										$pos_dif_record[$i][$j]= $store_ref_unconfirm_pos;###record the nearest matched position
									}
							}
						for($j=0;$j<$arry_sys_length[$i];$j++)##after all the matched postion recored,then calculate each word's Pos-Diff value
							{
								if($pos_dif_record_flag[$i][$j] eq "none_match")
									{
										##$pos_dif[$i][$j]= abs(($store_ref_pos+1)/$arry_ref_length[$i]-($j+1)/$arry_sys_length[$i]);
										$pos_dif[$i][$j]=0;
									}
								else ##calculate the matched word's PosDiff
									{
										$pos_dif[$i][$j]= abs((($j+1)/$arry_sys_length[$i])-(($pos_dif_record[$i][$j]+1)/$arry_ref_length[$i]));
									}
							}
					}
				@Pos_dif_sum= ();
				@Pos_dif_value= ();
				for($i=0;$i<$sentence_num;$i++)
					{
						for( $j=0; $j<$arry_sys_length[$i]; $j++ )    #### sum the Pos_dif_distance of one sentence,then divided by the lenth of the sentence
							{
								$Pos_dif_sum[$i]= $Pos_dif_sum[$i]+$pos_dif[$i][$j];
							}
						if($arry_sys_length[$i]>0)
							{
								$Pos_dif_sum[$i]=$Pos_dif_sum[$i]/$arry_sys_length[$i];
								$Pos_dif_value[$i]= exp(-$Pos_dif_sum[$i]);   #### calculate the every sentence's value of Pos_dif_value by taking the exp.
							}
						#$Pos_dif_sum[$i]=$Pos_dif_sum[$i]/$arry_sys_length[$i];
						#$Pos_dif_value[$i]= exp(-$Pos_dif_sum[$i]);   #### calculate the every sentence's value of Pos_dif_value by taking the exp.
					}
				print RESULT 'Position different penalty:',"\n","@Pos_dif_value","\n",$i,"\n";
				$Mean_pos_dif_value=0;
				for($i=0;$i<$sentence_num;$i++)
					{
						$Mean_pos_dif_value= $Mean_pos_dif_value+$Pos_dif_value[$i];
					}
				$Mean_pos_dif_value= $Mean_pos_dif_value/$sentence_num;
				print RESULT 'mean Position different penalty:',"\n","$Mean_pos_dif_value","\n",$i,"\n";



				
				@LEPOR_single_sentence=();
				$LEPOR=0;
				for($i=0;$i<$sentence_num;$i++)    #### calculate the final evaluation value of LEPOR
					{
						$LEPOR_single_sentence[$i]= $LP[$i]*$Pos_dif_value[$i]*$Harmonic_mean_PR[$i];
						$LEPOR= $LEPOR+$LEPOR_single_sentence[$i];
					}
				$LEPOR= $LEPOR/$sentence_num;
				print RESULT 'evaluation value LEPOR of every single sentence:',"\n","@LEPOR_single_sentence","\n",$i,"\n";
				print RESULT 'mean value LEPOR of all single sentence:',"\n","$LEPOR","\n";
				
				
				
				#### another way to calculate the mean LEPOR of system_output(using all sentences' mean parameter-value)
				$LEPOR_anotherway=0;
				$LEPOR_anotherway= $Mean_LP*$Mean_pos_dif_value*$Mean_HarmonicMean;
				print RESULT 'mean value LEPOR_anotherway of all single sentence:',"\n","$LEPOR_anotherway","\n";
				close RESULT;
				
			}
	}

