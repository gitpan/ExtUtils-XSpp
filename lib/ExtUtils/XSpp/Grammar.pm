####################################################################
#
#    This file was generated using Parse::Yapp version 1.05.
#
#        Don't edit this file, use source file instead.
#
#             ANY CHANGE MADE HERE WILL BE LOST !
#
####################################################################
package ExtUtils::XSpp::Grammar;
use vars qw ( @ISA );
use strict;

@ISA= qw ( ExtUtils::XSpp::Grammar::YappDriver );
#Included Parse/Yapp/Driver.pm file----------------------------------------
{
#
# Module ExtUtils::XSpp::Grammar::YappDriver
#
# This module is part of the Parse::Yapp package available on your
# nearest CPAN
#
# Any use of this module in a standalone parser make the included
# text under the same copyright as the Parse::Yapp module itself.
#
# This notice should remain unchanged.
#
# (c) Copyright 1998-2001 Francois Desarmenien, all rights reserved.
# (see the pod text in Parse::Yapp module for use and distribution rights)
#

package ExtUtils::XSpp::Grammar::YappDriver;

require 5.004;

use strict;

use vars qw ( $VERSION $COMPATIBLE $FILENAME );

$VERSION = '1.05';
$COMPATIBLE = '0.07';
$FILENAME=__FILE__;

use Carp;

#Known parameters, all starting with YY (leading YY will be discarded)
my(%params)=(YYLEX => 'CODE', 'YYERROR' => 'CODE', YYVERSION => '',
			 YYRULES => 'ARRAY', YYSTATES => 'ARRAY', YYDEBUG => '');
#Mandatory parameters
my(@params)=('LEX','RULES','STATES');

sub new {
    my($class)=shift;
	my($errst,$nberr,$token,$value,$check,$dotpos);
    my($self)={ ERROR => \&_Error,
				ERRST => \$errst,
                NBERR => \$nberr,
				TOKEN => \$token,
				VALUE => \$value,
				DOTPOS => \$dotpos,
				STACK => [],
				DEBUG => 0,
				CHECK => \$check };

	_CheckParams( [], \%params, \@_, $self );

		exists($$self{VERSION})
	and	$$self{VERSION} < $COMPATIBLE
	and	croak "Yapp driver version $VERSION ".
			  "incompatible with version $$self{VERSION}:\n".
			  "Please recompile parser module.";

        ref($class)
    and $class=ref($class);

    bless($self,$class);
}

sub YYParse {
    my($self)=shift;
    my($retval);

	_CheckParams( \@params, \%params, \@_, $self );

	if($$self{DEBUG}) {
		_DBLoad();
		$retval = eval '$self->_DBParse()';#Do not create stab entry on compile
        $@ and die $@;
	}
	else {
		$retval = $self->_Parse();
	}
    $retval
}

sub YYData {
	my($self)=shift;

		exists($$self{USER})
	or	$$self{USER}={};

	$$self{USER};
	
}

sub YYErrok {
	my($self)=shift;

	${$$self{ERRST}}=0;
    undef;
}

sub YYNberr {
	my($self)=shift;

	${$$self{NBERR}};
}

sub YYRecovering {
	my($self)=shift;

	${$$self{ERRST}} != 0;
}

sub YYAbort {
	my($self)=shift;

	${$$self{CHECK}}='ABORT';
    undef;
}

sub YYAccept {
	my($self)=shift;

	${$$self{CHECK}}='ACCEPT';
    undef;
}

sub YYError {
	my($self)=shift;

	${$$self{CHECK}}='ERROR';
    undef;
}

sub YYSemval {
	my($self)=shift;
	my($index)= $_[0] - ${$$self{DOTPOS}} - 1;

		$index < 0
	and	-$index <= @{$$self{STACK}}
	and	return $$self{STACK}[$index][1];

	undef;	#Invalid index
}

sub YYCurtok {
	my($self)=shift;

        @_
    and ${$$self{TOKEN}}=$_[0];
    ${$$self{TOKEN}};
}

sub YYCurval {
	my($self)=shift;

        @_
    and ${$$self{VALUE}}=$_[0];
    ${$$self{VALUE}};
}

sub YYExpect {
    my($self)=shift;

    keys %{$self->{STATES}[$self->{STACK}[-1][0]]{ACTIONS}}
}

sub YYLexer {
    my($self)=shift;

	$$self{LEX};
}


#################
# Private stuff #
#################


sub _CheckParams {
	my($mandatory,$checklist,$inarray,$outhash)=@_;
	my($prm,$value);
	my($prmlst)={};

	while(($prm,$value)=splice(@$inarray,0,2)) {
        $prm=uc($prm);
			exists($$checklist{$prm})
		or	croak("Unknow parameter '$prm'");
			ref($value) eq $$checklist{$prm}
		or	croak("Invalid value for parameter '$prm'");
        $prm=unpack('@2A*',$prm);
		$$outhash{$prm}=$value;
	}
	for (@$mandatory) {
			exists($$outhash{$_})
		or	croak("Missing mandatory parameter '".lc($_)."'");
	}
}

sub _Error {
	print "Parse error.\n";
}

sub _DBLoad {
	{
		no strict 'refs';

			exists(${__PACKAGE__.'::'}{_DBParse})#Already loaded ?
		and	return;
	}
	my($fname)=__FILE__;
	my(@drv);
	open(DRV,"<$fname") or die "Report this as a BUG: Cannot open $fname";
	while(<DRV>) {
                	/^\s*sub\s+_Parse\s*{\s*$/ .. /^\s*}\s*#\s*_Parse\s*$/
        	and     do {
                	s/^#DBG>//;
                	push(@drv,$_);
        	}
	}
	close(DRV);

	$drv[0]=~s/_P/_DBP/;
	eval join('',@drv);
}

#Note that for loading debugging version of the driver,
#this file will be parsed from 'sub _Parse' up to '}#_Parse' inclusive.
#So, DO NOT remove comment at end of sub !!!
sub _Parse {
    my($self)=shift;

	my($rules,$states,$lex,$error)
     = @$self{ 'RULES', 'STATES', 'LEX', 'ERROR' };
	my($errstatus,$nberror,$token,$value,$stack,$check,$dotpos)
     = @$self{ 'ERRST', 'NBERR', 'TOKEN', 'VALUE', 'STACK', 'CHECK', 'DOTPOS' };

#DBG>	my($debug)=$$self{DEBUG};
#DBG>	my($dbgerror)=0;

#DBG>	my($ShowCurToken) = sub {
#DBG>		my($tok)='>';
#DBG>		for (split('',$$token)) {
#DBG>			$tok.=		(ord($_) < 32 or ord($_) > 126)
#DBG>					?	sprintf('<%02X>',ord($_))
#DBG>					:	$_;
#DBG>		}
#DBG>		$tok.='<';
#DBG>	};

	$$errstatus=0;
	$$nberror=0;
	($$token,$$value)=(undef,undef);
	@$stack=( [ 0, undef ] );
	$$check='';

    while(1) {
        my($actions,$act,$stateno);

        $stateno=$$stack[-1][0];
        $actions=$$states[$stateno];

#DBG>	print STDERR ('-' x 40),"\n";
#DBG>		$debug & 0x2
#DBG>	and	print STDERR "In state $stateno:\n";
#DBG>		$debug & 0x08
#DBG>	and	print STDERR "Stack:[".
#DBG>					 join(',',map { $$_[0] } @$stack).
#DBG>					 "]\n";


        if  (exists($$actions{ACTIONS})) {

				defined($$token)
            or	do {
				($$token,$$value)=&$lex($self);
#DBG>				$debug & 0x01
#DBG>			and	print STDERR "Need token. Got ".&$ShowCurToken."\n";
			};

            $act=   exists($$actions{ACTIONS}{$$token})
                    ?   $$actions{ACTIONS}{$$token}
                    :   exists($$actions{DEFAULT})
                        ?   $$actions{DEFAULT}
                        :   undef;
        }
        else {
            $act=$$actions{DEFAULT};
#DBG>			$debug & 0x01
#DBG>		and	print STDERR "Don't need token.\n";
        }

            defined($act)
        and do {

                $act > 0
            and do {        #shift

#DBG>				$debug & 0x04
#DBG>			and	print STDERR "Shift and go to state $act.\n";

					$$errstatus
				and	do {
					--$$errstatus;

#DBG>					$debug & 0x10
#DBG>				and	$dbgerror
#DBG>				and	$$errstatus == 0
#DBG>				and	do {
#DBG>					print STDERR "**End of Error recovery.\n";
#DBG>					$dbgerror=0;
#DBG>				};
				};


                push(@$stack,[ $act, $$value ]);

					$$token ne ''	#Don't eat the eof
				and	$$token=$$value=undef;
                next;
            };

            #reduce
            my($lhs,$len,$code,@sempar,$semval);
            ($lhs,$len,$code)=@{$$rules[-$act]};

#DBG>			$debug & 0x04
#DBG>		and	$act
#DBG>		and	print STDERR "Reduce using rule ".-$act." ($lhs,$len): ";

                $act
            or  $self->YYAccept();

            $$dotpos=$len;

                unpack('A1',$lhs) eq '@'    #In line rule
            and do {
                    $lhs =~ /^\@[0-9]+\-([0-9]+)$/
                or  die "In line rule name '$lhs' ill formed: ".
                        "report it as a BUG.\n";
                $$dotpos = $1;
            };

            @sempar =       $$dotpos
                        ?   map { $$_[1] } @$stack[ -$$dotpos .. -1 ]
                        :   ();

            $semval = $code ? &$code( $self, @sempar )
                            : @sempar ? $sempar[0] : undef;

            splice(@$stack,-$len,$len);

                $$check eq 'ACCEPT'
            and do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Accept.\n";

				return($semval);
			};

                $$check eq 'ABORT'
            and	do {

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Abort.\n";

				return(undef);

			};

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Back to state $$stack[-1][0], then ";

                $$check eq 'ERROR'
            or  do {
#DBG>				$debug & 0x04
#DBG>			and	print STDERR 
#DBG>				    "go to state $$states[$$stack[-1][0]]{GOTOS}{$lhs}.\n";

#DBG>				$debug & 0x10
#DBG>			and	$dbgerror
#DBG>			and	$$errstatus == 0
#DBG>			and	do {
#DBG>				print STDERR "**End of Error recovery.\n";
#DBG>				$dbgerror=0;
#DBG>			};

			    push(@$stack,
                     [ $$states[$$stack[-1][0]]{GOTOS}{$lhs}, $semval ]);
                $$check='';
                next;
            };

#DBG>			$debug & 0x04
#DBG>		and	print STDERR "Forced Error recovery.\n";

            $$check='';

        };

        #Error
            $$errstatus
        or   do {

            $$errstatus = 1;
            &$error($self);
                $$errstatus # if 0, then YYErrok has been called
            or  next;       # so continue parsing

#DBG>			$debug & 0x10
#DBG>		and	do {
#DBG>			print STDERR "**Entering Error recovery.\n";
#DBG>			++$dbgerror;
#DBG>		};

            ++$$nberror;

        };

			$$errstatus == 3	#The next token is not valid: discard it
		and	do {
				$$token eq ''	# End of input: no hope
			and	do {
#DBG>				$debug & 0x10
#DBG>			and	print STDERR "**At eof: aborting.\n";
				return(undef);
			};

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Dicard invalid token ".&$ShowCurToken.".\n";

			$$token=$$value=undef;
		};

        $$errstatus=3;

		while(	  @$stack
			  and (		not exists($$states[$$stack[-1][0]]{ACTIONS})
			        or  not exists($$states[$$stack[-1][0]]{ACTIONS}{error})
					or	$$states[$$stack[-1][0]]{ACTIONS}{error} <= 0)) {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Pop state $$stack[-1][0].\n";

			pop(@$stack);
		}

			@$stack
		or	do {

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**No state left on stack: aborting.\n";

			return(undef);
		};

		#shift the error token

#DBG>			$debug & 0x10
#DBG>		and	print STDERR "**Shift \$error token and go to state ".
#DBG>						 $$states[$$stack[-1][0]]{ACTIONS}{error}.
#DBG>						 ".\n";

		push(@$stack, [ $$states[$$stack[-1][0]]{ACTIONS}{error}, undef ]);

    }

    #never reached
	croak("Error in driver logic. Please, report it as a BUG");

}#_Parse
#DO NOT remove comment

