use strict;
use warnings;
use Tk;
use Tk::BrowseEntry;
use Tk::NoteBook;
use SamsungRemote;

##############-----frontend-----##############
my $mw              	= Tk::MainWindow->new(-title=>"Samsung C650 Remote");
$mw->geometry("350x700+500+50");


my %languages = ( 
     "languagemenu"   => [ "Sprache", "Language" , "Jezyk", "\x{042F}\x{0437}\x{044B}\x{043A}" ],
     "control_tab"  => [ "Steuerung", "Control" , "Sterowanie", "\x{041A}\x{043E}\x{043D}\x{0442}\x{0440}\x{043E}\x{043B}\x{044C}" ],
     "msg_tab"    => [ "Nachrichten", "Messaging" , "Wiadomosci", "\x{0421}\x{043E}\x{043E}\x{0431}\x{0449}\x{0435}\x{043D}\x{0438}\x{044F}"],
     "search_langs"   => [ "Suche TV", "Find TV" , "Znajdz TV", "\x{041D}\x{0430}\x{0439}\x{0442}\x{0438} \x{0422}\x{0412}" ],
     "tv_list"    => [ "Keine Geräte gefunden", "No TV Devices" , "Nie znaleziono zadnych odbiornikow", "\x{0422}\x{0412}\x{0020}\x{043D}\x{0435}\x{0020}\x{043D}\x{0430}\x{0439}\x{0434}\x{0435}\x{043D}" ],
     "send_msg"    => [ "Nachricht Senden", "Send Message" , "Wyslij wiadomosc", "\x{041F}\x{043E}\x{0441}\x{043B}\x{0430}\x{0442}\x{044C}\x{0020}\x{0441}\x{043E}\x{043E}\x{0431}\x{0449}\x{0435}\x{043D}\x{0438}\x{0435}"  ],
     "send_text"    => [ "Text senden", "Send text" , "Wyslij tekst", "\x{041F}\x{043E}\x{0441}\x{043B}\x{0430}\x{0442}\x{044C}\x{0020}\x{0442}\x{0435}\x{043A}\x{0441}\x{0442}"  ],
     "initial_sms_text" => [ "Nachricht eingeben...", "Type message..." , "Wpisz wiadomosc...", "\x{0412}\x{0432}\x{0435}\x{0434}\x{0438}\x{0442}\x{0435}\x{0020}\x{0441}\x{043E}\x{043E}\x{0431}\x{0449}\x{0435}\x{043D}\x{0438}\x{0435}..."  ],
     "initial_text"  => [ "Text eingeben...", "Type text..." , "Wpisz tekst...", "\x{0412}\x{0432}\x{0435}\x{0434}\x{0438}\x{0442}\x{0435}\x{0020}\x{0442}\x{0435}\x{043A}\x{0441}\x{0442}..."  ],
     "send_button"   => [ "Senden", "Send" , "Wyslij", "\x{041E}\x{0442}\x{043E}\x{0441}\x{043B}\x{0430}\x{0442}\x{044C}" ],
     "volume"     => [ "Lautstärke", "Volume"  ,"Glosnosc", "\x{0413}\x{0440}\x{043E}\x{043C}\x{043A}\x{043E}\x{0441}\x{0442}\x{044C}" ],
     "extend_btn"    => [ "Erweitern", "Extend"  ,"Powiekszyc  ", "\x{0420}\x{0430}\x{0437}\x{0448}\x{0438}\x{0440}\x{0438}\x{0442}\x{044C}" ],
     "menu"      => [ "Menü", "Menu" ,"Menu", "\x{041C}\x{0435}\x{043D}\x{044E}" ],
     "up"      => [ "Hoch", "Up" ,"W góre", "\x{0412}\x{0432}\x{0435}\x{0440}\x{0445}" ],
     "down"      => [ "Runter", "Down" , "W dól", "\x{0412}\x{043D}\x{0438}\x{0437}" ],
     "left"      => [ "Links", "Left" , "Lewo", "\x{0412}\x{043B}\x{0435}\x{0432}\x{043E}" ],
     "right"      => [ "Rechts", "Right" ,"Prawo", "\x{0412}\x{043F}\x{0440}\x{0430}\x{0432}\x{043E}" ],
     "enter"      => [ "Eingabe", "Enter" ,"Enter", "\x{0412}\x{0432}\x{043E}\x{0434}" ],
     "exit"    => [ "Ausgang", "Exit" ,"Wyjscie", "\x{0412}\x{044B}\x{0445}\x{043E}\x{0434}" ],
     "back"    => [ "Zurück", "Back" ," Powrót", "\x{041D}\x{0430}\x{0437}\x{0430}\x{0434}" ],  
     "info"    => [ "Info", "Info" ,"Info", "\x{0418}\x{043D}\x{0444}\x{043E}" ],       
     "tools"   => [ "Tools", "Tools" ,"Narzedzia", "\x{0414}\x{043E}\x{043F}\x{043E}\x{043B}\x{043D}\x{002E}" ],
     "sender_label"  => [ "Absender", "From" ," Nadawca", "\x{041E}\x{0442}\x{0020}\x{043A}\x{043E}\x{0433}\x{043E}" ],
     "rec_label"  => [ "Empfänger", "To" ," Odbiorca", "\x{041A}\x{043E}\x{043C}\x{0443}" ] 
			 
				 );

