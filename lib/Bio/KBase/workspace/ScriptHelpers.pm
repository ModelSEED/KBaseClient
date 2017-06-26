package Bio::KBase::workspace::ScriptHelpers;
use strict;
use warnings;
use Bio::KBase::kbaseenv;
use Exporter;
use parent qw(Exporter);
our @EXPORT_OK = qw(	loadTableFile
			printJobData
			getToken
			getUser
			get_ws_client
			workspace workspaceURL
			getObjectRef
			parseObjectMeta
			parseWorkspaceInfo
			parseWorkspaceMeta
			printObjectMeta
			printWorkspaceMeta
			parseObjectInfo
			printObjectInfo);

Bio::KBase::kbaseenv::create_context_from_client_config();

my $urls = {
	default => "https://kbase.us/services/ws",
	appdev => "https://appdev.kbase.us/services/ws",
	ci => "https://ci.kbase.us/services/ws",
	"next" => "https://next.kbase.us/services/ws"
};

sub get_ws_client {
	my $url = shift;
	if (!defined($url)) {
		$url = workspaceURL();
	}
	return Bio::KBase::kbaseenv::ws_client({url => $url, refresh => 1});
}

sub getToken {
	return Bio::KBase::utilities::token();
}

sub getUser {
	my $user_id = Bio::KBase::utilities::user_id();
	if (!defined($user_id) || (ref($user_id) ne '')) {
		Bio::KBase::utilities::error("You must be logged in to use workspace CLI!");
	}
	return $user_id;
}

sub getKBaseCfg {
	my $kbConfPath = $ENV{KB_CLIENT_CONFIG};
	if (!-e $kbConfPath) {
		if (!defined($kbConfPath) || length($kbConfPath) == 0) {
			Bio::KBase::utilities::error("KB_CLIENT_CONFIG environment variable not set to meaningful value!");
		}
		my $newcfg = new Config::Simple(syntax=>'ini') or die Config::Simple->error();
		$newcfg->param("workspace_deluxe.url",$urls->{default});
		$newcfg->write($kbConfPath);
		$newcfg->close();
	}
	my $cfg = new Config::Simple(filename=>$kbConfPath,syntax=>'ini') or die Config::Simple->error();
	return $cfg;
}

sub workspace {
	my $newWs = shift;
	my $currentWs;
	my $cfg = getKBaseCfg();
	my $user_id = getUser();
	if (defined($newWs)) {
		$currentWs = $newWs;
		$cfg->param("workspace_deluxe.$user_id-current-workspace",$newWs);
		$cfg->save();
	} else {
		$currentWs = $cfg->param("workspace_deluxe.$user_id-current-workspace");
	}
	if (!defined($currentWs)) {
		Bio::KBase::utilities::error("No selected workspace set!");
	}
	$cfg->close();
	return $currentWs;
}


sub workspaceURL {
	my $newUrl = shift;
	my $currentURL;
	my $cfg = getKBaseCfg();
	if (defined($newUrl)) {
		if (defined($urls->{$newUrl})) {
			$newUrl = $urls->{$newUrl};
		}
		$cfg->param("workspace_deluxe.url",$newUrl);
		$cfg->save();
		$currentURL = $newUrl;
	} else {
		$currentURL = $cfg->param("workspace_deluxe.url");
	}
	$cfg->close();
	return $currentURL;
}