1;

}
#End of include--------------------------------------------------




sub new {
        my($class)=shift;
        ref($class)
    and $class=ref($class);

    my($self)=$class->SUPER::new( yyversion => '1.05',
                                  yystates =>
[
	{#State 0
		ACTIONS => {
			'ID' => 23,
			'p_typemap' => 3,
			'OPSPECIAL' => 28,
			'COMMENT' => 4,
			"class" => 6,
			'RAW_CODE' => 30,
			"const" => 8,
			"int" => 32,
			'p_module' => 13,
			'p_package' => 36,
			'p_loadplugin' => 37,
			"short" => 15,
			'p_file' => 38,
			"unsigned" => 39,
			'p_name' => 17,
			'p_include' => 18,
			"long" => 19,
			"char" => 22
		},
		GOTOS => {
			'perc_loadplugin' => 24,
			'class_name' => 1,
			'top_list' => 2,
			'nconsttype' => 27,
			'perc_package' => 26,
			'function' => 25,
			'special_block_start' => 29,
			'perc_name' => 5,
			'class_decl' => 31,
			'typemap' => 7,
			'decorate_class' => 9,
			'special_block' => 10,
			'perc_module' => 33,
			'type_name' => 11,
			'perc_file' => 35,
			'basic_type' => 34,
			'template' => 12,
			'decorate_function' => 14,
			'top' => 16,
			'function_decl' => 40,
			'perc_include' => 41,
			'directive' => 42,
			'type' => 20,
			'class' => 21,
			'raw' => 43
		}
	},
	{#State 1
		ACTIONS => {
			'OPANG' => 44
		},
		DEFAULT => -78
	},
	{#State 2
		ACTIONS => {
			'ID' => 23,
			'' => 45,
			'p_typemap' => 3,
			'OPSPECIAL' => 28,
			'COMMENT' => 4,
			"class" => 6,
			'RAW_CODE' => 30,
			"const" => 8,
			"int" => 32,
			'p_module' => 13,
			'p_package' => 36,
			'p_loadplugin' => 37,
			"short" => 15,
			'p_file' => 38,
			"unsigned" => 39,
			'p_name' => 17,
			'p_include' => 18,
			"long" => 19,
			"char" => 22
		},
		GOTOS => {
			'perc_loadplugin' => 24,
			'class_name' => 1,
			'function' => 25,
			'perc_package' => 26,
			'nconsttype' => 27,
			'special_block_start' => 29,
			'perc_name' => 5,
			'class_decl' => 31,
			'typemap' => 7,
			'decorate_class' => 9,
			'special_block' => 10,
			'perc_module' => 33,
			'type_name' => 11,
			'perc_file' => 35,
			'basic_type' => 34,
			'template' => 12,
			'decorate_function' => 14,
			'top' => 46,
			'function_decl' => 40,
			'perc_include' => 41,
			'directive' => 42,
			'type' => 20,
			'class' => 21,
			'raw' => 43
		}
	},
	{#State 3
		ACTIONS => {
			'OPCURLY' => 47
		}
	},
	{#State 4
		DEFAULT => -15
	},
	{#State 5
		ACTIONS => {
			'ID' => 23,
			"class" => 6,
			"short" => 15,
			"const" => 8,
			'p_name' => 17,
			"unsigned" => 39,
			"long" => 19,
			"int" => 32,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 34,
			'function' => 49,
			'nconsttype' => 27,
			'template' => 12,
			'decorate_function' => 14,
			'perc_name' => 5,
			'class_decl' => 31,
			'function_decl' => 40,
			'decorate_class' => 9,
			'type' => 20,
			'class' => 48
		}
	},
	{#State 6
		ACTIONS => {
			'ID' => 50
		}
	},
	{#State 7
		DEFAULT => -12
	},
	{#State 8
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 39,
			"long" => 19,
			"int" => 32,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 34,
			'nconsttype' => 51,
			'template' => 12
		}
	},
	{#State 9
		DEFAULT => -18
	},
	{#State 10
		DEFAULT => -16
	},
	{#State 11
		DEFAULT => -76
	},
	{#State 12
		DEFAULT => -77
	},
	{#State 13
		ACTIONS => {
			'OPCURLY' => 52
		}
	},
	{#State 14
		DEFAULT => -20
	},
	{#State 15
		ACTIONS => {
			"int" => 53
		},
		DEFAULT => -85
	},
	{#State 16
		DEFAULT => -1
	},
	{#State 17
		ACTIONS => {
			'OPCURLY' => 54
		}
	},
	{#State 18
		ACTIONS => {
			'OPCURLY' => 55
		}
	},
	{#State 19
		ACTIONS => {
			"int" => 56
		},
		DEFAULT => -84
	},
	{#State 20
		ACTIONS => {
			'ID' => 57
		}
	},
	{#State 21
		DEFAULT => -4
	},
	{#State 22
		DEFAULT => -82
	},
	{#State 23
		ACTIONS => {
			'DCOLON' => 59
		},
		DEFAULT => -91,
		GOTOS => {
			'class_suffix' => 58
		}
	},
	{#State 24
		ACTIONS => {
			'SEMICOLON' => 60
		}
	},
	{#State 25
		DEFAULT => -6
	},
	{#State 26
		ACTIONS => {
			'SEMICOLON' => 61
		}
	},
	{#State 27
		ACTIONS => {
			'STAR' => 63,
			'AMP' => 62
		},
		DEFAULT => -73
	},
	{#State 28
		DEFAULT => -118
	},
	{#State 29
		ACTIONS => {
			'CLSPECIAL' => 64,
			'line' => 65
		},
		GOTOS => {
			'special_block_end' => 66,
			'lines' => 67
		}
	},
	{#State 30
		DEFAULT => -14
	},
	{#State 31
		DEFAULT => -17
	},
	{#State 32
		DEFAULT => -83
	},
	{#State 33
		ACTIONS => {
			'SEMICOLON' => 68
		}
	},
	{#State 34
		DEFAULT => -79
	},
	{#State 35
		ACTIONS => {
			'SEMICOLON' => 69
		}
	},
	{#State 36
		ACTIONS => {
			'OPCURLY' => 70
		}
	},
	{#State 37
		ACTIONS => {
			'OPCURLY' => 71
		}
	},
	{#State 38
		ACTIONS => {
			'OPCURLY' => 72
		}
	},
	{#State 39
		ACTIONS => {
			"short" => 15,
			"long" => 19,
			"int" => 32,
			"char" => 22
		},
		DEFAULT => -80,
		GOTOS => {
			'basic_type' => 73
		}
	},
	{#State 40
		DEFAULT => -19
	},
	{#State 41
		ACTIONS => {
			'SEMICOLON' => 74
		}
	},
	{#State 42
		DEFAULT => -5
	},
	{#State 43
		DEFAULT => -3
	},
	{#State 44
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 39,
			"const" => 8,
			"long" => 19,
			"int" => 32,
			"char" => 22
		},
		GOTOS => {
			'type_list' => 76,
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 34,
			'nconsttype' => 27,
			'template' => 12,
			'type' => 75
		}
	},
	{#State 45
		DEFAULT => 0
	},
	{#State 46
		DEFAULT => -2
	},
	{#State 47
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 39,
			"const" => 8,
			"long" => 19,
			"int" => 32,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 34,
			'nconsttype' => 27,
			'template' => 12,
			'type' => 77
		}
	},
	{#State 48
		DEFAULT => -23
	},
	{#State 49
		DEFAULT => -24
	},
	{#State 50
		ACTIONS => {
			'COLON' => 79
		},
		DEFAULT => -32,
		GOTOS => {
			'base_classes' => 78
		}
	},
	{#State 51
		ACTIONS => {
			'STAR' => 63,
			'AMP' => 62
		},
		DEFAULT => -72
	},
	{#State 52
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 80
		}
	},
	{#State 53
		DEFAULT => -87
	},
	{#State 54
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 81
		}
	},
	{#State 55
		ACTIONS => {
			'ID' => 83,
			'DASH' => 84
		},
		GOTOS => {
			'file_name' => 82
		}
	},
	{#State 56
		DEFAULT => -86
	},
	{#State 57
		ACTIONS => {
			'OPPAR' => 85
		}
	},
	{#State 58
		ACTIONS => {
			'DCOLON' => 86
		},
		DEFAULT => -92
	},
	{#State 59
		ACTIONS => {
			'ID' => 87
		}
	},
	{#State 60
		DEFAULT => -10
	},
	{#State 61
		DEFAULT => -8
	},
	{#State 62
		DEFAULT => -75
	},
	{#State 63
		DEFAULT => -74
	},
	{#State 64
		DEFAULT => -119
	},
	{#State 65
		DEFAULT => -120
	},
	{#State 66
		DEFAULT => -117
	},
	{#State 67
		ACTIONS => {
			'CLSPECIAL' => 64,
			'line' => 88
		},
		GOTOS => {
			'special_block_end' => 89
		}
	},
	{#State 68
		DEFAULT => -7
	},
	{#State 69
		DEFAULT => -9
	},
	{#State 70
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 90
		}
	},
	{#State 71
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 91
		}
	},
	{#State 72
		ACTIONS => {
			'ID' => 83,
			'DASH' => 84
		},
		GOTOS => {
			'file_name' => 92
		}
	},
	{#State 73
		DEFAULT => -81
	},
	{#State 74
		DEFAULT => -11
	},
	{#State 75
		DEFAULT => -89
	},
	{#State 76
		ACTIONS => {
			'CLANG' => 93,
			'COMMA' => 94
		}
	},
	{#State 77
		ACTIONS => {
			'CLCURLY' => 95
		}
	},
	{#State 78
		ACTIONS => {
			'OPCURLY' => 96,
			'COMMA' => 97
		}
	},
	{#State 79
		ACTIONS => {
			"protected" => 101,
			"private" => 100,
			"public" => 98
		},
		GOTOS => {
			'base_class' => 99
		}
	},
	{#State 80
		ACTIONS => {
			'CLCURLY' => 102
		}
	},
	{#State 81
		ACTIONS => {
			'CLCURLY' => 103
		}
	},
	{#State 82
		ACTIONS => {
			'CLCURLY' => 104
		}
	},
	{#State 83
		ACTIONS => {
			'DOT' => 106,
			'SLASH' => 105
		}
	},
	{#State 84
		DEFAULT => -95
	},
	{#State 85
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"const" => 8,
			"unsigned" => 39,
			"long" => 19,
			"int" => 32,
			"char" => 22
		},
		DEFAULT => -100,
		GOTOS => {
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 34,
			'nconsttype' => 27,
			'template' => 12,
			'arg_list' => 108,
			'argument' => 109,
			'type' => 107
		}
	},
	{#State 86
		ACTIONS => {
			'ID' => 110
		}
	},
	{#State 87
		DEFAULT => -93
	},
	{#State 88
		DEFAULT => -121
	},
	{#State 89
		DEFAULT => -116
	},
	{#State 90
		ACTIONS => {
			'CLCURLY' => 111
		}
	},
	{#State 91
		ACTIONS => {
			'CLCURLY' => 112
		}
	},
	{#State 92
		ACTIONS => {
			'CLCURLY' => 113
		}
	},
	{#State 93
		DEFAULT => -88
	},
	{#State 94
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 39,
			"const" => 8,
			"long" => 19,
			"int" => 32,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 34,
			'nconsttype' => 27,
			'template' => 12,
			'type' => 114
		}
	},
	{#State 95
		ACTIONS => {
			'OPCURLY' => 115
		}
	},
	{#State 96
		ACTIONS => {
			'ID' => 128,
			'p_typemap' => 3,
			'OPSPECIAL' => 28,
			"virtual" => 130,
			'COMMENT' => 4,
			"class_static" => 116,
			"package_static" => 131,
			"public" => 118,
			'RAW_CODE' => 30,
			"const" => 8,
			"int" => 32,
			"private" => 121,
			'CLCURLY' => 136,
			"short" => 15,
			"unsigned" => 39,
			'p_name' => 17,
			'TILDE' => 124,
			"protected" => 125,
			"long" => 19,
			"char" => 22
		},
		GOTOS => {
			'decorate_method' => 129,
			'class_name' => 1,
			'nconsttype' => 27,
			'static' => 117,
			'special_block_start' => 29,
			'perc_name' => 119,
			'typemap' => 120,
			'class_body_element' => 132,
			'class_body_list' => 134,
			'method' => 133,
			'special_block' => 10,
			'access_specifier' => 122,
			'type_name' => 11,
			'ctor' => 123,
			'basic_type' => 34,
			'template' => 12,
			'virtual' => 135,
			'function_decl' => 137,
			'type' => 20,
			'dtor' => 126,
			'raw' => 138,
			'method_decl' => 127
		}
	},
	{#State 97
		ACTIONS => {
			"protected" => 101,
			"private" => 100,
			"public" => 98
		},
		GOTOS => {
			'base_class' => 139
		}
	},
	{#State 98
		ACTIONS => {
			'ID' => 23,
			'p_name' => 17
		},
		GOTOS => {
			'perc_name' => 141,
			'class_name' => 140,
			'class_name_rename' => 142
		}
	},
	{#State 99
		DEFAULT => -30
	},
	{#State 100
		ACTIONS => {
			'ID' => 23,
			'p_name' => 17
		},
		GOTOS => {
			'perc_name' => 141,
			'class_name' => 140,
			'class_name_rename' => 143
		}
	},
	{#State 101
		ACTIONS => {
			'ID' => 23,
			'p_name' => 17
		},
		GOTOS => {
			'perc_name' => 141,
			'class_name' => 140,
			'class_name_rename' => 144
		}
	},
	{#State 102
		DEFAULT => -65
	},
	{#State 103
		DEFAULT => -63
	},
	{#State 104
		DEFAULT => -68
	},
	{#State 105
		ACTIONS => {
			'ID' => 83,
			'DASH' => 84
		},
		GOTOS => {
			'file_name' => 145
		}
	},
	{#State 106
		ACTIONS => {
			'ID' => 146
		}
	},
	{#State 107
		ACTIONS => {
			'ID' => 148,
			'p_length' => 147
		}
	},
	{#State 108
		ACTIONS => {
			'CLPAR' => 149,
			'COMMA' => 150
		}
	},
	{#State 109
		DEFAULT => -98
	},
	{#State 110
		DEFAULT => -94
	},
	{#State 111
		DEFAULT => -64
	},
	{#State 112
		DEFAULT => -67
	},
	{#State 113
		DEFAULT => -66
	},
	{#State 114
		DEFAULT => -90
	},
	{#State 115
		ACTIONS => {
			'ID' => 151
		}
	},
	{#State 116
		DEFAULT => -54
	},
	{#State 117
		ACTIONS => {
			'ID' => 128,
			"virtual" => 130,
			"class_static" => 116,
			"package_static" => 131,
			"short" => 15,
			"unsigned" => 39,
			"const" => 8,
			'p_name' => 17,
			'TILDE' => 124,
			"long" => 19,
			"int" => 32,
			"char" => 22
		},
		GOTOS => {
			'decorate_method' => 129,
			'type_name' => 11,
			'class_name' => 1,
			'ctor' => 123,
			'basic_type' => 34,
			'nconsttype' => 27,
			'template' => 12,
			'static' => 117,
			'virtual' => 135,
			'perc_name' => 119,
			'function_decl' => 137,
			'method' => 152,
			'type' => 20,
			'dtor' => 126,
			'method_decl' => 127
		}
	},
	{#State 118
		ACTIONS => {
			'COLON' => 153
		}
	},
	{#State 119
		ACTIONS => {
			'ID' => 128,
			"virtual" => 130,
			"class_static" => 116,
			"package_static" => 131,
			"short" => 15,
			"unsigned" => 39,
			"const" => 8,
			'p_name' => 17,
			'TILDE' => 124,
			"long" => 19,
			"int" => 32,
			"char" => 22
		},
		GOTOS => {
			'decorate_method' => 129,
			'type_name' => 11,
			'class_name' => 1,
			'ctor' => 123,
			'basic_type' => 34,
			'nconsttype' => 27,
			'template' => 12,
			'static' => 117,
			'virtual' => 135,
			'perc_name' => 119,
			'function_decl' => 137,
			'method' => 154,
			'type' => 20,
			'dtor' => 126,
			'method_decl' => 127
		}
	},
	{#State 120
		DEFAULT => -42
	},
	{#State 121
		ACTIONS => {
			'COLON' => 155
		}
	},
	{#State 122
		DEFAULT => -43
	},
	{#State 123
		DEFAULT => -48
	},
	{#State 124
		ACTIONS => {
			'ID' => 156
		}
	},
	{#State 125
		ACTIONS => {
			'COLON' => 157
		}
	},
	{#State 126
		DEFAULT => -49
	},
	{#State 127
		DEFAULT => -21
	},
	{#State 128
		ACTIONS => {
			'DCOLON' => 59,
			'OPPAR' => 158
		},
		DEFAULT => -91,
		GOTOS => {
			'class_suffix' => 58
		}
	},
	{#State 129
		DEFAULT => -22
	},
	{#State 130
		DEFAULT => -52
	},
	{#State 131
		DEFAULT => -53
	},
	{#State 132
		DEFAULT => -38
	},
	{#State 133
		DEFAULT => -40
	},
	{#State 134
		ACTIONS => {
			'ID' => 128,
			'p_typemap' => 3,
			'OPSPECIAL' => 28,
			"virtual" => 130,
			'COMMENT' => 4,
			"class_static" => 116,
			"package_static" => 131,
			"public" => 118,
			'RAW_CODE' => 30,
			"const" => 8,
			"int" => 32,
			"private" => 121,
			'CLCURLY' => 160,
			"short" => 15,
			"unsigned" => 39,
			'p_name' => 17,
			'TILDE' => 124,
			"protected" => 125,
			"long" => 19,
			"char" => 22
		},
		GOTOS => {
			'decorate_method' => 129,
			'class_name' => 1,
			'nconsttype' => 27,
			'static' => 117,
			'special_block_start' => 29,
			'perc_name' => 119,
			'typemap' => 120,
			'class_body_element' => 159,
			'method' => 133,
			'special_block' => 10,
			'access_specifier' => 122,
			'type_name' => 11,
			'ctor' => 123,
			'basic_type' => 34,
			'template' => 12,
			'virtual' => 135,
			'function_decl' => 137,
			'type' => 20,
			'dtor' => 126,
			'raw' => 138,
			'method_decl' => 127
		}
	},
	{#State 135
		ACTIONS => {
			'ID' => 128,
			"virtual" => 130,
			"class_static" => 116,
			"package_static" => 131,
			"short" => 15,
			"unsigned" => 39,
			"const" => 8,
			'p_name' => 17,
			'TILDE' => 124,
			"long" => 19,
			"int" => 32,
			"char" => 22
		},
		GOTOS => {
			'decorate_method' => 129,
			'type_name' => 11,
			'class_name' => 1,
			'ctor' => 123,
			'basic_type' => 34,
			'nconsttype' => 27,
			'template' => 12,
			'static' => 117,
			'virtual' => 135,
			'perc_name' => 119,
			'function_decl' => 137,
			'method' => 161,
			'type' => 20,
			'dtor' => 126,
			'method_decl' => 127
		}
	},
	{#State 136
		ACTIONS => {
			'SEMICOLON' => 162
		}
	},
	{#State 137
		DEFAULT => -47
	},
	{#State 138
		DEFAULT => -41
	},
	{#State 139
		DEFAULT => -31
	},
	{#State 140
		DEFAULT => -36
	},
	{#State 141
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 163
		}
	},
	{#State 142
		DEFAULT => -33
	},
	{#State 143
		DEFAULT => -35
	},
	{#State 144
		DEFAULT => -34
	},
	{#State 145
		DEFAULT => -97
	},
	{#State 146
		DEFAULT => -96
	},
	{#State 147
		ACTIONS => {
			'OPCURLY' => 164
		}
	},
	{#State 148
		ACTIONS => {
			'EQUAL' => 165
		},
		DEFAULT => -103
	},
	{#State 149
		ACTIONS => {
			"const" => 166
		},
		DEFAULT => -51,
		GOTOS => {
			'const' => 167
		}
	},
	{#State 150
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 39,
			"const" => 8,
			"long" => 19,
			"int" => 32,
			"char" => 22
		},
		GOTOS => {
			'argument' => 168,
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 34,
			'nconsttype' => 27,
			'template' => 12,
			'type' => 107
		}
	},
	{#State 151
		ACTIONS => {
			'CLCURLY' => 169
		}
	},
	{#State 152
		DEFAULT => -26
	},
	{#State 153
		DEFAULT => -44
	},
	{#State 154
		DEFAULT => -25
	},
	{#State 155
		DEFAULT => -46
	},
	{#State 156
		ACTIONS => {
			'OPPAR' => 170
		}
	},
	{#State 157
		DEFAULT => -45
	},
	{#State 158
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"const" => 8,
			"unsigned" => 39,
			"long" => 19,
			"int" => 32,
			"char" => 22
		},
		DEFAULT => -100,
		GOTOS => {
			'type_name' => 11,
			'class_name' => 1,
			'basic_type' => 34,
			'nconsttype' => 27,
			'template' => 12,
			'arg_list' => 171,
			'argument' => 109,
			'type' => 107
		}
	},
	{#State 159
		DEFAULT => -39
	},
	{#State 160
		ACTIONS => {
			'SEMICOLON' => 172
		}
	},
	{#State 161
		DEFAULT => -27
	},
	{#State 162
		DEFAULT => -29
	},
	{#State 163
		DEFAULT => -37
	},
	{#State 164
		ACTIONS => {
			'ID' => 173
		}
	},
	{#State 165
		ACTIONS => {
			'ID' => 23,
			'INTEGER' => 175,
			'QUOTED_STRING' => 177,
			'DASH' => 179,
			'FLOAT' => 178
		},
		GOTOS => {
			'class_name' => 174,
			'value' => 176
		}
	},
	{#State 166
		DEFAULT => -50
	},
	{#State 167
		DEFAULT => -59,
		GOTOS => {
			'metadata' => 180
		}
	},
	{#State 168
		DEFAULT => -99
	},
	{#State 169
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		DEFAULT => -115,
		GOTOS => {
			'special_blocks' => 182,
			'special_block' => 181,
			'special_block_start' => 29
		}
	},
	{#State 170
		ACTIONS => {
			'CLPAR' => 183
		}
	},
	{#State 171
		ACTIONS => {
			'CLPAR' => 184,
			'COMMA' => 150
		}
	},
	{#State 172
		DEFAULT => -28
	},
	{#State 173
		ACTIONS => {
			'CLCURLY' => 185
		}
	},
	{#State 174
		ACTIONS => {
			'OPPAR' => 186
		},
		DEFAULT => -108
	},
	{#State 175
		DEFAULT => -104
	},
	{#State 176
		DEFAULT => -102
	},
	{#State 177
		DEFAULT => -107
	},
	{#State 178
		DEFAULT => -106
	},
	{#State 179
		ACTIONS => {
			'INTEGER' => 187
		}
	},
	{#State 180
		ACTIONS => {
			'p_code' => 193,
			'p_cleanup' => 189,
			'SEMICOLON' => 194,
			'p_postcall' => 190
		},
		GOTOS => {
			'_metadata' => 191,
			'perc_postcall' => 192,
			'perc_code' => 188,
			'perc_cleanup' => 195
		}
	},
	{#State 181
		DEFAULT => -113
	},
	{#State 182
		ACTIONS => {
			'OPSPECIAL' => 28,
			'SEMICOLON' => 197
		},
		GOTOS => {
			'special_block' => 196,
			'special_block_start' => 29
		}
	},
	{#State 183
		DEFAULT => -59,
		GOTOS => {
			'metadata' => 198
		}
	},
	{#State 184
		DEFAULT => -59,
		GOTOS => {
			'metadata' => 199
		}
	},
	{#State 185
		DEFAULT => -101
	},
	{#State 186
		ACTIONS => {
			'ID' => 23,
			'INTEGER' => 175,
			'QUOTED_STRING' => 177,
			'DASH' => 179,
			'FLOAT' => 178
		},
		DEFAULT => -112,
		GOTOS => {
			'class_name' => 174,
			'value_list' => 200,
			'value' => 201
		}
	},
	{#State 187
		DEFAULT => -105
	},
	{#State 188
		DEFAULT => -60
	},
	{#State 189
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		GOTOS => {
			'special_block' => 202,
			'special_block_start' => 29
		}
	},
	{#State 190
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		GOTOS => {
			'special_block' => 203,
			'special_block_start' => 29
		}
	},
	{#State 191
		DEFAULT => -58
	},
	{#State 192
		DEFAULT => -62
	},
	{#State 193
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		GOTOS => {
			'special_block' => 204,
			'special_block_start' => 29
		}
	},
	{#State 194
		DEFAULT => -55
	},
	{#State 195
		DEFAULT => -61
	},
	{#State 196
		DEFAULT => -114
	},
	{#State 197
		DEFAULT => -13
	},
	{#State 198
		ACTIONS => {
			'p_code' => 193,
			'p_cleanup' => 189,
			'SEMICOLON' => 205,
			'p_postcall' => 190
		},
		GOTOS => {
			'_metadata' => 191,
			'perc_postcall' => 192,
			'perc_code' => 188,
			'perc_cleanup' => 195
		}
	},
	{#State 199
		ACTIONS => {
			'p_code' => 193,
			'p_cleanup' => 189,
			'SEMICOLON' => 206,
			'p_postcall' => 190
		},
		GOTOS => {
			'_metadata' => 191,
			'perc_postcall' => 192,
			'perc_code' => 188,
			'perc_cleanup' => 195
		}
	},
	{#State 200
		ACTIONS => {
			'CLPAR' => 207,
			'COMMA' => 208
		}
	},
	{#State 201
		DEFAULT => -110
	},
	{#State 202
		DEFAULT => -70
	},
	{#State 203
		DEFAULT => -71
	},
	{#State 204
		DEFAULT => -69
	},
	{#State 205
		DEFAULT => -57
	},
	{#State 206
		DEFAULT => -56
	},
	{#State 207
		DEFAULT => -109
	},
	{#State 208
		ACTIONS => {
			'ID' => 23,
			'INTEGER' => 175,
			'QUOTED_STRING' => 177,
			'DASH' => 179,
			'FLOAT' => 178
		},
		GOTOS => {
			'class_name' => 174,
			'value' => 209
		}
	},
	{#State 209
		DEFAULT => -111
	}
],
                                  yyrules  =>