my $initlang 			= 0;				 
my $lang 				= $initlang;

#menubar
my $menubar             = $mw->Menu();
$mw->configure(-menu => $menubar);
my $menu_lang           = $menubar->cascade(-label => $languages{"languagemenu"}->[$lang]);

my $german_radio_menu   = $menu_lang->radiobutton(-label=>"deutsch", -variable=>\$lang, -value=>0, -command=>\&update_langs);
my $english_radio_menu  = $menu_lang->radiobutton(-label=>"english", -variable=>\$lang, -value=>1, -command=>\&update_langs);
my $polski_radio_menu   = $menu_lang->radiobutton(-label=>"polski", -variable=>\$lang, -value=>2, -command=>\&update_langs);
my $russian_radio_menu  = $menu_lang->radiobutton(-label=>"\x{0420}\x{0443}\x{0441}\x{0441}\x{043A}\x{0438}\x{0439}", -variable=>\$lang, -value=>3, -command=>\&update_langs);

#search TV frame

my $devices_found 		= 0;
my $search_frame        = $mw->Frame(-borderwidth => 2, -relief => 'groove')->pack(-side=>"top", -anchor=>"w", -fill=>"x");
my $browse_entry_value  = $languages{"tv_list"}->[$lang];
my $browse_entry        = $mw->BrowseEntry( -label => 'TV Ip: ',-listwidth=>100, -variable =>\$browse_entry_value, -command=>\&entry_sel_clb)->pack(-in=>$search_frame, -side=>"left");
my $tv_search_button    = $mw->Button(-text=>$languages{"search_langs"}->[$lang], -command=>\&tv_search_button_clb)->pack(-in=>$search_frame, -side=>"left");
my $timeout_label       = $mw->Label(-text=>"Timeout")->pack(-side=>"bottom", -in=>$search_frame, -anchor=>"s");
my $timeout_value       = 3;
my $timeout_entry       = $mw->Entry(-width=>2,-textvariable=>\$timeout_value, -text=>\$timeout_value )->pack(-in=>$search_frame, -side=>"bottom", -anchor=>"s");
my %device_handle_list = ();

#tabs
my $notebook         	= $mw->NoteBook()->pack(-expand => 1, -fill => 'both');
my $page1               = $notebook->add('page1', -label => $languages{"control_tab"}->[$lang]);
my $page2               = $notebook->add('page2', -label => $languages{"msg_tab"}->[$lang]);

