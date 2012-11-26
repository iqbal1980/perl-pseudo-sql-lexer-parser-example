#!/usr/bin/perl

use Data::Dumper;
our @sorted_indices;
our $pseudoSQL = "";
our $queryString = "";

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
	my %tokensHash = @_;
	
	my $i = 0;
	foreach $key (sort { $a <=> $b } keys %tokensHash) {
		push @sorted_indices ,  $tokensHash{$key};
	}

	print (Dumper(\@sorted_indices))."\n";
	my $tokenValue = $sorted_indices[0];
	
	if($tokenValue->{TOKEN_TYPE} eq "TOK_SELECT") {
		shift @sorted_indices;	
		matchStar();
	} else {
		print "ERROR expecting token 'select' at position $tokenValue->{TOKEN_POS} \n";
	}
	
	
}

sub tokenizeString2 {
	my %tokens;
	my $tmp =  shift;
	my %tokens_regex_hash = ( TOK_STAR => qr/(\*)/ , TOK_SELECT => qr/(select)/, TOK_FROM => qr/(from)/ , TOK_GOOGLE => qr/(google)/
							  TOK_WHERE => qr/(where)/, TOK_QUERY => qr/(query)/ , TOK_EQ => qr/(\=)/ ,TOK_QUERY_STRING => qr/'(.*)'/);	
	my $currentPosition;

	#Start of lexical analysis, I use perl regexes and the pos function to get the position
	#of each token, then store it into a hash of hash indexed by position
	$currentPosition = 0;
	$pseudoSqlTokenized = $tmp;
	
	for my $key ( keys %tokens_regex_hash ) {
		while( $pseudoSqlTokenized =~ m/$tokens_regex_hash{$key}/g ) {
			my %token;
			$currentPosition = pos($pseudoSqlTokenized) - length($1);
			%token = (TOKEN_TYPE  => $key , TOKEN_STRING => '*', TOKEN_POS => $currentPosition );
			$tokens{$currentPosition} = { %token };
		}		
	}	

	my $lastPosition = 	length($tmp) + 1;
	%token = (TOKEN_TYPE  => 'TOK_LAST' , TOKEN_STRING => 'LAST' , TOKEN_POS => $lastPosition );
	$tokens{$lastPosition} = { %token };

	return %tokens;
	
}

print "****************************************************************************************************************************\n";
print "This is simple demo of lexical and syntactical analysis of a SQL like language to query google\n";
print "Lexical analysis uses Perl regexes with pos function whereas Syntactical analysis uses a left recursive descent parser\n";
print "References: http://en.wikipedia.org/wiki/Recursive_descent_parser \n";
print "Or read the: Dragon Book http://en.wikipedia.org/wiki/Compilers:_Principles,_Techniques,_and_Tools \n";
print "TODO: use WWW::Curl::Easy to search google then HTML::PARSER to get the results\n";
print "Iqbal Addou: (iqbal.addou@gmail.com)\n";
print "Please enter a pseudo SQL command (Try different bad and good queries to test the parsing\n";
print "Example:\n";
print "Good query:select * from google where query = 'search string'\n";
print "Bad  query:select *  * from google  where query  'search string'\n";
print "****************************************************************************************************************************\n\n\n";
$pseudoSQL = <>;

my %tmp = tokenizeString($pseudoSQL);
parseTokens(%tmp);

#print Dumper(\@sorted_indices);





