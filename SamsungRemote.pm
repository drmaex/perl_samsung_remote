use SOAP::Lite;# ("trace");
use MIME::Base64;
use IO::Socket::INET;
use Net::UPnP::ControlPoint;
use Data::Hexdumper;

package SamsungRemote;

sub new
{
	my $package = shift;
	my ( $ip ) = @_;

	my $self = {};

	$self->{ip} = $ip;
	$self->{sockethost} 	= $ip.":55000";
	$self->{upnphost} 	= "http://".$ip.":52235";
	
	my $myip = ""; #Doesn't seem to be really used
    my $unique_id_string = "Powered by Perl"; #If changed, remote has to be accepted again
	my $appstring = ""; #seems to be useless
	my $tvappstring = ""; #seems to be useless
    my $remotename = "C650 Remote"; #What gets reported when it asks for permission/also shows in General->Wireless Remote Control menu
	
	my @id_array = ( 	
						"d", 
						length(MIME::Base64::encode_base64($myip, "")), 
						MIME::Base64::encode_base64($myip, ""),
						length(MIME::Base64::encode_base64($unique_id_string, "")),
						MIME::Base64::encode_base64($unique_id_string, ""),
						length(MIME::Base64::encode_base64($remotename, "")),
						MIME::Base64::encode_base64($remotename, "")
					);
					
	my $id_string = pack( "ax (s a*)*",@id_array );

	my @msg_array = ( 	
						length($appstring), 
						$appstring,
						length($id_string),
						$id_string
					);
	$self->{id_string1} = pack( "x(s a*)*",@msg_array );

	my @msg_array2 = (
						length($appstring),
						$appstring,
						length(pack("s")),
						0x00c8
					);
	
	$self->{id_string2} = pack( "x s a* s s",@msg_array2 );

	$self->{socket} = new IO::Socket::INET (
										PeerAddr => $self->{sockethost},
										Proto => 'tcp'
									) or print "could not create socket: $!\n";	
	$self->{socket}->autoflush(1);    # so output gets there right away	
	
	bless $self, $package;
	return $self;
}

sub getVolume
{
    my $self = shift;
  
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/RenderingControl1",
									uri=>"urn:schemas-upnp-org:service:RenderingControl:1" );

	my $channel = SOAP::Data->type("string")->name("Channel")->value("Master");
	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 

	my $response = $request->GetVolume($instanceID, $channel);

	unless ($response->fault) 
	{
		return $response->valueof('//GetVolumeResponse/CurrentVolume');
	} 
	else 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	}
}

sub setVolume
{
	my $self = shift;
	my $desiredVolume = shift;
	
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/RenderingControl1",
									uri=>"urn:schemas-upnp-org:service:RenderingControl:1" );

	my $channel = SOAP::Data->type("string")->name("Channel")->value("Master");
	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 
	my $desiredVolume_req = SOAP::Data->type("int")->name("DesiredVolume")->value($desiredVolume); 

	my $response = $request->SetVolume($instanceID, $channel, $desiredVolume_req);
	
	if ($response->fault) 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	} 
	return 0;
}

sub getBrightness
{
    my $self = shift;
  
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/RenderingControl1",
									uri=>"urn:schemas-upnp-org:service:RenderingControl:1" );

	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 

	my $response = $request->GetBrightness($instanceID);

	unless ($response->fault) 
	{
		return $response->valueof('//GetBrightnessResponse/CurrentBrightness');
	} 
	else 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	}
}

sub setBrightness
{
	my $self = shift;
	my $desiredBrightness = shift;
	
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/RenderingControl1",
									uri=>"urn:schemas-upnp-org:service:RenderingControl:1" );

	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 
	my $desiredBrightness_req = SOAP::Data->type("int")->name("DesiredBrightness")->value($desiredBrightness); 

	my $response = $request->SetBrightness($instanceID, $desiredBrightness_req);
	
	if ($response->fault) 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	} 
	return 0;
}

sub getContrast
{
    my $self = shift;
  
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/RenderingControl1",
									uri=>"urn:schemas-upnp-org:service:RenderingControl:1" );

	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 

	my $response = $request->GetContrast($instanceID);
	
	unless ($response->fault) 
	{
		return $response->valueof('//GetContrastResponse/CurrentContrast');
	} 
	else 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	}
}

sub setContrast
{
	my $self = shift;
	my $desiredContrast = shift;
	
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/RenderingControl1",
									uri=>"urn:schemas-upnp-org:service:RenderingControl:1" );

	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 
	my $desiredContrast_req = SOAP::Data->type("int")->name("DesiredContrast")->value($desiredContrast); 

	my $response = $request->SetContrast($instanceID, $desiredContrast_req);
	
	if ($response->fault) 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	} 
	return 0;
}