#sending tab
#message
my $msg_frame           = $page2->Frame(-borderwidth => 2, -relief => 'groove')->pack(-side=>"top", -anchor=>"n", -fill=>"x", -pady =>10);

my $sender_entry_label  = $page2->Label(-text=>$languages{"sender_label"}->[$lang])->pack(-side=>"top", -in=>$msg_frame, -anchor=>"nw", -padx=>5);
my $sender_var 			= ""; 
my $sender_entry        = $page2->Entry(-textvariable=>\$sender_var)->pack(-in=>$msg_frame,-side=>"top", -anchor=>"nw", -padx=>5);

my $rec_entry_label  	= $page2->Label(-text=>$languages{"rec_label"}->[$lang])->pack(-side=>"top", -in=>$msg_frame, -anchor=>"nw", -padx=>5);
my $rec_var 			= ""; 
my $rec_entry        	= $page2->Entry(-textvariable=>\$rec_var)->pack(-in=>$msg_frame,-side=>"top", -anchor=>"nw", -padx=>5);

my $msg_entry_label     = $page2->Label(-text=>$languages{"send_msg"}->[$lang], -height=>3)->pack(-side=>"top", -in=>$msg_frame, -anchor=>"sw", -padx=>5);
my $msg_var             = $languages{"initial_sms_text"}->[$lang];
my $msg_entry           = $page2->Entry(-textvariable=>\$msg_var)->pack(-in=>$msg_frame,-side=>"top", -anchor=>"sw", -fill=>"x", -padx=>5);
my $msg_send_button     = $page2->Button(-text=>$languages{"send_button"}->[$lang], -command=>\&msg_send_button_clb )->pack(-in=>$msg_frame, -side=>"bottom", -anchor=>"w", -padx=>5, -pady=>5);

#text
my $text_frame           = $page2->Frame(-borderwidth => 2, -relief => 'groove')->pack(-side=>"top", -anchor=>"n", -fill=>"x", -pady =>10);
my $text_entry_label     = $page2->Label(-text=>$languages{"send_text"}->[$lang])->pack(-side=>"top", -in=>$text_frame, -anchor=>"nw", -padx=>5, -pady=>5);
my $text_var             = $languages{"initial_text"}->[$lang];
my $text_entry           = $page2->Entry(-textvariable=>\$text_var)->pack(-in=>$text_frame,-side=>"top",-anchor=>"nw", -fill=>"x", -padx=>5);
my $text_send_button     = $page2->Button(-text=>$languages{"send_button"}->[$lang], -command=>\&text_send_button_clb)->pack(-in=>$text_frame, -side=>"top", -anchor=>"nw", -padx=>5, -pady=>5);


#buttons
my $numbers_frame       = $page1->Frame(-borderwidth => 2, -relief => 'groove')->pack(-side=>"top", -anchor=>"n", -ipadx=>10, -ipady=>10, -fill=>"x");
my $cross_frame       	= $page1->Frame(-borderwidth => 2, -relief => 'groove')->pack(-side=>"top", -anchor=>"n", -pady=>10, -fill=>"x");
my $addition_frame     	= $page1->Frame(-borderwidth => 2, -relief => 'groove')->pack(-side=>"top", -anchor=>"n", -pady=>10, -fill=>"x");
my $media_frame     	= $page1->Frame(-borderwidth => 2, -relief => 'groove')->pack(-side=>"top", -anchor=>"n", -pady=>10, -fill=>"x");

