use strict;
use PSLexer;
use PSParser;
use Data::Dumper;

print "****************************************************************************************************************************\n";
print "This is simple demo of lexical and syntactical analysis of a SQL like language to query google\n";
print "Lexical analysis uses Perl regexes with pos function whereas Syntactical analysis uses a left recursive descent parser\n";
print "References: http://en.wikipedia.org/wiki/Recursive_descent_parser \n";
print "Or read the: Dragon Book http://en.wikipedia.org/wiki/Compilers:_Principles,_Techniques,_and_Tools \n";
print "TODO: use WWW::Curl::Easy to search google then HTML::PARSER to get the results\n";
print "Iqbal Addou: (iqbal.addou\@gmail.com)\n";
print "Please enter a pseudo SQL command (Try different bad and good queries to test the parsing\n";
print "Example:\n";
print "Good query:select * from google where query = 'search string'\n";
print "Bad  query:select *  * from google  where query  'search string'\n";
print "****************************************************************************************************************************\n\n\n";

my $pseudoSQL = <>;

#object instanciation
#alternative to try/catch in perl. Wish they had try/catch in perl :(
my $lexerObj =  eval { new PSLexer(); }  or die ($@);
my %usedTokens = $lexerObj->tokenizeString($pseudoSQL);

my $parserObj = eval { new PSParser(); } or die ($@);
$parserObj->parseTokens(%usedTokens);