# given the strings passed to a script as an ws, object name, and version returns
# the reference string of the object. The magic is that if, in the object name,
# it is a reference to begin with, then that reference information overrides
# what is passed in as other args or if there is a default workspace set.
sub getObjectRef {
	my($ws,$obj,$ver) = @_;
	my $versionString = '';
	if (defined($ver)) { if($ver ne '') { $versionString="/".$ver;} }
	
	# check for refs of the form kb|ws.1.obj.2.ver.4
	my @idtokens = split(/\./,$obj);
	if (scalar(@idtokens)==4) {
		if ($idtokens[0] eq 'kb|ws' && $idtokens[2] eq 'obj' && $idtokens[1]=~/^\d+$/ && $idtokens[3]=~/^\d+$/) {
			return $idtokens[1]."/".$idtokens[3].$versionString;
		}
	} elsif(scalar(@idtokens)==6) {
		if ($idtokens[0] eq 'kb|ws' && $idtokens[2] eq 'obj' && $idtokens[4] eq 'ver' && $idtokens[1]=~/^\d+$/ && $idtokens[3]=~/^\d+$/ && $idtokens[5]=~/^\d+$/) {
			return $idtokens[1]."/".$idtokens[3]."/".$idtokens[5];
		}
	}
	
	# check for refs of the form ws/obj/ver
	my @tokens = split(/\//, $obj);
	if (scalar(@tokens)==1) {
		return $ws."/".$obj.$versionString;
	} elsif (scalar(@tokens)==2) {
		return $tokens[0]."/".$tokens[1].$versionString;
	} elsif (scalar(@tokens)==3) {
		return $obj;
	}
	
	#should never get here!!!
	return $ws."/".$obj.$versionString;
}


sub parseObjectMeta {
	my $object = shift;
	my $hash = {
		id => $object->[0],
		type => $object->[1],
		moddate => $object->[2],
		instance => $object->[3],
		command => $object->[4],
		lastmodifier => $object->[5],
		owner => $object->[6],
		workspace => $object->[7],
		reference => $object->[8],
		chsum => $object->[9],
		metadata => $object->[10]
	};
	return $hash;
}

sub printObjectMeta {
	my $meta = shift;
	my $obj = parseObjectMeta($meta);
	print "Object Name: ".$obj->{id}."\n";
	print "Type: ".$obj->{type}."\n";
	print "Instance: ".$obj->{instance}."\n";
	print "Workspace: ".$obj->{workspace}."\n";
	print "Owner: ".$obj->{owner}."\n";
	print "Moddate: ".$obj->{moddate}."\n";
	#print "Last cmd: ".$obj->{command}."\n";
	print "Modified by: ".$obj->{lastmodifier}."\n";
	#print "Perm ref: ".$obj->{reference}."\n";
	print "Checksum: ".$obj->{chsum}."\n";
	if (defined($obj->{metadata})) {
		foreach my $key (keys(%{$obj->{metadata}})) {
			print $key.": ".$obj->{metadata}->{$key}."\n";
		}
	}
}


sub parseObjectInfo {
	my $object = shift;
	my $hash = {
		id => $object->[0],
		name => $object->[1],
		type => $object->[2],
		save_date => $object->[3],
		version => $object->[4],
		saved_by => $object->[5],
		wsid => $object->[6],
		workspace => $object->[7],
		chsum => $object->[8],
		size => $object->[9],
		metadata => $object->[10]
	};
	return $hash;
}

sub printObjectInfo {
	my $meta = shift;
	my $obj = parseObjectInfo($meta);
	print "Object Name: ".$obj->{name}."\n";
	print "Object ID: ".$obj->{id}."\n";
	print "Type: ".$obj->{type}."\n";
	print "Version: ".$obj->{version}."\n";
	print "Workspace: ".$obj->{workspace}."\n";
	print "Save Date: ".$obj->{save_date}."\n";
	print "Saved by: ".$obj->{saved_by}."\n";
	print "Checksum: ".$obj->{chsum}."\n";
	print "Size(bytes): ".$obj->{size}."\n";
	print "User Meta Data: ";
	if (defined($obj->{metadata})) {
		if (scalar(keys(%{$obj->{metadata}}))>0) { print "\n"; }
		else { print " none.\n"; }
		foreach my $key (keys(%{$obj->{metadata}})) {
			print "  ".$key.": ".$obj->{metadata}->{$key}."\n";
		}
	} else {
		print "none.\n";
	}
}



sub parseWorkspaceInfo {
	my $object = shift;
	my $hash = {
		id => $object->[0],
		workspace => $object->[1],
		owner => $object->[2],
		moddate => $object->[3],
		objects => $object->[4],
		user_permission => $object->[5],
		globalread => $object->[6]
	};
	return $hash;
}

sub parseWorkspaceMeta {
	my $object = shift;
	my $hash = {
		id => $object->[0],
		owner => $object->[1],
		moddate => $object->[2],
		objects => $object->[3],
		user_permission => $object->[4],
		global_permission => $object->[5],
	};
	return $hash;
}

sub printWorkspaceMeta {
	my $meta = shift;
	my $obj = parseWorkspaceMeta($meta);
	print "Workspace ID: ".$obj->{id}."\n";
	print "Owner: ".$obj->{owner}."\n";
	print "Moddate: ".$obj->{moddate}."\n";
	print "Objects: ".$obj->{objects}."\n";
	print "User permission: ".$obj->{user_permission}."\n";
	print "Global permission:".$obj->{global_permission}."\n";
}

sub loadTableFile {
	my ($filename) = @_;
	if (!-e $filename) {
		print "Could not open table file ".$filename."!\n";
		exit();
	}
	open(my $fh, "<", $filename) || return;
	my $headingline = <$fh>;
	my $tbl;
	chomp($headingline);
	my $headings = [split(/\t/,$headingline)];
	for (my $i=0; $i < @{$headings}; $i++) {
		$tbl->{headings}->{$headings->[$i]} = $i;
	}
	while (my $line = <$fh>) {
		chomp($line);
		push(@{$tbl->{data}},[split(/\t/,$line)]);
	}
	close($fh);
	return $tbl;
}

1;