my $btn1         		= $mw->Button(-text=>"1", 									-command=>[\&send_btn_clb, "KEY_1"]);
my $btn2           		= $mw->Button(-text=>"2", 									-command=>[\&send_btn_clb, "KEY_2"]);
my $btn3           		= $mw->Button(-text=>"3", 									-command=>[\&send_btn_clb, "KEY_3"]);
my $btn4           		= $mw->Button(-text=>"4", 									-command=>[\&send_btn_clb, "KEY_4"]);
my $btn5           		= $mw->Button(-text=>"5", 									-command=>[\&send_btn_clb, "KEY_5"]);
my $btn6           		= $mw->Button(-text=>"6", 									-command=>[\&send_btn_clb, "KEY_6"]);
my $btn7           		= $mw->Button(-text=>"7", 									-command=>[\&send_btn_clb, "KEY_7"]);
my $btn8           		= $mw->Button(-text=>"8", 									-command=>[\&send_btn_clb, "KEY_8"]);
my $btn9           		= $mw->Button(-text=>"9", 									-command=>[\&send_btn_clb, "KEY_9"]);
my $btn0           		= $mw->Button(-text=>"0", 									-command=>[\&send_btn_clb, "KEY_0"]);
my $btn_prech      		= $mw->Button(-text=>"PRECH",-background=>"grey",-width=>2,	-font=>[-size=>5],	-command=>[\&send_btn_clb, "KEY_PRECH"]);
my $btn_ttx       		= $mw->Button(-text=>"TTX", -background=>"grey",-width=>2,	-font=>[-size=>5],		-command=>[\&send_btn_clb, "KEY_TTX_MIX"]);

my $bMute				= 0;
my $btn_mute        	= $mw->Checkbutton(-text=>"Mute", -variable=>\$bMute, 		-command=>\&mute_clb);
my $bVolSLider 			= 0;
my $btn_extend_vol     	= $mw->Checkbutton(-text=>$languages{"extend_btn"}->[$lang], -width=>10, -variable=>\$bVolSLider,-command=>\&extend_vol_slider_clb);

my $btn_up           	= $mw->Button(-text=>$languages{"up"}->[$lang], 	-width=>5,	-command=>[\&send_btn_clb, "KEY_UP"],	-background=>"grey", -relief=>"solid" );
my $btn_down           	= $mw->Button(-text=>$languages{"down"}->[$lang],	-width=>5,	-command=>[\&send_btn_clb, "KEY_DOWN"],	-background=>"grey", -relief=>"solid" );
my $btn_left           	= $mw->Button(-text=>$languages{"left"}->[$lang], 	-width=>5,	-command=>[\&send_btn_clb, "KEY_LEFT"],	-background=>"grey", -relief=>"solid" );
my $btn_right           = $mw->Button(-text=>$languages{"right"}->[$lang], 	-width=>5,	-command=>[\&send_btn_clb, "KEY_RIGHT"],-background=>"grey", -relief=>"solid" );
my $btn_enter 	        = $mw->Button(-text=>$languages{"enter"}->[$lang], 	-width=>3, -height=>2,	-command=>[\&send_btn_clb, "KEY_ENTER"],-background=>"grey", -relief=>"solid" );
my $btn_prg_up  		= $mw->Button(-text=>"P+", 										-command=>[\&send_btn_clb, "KEY_CHUP"]);
my $btn_prg_down    	= $mw->Button(-text=>"P-", 										-command=>[\&send_btn_clb, "KEY_CHDOWN"]);
my $btn_vol_up       	= $mw->Button(-text=>"V+", 										-command=>[\&send_btn_clb, "KEY_VOLUP"]);#\&setVolume_btnup_clb);
my $btn_vol_down     	= $mw->Button(-text=>"V-", 										-command=>[\&send_btn_clb, "KEY_VOLDOWN"]);#\&setVolume_btndown_clb);
my $btn_menu         	= $mw->Button(-text=>$languages{"menu"}->[$lang], 	-width=>5,	-command=>[\&send_btn_clb, "KEY_MENU"]);
my $btn_exit        	= $mw->Button(-text=>$languages{"exit"}->[$lang], 	-width=>3, -height=>2,	-command=>[\&send_btn_clb, "KEY_EXIT"]);
my $btn_back        	= $mw->Button(-text=>$languages{"back"}->[$lang], 	-width=>3, -height=>2,	-command=>[\&send_btn_clb, "KEY_RETURN"]);
my $btn_tools        	= $mw->Button(-text=>$languages{"tools"}->[$lang], 	-width=>3, -height=>2,	-command=>[\&send_btn_clb, "KEY_TOOLS"]);
my $btn_info        	= $mw->Button(-text=>$languages{"info"}->[$lang], 	-width=>3, -height=>2,	-command=>[\&send_btn_clb, "KEY_INFO"]);
my $vol_slider_value 	= 0;
my $volume_slider     	= $mw->Scale(-label=>$languages{"volume"}->[$lang], -repeatdelay=>1000 ,-sliderlength => 10,-width=>10, -orient=>'vertical',-from=>20, -to=>0, -tickinterval=>20,  -variable=>\$vol_slider_value, -command=>\&setVolume_slider_clb);


