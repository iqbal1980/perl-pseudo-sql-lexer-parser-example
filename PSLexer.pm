package PSLexer;
use strict;
use warnings;
use Data::Dumper;

sub new {
  my ($classe) = @_;    
  my $this = {};        
  bless( $this, $classe );   
  return $this;              
}		

sub tokenizeString {
	my %tokens;
	my %token;
	my $tmp =  shift;
	$tmp = shift;

	#Got rid of repetitive codes , by putting Token and it's regex "qr/regex/" 
	#in another hashmap and looping trough it.
	my %tokens_regex_hash = ( 
		TOK_STAR   => qr/(\*)/ , 
		TOK_SELECT => qr/(select)/, 
		TOK_FROM   => qr/(from)/ , 
		TOK_GOOGLE => qr/(google)/, 
		TOK_WHERE  => qr/(where)/, 
		TOK_QUERY  => qr/(query)/ , 
		TOK_EQ	   => qr/(\=)/ ,
		TOK_QUERY_STRING => qr/'(.*)'/ );	
	#my $currentPosition;

	#Start of lexical analysis, I use perl regexes and the pos function to get the position
	#of each token, then store it into a hash of hash indexed by position
	for my $key ( keys %tokens_regex_hash ) {
		my $currentPosition = 0;
		my $pseudoSqlTokenized = $tmp;
		
		while( $pseudoSqlTokenized =~ m/$tokens_regex_hash{$key}/g ) {
			$currentPosition = pos($pseudoSqlTokenized) - length($1);
			%token = ();
			%token = (TOKEN_TYPE  => $key , TOKEN_STRING => '*', TOKEN_POS => $currentPosition );
			$tokens{$currentPosition} = { %token };
		}		
	}	

	my $lastPosition = 	length($tmp) + 1;
	%token = (TOKEN_TYPE  => 'TOK_LAST' , TOKEN_STRING => 'LAST' , TOKEN_POS => $lastPosition );
	$tokens{$lastPosition} = { %token };

	return %tokens;
}

1;