sub getSharpness
{
    my $self = shift;
  
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/RenderingControl1",
									uri=>"urn:schemas-upnp-org:service:RenderingControl:1" );

	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 

	my $response = $request->GetSharpness($instanceID);
	
	unless ($response->fault) 
	{
		return $response->valueof('//GetSharpnessResponse/CurrentSharpness');
	} 
	else 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	}
}

sub setSharpness
{
	my $self = shift;
	my $desiredSharpness = shift;
	
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/RenderingControl1",
									uri=>"urn:schemas-upnp-org:service:RenderingControl:1" );

	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 
	my $desiredSharpness_req = SOAP::Data->type("int")->name("DesiredSharpness")->value($desiredSharpness); 

	my $response = $request->SetContrast($instanceID, $desiredSharpness_req);
	
	if ($response->fault) 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	} 
	return 0;
}

sub getColorTemperature
{
    my $self = shift;
  
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/RenderingControl1",
									uri=>"urn:schemas-upnp-org:service:RenderingControl:1" );

	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 

	my $response = $request->GetColorTemperature($instanceID);
	
	unless ($response->fault) 
	{
		return $response->valueof('//GetColorTemperatureResponse/CurrentColorTemperature');
	} 
	else 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	}
}

sub setColorTemperature
{
	my $self = shift;
	my $desiredColorTemperature = shift;
	
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/RenderingControl1",
									uri=>"urn:schemas-upnp-org:service:RenderingControl:1" );

	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 
	my $desiredColorTemperature_req = SOAP::Data->type("int")->name("DesiredColorTemperature")->value($desiredColorTemperature); 

	my $response = $request->SetColorTemperature($instanceID, $desiredColorTemperature_req);
	
	if ($response->fault) 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	} 
	return 0;
}

sub getImageRotation
{
    my $self = shift;
  
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/RenderingControl1",
									uri=>"urn:schemas-upnp-org:service:RenderingControl:1" );

	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 

	my $response = $request->X_GetImageRotation($instanceID);

	unless ($response->fault) 
	{
		return $response->valueof('//X_GetImageRotationResponse/ImageRotation');
	} 
	else 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	}
}

sub setImageRotation
{
	my $self = shift;
	my $desiredImageRotation = shift;
	
	if( ($desiredImageRotation >= 0) && ($desiredImageRotation < 90) )
	{
		$desiredImageRotation = 0;
	}
	elsif( ($desiredImageRotation >= 90) && ($desiredImageRotation < 180) )
	{
		$desiredImageRotation = 90;
	}
	elsif ( ($desiredImageRotation >= 180) && ($desiredImageRotation < 270) )
	{
		$desiredImageRotation = 180;
	}
	elsif ( ($desiredImageRotation >= 270) && ($desiredImageRotation < 360) )
	{
		$desiredImageRotation = 270;
	}
	
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/RenderingControl1",
									uri=>"urn:schemas-upnp-org:service:RenderingControl:1" );

	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 
	my $desiredImageRotation_req = SOAP::Data->type("int")->name("ImageRotation")->value($desiredImageRotation); 

	my $response = $request->X_SetImageRotation($instanceID, $desiredImageRotation_req);
	
	if ($response->fault) 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	} 
	return 0;
}

sub getMute
{
    my $self = shift;
  
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/RenderingControl1",
									uri=>"urn:schemas-upnp-org:service:RenderingControl:1" );

	my $channel = SOAP::Data->type("string")->name("Channel")->value("Master");
	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 

	my $response = $request->GetMute($instanceID, $channel);
	
	unless ($response->fault) 
	{
		return $response->valueof('//GetMuteResponse/CurrentMute');
	} 
	else 
	{
		printf( "SOAP Error: %d %s\n", $response->faultcode ,$response->faultstring );
		return 1;
	}
}

sub setMute
{
	my $self = shift;
	my $desiredMute = shift;
	
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/RenderingControl1",
									uri=>"urn:schemas-upnp-org:service:RenderingControl:1" );

	my $channel = SOAP::Data->type("string")->name("Channel")->value("Master");
	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 
	my $desiredMute_req = SOAP::Data->type("boolean")->name("DesiredMute")->value($desiredMute); 

	my $response = $request->SetMute($instanceID, $channel, $desiredMute_req);
	
	if ($response->fault) 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	} 
	return 0;
}