my $btn_a        	= $mw->Button(-text=>"A", -background=>"RED",						-command=>[\&send_btn_clb, "KEY_RED"]);
my $btn_b         	= $mw->Button(-text=>"B", -background=>"GREEN",						-command=>[\&send_btn_clb, "KEY_GREEN"]);
my $btn_c         	= $mw->Button(-text=>"C", -background=>"YELLOW",					-command=>[\&send_btn_clb, "KEY_YELLOW"]);
my $btn_d         	= $mw->Button(-text=>"D", -background=>"BLUE",						-command=>[\&send_btn_clb, "KEY_CYAN"]);

my $btn_media      	= $mw->Button(-text=>"Media",			-width=>5,						-command=>[\&send_btn_clb, "KEY_W_LINK"]);
my $btn_internet  	= $mw->Button(-text=>"Internet",		-width=>5,						-command=>[\&send_btn_clb, "KEY_RSS"]);
my $btn_dual      	= $mw->Button(-text=>"Dual",			-width=>5,						-command=>[\&send_btn_clb, "KEY_MTS"]);
my $btn_ad      	= $mw->Button(-text=>"AD",				-width=>5,						-command=>[\&send_btn_clb, "KEY_AD"]);
my $btn_psize      	= $mw->Button(-text=>"P.Size",			-width=>5,						-command=>[\&send_btn_clb, "KEY_ASPECT"]);
my $btn_subt      	= $mw->Button(-text=>"Subt.",			-width=>5,						-command=>[\&send_btn_clb, "KEY_CAPTION"]);
my $btn_stop      	= $mw->Button(-text=>"\x{25FC}",		-width=>5,						-command=>[\&send_btn_clb, "KEY_STOP"]);
my $btn_next       	= $mw->Button(-text=>"\x{25BA}\x{25BA}",-width=>5,						-command=>[\&send_btn_clb, "KEY_FF"]);
my $btn_play       	= $mw->Button(-text=>"\x{25BA}",		-width=>5,						-command=>[\&send_btn_clb, "KEY_PLAY"]);
my $btn_prev   		= $mw->Button(-text=>"\x{25C4}\x{25C4}",-width=>5,						-command=>[\&send_btn_clb, "KEY_REWIND"]);
my $btn_pause  		= $mw->Button(-text=>"\x{2590}\x{2590}",-width=>5,						-command=>[\&send_btn_clb, "KEY_PAUSE"]);
my $btn_record 		= $mw->Button(-text=>"\x{2B24}",		-width=>5,-foreground=>"red",	-command=>[\&send_btn_clb, "KEY_REC"]);

