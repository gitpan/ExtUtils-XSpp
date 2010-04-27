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
			'COMMENT' => 5,
			'p_exceptionmap' => 31,
			"class" => 7,
			'RAW_CODE' => 32,
			"const" => 9,
			"int" => 34,
			'p_module' => 14,
			'p_loadplugin' => 39,
			'p_package' => 38,
			"short" => 15,
			'p_file' => 41,
			"unsigned" => 42,
			'p_name' => 17,
			'p_include' => 18,
			"long" => 19,
			"char" => 22
		},
		GOTOS => {
			'perc_loadplugin' => 24,
			'class_name' => 1,
			'top_list' => 2,
			'perc_package' => 27,
			'function' => 26,
			'nconsttype' => 25,
			'looks_like_function' => 4,
			'exceptionmap' => 29,
			'special_block_start' => 30,
			'perc_name' => 6,
			'class_decl' => 33,
			'typemap' => 8,
			'decorate_class' => 10,
			'special_block' => 11,
			'perc_module' => 35,
			'type_name' => 12,
			'perc_file' => 37,
			'basic_type' => 36,
			'template' => 13,
			'looks_like_renamed_function' => 40,
			'top' => 16,
			'function_decl' => 43,
			'perc_include' => 44,
			'directive' => 45,
			'type' => 20,
			'class' => 21,
			'raw' => 46
		}
	},
	{#State 1
		ACTIONS => {
			'OPANG' => 47
		},
		DEFAULT => -99
	},
	{#State 2
		ACTIONS => {
			'ID' => 23,
			'' => 48,
			'p_typemap' => 3,
			'OPSPECIAL' => 28,
			'COMMENT' => 5,
			'p_exceptionmap' => 31,
			"class" => 7,
			'RAW_CODE' => 32,
			"const" => 9,
			"int" => 34,
			'p_module' => 14,
			'p_package' => 38,
			'p_loadplugin' => 39,
			"short" => 15,
			'p_file' => 41,
			"unsigned" => 42,
			'p_name' => 17,
			'p_include' => 18,
			"long" => 19,
			"char" => 22
		},
		GOTOS => {
			'perc_loadplugin' => 24,
			'class_name' => 1,
			'function' => 26,
			'perc_package' => 27,
			'nconsttype' => 25,
			'looks_like_function' => 4,
			'exceptionmap' => 29,
			'special_block_start' => 30,
			'perc_name' => 6,
			'class_decl' => 33,
			'typemap' => 8,
			'decorate_class' => 10,
			'special_block' => 11,
			'perc_module' => 35,
			'type_name' => 12,
			'perc_file' => 37,
			'basic_type' => 36,
			'template' => 13,
			'looks_like_renamed_function' => 40,
			'top' => 49,
			'function_decl' => 43,
			'perc_include' => 44,
			'directive' => 45,
			'type' => 20,
			'class' => 21,
			'raw' => 46
		}
	},
	{#State 3
		ACTIONS => {
			'OPCURLY' => 50
		}
	},
	{#State 4
		DEFAULT => -61
	},
	{#State 5
		DEFAULT => -22
	},
	{#State 6
		ACTIONS => {
			'ID' => 23,
			"class" => 7,
			"short" => 15,
			"const" => 9,
			"unsigned" => 42,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'looks_like_function' => 51,
			'class_decl' => 52,
			'type' => 20
		}
	},
	{#State 7
		ACTIONS => {
			'ID' => 53
		}
	},
	{#State 8
		DEFAULT => -12
	},
	{#State 9
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 54,
			'template' => 13
		}
	},
	{#State 10
		ACTIONS => {
			'SEMICOLON' => 55
		}
	},
	{#State 11
		DEFAULT => -23
	},
	{#State 12
		DEFAULT => -97
	},
	{#State 13
		DEFAULT => -98
	},
	{#State 14
		ACTIONS => {
			'OPCURLY' => 56
		}
	},
	{#State 15
		ACTIONS => {
			"int" => 57
		},
		DEFAULT => -106
	},
	{#State 16
		DEFAULT => -1
	},
	{#State 17
		ACTIONS => {
			'OPCURLY' => 58
		}
	},
	{#State 18
		ACTIONS => {
			'OPCURLY' => 59
		}
	},
	{#State 19
		ACTIONS => {
			"int" => 60
		},
		DEFAULT => -105
	},
	{#State 20
		ACTIONS => {
			'ID' => 61
		}
	},
	{#State 21
		DEFAULT => -4
	},
	{#State 22
		DEFAULT => -103
	},
	{#State 23
		ACTIONS => {
			'DCOLON' => 63
		},
		DEFAULT => -112,
		GOTOS => {
			'class_suffix' => 62
		}
	},
	{#State 24
		ACTIONS => {
			'SEMICOLON' => 64
		}
	},
	{#State 25
		ACTIONS => {
			'STAR' => 66,
			'AMP' => 65
		},
		DEFAULT => -94
	},
	{#State 26
		DEFAULT => -6
	},
	{#State 27
		ACTIONS => {
			'SEMICOLON' => 67
		}
	},
	{#State 28
		DEFAULT => -144
	},
	{#State 29
		DEFAULT => -13
	},
	{#State 30
		ACTIONS => {
			'CLSPECIAL' => 68,
			'line' => 69
		},
		GOTOS => {
			'special_block_end' => 70,
			'lines' => 71
		}
	},
	{#State 31
		ACTIONS => {
			'OPCURLY' => 72
		}
	},
	{#State 32
		DEFAULT => -21
	},
	{#State 33
		ACTIONS => {
			'SEMICOLON' => 73
		}
	},
	{#State 34
		DEFAULT => -104
	},
	{#State 35
		ACTIONS => {
			'SEMICOLON' => 74
		}
	},
	{#State 36
		DEFAULT => -100
	},
	{#State 37
		ACTIONS => {
			'SEMICOLON' => 75
		}
	},
	{#State 38
		ACTIONS => {
			'OPCURLY' => 76
		}
	},
	{#State 39
		ACTIONS => {
			'OPCURLY' => 77
		}
	},
	{#State 40
		DEFAULT => -69,
		GOTOS => {
			'function_metadata' => 78
		}
	},
	{#State 41
		ACTIONS => {
			'OPCURLY' => 79
		}
	},
	{#State 42
		ACTIONS => {
			"short" => 15,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		DEFAULT => -101,
		GOTOS => {
			'basic_type' => 80
		}
	},
	{#State 43
		ACTIONS => {
			'SEMICOLON' => 81
		}
	},
	{#State 44
		ACTIONS => {
			'SEMICOLON' => 82
		}
	},
	{#State 45
		DEFAULT => -5
	},
	{#State 46
		DEFAULT => -3
	},
	{#State 47
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_list' => 84,
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'type' => 83
		}
	},
	{#State 48
		DEFAULT => 0
	},
	{#State 49
		DEFAULT => -2
	},
	{#State 50
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'type' => 85
		}
	},
	{#State 51
		DEFAULT => -62
	},
	{#State 52
		DEFAULT => -28
	},
	{#State 53
		ACTIONS => {
			'COLON' => 87
		},
		DEFAULT => -32,
		GOTOS => {
			'base_classes' => 86
		}
	},
	{#State 54
		ACTIONS => {
			'STAR' => 66,
			'AMP' => 65
		},
		DEFAULT => -93
	},
	{#State 55
		DEFAULT => -25
	},
	{#State 56
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 88
		}
	},
	{#State 57
		DEFAULT => -108
	},
	{#State 58
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 89
		}
	},
	{#State 59
		ACTIONS => {
			'ID' => 91,
			'DASH' => 92
		},
		GOTOS => {
			'file_name' => 90
		}
	},
	{#State 60
		DEFAULT => -107
	},
	{#State 61
		ACTIONS => {
			'OPPAR' => 93
		}
	},
	{#State 62
		ACTIONS => {
			'DCOLON' => 94
		},
		DEFAULT => -113
	},
	{#State 63
		ACTIONS => {
			'ID' => 95
		}
	},
	{#State 64
		DEFAULT => -10
	},
	{#State 65
		DEFAULT => -96
	},
	{#State 66
		DEFAULT => -95
	},
	{#State 67
		DEFAULT => -8
	},
	{#State 68
		DEFAULT => -145
	},
	{#State 69
		DEFAULT => -146
	},
	{#State 70
		DEFAULT => -143
	},
	{#State 71
		ACTIONS => {
			'CLSPECIAL' => 68,
			'line' => 96
		},
		GOTOS => {
			'special_block_end' => 97
		}
	},
	{#State 72
		ACTIONS => {
			'ID' => 98
		}
	},
	{#State 73
		DEFAULT => -24
	},
	{#State 74
		DEFAULT => -7
	},
	{#State 75
		DEFAULT => -9
	},
	{#State 76
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 99
		}
	},
	{#State 77
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 100
		}
	},
	{#State 78
		ACTIONS => {
			'p_code' => 106,
			'p_cleanup' => 102,
			'p_catch' => 109,
			'p_postcall' => 104
		},
		DEFAULT => -63,
		GOTOS => {
			'perc_postcall' => 105,
			'perc_code' => 101,
			'perc_cleanup' => 107,
			'perc_catch' => 103,
			'_function_metadata' => 108
		}
	},
	{#State 79
		ACTIONS => {
			'ID' => 91,
			'DASH' => 92
		},
		GOTOS => {
			'file_name' => 110
		}
	},
	{#State 80
		DEFAULT => -102
	},
	{#State 81
		DEFAULT => -26
	},
	{#State 82
		DEFAULT => -11
	},
	{#State 83
		DEFAULT => -110
	},
	{#State 84
		ACTIONS => {
			'CLANG' => 111,
			'COMMA' => 112
		}
	},
	{#State 85
		ACTIONS => {
			'CLCURLY' => 113
		}
	},
	{#State 86
		ACTIONS => {
			'COMMA' => 115
		},
		DEFAULT => -39,
		GOTOS => {
			'class_metadata' => 114
		}
	},
	{#State 87
		ACTIONS => {
			"protected" => 119,
			"private" => 118,
			"public" => 116
		},
		GOTOS => {
			'base_class' => 117
		}
	},
	{#State 88
		ACTIONS => {
			'CLCURLY' => 120
		}
	},
	{#State 89
		ACTIONS => {
			'CLCURLY' => 121
		}
	},
	{#State 90
		ACTIONS => {
			'CLCURLY' => 122
		}
	},
	{#State 91
		ACTIONS => {
			'DOT' => 124,
			'SLASH' => 123
		}
	},
	{#State 92
		DEFAULT => -118
	},
	{#State 93
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"const" => 9,
			"unsigned" => 42,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		DEFAULT => -123,
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'arg_list' => 126,
			'argument' => 127,
			'type' => 125
		}
	},
	{#State 94
		ACTIONS => {
			'ID' => 128
		}
	},
	{#State 95
		DEFAULT => -116
	},
	{#State 96
		DEFAULT => -147
	},
	{#State 97
		DEFAULT => -142
	},
	{#State 98
		ACTIONS => {
			'CLCURLY' => 129
		}
	},
	{#State 99
		ACTIONS => {
			'CLCURLY' => 130
		}
	},
	{#State 100
		ACTIONS => {
			'CLCURLY' => 131
		}
	},
	{#State 101
		DEFAULT => -76
	},
	{#State 102
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		GOTOS => {
			'special_block' => 132,
			'special_block_start' => 30
		}
	},
	{#State 103
		DEFAULT => -79
	},
	{#State 104
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		GOTOS => {
			'special_block' => 133,
			'special_block_start' => 30
		}
	},
	{#State 105
		DEFAULT => -78
	},
	{#State 106
		ACTIONS => {
			'OPSPECIAL' => 28
		},
		GOTOS => {
			'special_block' => 134,
			'special_block_start' => 30
		}
	},
	{#State 107
		DEFAULT => -77
	},
	{#State 108
		DEFAULT => -68
	},
	{#State 109
		ACTIONS => {
			'OPCURLY' => 135
		}
	},
	{#State 110
		ACTIONS => {
			'CLCURLY' => 136
		}
	},
	{#State 111
		DEFAULT => -109
	},
	{#State 112
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'type' => 137
		}
	},
	{#State 113
		ACTIONS => {
			'OPCURLY' => 138
		}
	},
	{#State 114
		ACTIONS => {
			'OPCURLY' => 139,
			'p_catch' => 109
		},
		GOTOS => {
			'perc_catch' => 140
		}
	},
	{#State 115
		ACTIONS => {
			"protected" => 119,
			"private" => 118,
			"public" => 116
		},
		GOTOS => {
			'base_class' => 141
		}
	},
	{#State 116
		ACTIONS => {
			'ID' => 23,
			'p_name' => 17
		},
		GOTOS => {
			'perc_name' => 143,
			'class_name' => 142,
			'class_name_rename' => 144
		}
	},
	{#State 117
		DEFAULT => -30
	},
	{#State 118
		ACTIONS => {
			'ID' => 23,
			'p_name' => 17
		},
		GOTOS => {
			'perc_name' => 143,
			'class_name' => 142,
			'class_name_rename' => 145
		}
	},
	{#State 119
		ACTIONS => {
			'ID' => 23,
			'p_name' => 17
		},
		GOTOS => {
			'perc_name' => 143,
			'class_name' => 142,
			'class_name_rename' => 146
		}
	},
	{#State 120
		DEFAULT => -82
	},
	{#State 121
		DEFAULT => -80
	},
	{#State 122
		DEFAULT => -85
	},
	{#State 123
		ACTIONS => {
			'ID' => 91,
			'DASH' => 92
		},
		GOTOS => {
			'file_name' => 147
		}
	},
	{#State 124
		ACTIONS => {
			'ID' => 148
		}
	},
	{#State 125
		ACTIONS => {
			'ID' => 150,
			'p_length' => 149
		}
	},
	{#State 126
		ACTIONS => {
			'CLPAR' => 151,
			'COMMA' => 152
		}
	},
	{#State 127
		DEFAULT => -121
	},
	{#State 128
		DEFAULT => -117
	},
	{#State 129
		ACTIONS => {
			'OPCURLY' => 153
		}
	},
	{#State 130
		DEFAULT => -81
	},
	{#State 131
		DEFAULT => -84
	},
	{#State 132
		DEFAULT => -87
	},
	{#State 133
		DEFAULT => -88
	},
	{#State 134
		DEFAULT => -86
	},
	{#State 135
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 154,
			'class_name_list' => 155
		}
	},
	{#State 136
		DEFAULT => -83
	},
	{#State 137
		DEFAULT => -111
	},
	{#State 138
		ACTIONS => {
			'ID' => 156
		}
	},
	{#State 139
		DEFAULT => -40,
		GOTOS => {
			'class_body_list' => 157
		}
	},
	{#State 140
		DEFAULT => -38
	},
	{#State 141
		DEFAULT => -31
	},
	{#State 142
		DEFAULT => -36
	},
	{#State 143
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 158
		}
	},
	{#State 144
		DEFAULT => -33
	},
	{#State 145
		DEFAULT => -35
	},
	{#State 146
		DEFAULT => -34
	},
	{#State 147
		DEFAULT => -120
	},
	{#State 148
		DEFAULT => -119
	},
	{#State 149
		ACTIONS => {
			'OPCURLY' => 159
		}
	},
	{#State 150
		ACTIONS => {
			'EQUAL' => 160
		},
		DEFAULT => -126
	},
	{#State 151
		ACTIONS => {
			"const" => 161
		},
		DEFAULT => -55,
		GOTOS => {
			'const' => 162
		}
	},
	{#State 152
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'argument' => 163,
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'type' => 125
		}
	},
	{#State 153
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 165,
			'class_name' => 164,
			'basic_type' => 36
		}
	},
	{#State 154
		DEFAULT => -114
	},
	{#State 155
		ACTIONS => {
			'COMMA' => 166,
			'CLCURLY' => 167
		}
	},
	{#State 156
		ACTIONS => {
			'CLCURLY' => 168
		}
	},
	{#State 157
		ACTIONS => {
			'ID' => 183,
			'p_typemap' => 3,
			'OPSPECIAL' => 28,
			"virtual" => 184,
			'COMMENT' => 5,
			"class_static" => 170,
			"package_static" => 185,
			"public" => 171,
			'p_exceptionmap' => 31,
			'RAW_CODE' => 32,
			"const" => 9,
			"static" => 189,
			"int" => 34,
			"private" => 176,
			'CLCURLY' => 191,
			"short" => 15,
			"unsigned" => 42,
			'p_name' => 17,
			'TILDE' => 179,
			"protected" => 180,
			"long" => 19,
			"char" => 22
		},
		GOTOS => {
			'class_name' => 1,
			'nconsttype' => 25,
			'looks_like_function' => 4,
			'static' => 169,
			'exceptionmap' => 186,
			'special_block_start' => 30,
			'perc_name' => 172,
			'typemap' => 173,
			'class_body_element' => 187,
			'method' => 188,
			'vmethod' => 174,
			'nmethod' => 175,
			'special_block' => 11,
			'access_specifier' => 177,
			'type_name' => 12,
			'ctor' => 178,
			'basic_type' => 36,
			'template' => 13,
			'virtual' => 190,
			'looks_like_renamed_function' => 192,
			'_vmethod' => 193,
			'type' => 20,
			'dtor' => 181,
			'raw' => 194,
			'method_decl' => 182
		}
	},
	{#State 158
		DEFAULT => -37
	},
	{#State 159
		ACTIONS => {
			'ID' => 195
		}
	},
	{#State 160
		ACTIONS => {
			'ID' => 23,
			'INTEGER' => 198,
			'QUOTED_STRING' => 200,
			'DASH' => 202,
			'FLOAT' => 201
		},
		GOTOS => {
			'class_name' => 196,
			'value' => 199,
			'expression' => 197
		}
	},
	{#State 161
		DEFAULT => -54
	},
	{#State 162
		DEFAULT => -60
	},
	{#State 163
		DEFAULT => -122
	},
	{#State 164
		DEFAULT => -99
	},
	{#State 165
		ACTIONS => {
			'CLCURLY' => 203
		}
	},
	{#State 166
		ACTIONS => {
			'ID' => 23
		},
		GOTOS => {
			'class_name' => 204
		}
	},
	{#State 167
		DEFAULT => -89
	},
	{#State 168
		ACTIONS => {
			'OPCURLY' => 205,
			'OPSPECIAL' => 28
		},
		DEFAULT => -141,
		GOTOS => {
			'special_blocks' => 207,
			'special_block' => 206,
			'special_block_start' => 30
		}
	},
	{#State 169
		ACTIONS => {
			'ID' => 23,
			"class_static" => 170,
			"package_static" => 185,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			'p_name' => 17,
			"long" => 19,
			"static" => 189,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'looks_like_function' => 4,
			'static' => 169,
			'perc_name' => 208,
			'looks_like_renamed_function' => 192,
			'nmethod' => 209,
			'type' => 20
		}
	},
	{#State 170
		DEFAULT => -58
	},
	{#State 171
		ACTIONS => {
			'COLON' => 210
		}
	},
	{#State 172
		ACTIONS => {
			'ID' => 183,
			"virtual" => 184,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			'p_name' => 17,
			'TILDE' => 179,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'ctor' => 213,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'looks_like_function' => 51,
			'virtual' => 190,
			'perc_name' => 211,
			'_vmethod' => 193,
			'dtor' => 214,
			'vmethod' => 212,
			'type' => 20
		}
	},
	{#State 173
		DEFAULT => -44
	},
	{#State 174
		DEFAULT => -51
	},
	{#State 175
		DEFAULT => -50
	},
	{#State 176
		ACTIONS => {
			'COLON' => 215
		}
	},
	{#State 177
		DEFAULT => -46
	},
	{#State 178
		DEFAULT => -52
	},
	{#State 179
		ACTIONS => {
			'ID' => 216
		}
	},
	{#State 180
		ACTIONS => {
			'COLON' => 217
		}
	},
	{#State 181
		DEFAULT => -53
	},
	{#State 182
		ACTIONS => {
			'SEMICOLON' => 218
		}
	},
	{#State 183
		ACTIONS => {
			'DCOLON' => 63,
			'OPPAR' => 219
		},
		DEFAULT => -112,
		GOTOS => {
			'class_suffix' => 62
		}
	},
	{#State 184
		DEFAULT => -56
	},
	{#State 185
		DEFAULT => -57
	},
	{#State 186
		DEFAULT => -45
	},
	{#State 187
		DEFAULT => -41
	},
	{#State 188
		DEFAULT => -42
	},
	{#State 189
		DEFAULT => -59
	},
	{#State 190
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'looks_like_function' => 220,
			'type' => 20
		}
	},
	{#State 191
		DEFAULT => -29
	},
	{#State 192
		DEFAULT => -69,
		GOTOS => {
			'function_metadata' => 221
		}
	},
	{#State 193
		DEFAULT => -72
	},
	{#State 194
		DEFAULT => -43
	},
	{#State 195
		ACTIONS => {
			'CLCURLY' => 222
		}
	},
	{#State 196
		ACTIONS => {
			'OPPAR' => 223
		},
		DEFAULT => -131
	},
	{#State 197
		DEFAULT => -125
	},
	{#State 198
		DEFAULT => -127
	},
	{#State 199
		ACTIONS => {
			'AMP' => 224,
			'PIPE' => 225
		},
		DEFAULT => -136
	},
	{#State 200
		DEFAULT => -130
	},
	{#State 201
		DEFAULT => -129
	},
	{#State 202
		ACTIONS => {
			'INTEGER' => 226
		}
	},
	{#State 203
		ACTIONS => {
			'OPCURLY' => 227
		}
	},
	{#State 204
		DEFAULT => -115
	},
	{#State 205
		ACTIONS => {
			'p_any' => 228
		},
		GOTOS => {
			'perc_any_arg' => 229,
			'perc_any_args' => 230
		}
	},
	{#State 206
		DEFAULT => -139
	},
	{#State 207
		ACTIONS => {
			'OPSPECIAL' => 28,
			'SEMICOLON' => 232
		},
		GOTOS => {
			'special_block' => 231,
			'special_block_start' => 30
		}
	},
	{#State 208
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"unsigned" => 42,
			"const" => 9,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'looks_like_function' => 51,
			'type' => 20
		}
	},
	{#State 209
		DEFAULT => -71
	},
	{#State 210
		DEFAULT => -47
	},
	{#State 211
		ACTIONS => {
			'ID' => 233,
			'TILDE' => 179,
			'p_name' => 17,
			"virtual" => 184
		},
		GOTOS => {
			'perc_name' => 211,
			'ctor' => 213,
			'_vmethod' => 193,
			'dtor' => 214,
			'vmethod' => 212,
			'virtual' => 190
		}
	},
	{#State 212
		DEFAULT => -73
	},
	{#State 213
		DEFAULT => -65
	},
	{#State 214
		DEFAULT => -67
	},
	{#State 215
		DEFAULT => -49
	},
	{#State 216
		ACTIONS => {
			'OPPAR' => 234
		}
	},
	{#State 217
		DEFAULT => -48
	},
	{#State 218
		DEFAULT => -27
	},
	{#State 219
		ACTIONS => {
			'ID' => 23,
			"short" => 15,
			"const" => 9,
			"unsigned" => 42,
			"long" => 19,
			"int" => 34,
			"char" => 22
		},
		DEFAULT => -123,
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 36,
			'nconsttype' => 25,
			'template' => 13,
			'arg_list' => 235,
			'argument' => 127,
			'type' => 125
		}
	},
	{#State 220
		ACTIONS => {
			'EQUAL' => 236
		},
		DEFAULT => -69,
		GOTOS => {
			'function_metadata' => 237
		}
	},
	{#State 221
		ACTIONS => {
			'p_code' => 106,
			'p_cleanup' => 102,
			'p_catch' => 109,
			'p_postcall' => 104
		},
		DEFAULT => -70,
		GOTOS => {
			'perc_postcall' => 105,
			'perc_code' => 101,
			'perc_cleanup' => 107,
			'perc_catch' => 103,
			'_function_metadata' => 108
		}
	},
	{#State 222
		DEFAULT => -124
	},
	{#State 223
		ACTIONS => {
			'ID' => 23,
			'INTEGER' => 198,
			'QUOTED_STRING' => 200,
			'DASH' => 202,
			'FLOAT' => 201
		},
		DEFAULT => -135,
		GOTOS => {
			'class_name' => 196,
			'value_list' => 238,
			'value' => 239
		}
	},
	{#State 224
		ACTIONS => {
			'ID' => 23,
			'INTEGER' => 198,
			'QUOTED_STRING' => 200,
			'DASH' => 202,
			'FLOAT' => 201
		},
		GOTOS => {
			'class_name' => 196,
			'value' => 240
		}
	},
	{#State 225
		ACTIONS => {
			'ID' => 23,
			'INTEGER' => 198,
			'QUOTED_STRING' => 200,
			'DASH' => 202,
			'FLOAT' => 201
		},
		GOTOS => {
			'class_name' => 196,
			'value' => 241
		}
	},
	{#State 226
		DEFAULT => -128
	},
	{#State 227
		ACTIONS => {
			'ID' => 242
		}
	},
	{#State 228
		DEFAULT => -19,
		GOTOS => {
			'mixed_blocks' => 243
		}
	},
	{#State 229
		DEFAULT => -90
	},
	{#State 230
		ACTIONS => {
			'p_any' => 228,
			'CLCURLY' => 245
		},
		GOTOS => {
			'perc_any_arg' => 244
		}
	},
	{#State 231
		DEFAULT => -140
	},
	{#State 232
		DEFAULT => -14
	},
	{#State 233
		ACTIONS => {
			'OPPAR' => 219
		}
	},
	{#State 234
		ACTIONS => {
			'CLPAR' => 246
		}
	},
	{#State 235
		ACTIONS => {
			'CLPAR' => 247,
			'COMMA' => 152
		}
	},
	{#State 236
		ACTIONS => {
			'INTEGER' => 248
		}
	},
	{#State 237
		ACTIONS => {
			'p_code' => 106,
			'p_cleanup' => 102,
			'p_catch' => 109,
			'p_postcall' => 104
		},
		DEFAULT => -74,
		GOTOS => {
			'perc_postcall' => 105,
			'perc_code' => 101,
			'perc_cleanup' => 107,
			'perc_catch' => 103,
			'_function_metadata' => 108
		}
	},
	{#State 238
		ACTIONS => {
			'CLPAR' => 249,
			'COMMA' => 250
		}
	},
	{#State 239
		DEFAULT => -133
	},
	{#State 240
		DEFAULT => -137
	},
	{#State 241
		DEFAULT => -138
	},
	{#State 242
		ACTIONS => {
			'CLCURLY' => 251
		}
	},
	{#State 243
		ACTIONS => {
			'OPCURLY' => 252,
			'OPSPECIAL' => 28,
			'SEMICOLON' => 254
		},
		GOTOS => {
			'simple_block' => 255,
			'special_block' => 253,
			'special_block_start' => 30
		}
	},
	{#State 244
		DEFAULT => -91
	},
	{#State 245
		ACTIONS => {
			'SEMICOLON' => 256
		}
	},
	{#State 246
		DEFAULT => -69,
		GOTOS => {
			'function_metadata' => 257
		}
	},
	{#State 247
		DEFAULT => -69,
		GOTOS => {
			'function_metadata' => 258
		}
	},
	{#State 248
		DEFAULT => -69,
		GOTOS => {
			'function_metadata' => 259
		}
	},
	{#State 249
		DEFAULT => -132
	},
	{#State 250
		ACTIONS => {
			'ID' => 23,
			'INTEGER' => 198,
			'QUOTED_STRING' => 200,
			'DASH' => 202,
			'FLOAT' => 201
		},
		GOTOS => {
			'class_name' => 196,
			'value' => 260
		}
	},
	{#State 251
		DEFAULT => -19,
		GOTOS => {
			'mixed_blocks' => 261
		}
	},
	{#State 252
		ACTIONS => {
			'ID' => 262
		}
	},
	{#State 253
		DEFAULT => -17
	},
	{#State 254
		DEFAULT => -92
	},
	{#State 255
		DEFAULT => -18
	},
	{#State 256
		DEFAULT => -15
	},
	{#State 257
		ACTIONS => {
			'p_code' => 106,
			'p_cleanup' => 102,
			'p_catch' => 109,
			'p_postcall' => 104
		},
		DEFAULT => -66,
		GOTOS => {
			'perc_postcall' => 105,
			'perc_code' => 101,
			'perc_cleanup' => 107,
			'perc_catch' => 103,
			'_function_metadata' => 108
		}
	},
	{#State 258
		ACTIONS => {
			'p_code' => 106,
			'p_cleanup' => 102,
			'p_catch' => 109,
			'p_postcall' => 104
		},
		DEFAULT => -64,
		GOTOS => {
			'perc_postcall' => 105,
			'perc_code' => 101,
			'perc_cleanup' => 107,
			'perc_catch' => 103,
			'_function_metadata' => 108
		}
	},
	{#State 259
		ACTIONS => {
			'p_code' => 106,
			'p_cleanup' => 102,
			'p_catch' => 109,
			'p_postcall' => 104
		},
		DEFAULT => -75,
		GOTOS => {
			'perc_postcall' => 105,
			'perc_code' => 101,
			'perc_cleanup' => 107,
			'perc_catch' => 103,
			'_function_metadata' => 108
		}
	},
	{#State 260
		DEFAULT => -134
	},
	{#State 261
		ACTIONS => {
			'OPCURLY' => 252,
			'OPSPECIAL' => 28,
			'SEMICOLON' => 263
		},
		GOTOS => {
			'simple_block' => 255,
			'special_block' => 253,
			'special_block_start' => 30
		}
	},
	{#State 262
		ACTIONS => {
			'CLCURLY' => 264
		}
	},
	{#State 263
		DEFAULT => -16
	},
	{#State 264
		DEFAULT => -20
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
{ $_[1]->resolve_typemaps; $_[1]->resolve_exceptions; $_[1] }
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
		 'directive', 1,
sub
#line 39 "XSP.yp"
{ }
	],
	[#Rule 14
		 'typemap', 9,
sub
#line 43 "XSP.yp"
{ my $package = "ExtUtils::XSpp::Typemap::" . $_[6];
                      my $type = $_[3]; my $c = 0;
                      my %args = map { "arg" . ++$c => $_ }
                                 map { join( '', @$_ ) }
                                     @{$_[8] || []};
                      my $tm = $package->new( type => $type, %args );
                      ExtUtils::XSpp::Typemap::add_typemap_for_type( $type, $tm );
                      undef }
	],
	[#Rule 15
		 'typemap', 11,
sub
#line 53 "XSP.yp"
{ my $package = "ExtUtils::XSpp::Typemap::" . $_[6];
                      my $type = $_[3];
                      # this assumes that there will be at most one named
                      # block for each directive inside the typemap
                      for( my $i = 1; $i <= $#{$_[9]}; $i += 2 ) {
                          $_[9][$i] = join "\n", @{$_[9][$i][0]}
                              if ref( $_[9][$i] ) && ref( $_[9][$i][0] );
                      }
                      my $tm = $package->new( type => $type, @{$_[9]} );
                      ExtUtils::XSpp::Typemap::add_typemap_for_type( $type, $tm );
                      undef }
	],
	[#Rule 16
		 'exceptionmap', 12,
sub
#line 69 "XSP.yp"
{ my $package = "ExtUtils::XSpp::Exception::" . $_[9];
                      my $type = make_type($_[6]); my $c = 0;
                      my %args = map { "arg" . ++$c => $_ }
                                 map { join( "\n", @$_ ) }
                                     @{$_[11] || []};
                      my $e = $package->new( name => $_[3], type => $type, %args );
                      ExtUtils::XSpp::Exception->add_exception( $e );
                      undef }
	],
	[#Rule 17
		 'mixed_blocks', 2,
sub
#line 79 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 18
		 'mixed_blocks', 2,
sub
#line 81 "XSP.yp"
{ [ @{$_[1]}, [ $_[2] ] ] }
	],
	[#Rule 19
		 'mixed_blocks', 0,
sub
#line 82 "XSP.yp"
{ [] }
	],
	[#Rule 20
		 'simple_block', 3,
sub
#line 85 "XSP.yp"
{ $_[2] }
	],
	[#Rule 21
		 'raw', 1,
sub
#line 87 "XSP.yp"
{ add_data_raw( $_[0], [ $_[1] ] ) }
	],
	[#Rule 22
		 'raw', 1,
sub
#line 88 "XSP.yp"
{ add_data_comment( $_[0], $_[1] ) }
	],
	[#Rule 23
		 'raw', 1,
sub
#line 89 "XSP.yp"
{ add_data_raw( $_[0], [ @{$_[1]} ] ) }
	],
	[#Rule 24
		 'class', 2, undef
	],
	[#Rule 25
		 'class', 2, undef
	],
	[#Rule 26
		 'function', 2, undef
	],
	[#Rule 27
		 'method', 2, undef
	],
	[#Rule 28
		 'decorate_class', 2,
sub
#line 96 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 29
		 'class_decl', 7,
sub
#line 99 "XSP.yp"
{ create_class( $_[0], $_[2], $_[3], $_[4], $_[6] ) }
	],
	[#Rule 30
		 'base_classes', 2,
sub
#line 102 "XSP.yp"
{ [ $_[2] ] }
	],
	[#Rule 31
		 'base_classes', 3,
sub
#line 103 "XSP.yp"
{ push @{$_[1]}, $_[3] if $_[3]; $_[1] }
	],
	[#Rule 32
		 'base_classes', 0, undef
	],
	[#Rule 33
		 'base_class', 2,
sub
#line 107 "XSP.yp"
{ $_[2] }
	],
	[#Rule 34
		 'base_class', 2,
sub
#line 108 "XSP.yp"
{ $_[2] }
	],
	[#Rule 35
		 'base_class', 2,
sub
#line 109 "XSP.yp"
{ $_[2] }
	],
	[#Rule 36
		 'class_name_rename', 1,
sub
#line 113 "XSP.yp"
{ create_class( $_[0], $_[1], [], [] ) }
	],
	[#Rule 37
		 'class_name_rename', 2,
sub
#line 114 "XSP.yp"
{ my $klass = create_class( $_[0], $_[2], [], [] );
                             $klass->set_perl_name( $_[1] );
                             $klass
                             }
	],
	[#Rule 38
		 'class_metadata', 2,
sub
#line 120 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 39
		 'class_metadata', 0,
sub
#line 121 "XSP.yp"
{ [] }
	],
	[#Rule 40
		 'class_body_list', 0,
sub
#line 125 "XSP.yp"
{ [] }
	],
	[#Rule 41
		 'class_body_list', 2,
sub
#line 127 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 42
		 'class_body_element', 1, undef
	],
	[#Rule 43
		 'class_body_element', 1, undef
	],
	[#Rule 44
		 'class_body_element', 1, undef
	],
	[#Rule 45
		 'class_body_element', 1, undef
	],
	[#Rule 46
		 'class_body_element', 1, undef
	],
	[#Rule 47
		 'access_specifier', 2,
sub
#line 133 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 48
		 'access_specifier', 2,
sub
#line 134 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 49
		 'access_specifier', 2,
sub
#line 135 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 50
		 'method_decl', 1, undef
	],
	[#Rule 51
		 'method_decl', 1, undef
	],
	[#Rule 52
		 'method_decl', 1, undef
	],
	[#Rule 53
		 'method_decl', 1, undef
	],
	[#Rule 54
		 'const', 1,
sub
#line 140 "XSP.yp"
{ 1 }
	],
	[#Rule 55
		 'const', 0,
sub
#line 141 "XSP.yp"
{ 0 }
	],
	[#Rule 56
		 'virtual', 1, undef
	],
	[#Rule 57
		 'static', 1, undef
	],
	[#Rule 58
		 'static', 1, undef
	],
	[#Rule 59
		 'static', 1,
sub
#line 147 "XSP.yp"
{ 'package_static' }
	],
	[#Rule 60
		 'looks_like_function', 6,
sub
#line 152 "XSP.yp"
{
              return { ret_type  => $_[1],
                       name      => $_[2],
                       arguments => $_[4],
                       const     => $_[6],
                       };
          }
	],
	[#Rule 61
		 'looks_like_renamed_function', 1, undef
	],
	[#Rule 62
		 'looks_like_renamed_function', 2,
sub
#line 163 "XSP.yp"
{ $_[2]->{perl_name} = $_[1]; $_[2] }
	],
	[#Rule 63
		 'function_decl', 2,
sub
#line 166 "XSP.yp"
{ add_data_function( $_[0],
                                         name      => $_[1]->{name},
                                         perl_name => $_[1]->{perl_name},
                                         ret_type  => $_[1]->{ret_type},
                                         arguments => $_[1]->{arguments},
                                         @{$_[2]} ) }
	],
	[#Rule 64
		 'ctor', 5,
sub
#line 174 "XSP.yp"
{ add_data_ctor( $_[0], name      => $_[1],
                                            arguments => $_[3],
                                            @{ $_[5] } ) }
	],
	[#Rule 65
		 'ctor', 2,
sub
#line 177 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 66
		 'dtor', 5,
sub
#line 180 "XSP.yp"
{ add_data_dtor( $_[0], name  => $_[2],
                                            @{ $_[5] },
                                      ) }
	],
	[#Rule 67
		 'dtor', 2,
sub
#line 183 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 68
		 'function_metadata', 2,
sub
#line 185 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 69
		 'function_metadata', 0,
sub
#line 186 "XSP.yp"
{ [] }
	],
	[#Rule 70
		 'nmethod', 2,
sub
#line 191 "XSP.yp"
{ my $m = add_data_method
                        ( $_[0],
                          name      => $_[1]->{name},
                          perl_name => $_[1]->{perl_name},
                          ret_type  => $_[1]->{ret_type},
                          arguments => $_[1]->{arguments},
                          const     => $_[1]->{const},
                          @{$_[2]},
                          );
            $m
          }
	],
	[#Rule 71
		 'nmethod', 2,
sub
#line 203 "XSP.yp"
{ $_[2]->set_static( $_[1] ); $_[2] }
	],
	[#Rule 72
		 'vmethod', 1, undef
	],
	[#Rule 73
		 'vmethod', 2,
sub
#line 208 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 74
		 '_vmethod', 3,
sub
#line 213 "XSP.yp"
{ my $m = add_data_method
                        ( $_[0],
                          name      => $_[2]->{name},
                          perl_name => $_[2]->{perl_name},
                          ret_type  => $_[2]->{ret_type},
                          arguments => $_[2]->{arguments},
                          const     => $_[2]->{const},
                          @{$_[3]},
                          );
            $m->set_virtual( 1 );
            $m
          }
	],
	[#Rule 75
		 '_vmethod', 5,
sub
#line 226 "XSP.yp"
{ my $m = add_data_method
                        ( $_[0],
                          name      => $_[2]->{name},
                          perl_name => $_[2]->{perl_name},
                          ret_type  => $_[2]->{ret_type},
                          arguments => $_[2]->{arguments},
                          const     => $_[2]->{const},
                          @{$_[5]},
                          );
            die "Invalid pure virtual method" unless $_[4] eq '0';
            $m->set_virtual( 2 );
            $m
          }
	],
	[#Rule 76
		 '_function_metadata', 1, undef
	],
	[#Rule 77
		 '_function_metadata', 1, undef
	],
	[#Rule 78
		 '_function_metadata', 1, undef
	],
	[#Rule 79
		 '_function_metadata', 1, undef
	],
	[#Rule 80
		 'perc_name', 4,
sub
#line 247 "XSP.yp"
{ $_[3] }
	],
	[#Rule 81
		 'perc_package', 4,
sub
#line 248 "XSP.yp"
{ $_[3] }
	],
	[#Rule 82
		 'perc_module', 4,
sub
#line 249 "XSP.yp"
{ $_[3] }
	],
	[#Rule 83
		 'perc_file', 4,
sub
#line 250 "XSP.yp"
{ $_[3] }
	],
	[#Rule 84
		 'perc_loadplugin', 4,
sub
#line 251 "XSP.yp"
{ $_[3] }
	],
	[#Rule 85
		 'perc_include', 4,
sub
#line 252 "XSP.yp"
{ $_[3] }
	],
	[#Rule 86
		 'perc_code', 2,
sub
#line 253 "XSP.yp"
{ [ code => $_[2] ] }
	],
	[#Rule 87
		 'perc_cleanup', 2,
sub
#line 254 "XSP.yp"
{ [ cleanup => $_[2] ] }
	],
	[#Rule 88
		 'perc_postcall', 2,
sub
#line 255 "XSP.yp"
{ [ postcall => $_[2] ] }
	],
	[#Rule 89
		 'perc_catch', 4,
sub
#line 256 "XSP.yp"
{ [ map {(catch => $_)} @{$_[3]} ] }
	],
	[#Rule 90
		 'perc_any_args', 1,
sub
#line 259 "XSP.yp"
{ $_[1] }
	],
	[#Rule 91
		 'perc_any_args', 2,
sub
#line 260 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 92
		 'perc_any_arg', 3,
sub
#line 264 "XSP.yp"
{ [ $_[1] => $_[2] ] }
	],
	[#Rule 93
		 'type', 2,
sub
#line 268 "XSP.yp"
{ make_const( $_[2] ) }
	],
	[#Rule 94
		 'type', 1, undef
	],
	[#Rule 95
		 'nconsttype', 2,
sub
#line 273 "XSP.yp"
{ make_ptr( $_[1] ) }
	],
	[#Rule 96
		 'nconsttype', 2,
sub
#line 274 "XSP.yp"
{ make_ref( $_[1] ) }
	],
	[#Rule 97
		 'nconsttype', 1,
sub
#line 275 "XSP.yp"
{ make_type( $_[1] ) }
	],
	[#Rule 98
		 'nconsttype', 1, undef
	],
	[#Rule 99
		 'type_name', 1, undef
	],
	[#Rule 100
		 'type_name', 1, undef
	],
	[#Rule 101
		 'type_name', 1,
sub
#line 282 "XSP.yp"
{ 'unsigned int' }
	],
	[#Rule 102
		 'type_name', 2,
sub
#line 283 "XSP.yp"
{ 'unsigned' . ' ' . $_[2] }
	],
	[#Rule 103
		 'basic_type', 1, undef
	],
	[#Rule 104
		 'basic_type', 1, undef
	],
	[#Rule 105
		 'basic_type', 1, undef
	],
	[#Rule 106
		 'basic_type', 1, undef
	],
	[#Rule 107
		 'basic_type', 2, undef
	],
	[#Rule 108
		 'basic_type', 2, undef
	],
	[#Rule 109
		 'template', 4,
sub
#line 289 "XSP.yp"
{ make_template( $_[1], $_[3] ) }
	],
	[#Rule 110
		 'type_list', 1,
sub
#line 293 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 111
		 'type_list', 3,
sub
#line 294 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 112
		 'class_name', 1, undef
	],
	[#Rule 113
		 'class_name', 2,
sub
#line 298 "XSP.yp"
{ $_[1] . '::' . $_[2] }
	],
	[#Rule 114
		 'class_name_list', 1,
sub
#line 301 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 115
		 'class_name_list', 3,
sub
#line 302 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 116
		 'class_suffix', 2,
sub
#line 305 "XSP.yp"
{ $_[2] }
	],
	[#Rule 117
		 'class_suffix', 3,
sub
#line 306 "XSP.yp"
{ $_[1] . '::' . $_[3] }
	],
	[#Rule 118
		 'file_name', 1,
sub
#line 308 "XSP.yp"
{ '-' }
	],
	[#Rule 119
		 'file_name', 3,
sub
#line 309 "XSP.yp"
{ $_[1] . '.' . $_[3] }
	],
	[#Rule 120
		 'file_name', 3,
sub
#line 310 "XSP.yp"
{ $_[1] . '/' . $_[3] }
	],
	[#Rule 121
		 'arg_list', 1,
sub
#line 312 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 122
		 'arg_list', 3,
sub
#line 313 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 123
		 'arg_list', 0, undef
	],
	[#Rule 124
		 'argument', 5,
sub
#line 317 "XSP.yp"
{ make_argument( @_[0, 1], "length($_[4])" ) }
	],
	[#Rule 125
		 'argument', 4,
sub
#line 319 "XSP.yp"
{ make_argument( @_[0, 1, 2, 4] ) }
	],
	[#Rule 126
		 'argument', 2,
sub
#line 320 "XSP.yp"
{ make_argument( @_ ) }
	],
	[#Rule 127
		 'value', 1, undef
	],
	[#Rule 128
		 'value', 2,
sub
#line 323 "XSP.yp"
{ '-' . $_[2] }
	],
	[#Rule 129
		 'value', 1, undef
	],
	[#Rule 130
		 'value', 1, undef
	],
	[#Rule 131
		 'value', 1, undef
	],
	[#Rule 132
		 'value', 4,
sub
#line 327 "XSP.yp"
{ "$_[1]($_[3])" }
	],
	[#Rule 133
		 'value_list', 1, undef
	],
	[#Rule 134
		 'value_list', 3,
sub
#line 332 "XSP.yp"
{ "$_[1], $_[2]" }
	],
	[#Rule 135
		 'value_list', 0,
sub
#line 333 "XSP.yp"
{ "" }
	],
	[#Rule 136
		 'expression', 1, undef
	],
	[#Rule 137
		 'expression', 3,
sub
#line 339 "XSP.yp"
{ "$_[1] & $_[3]" }
	],
	[#Rule 138
		 'expression', 3,
sub
#line 341 "XSP.yp"
{ "$_[1] | $_[3]" }
	],
	[#Rule 139
		 'special_blocks', 1,
sub
#line 345 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 140
		 'special_blocks', 2,
sub
#line 347 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 141
		 'special_blocks', 0, undef
	],
	[#Rule 142
		 'special_block', 3,
sub
#line 351 "XSP.yp"
{ $_[2] }
	],
	[#Rule 143
		 'special_block', 2,
sub
#line 353 "XSP.yp"
{ [] }
	],
	[#Rule 144
		 'special_block_start', 1,
sub
#line 356 "XSP.yp"
{ push_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 145
		 'special_block_end', 1,
sub
#line 358 "XSP.yp"
{ pop_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 146
		 'lines', 1,
sub
#line 360 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 147
		 'lines', 2,
sub
#line 361 "XSP.yp"
{ push @{$_[1]}, $_[2]; $_[1] }
	]
],
                                  @_);
    bless($self,$class);
}

#line 363 "XSP.yp"


use ExtUtils::XSpp::Lexer;

1;