[
	[#Rule 0
		 '$start', 2, undef
	],
	[#Rule 1
		 'top_list', 1,
sub
#line 21 "XSP.yp"
{ $_[1] ? [ $_[1] ] : [] }
	],
	[#Rule 2
		 'top_list', 2,
sub
#line 22 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 3
		 'top', 1, undef
	],
	[#Rule 4
		 'top', 1, undef
	],
	[#Rule 5
		 'top', 1, undef
	],
	[#Rule 6
		 'top', 1,
sub
#line 26 "XSP.yp"
{ $_[1]->resolve_typemaps; $_[1] }
	],
	[#Rule 7
		 'directive', 2,
sub
#line 29 "XSP.yp"
{ ExtUtils::XSpp::Node::Module->new( module => $_[1] ) }
	],
	[#Rule 8
		 'directive', 2,
sub
#line 31 "XSP.yp"
{ ExtUtils::XSpp::Node::Package->new( perl_name => $_[1] ) }
	],
	[#Rule 9
		 'directive', 2,
sub
#line 33 "XSP.yp"
{ ExtUtils::XSpp::Node::File->new( file => $_[1] ) }
	],
	[#Rule 10
		 'directive', 2,
sub
#line 35 "XSP.yp"
{ $_[0]->YYData->{PARSER}->load_plugin( $_[1] ); undef }
	],
	[#Rule 11
		 'directive', 2,
sub
#line 37 "XSP.yp"
{ $_[0]->YYData->{PARSER}->include_file( $_[1] ); undef }
	],
	[#Rule 12
		 'directive', 1,
sub
#line 38 "XSP.yp"
{ }
	],
	[#Rule 13
		 'typemap', 9,
sub
#line 42 "XSP.yp"
{ my $package = "ExtUtils::XSpp::Typemap::" . $_[6];
                      my $type = $_[3]; my $c = 0;
                      my %args = map { "arg" . ++$c => $_ }
                                 map { join( '', @$_ ) }
                                     @{$_[8] || []};
                      my $tm = $package->new( type => $type, %args );
                      ExtUtils::XSpp::Typemap::add_typemap_for_type( $type, $tm );
                      undef }
	],
	[#Rule 14
		 'raw', 1,
sub
#line 51 "XSP.yp"
{ add_data_raw( $_[0], [ $_[1] ] ) }
	],
	[#Rule 15
		 'raw', 1,
sub
#line 52 "XSP.yp"
{ add_data_comment( $_[0], $_[1] ) }
	],
	[#Rule 16
		 'raw', 1,
sub
#line 53 "XSP.yp"
{ add_data_raw( $_[0], [ @{$_[1]} ] ) }
	],
	[#Rule 17
		 'class', 1, undef
	],
	[#Rule 18
		 'class', 1, undef
	],
	[#Rule 19
		 'function', 1, undef
	],
	[#Rule 20
		 'function', 1, undef
	],
	[#Rule 21
		 'method', 1, undef
	],
	[#Rule 22
		 'method', 1, undef
	],
	[#Rule 23
		 'decorate_class', 2,
sub
#line 59 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 24
		 'decorate_function', 2,
sub
#line 60 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 25
		 'decorate_method', 2,
sub
#line 61 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 26
		 'decorate_method', 2,
sub
#line 62 "XSP.yp"
{ $_[2]->set_static( $_[1] ); $_[2] }
	],
	[#Rule 27
		 'decorate_method', 2,
sub
#line 63 "XSP.yp"
{ $_[2]->set_virtual( 1 ); $_[2] }
	],
	[#Rule 28
		 'class_decl', 7,
sub
#line 66 "XSP.yp"
{ create_class( $_[0], $_[2], $_[3], $_[5] ) }
	],
	[#Rule 29
		 'class_decl', 6,
sub
#line 68 "XSP.yp"
{ create_class( $_[0], $_[2], $_[3], [] ) }
	],
	[#Rule 30
		 'base_classes', 2,
sub
#line 71 "XSP.yp"
{ [ $_[2] ] }
	],
	[#Rule 31
		 'base_classes', 3,
sub
#line 72 "XSP.yp"
{ push @{$_[1]}, $_[3] if $_[3]; $_[1] }
	],
	[#Rule 32
		 'base_classes', 0, undef
	],
	[#Rule 33
		 'base_class', 2,
sub
#line 76 "XSP.yp"
{ $_[2] }
	],
	[#Rule 34
		 'base_class', 2,
sub
#line 77 "XSP.yp"
{ $_[2] }
	],
	[#Rule 35
		 'base_class', 2,
sub
#line 78 "XSP.yp"
{ $_[2] }
	],
	[#Rule 36
		 'class_name_rename', 1,
sub
#line 82 "XSP.yp"
{ create_class( $_[0], $_[1], [], [] ) }
	],
	[#Rule 37
		 'class_name_rename', 2,
sub
#line 83 "XSP.yp"
{ my $klass = create_class( $_[0], $_[2], [], [] );
                             $klass->set_perl_name( $_[1] );
                             $klass
                             }
	],
	[#Rule 38
		 'class_body_list', 1,
sub
#line 91 "XSP.yp"
{ $_[1] ? [ $_[1] ] : [] }
	],
	[#Rule 39
		 'class_body_list', 2,
sub
#line 93 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 40
		 'class_body_element', 1, undef
	],
	[#Rule 41
		 'class_body_element', 1, undef
	],
	[#Rule 42
		 'class_body_element', 1, undef
	],
	[#Rule 43
		 'class_body_element', 1, undef
	],
	[#Rule 44
		 'access_specifier', 2,
sub
#line 99 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 45
		 'access_specifier', 2,
sub
#line 100 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 46
		 'access_specifier', 2,
sub
#line 101 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 47
		 'method_decl', 1,
sub
#line 105 "XSP.yp"
{ my $f = $_[1];
                           my $m = add_data_method
                             ( $_[0],
                               name      => $f->cpp_name,
                               ret_type  => $f->ret_type,
                               arguments => $f->arguments,
                               code      => $f->code,
                               cleanup   => $f->cleanup,
                               postcall  => $f->postcall,
                               );
                           $m
                         }
	],
	[#Rule 48
		 'method_decl', 1, undef
	],
	[#Rule 49
		 'method_decl', 1, undef
	],
	[#Rule 50
		 'const', 1, undef
	],
	[#Rule 51
		 'const', 0, undef
	],
	[#Rule 52
		 'virtual', 1, undef
	],
	[#Rule 53
		 'static', 1, undef
	],
	[#Rule 54
		 'static', 1, undef
	],
	[#Rule 55
		 'function_decl', 8,
sub
#line 130 "XSP.yp"
{ add_data_function( $_[0],
                                         name      => $_[2],
                                         ret_type  => $_[1],
                                         arguments => $_[4],
                                         @{ $_[7] } ) }
	],
	[#Rule 56
		 'ctor', 6,
sub
#line 137 "XSP.yp"
{ add_data_ctor( $_[0], name      => $_[1],
                                            arguments => $_[3],
                                            @{ $_[5] } ) }
	],
	[#Rule 57
		 'dtor', 6,
sub
#line 142 "XSP.yp"
{ add_data_dtor( $_[0], name  => $_[2],
                                            @{ $_[5] },
                                      ) }
	],
	[#Rule 58
		 'metadata', 2,
sub
#line 146 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 59
		 'metadata', 0,
sub
#line 147 "XSP.yp"
{ [] }
	],
	[#Rule 60
		 '_metadata', 1, undef
	],
	[#Rule 61
		 '_metadata', 1, undef
	],
	[#Rule 62
		 '_metadata', 1, undef
	],
	[#Rule 63
		 'perc_name', 4,
sub
#line 155 "XSP.yp"
{ $_[3] }
	],
	[#Rule 64
		 'perc_package', 4,
sub
#line 156 "XSP.yp"
{ $_[3] }
	],
	[#Rule 65
		 'perc_module', 4,
sub
#line 157 "XSP.yp"
{ $_[3] }
	],
	[#Rule 66
		 'perc_file', 4,
sub
#line 158 "XSP.yp"
{ $_[3] }
	],
	[#Rule 67
		 'perc_loadplugin', 4,
sub
#line 159 "XSP.yp"
{ $_[3] }
	],
	[#Rule 68
		 'perc_include', 4,
sub
#line 160 "XSP.yp"
{ $_[3] }
	],
	[#Rule 69
		 'perc_code', 2,
sub
#line 161 "XSP.yp"
{ [ code => $_[2] ] }
	],
	[#Rule 70
		 'perc_cleanup', 2,
sub
#line 162 "XSP.yp"
{ [ cleanup => $_[2] ] }
	],
	[#Rule 71
		 'perc_postcall', 2,
sub
#line 163 "XSP.yp"
{ [ postcall => $_[2] ] }
	],
	[#Rule 72
		 'type', 2,
sub
#line 166 "XSP.yp"
{ make_const( $_[2] ) }
	],
	[#Rule 73
		 'type', 1, undef
	],
	[#Rule 74
		 'nconsttype', 2,
sub
#line 171 "XSP.yp"
{ make_ptr( $_[1] ) }
	],
	[#Rule 75
		 'nconsttype', 2,
sub
#line 172 "XSP.yp"
{ make_ref( $_[1] ) }
	],
	[#Rule 76
		 'nconsttype', 1,
sub
#line 173 "XSP.yp"
{ make_type( $_[1] ) }
	],
	[#Rule 77
		 'nconsttype', 1, undef
	],
	[#Rule 78
		 'type_name', 1, undef
	],
	[#Rule 79
		 'type_name', 1, undef
	],
	[#Rule 80
		 'type_name', 1,
sub
#line 180 "XSP.yp"
{ 'unsigned int' }
	],
	[#Rule 81
		 'type_name', 2,
sub
#line 181 "XSP.yp"
{ 'unsigned' . ' ' . $_[2] }
	],
	[#Rule 82
		 'basic_type', 1, undef
	],
	[#Rule 83
		 'basic_type', 1, undef
	],
	[#Rule 84
		 'basic_type', 1, undef
	],
	[#Rule 85
		 'basic_type', 1, undef
	],
	[#Rule 86
		 'basic_type', 2, undef
	],
	[#Rule 87
		 'basic_type', 2, undef
	],
	[#Rule 88
		 'template', 4,
sub
#line 187 "XSP.yp"
{ make_template( $_[1], $_[3] ) }
	],
	[#Rule 89
		 'type_list', 1,
sub
#line 191 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 90
		 'type_list', 3,
sub
#line 192 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 91
		 'class_name', 1, undef
	],
	[#Rule 92
		 'class_name', 2,
sub
#line 196 "XSP.yp"
{ $_[1] . '::' . $_[2] }
	],
	[#Rule 93
		 'class_suffix', 2,
sub
#line 198 "XSP.yp"
{ $_[2] }
	],
	[#Rule 94
		 'class_suffix', 3,
sub
#line 199 "XSP.yp"
{ $_[1] . '::' . $_[3] }
	],
	[#Rule 95
		 'file_name', 1,
sub
#line 201 "XSP.yp"
{ '-' }
	],
	[#Rule 96
		 'file_name', 3,
sub
#line 202 "XSP.yp"
{ $_[1] . '.' . $_[3] }
	],
	[#Rule 97
		 'file_name', 3,
sub
#line 203 "XSP.yp"
{ $_[1] . '/' . $_[3] }
	],
	[#Rule 98
		 'arg_list', 1,
sub
#line 205 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 99
		 'arg_list', 3,
sub
#line 206 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 100
		 'arg_list', 0, undef
	],
	[#Rule 101
		 'argument', 5,
sub
#line 210 "XSP.yp"
{ make_argument( @_[0, 1], "length($_[4])" ) }
	],
	[#Rule 102
		 'argument', 4,
sub
#line 212 "XSP.yp"
{ make_argument( @_[0, 1, 2, 4] ) }
	],
	[#Rule 103
		 'argument', 2,
sub
#line 213 "XSP.yp"
{ make_argument( @_ ) }
	],
	[#Rule 104
		 'value', 1, undef
	],
	[#Rule 105
		 'value', 2,
sub
#line 216 "XSP.yp"
{ '-' . $_[2] }
	],
	[#Rule 106
		 'value', 1, undef
	],
	[#Rule 107
		 'value', 1, undef
	],
	[#Rule 108
		 'value', 1, undef
	],
	[#Rule 109
		 'value', 4,
sub
#line 220 "XSP.yp"
{ "$_[1]($_[3])" }
	],
	[#Rule 110
		 'value_list', 1, undef
	],
	[#Rule 111
		 'value_list', 3,
sub
#line 225 "XSP.yp"
{ "$_[1], $_[2]" }
	],
	[#Rule 112
		 'value_list', 0,
sub
#line 226 "XSP.yp"
{ "" }
	],
	[#Rule 113
		 'special_blocks', 1,
sub
#line 230 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 114
		 'special_blocks', 2,
sub
#line 232 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 115
		 'special_blocks', 0, undef
	],
	[#Rule 116
		 'special_block', 3,
sub
#line 236 "XSP.yp"
{ $_[2] }
	],
	[#Rule 117
		 'special_block', 2,
sub
#line 238 "XSP.yp"
{ [] }
	],
	[#Rule 118
		 'special_block_start', 1,
sub
#line 241 "XSP.yp"
{ push_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 119
		 'special_block_end', 1,
sub
#line 243 "XSP.yp"
{ pop_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 120
		 'lines', 1,
sub
#line 245 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 121
		 'lines', 2,
sub
#line 246 "XSP.yp"
{ push @{$_[1]}, $_[2]; $_[1] }
	]
],
                                  @_);
    bless($self,$class);
}

#line 248 "XSP.yp"


use ExtUtils::XSpp::Lexer;
1;