$btn1->grid ( 			-in=>$numbers_frame, 				-row=>0, -column=>0, -ipadx=>10, -ipady=>5  );
$btn2->grid ( 			-in=>$numbers_frame, 				-row=>0, -column=>1, -ipadx=>10, -ipady=>5  );
$btn3->grid ( 			-in=>$numbers_frame, 				-row=>0, -column=>2, -ipadx=>10, -ipady=>5  );
$btn4->grid ( 			-in=>$numbers_frame, 				-row=>1, -column=>0, -ipadx=>10, -ipady=>5  );
$btn5->grid ( 			-in=>$numbers_frame, 				-row=>1, -column=>1, -ipadx=>10, -ipady=>5  );
$btn6->grid ( 			-in=>$numbers_frame, 				-row=>1, -column=>2, -ipadx=>10, -ipady=>5  );
$btn7->grid ( 			-in=>$numbers_frame, 				-row=>2, -column=>0, -ipadx=>10, -ipady=>5  );
$btn8->grid ( 			-in=>$numbers_frame, 				-row=>2, -column=>1, -ipadx=>10, -ipady=>5  );
$btn9->grid ( 			-in=>$numbers_frame, 				-row=>2, -column=>2, -ipadx=>10, -ipady=>5  );
$btn0->grid ( 			-in=>$numbers_frame, 				-row=>3, -column=>1, -ipadx=>10, -ipady=>5  );
$btn_prech->grid (		-in=>$numbers_frame, 				-row=>3, -column=>2, -ipadx=>10, -ipady=>5, -padx=>2  );
$btn_ttx->grid ( 		-in=>$numbers_frame, 				-row=>3, -column=>0, -ipadx=>10, -ipady=>5, -padx=>2  );
$volume_slider->grid( 	-in=>$numbers_frame, 				-row=>1, -column=>5, -rowspan=>4);
$btn_mute->grid(		-in=>$numbers_frame, 				-row=>0, -column=>6 );
$btn_extend_vol->grid(	-in=>$numbers_frame, 				-row=>0, -column=>5, -ipadx=>30 );

$btn_menu->grid 	( -in=>$cross_frame, 			-row=>0, 				-column=>2, -ipadx=>10, -pady=>5					);
$btn_up->grid		( -in=>$cross_frame,			-row=>1, 				-column=>2, -ipadx=>10, -pady=>5 					);
$btn_enter->grid 	( -in=>$cross_frame, 			-row=>2, 				-column=>2, -ipadx=>10 								);
$btn_down->grid		( -in=>$cross_frame,			-row=>3, 				-column=>2, -ipadx=>10, -pady=>5 					);
$btn_tools->grid	( -in=>$cross_frame,			-row=>1, 				-column=>1, -ipadx=>10 								);
$btn_left->grid		( -in=>$cross_frame,			-row=>2, 				-column=>1, -ipadx=>10,				-padx=>5		);
$btn_back->grid		( -in=>$cross_frame,			-row=>3, 				-column=>1, -ipadx=>10 								);
$btn_info->grid		( -in=>$cross_frame,			-row=>1, 				-column=>3, -ipadx=>10 								);
$btn_right->grid	( -in=>$cross_frame,			-row=>2, 				-column=>3, -ipadx=>10,				-padx=>5		);
$btn_exit->grid		( -in=>$cross_frame,			-row=>3, 				-column=>3, -ipadx=>10, 							);
$btn_prg_up->grid 	( -in=>$cross_frame, 			-row=>0, -rowspan=>2, -column=>0, -ipadx=>10, 	-ipady=>20, -padx=>5 	);
$btn_prg_down->grid ( -in=>$cross_frame, 			-row=>2, -rowspan=>2, -column=>0, -ipadx=>11.5, 	-ipady=>20 );
$btn_vol_up->grid 	( -in=>$cross_frame, 			-row=>0, -rowspan=>2, -column=>4, -ipadx=>10, 	-ipady=>20, -padx=>5 	);
$btn_vol_down->grid ( -in=>$cross_frame, 			-row=>2, -rowspan=>2, -column=>4, -ipadx=>11.5, 	-ipady=>20, -padx=>5 	);

