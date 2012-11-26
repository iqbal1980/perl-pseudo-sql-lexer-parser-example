package PSParser;
use strict;
use warnings;
use Data::Dumper;

my @sorted_indices;
my $pseudoSQL = "";
my $queryString = "";
my %tokenHash;

sub new {
  my ($classe) = @_;    
  my $this = {};        
  bless( $this, $classe );   
  return $this;              
}	

sub matchLast {
	my $tokenValue = $sorted_indices[0];
	if($tokenValue->{TOKEN_TYPE} eq "TOK_LAST") {
		shift @sorted_indices;	
		print "Your pseudo SQL is fine :)\n";
	} else {
		print "ERROR expecting token 'End of query' at position $tokenValue->{TOKEN_POS} \n";
	}
}

sub matchQueryString {
	my $tokenValue = $sorted_indices[0];
	if($tokenValue->{TOKEN_TYPE} eq "TOK_QUERY_STRING") {
		shift @sorted_indices;	
		use URI::Escape;
		$queryString = uri_escape($tokenValue->{TOKEN_STRING});
		matchLast();
	} else {
		print "ERROR expecting token 'Query String' at position $tokenValue->{TOKEN_POS} \n";
	}
}

sub matchEqual {
	my $tokenValue = $sorted_indices[0];
	if($tokenValue->{TOKEN_TYPE} eq "TOK_EQ") {
		shift @sorted_indices;	
		matchQueryString();
	} else {
		print "ERROR expecting token '=' at position $tokenValue->{TOKEN_POS} \n";
	}
}

sub matchQuery {
	my $tokenValue = $sorted_indices[0];
	if($tokenValue->{TOKEN_TYPE} eq "TOK_QUERY") {
		shift @sorted_indices;	
		matchEqual();
	} else {
		print "ERROR expecting token 'query' at position $tokenValue->{TOKEN_POS} \n";
	}
}


sub matchWhere {
	my $tokenValue = $sorted_indices[0];
	if($tokenValue->{TOKEN_TYPE} eq "TOK_WHERE") {
		shift @sorted_indices;	
		matchQuery();
	} else {
		print "ERROR expecting token 'where' at position $tokenValue->{TOKEN_POS} \n";
	}
}

sub matchGoogle {
	my $tokenValue = $sorted_indices[0];
	if($tokenValue->{TOKEN_TYPE} eq "TOK_GOOGLE") {
		shift @sorted_indices;	
		matchWhere();
	} else {
		print "ERROR expecting token 'google' at position $tokenValue->{TOKEN_POS} \n";
	}
}

sub matchFrom {
	my $tokenValue = $sorted_indices[0];
	if($tokenValue->{TOKEN_TYPE} eq "TOK_FROM") {
		shift @sorted_indices;	
		matchGoogle();
	} else {
		print "ERROR expecting token 'from' at position $tokenValue->{TOKEN_POS} \n";
	}
}

sub matchStar {
	my $tokenValue = $sorted_indices[0];
	if($tokenValue->{TOKEN_TYPE} eq "TOK_STAR") {
		shift @sorted_indices;	
		matchFrom();
	} else {
		print "ERROR expecting token 'star' at position $tokenValue->{TOKEN_POS} \n";
	}
}

sub parseTokens {
	#Start of recursive parsing, the grammar is a set of recursive functions, 
	#in this case there is no real recursion the grammar is simple
	
	my $self = shift(@_);#shifting class/object name
	my %tokensHash =  @_ ;#getting the passed hashmap
	
	my $i = 0;
	for my $key (sort { $a <=> $b } keys %tokensHash) {
		push @sorted_indices ,  $tokensHash{$key};
	}

	my $tokenValue = $sorted_indices[0];
	
	if($tokenValue->{TOKEN_TYPE} eq "TOK_SELECT") {
		shift @sorted_indices;	
		matchStar();
	} else {
		print "ERROR expecting token 'select' at position $tokenValue->{TOKEN_POS} \n";
	}	
}

1;