sub sendButton
{
	my ($self, $button ) = @_;
	
	my @payload_array = ( 
							length(MIME::Base64::encode_base64($button, "")),
							MIME::Base64::encode_base64($button, "")
						);
	
	my $payload_array_string = pack( "xxx s a*", @payload_array );
	
	my @payload_message = (
								length($tvappstring),
								$tvappstring,
								length($payload_array_string),
								$payload_array_string
							);
	my $payload_string = pack("s x a* s a*", @payload_message);

	#print ${$self->{socket}} ( $self->{id_string1}.$self->{id_string2}.$payload_string);
	$self->{socket}->send( $self->{id_string1}.$self->{id_string2}.$payload_string );
	
	# my $test = $self->{id_string1}.$self->{id_string2}.$payload_string;
	
	# print "Gesendet: \n" . Data::Hexdumper::hexdump($test);
	
	my $response;
	$self->{socket}->recv($response, 1000000);
	print "Antwort vom Fernseher: $response\n" . Data::Hexdumper::hexdump($response);
	
}

sub sendText
{
	my ($self, $text ) = @_;
	
	my @payload_array = ( 
						length(MIME::Base64::encode_base64($text, "")),
						MIME::Base64::encode_base64($text, "")
					);
	my $payload_array_string = pack( "s s a*",(1, @payload_array) );

	my @payload_message = (
							length($tvappstring),
							$tvappstring,
							length($payload_array_string),
							$payload_array_string
						);
						
	my $payload_string = pack("c s a* s a*", (1, @payload_message ));
   
	print ${$self->{socket}} ( $self->{id_string1}.$self->{id_string2}.$payload_string);
}


sub find_devices
{
	my $timeout_value = $_[0];
	unless(defined ($timeout_value) )
	{
		$timeout_value = 3;
	}
	
	my $cp = Net::UPnP::ControlPoint->new();
	my @dev_list = $cp->search(st =>'upnp:rootdevice', mx => $timeout_value);

	my $number_devices = @dev_list;

	my @list_of_ips = ();

	foreach my $dev (@dev_list)
	{
		# my $device_type = $dev->getdevicetype();
		# my $device_name = $dev->getfriendlyname();
		my $device_location = $dev->getlocation();
		#my $device_desc = $dev->getdescription();

		if( $device_location =~ /http:\/\/.+:52235/i)
		{
			$device_location =~ m/\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ig;
			if( index( join( " ", @list_of_ips ), $& ) == -1 )
			{
				push(@list_of_ips, $&);
			}
		}
	}
	return @list_of_ips;
}
sub sendSMS_now
{
	my ( $self, $message, $sendername, $sendernumber, $receivername, $receivernumber ) = @_;
	
	if ( not defined($message) )
	{
		$message = "";
	}
	if ( not defined($sendername) )
	{
		$sendername = "";
	}
	if ( not defined($sendernumber) )
	{
		$sendernumber = "";
	}
	if ( not defined($receivername) )
	{
		$receivername = "";
	}
	if ( not defined($receivernumber) )
	{
		$receivernumber = "";
	}

	my @datearray = localtime(time);
	
	my $calltime = sprintf( "%02d:%02d:%02d", $datearray[2],$datearray[1],$datearray[0]);
	my $calldate = sprintf( "%04d-%02d-%02d", $datearray[5]+1900,$datearray[4]+1,$datearray[3] );

	$self->sendSMS( $message, $sendername, $sendernumber, $receivername, $receivernumber, $calltime, $calldate );
}
sub sendSMS
{
	my ( $self, $message, $sendername, $sendernumber, $receivername, $receivernumber, $calltime, $calldate ) = @_;
	
	if ( not defined($message) )
	{
		$message = "";
	}
	if ( not defined($sendername) )
	{
		$sendername = "";
	}
	if ( not defined($sendernumber) )
	{
		$sendernumber = "";
	}
	if ( not defined($receivername) )
	{
		$receivername = "";
	}
	if ( not defined($receivernumber) )
	{
		$receivernumber = "";
	}	
	if ( not defined($calltime) )
	{
		$calltime = "";
	}
	if ( not defined($calldate) )
	{
		$calldate = "";
	}	
	
	my  $msg =  "<Category>SMS</Category>
			 <DisplayType>Maximum</DisplayType>
			 <ReceiveTime>
				 <Date>$calldate</Date>
				 <Time>$calltime</Time>
			 </ReceiveTime>
			 <Receiver>
				 <Number>$receivernumber</Number>
				 <Name>$receivername</Name>
			 </Receiver>
			 <Sender>
				 <Number>$sendernumber</Number>
				 <Name>$sendername</Name>
			 </Sender>
			 <Body>$message</Body>";

	$self->send_soap_message($msg);
}