$btn_a->grid		( 	-in=>$addition_frame, 		-row=>0,-column=>0,-ipadx=>10, -padx=>20 	);
$btn_b->grid		( 	-in=>$addition_frame, 		-row=>0,-column=>1,-ipadx=>10, -padx=>20 	);
$btn_c->grid		( 	-in=>$addition_frame, 		-row=>0,-column=>2,-ipadx=>10, -padx=>20 	);
$btn_d->grid		( 	-in=>$addition_frame, 		-row=>0,-column=>3,-ipadx=>10, -padx=>20 	);

$btn_media->grid	( 	-in=>$media_frame, 		-row=>0,-column=>0,-ipadx=>10, -padx=>20, -pady=>5	);
$btn_internet->grid	( 	-in=>$media_frame, 		-row=>0,-column=>1,-ipadx=>10, -padx=>20, -pady=>5	);
$btn_dual->grid		( 	-in=>$media_frame, 		-row=>0,-column=>2,-ipadx=>10, -padx=>20, -pady=>5	);
$btn_ad->grid		( 	-in=>$media_frame, 		-row=>1,-column=>0,-ipadx=>10, -padx=>20, -pady=>5	);
$btn_psize->grid	( 	-in=>$media_frame, 		-row=>1,-column=>1,-ipadx=>10, -padx=>20, -pady=>5	);
$btn_subt->grid		( 	-in=>$media_frame, 		-row=>1,-column=>2,-ipadx=>10, -padx=>20, -pady=>5	);
$btn_prev->grid		( 	-in=>$media_frame, 		-row=>2,-column=>0,-ipadx=>10, -padx=>20, -pady=>5	);
$btn_pause->grid	( 	-in=>$media_frame, 		-row=>2,-column=>1,-ipadx=>10, -padx=>20, -pady=>5 	);
$btn_next->grid		( 	-in=>$media_frame, 		-row=>2,-column=>2,-ipadx=>10, -padx=>20, -pady=>5 	);
$btn_record->grid	( 	-in=>$media_frame, 		-row=>3,-column=>0,-ipadx=>10, -padx=>20, -pady=>5 	);
$btn_play->grid		( 	-in=>$media_frame, 		-row=>3,-column=>1,-ipadx=>10, -padx=>20, -pady=>5 	);
$btn_stop->grid		( 	-in=>$media_frame, 		-row=>3,-column=>2,-ipadx=>10, -padx=>20, -pady=>5 	);

#report preview
my @debug_array         = ();
my $debug_label         = $mw->Label(-text=>"Debugwindow")->pack(-side=>"top", -anchor=>"nw");
my $debug_listbox       = $mw->Listbox(-width=>100, -height=>5 )->pack(-side=>"top", -anchor=>"nw");

# exit button
my $exit_button         = $mw->Button(-text=>"Exit", -command=>\&exit_fnc)->pack(-side=>"bottom", -anchor=>"se");


Tk::MainLoop();


###############----functions----####################

sub update_langs
{
    $menu_lang->configure		( -label=>$languages{"languagemenu"}->[$lang]			);
	$notebook->pageconfigure	( 'page1', -label=>$languages{"control_tab"}->[$lang]	);
	$notebook->pageconfigure	( 'page2', -label=>$languages{"msg_tab"}->[$lang]		);
	$tv_search_button->configure( -text=>$languages{"search_langs"}->[$lang]			);
	$msg_entry_label->configure	( -text=>$languages{"send_msg"}->[$lang] 				);
	$rec_entry_label->configure	( -text=>$languages{"rec_label"}->[$lang] 				);
	$sender_entry_label->configure( -text=>$languages{"sender_label"}->[$lang] 			);
	$msg_send_button->configure	( -text=>$languages{"send_button"}->[$lang] 			);
	$text_entry_label->configure( -text=>$languages{"send_text"}->[$lang] 				);
	$text_send_button->configure( -text=>$languages{"send_button"}->[$lang] 			);
	$btn_menu->configure		( -text=>$languages{"menu"}->[$lang] 					);
	$volume_slider->configure	(-label=>$languages{"volume"}->[$lang]					);
	$btn_down->configure		( -text=>$languages{"down"}->[$lang] 					);
	$btn_up->configure			( -text=>$languages{"up"}->[$lang] 						);
	$btn_left->configure		( -text=>$languages{"left"}->[$lang] 					);
	$btn_right->configure		( -text=>$languages{"right"}->[$lang]					);
	$btn_enter->configure		( -text=>$languages{"enter"}->[$lang] 					);
	$btn_extend_vol->configure	( -text=>$languages{"extend_btn"}->[$lang] 				);
	$btn_exit->configure		( -text=>$languages{"exit"}->[$lang] 					);
	$btn_back->configure		( -text=>$languages{"back"}->[$lang] 					);
	$btn_tools->configure		( -text=>$languages{"tools"}->[$lang] 					);
	$btn_info->configure		( -text=>$languages{"info"}->[$lang] 					);

	if( index( join( " ", @{$languages{"initial_sms_text"}}), $msg_var ) >=0 )
	{
		$msg_var = $languages{"initial_sms_text"}->[$lang];
		$text_var = $languages{"initial_text"}->[$lang];
	}
	
	if( $devices_found == 0 )
	{
		$browse_entry_value  = $languages{"tv_list"}->[$lang];
	}
}
sub mute_clb
{
	if( $devices_found == 1 )
	{
		$device_handle_list{$browse_entry_value}->setMute($bMute);
	}
}

sub extend_vol_slider_clb
{
	if( $bVolSLider )
	{
		$volume_slider->configure( -from=>100 ); 
	}
	else
	{
		$volume_slider->configure( -from=>20 ); 
	}
}

sub update_values
{
	if( $devices_found == 1 )
	{
		$vol_slider_value = $device_handle_list{$browse_entry_value}->getVolume();
		$bMute = $device_handle_list{$browse_entry_value}->getMute();
	}
}

sub send_btn_clb
{
	my $button = shift;
	
	if( $devices_found == 1 )
	{
		$device_handle_list{$browse_entry_value}->sendButton($button);
		report ("Pressed $button");
	}
}

sub tv_search_button_clb
{
	my @devices = SamsungRemote::find_devices();
	
	if(@devices)
	{
		$devices_found = 1;
	
		foreach my $device (@devices)
		{
			$device_handle_list{$device} = SamsungRemote->new($device);
		}
		$browse_entry->configure( -choices=>\@devices );
		$browse_entry_value = $devices[0];
		entry_sel_clb();
	}
}

sub exit_fnc
{
    report("exiting..." );
    exit();
}

sub text_send_button_clb
{
	if( $devices_found == 1 )
	{
		$device_handle_list{$browse_entry_value}->sendText($text_var);
		report( "Sent Text $text_var" );
		$text_var = "";
	}
}

sub msg_send_button_clb
{
	if( $devices_found == 1 )
	{	
		$device_handle_list{$browse_entry_value}->sendSMS_now($msg_var, $sender_var, undef, $rec_var, undef);
		report( "Sent $msg_var" );
		$msg_var = "";
	}
}

sub setVolume_btnup_clb
{
	if($devices_found == 1)
	{
		$vol_slider_value++;
		setVolume_slider_clb();
	}
}

sub setVolume_btndown_clb
{
	if($devices_found == 1)
	{
		$vol_slider_value--;
		setVolume_slider_clb();
	}
}

sub setVolume_slider_clb
{
	if($devices_found == 1)
	{
		$device_handle_list{$browse_entry_value}->setVolume( $vol_slider_value );
		report( "Set Volume to $vol_slider_value" );
	}
}

sub entry_sel_clb
{
    report("selected $browse_entry_value as device");
	update_values();
}

sub report 
{
    push(@debug_array,$_[0]);
    
	my $debug_array_size = @debug_array;
    
    if( $debug_array_size >5)
    {
        shift(@debug_array);
    }
    
	$debug_listbox->delete("0", "end");
    $debug_listbox->insert("end", @debug_array );
}