sub reportCall
{
	my ( $self, $calldate, $calltime, $callername, $callernumber ) = @_;
	
	my @datearray = localtime(time);
	
	if ( not defined($callername) )
	{
		$callername = "";
	}
	if ( not defined($callernumber) )
	{
		$callernumber = "";
	}
	if ( not defined($calltime) )
	{
		$calltime = sprintf( "%02d:%02d:%02d", $datearray[2],$datearray[1],$datearray[0]);
	}
	if ( not defined($calldate) )
	{
		$calldate = sprintf( "%04d-%02d-%02d", $datearray[5]+1900,$datearray[4]+1,$datearray[3] );	
	}

	 my $msg = "<Category>Incoming Call</Category>
				<DisplayType>Maximum</DisplayType><CallTime>
				   <Date>$calldate</Date>
				   <Time>$calltime</Time>	
				 </CallTime>
				 <Callee>
				   <Number>$callername</Number>
				   <Name>$callername</Name>
				 </Callee>
				 <Caller>
				   <Number>$callernumber</Number>
				   <Name>$callername</Name>
				 </Caller>";

	$self->send_soap_message($msg);
}

sub showScheduler
{
	my ( $self, $starttime, $startdate, $endtime, $enddate, $subject, $location, $description, $name, $number ) = @_;
	
	my @datearray = localtime(time);
	
	if ( not defined($starttime) )
	{
		$starttime = sprintf( "%02d:%02d:%02d", $datearray[2],$datearray[1],$datearray[0]);
	}
	if ( not defined($startdate) )
	{
		$startdate = sprintf( "%04d-%02d-%02d", $datearray[5]+1900,$datearray[4]+1,$datearray[3] );
	}
	if ( not defined($endtime) )
	{
		$endtime = sprintf( "%02d:%02d:%02d", $datearray[2],$datearray[1],$datearray[0]);
	}
	if ( not defined($enddate) )
	{
		$enddate = sprintf( "%04d-%02d-%02d", $datearray[5]+1900,$datearray[4]+1,$datearray[3] );
	}
	if ( not defined($subject) )
	{
		$subject = "";
	}
	if ( not defined($location) )
	{
		$location = "";
	}
	if ( not defined($description) )
	{
		$description = "";
	}	
	if ( not defined($name) )
	{
		$name = "";
	}	
	if ( not defined($number) )
	{
		$number = "";
	}
    
	my $msg =  "<Category>Schedule Reminder</Category>
				<DisplayType>Maximum</DisplayType><CallTime>
				<StartTime>
				   <Date>$startdate</Date>
				   <Time>$starttime</Time>
				</StartTime>
				<Owner>
				   <Number>$number</Number>
				   <Name>$name</Name>
				</Owner>
				<Subject>$subject</Subject>
				<EndTime>
				   <Date>$enddate</Date>
				   <Time>$endtime</Time>
				</EndTime>
				<Location>$location</Location>
				<Body>$description</Body>";   
	
	$self->send_soap_message($msg);
}

sub send_soap_message
{
	my ( $self, $msg ) = @_;
	
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/PMR/control/MessageBoxService",
									uri=>"urn:samsung.com:service:MessageBoxService:1" );

	my $messageID = SOAP::Data->type("string")->name("MessageID")->value("0");
	my $SOAPmessage = SOAP::Data->type("string")->name("Message")->value($msg); 
	my $messageType = SOAP::Data->type("string")->name("MessageType")->value('text/xml; charset="utf-8"');
	my $response = $request->AddMessage( $messageType, $messageID, $SOAPmessage);
	
	if ($response->fault) 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	} 
	return 0;
}

sub getMediaInfo
{
	my $self = shift;
	my $desiredMute = shift;
	
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/AVTransport1",
									uri=>"urn:schemas-upnp-org:service:AVTransport:1" );

	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 
	my $response = $request->GetMediaInfo($instanceID);

}

sub setAVTransportURI
{
	my $self = shift;
	my $currentURI = shift;
	
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/AVTransport1",
									uri=>"urn:schemas-upnp-org:service:AVTransport:1" );

	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 
	my $URI = SOAP::Data->type("string")->name("CurrentURI")->value($currentURI); 
	my $URIMeta = SOAP::Data->type("string")->name("CurrentURIMetaData")->value(""); 
	my $response = $request->SetAVTransportURI($instanceID, $URI, $URIMeta);
	
	if ($response->fault) 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	} 

	return 0;
}

sub play
{
	my $self = shift;
	my $request = SOAP::Lite->new ( proxy =>$self->{upnphost}."/upnp/control/AVTransport1",
									uri=>"urn:schemas-upnp-org:service:AVTransport:1" );
									
	my $instanceID = SOAP::Data->type("int")->name("InstanceID")->value(0); 
	my $transportPlaySpeed = SOAP::Data->type("string")->name("Speed")->value(1); 
	my $response = $request->Play($instanceID, $transportPlaySpeed);
	
	if ($response->fault) 
	{
		print "SOAP Error: ". $response->faultcode . " ". $response->faultstring ."\n";
		return 1;
	}		
	return 0;
}

1;