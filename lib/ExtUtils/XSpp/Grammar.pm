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
			'ID' => 25,
			'p_typemap' => 4,
			'p_any' => 3,
			'OPSPECIAL' => 30,
			'COMMENT' => 6,
			'p_exceptionmap' => 33,
			"class" => 8,
			'RAW_CODE' => 34,
			"const" => 10,
			"int" => 37,
			'p_module' => 15,
			'p_package' => 44,
			"enum" => 43,
			'p_loadplugin' => 42,
			'PREPROCESSOR' => 16,
			"short" => 17,
			'p_file' => 46,
			"unsigned" => 47,
			'p_name' => 19,
			'p_include' => 20,
			"long" => 21,
			"char" => 24
		},
		GOTOS => {
			'perc_loadplugin' => 26,
			'class_name' => 1,
			'top_list' => 2,
			'perc_package' => 29,
			'function' => 28,
			'nconsttype' => 27,
			'looks_like_function' => 5,
			'exceptionmap' => 31,
			'special_block_start' => 32,
			'perc_name' => 7,
			'class_decl' => 35,
			'typemap' => 9,
			'enum' => 36,
			'decorate_class' => 11,
			'special_block' => 12,
			'perc_module' => 38,
			'type_name' => 13,
			'perc_file' => 41,
			'perc_any' => 40,
			'basic_type' => 39,
			'template' => 14,
			'looks_like_renamed_function' => 45,
			'top' => 18,
			'function_decl' => 48,
			'perc_include' => 49,
			'directive' => 50,
			'type' => 22,
			'class' => 23,
			'raw' => 51
		}
	},
	{#State 1
		ACTIONS => {
			'OPANG' => 52
		},
		DEFAULT => -121
	},
	{#State 2
		ACTIONS => {
			'ID' => 25,
			'' => 53,
			'p_typemap' => 4,
			'p_any' => 3,
			'OPSPECIAL' => 30,
			'COMMENT' => 6,
			'p_exceptionmap' => 33,
			"class" => 8,
			'RAW_CODE' => 34,
			"const" => 10,
			"int" => 37,
			'p_module' => 15,
			"enum" => 43,
			'p_package' => 44,
			'p_loadplugin' => 42,
			'PREPROCESSOR' => 16,
			"short" => 17,
			'p_file' => 46,
			"unsigned" => 47,
			'p_name' => 19,
			'p_include' => 20,
			"long" => 21,
			"char" => 24
		},
		GOTOS => {
			'perc_loadplugin' => 26,
			'class_name' => 1,
			'function' => 28,
			'perc_package' => 29,
			'nconsttype' => 27,
			'looks_like_function' => 5,
			'exceptionmap' => 31,
			'special_block_start' => 32,
			'perc_name' => 7,
			'class_decl' => 35,
			'typemap' => 9,
			'enum' => 36,
			'decorate_class' => 11,
			'special_block' => 12,
			'perc_module' => 38,
			'type_name' => 13,
			'perc_file' => 41,
			'perc_any' => 40,
			'basic_type' => 39,
			'template' => 14,
			'looks_like_renamed_function' => 45,
			'top' => 54,
			'function_decl' => 48,
			'perc_include' => 49,
			'directive' => 50,
			'type' => 22,
			'class' => 23,
			'raw' => 51
		}
	},
	{#State 3
		ACTIONS => {
			'OPSPECIAL' => 30,
			'OPCURLY' => 55
		},
		DEFAULT => -111,
		GOTOS => {
			'special_block' => 56,
			'special_block_start' => 32
		}
	},
	{#State 4
		ACTIONS => {
			'OPCURLY' => 57
		}
	},
	{#State 5
		DEFAULT => -75
	},
	{#State 6
		DEFAULT => -25
	},
	{#State 7
		ACTIONS => {
			'ID' => 25,
			"class" => 8,
			"short" => 17,
			"const" => 10,
			"unsigned" => 47,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		GOTOS => {
			'type_name' => 13,
			'class_name' => 1,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'looks_like_function' => 58,
			'class_decl' => 59,
			'type' => 22
		}
	},
	{#State 8
		ACTIONS => {
			'ID' => 60
		}
	},
	{#State 9
		DEFAULT => -14
	},
	{#State 10
		ACTIONS => {
			'ID' => 25,
			"short" => 17,
			"unsigned" => 47,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		GOTOS => {
			'type_name' => 13,
			'class_name' => 1,
			'basic_type' => 39,
			'nconsttype' => 61,
			'template' => 14
		}
	},
	{#State 11
		ACTIONS => {
			'SEMICOLON' => 62
		}
	},
	{#State 12
		DEFAULT => -27
	},
	{#State 13
		DEFAULT => -119
	},
	{#State 14
		DEFAULT => -120
	},
	{#State 15
		ACTIONS => {
			'OPCURLY' => 63
		}
	},
	{#State 16
		DEFAULT => -26
	},
	{#State 17
		ACTIONS => {
			"int" => 64
		},
		DEFAULT => -128
	},
	{#State 18
		DEFAULT => -1
	},
	{#State 19
		ACTIONS => {
			'OPCURLY' => 65
		}
	},
	{#State 20
		ACTIONS => {
			'OPCURLY' => 66
		}
	},
	{#State 21
		ACTIONS => {
			"int" => 67
		},
		DEFAULT => -127
	},
	{#State 22
		ACTIONS => {
			'ID' => 68
		}
	},
	{#State 23
		DEFAULT => -4
	},
	{#State 24
		DEFAULT => -125
	},
	{#State 25
		ACTIONS => {
			'DCOLON' => 70
		},
		DEFAULT => -134,
		GOTOS => {
			'class_suffix' => 69
		}
	},
	{#State 26
		ACTIONS => {
			'SEMICOLON' => 71
		}
	},
	{#State 27
		ACTIONS => {
			'STAR' => 73,
			'AMP' => 72
		},
		DEFAULT => -116
	},
	{#State 28
		DEFAULT => -7
	},
	{#State 29
		ACTIONS => {
			'SEMICOLON' => 74
		}
	},
	{#State 30
		DEFAULT => -166
	},
	{#State 31
		DEFAULT => -15
	},
	{#State 32
		ACTIONS => {
			'CLSPECIAL' => 75,
			'line' => 76
		},
		GOTOS => {
			'special_block_end' => 77,
			'lines' => 78
		}
	},
	{#State 33
		ACTIONS => {
			'OPCURLY' => 79
		}
	},
	{#State 34
		DEFAULT => -24
	},
	{#State 35
		ACTIONS => {
			'SEMICOLON' => 80
		}
	},
	{#State 36
		DEFAULT => -6
	},
	{#State 37
		DEFAULT => -126
	},
	{#State 38
		ACTIONS => {
			'SEMICOLON' => 81
		}
	},
	{#State 39
		DEFAULT => -122
	},
	{#State 40
		ACTIONS => {
			'SEMICOLON' => 82
		}
	},
	{#State 41
		ACTIONS => {
			'SEMICOLON' => 83
		}
	},
	{#State 42
		ACTIONS => {
			'OPCURLY' => 84
		}
	},
	{#State 43
		ACTIONS => {
			'ID' => 86,
			'OPCURLY' => 85
		}
	},
	{#State 44
		ACTIONS => {
			'OPCURLY' => 87
		}
	},
	{#State 45
		DEFAULT => -84,
		GOTOS => {
			'function_metadata' => 88
		}
	},
	{#State 46
		ACTIONS => {
			'OPCURLY' => 89
		}
	},
	{#State 47
		ACTIONS => {
			"short" => 17,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		DEFAULT => -123,
		GOTOS => {
			'basic_type' => 90
		}
	},
	{#State 48
		ACTIONS => {
			'SEMICOLON' => 91
		}
	},
	{#State 49
		ACTIONS => {
			'SEMICOLON' => 92
		}
	},
	{#State 50
		DEFAULT => -5
	},
	{#State 51
		DEFAULT => -3
	},
	{#State 52
		ACTIONS => {
			'ID' => 25,
			"short" => 17,
			"unsigned" => 47,
			"const" => 10,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		GOTOS => {
			'type_list' => 94,
			'type_name' => 13,
			'class_name' => 1,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'type' => 93
		}
	},
	{#State 53
		DEFAULT => 0
	},
	{#State 54
		DEFAULT => -2
	},
	{#State 55
		ACTIONS => {
			'ID' => 97,
			'p_any' => 95
		},
		GOTOS => {
			'perc_any_arg' => 96,
			'perc_any_args' => 98
		}
	},
	{#State 56
		DEFAULT => -22,
		GOTOS => {
			'mixed_blocks' => 99
		}
	},
	{#State 57
		ACTIONS => {
			'ID' => 25,
			"short" => 17,
			"unsigned" => 47,
			"const" => 10,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		GOTOS => {
			'type_name' => 13,
			'class_name' => 1,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'type' => 100
		}
	},
	{#State 58
		DEFAULT => -76
	},
	{#State 59
		DEFAULT => -40
	},
	{#State 60
		ACTIONS => {
			'COLON' => 102
		},
		DEFAULT => -44,
		GOTOS => {
			'base_classes' => 101
		}
	},
	{#State 61
		ACTIONS => {
			'STAR' => 73,
			'AMP' => 72
		},
		DEFAULT => -115
	},
	{#State 62
		DEFAULT => -37
	},
	{#State 63
		ACTIONS => {
			'ID' => 25
		},
		GOTOS => {
			'class_name' => 103
		}
	},
	{#State 64
		DEFAULT => -130
	},
	{#State 65
		ACTIONS => {
			'ID' => 25
		},
		GOTOS => {
			'class_name' => 104
		}
	},
	{#State 66
		ACTIONS => {
			'ID' => 106,
			'DASH' => 107
		},
		GOTOS => {
			'file_name' => 105
		}
	},
	{#State 67
		DEFAULT => -129
	},
	{#State 68
		ACTIONS => {
			'OPPAR' => 108
		}
	},
	{#State 69
		ACTIONS => {
			'DCOLON' => 109
		},
		DEFAULT => -135
	},
	{#State 70
		ACTIONS => {
			'ID' => 110
		}
	},
	{#State 71
		DEFAULT => -11
	},
	{#State 72
		DEFAULT => -118
	},
	{#State 73
		DEFAULT => -117
	},
	{#State 74
		DEFAULT => -9
	},
	{#State 75
		DEFAULT => -167
	},
	{#State 76
		DEFAULT => -168
	},
	{#State 77
		DEFAULT => -165
	},
	{#State 78
		ACTIONS => {
			'CLSPECIAL' => 75,
			'line' => 111
		},
		GOTOS => {
			'special_block_end' => 112
		}
	},
	{#State 79
		ACTIONS => {
			'ID' => 113
		}
	},
	{#State 80
		DEFAULT => -36
	},
	{#State 81
		DEFAULT => -8
	},
	{#State 82
		DEFAULT => -13
	},
	{#State 83
		DEFAULT => -10
	},
	{#State 84
		ACTIONS => {
			'ID' => 25
		},
		GOTOS => {
			'class_name' => 114
		}
	},
	{#State 85
		DEFAULT => -30,
		GOTOS => {
			'enum_element_list' => 115
		}
	},
	{#State 86
		ACTIONS => {
			'OPCURLY' => 116
		}
	},
	{#State 87
		ACTIONS => {
			'ID' => 25
		},
		GOTOS => {
			'class_name' => 117
		}
	},
	{#State 88
		ACTIONS => {
			'p_any' => 3,
			'p_alias' => 122,
			'p_code' => 125,
			'p_cleanup' => 119,
			'p_postcall' => 121,
			'p_catch' => 129
		},
		DEFAULT => -77,
		GOTOS => {
			'perc_postcall' => 124,
			'perc_code' => 118,
			'perc_any' => 126,
			'perc_cleanup' => 127,
			'perc_catch' => 120,
			'_function_metadata' => 128,
			'perc_alias' => 123
		}
	},
	{#State 89
		ACTIONS => {
			'ID' => 106,
			'DASH' => 107
		},
		GOTOS => {
			'file_name' => 130
		}
	},
	{#State 90
		DEFAULT => -124
	},
	{#State 91
		DEFAULT => -38
	},
	{#State 92
		DEFAULT => -12
	},
	{#State 93
		DEFAULT => -132
	},
	{#State 94
		ACTIONS => {
			'CLANG' => 131,
			'COMMA' => 132
		}
	},
	{#State 95
		DEFAULT => -22,
		GOTOS => {
			'mixed_blocks' => 133
		}
	},
	{#State 96
		DEFAULT => -112
	},
	{#State 97
		ACTIONS => {
			'CLCURLY' => 134
		}
	},
	{#State 98
		ACTIONS => {
			'p_any' => 95,
			'CLCURLY' => 136
		},
		GOTOS => {
			'perc_any_arg' => 135
		}
	},
	{#State 99
		ACTIONS => {
			'OPSPECIAL' => 30,
			'OPCURLY' => 137
		},
		DEFAULT => -110,
		GOTOS => {
			'simple_block' => 139,
			'special_block' => 138,
			'special_block_start' => 32
		}
	},
	{#State 100
		ACTIONS => {
			'CLCURLY' => 140
		}
	},
	{#State 101
		ACTIONS => {
			'COMMA' => 142
		},
		DEFAULT => -52,
		GOTOS => {
			'class_metadata' => 141
		}
	},
	{#State 102
		ACTIONS => {
			"protected" => 146,
			"private" => 145,
			"public" => 143
		},
		GOTOS => {
			'base_class' => 144
		}
	},
	{#State 103
		ACTIONS => {
			'CLCURLY' => 147
		}
	},
	{#State 104
		ACTIONS => {
			'CLCURLY' => 148
		}
	},
	{#State 105
		ACTIONS => {
			'CLCURLY' => 149
		}
	},
	{#State 106
		ACTIONS => {
			'DOT' => 151,
			'SLASH' => 150
		}
	},
	{#State 107
		DEFAULT => -140
	},
	{#State 108
		ACTIONS => {
			'ID' => 25,
			"short" => 17,
			"const" => 10,
			"unsigned" => 47,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		DEFAULT => -145,
		GOTOS => {
			'type_name' => 13,
			'class_name' => 1,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'arg_list' => 153,
			'argument' => 154,
			'type' => 152
		}
	},
	{#State 109
		ACTIONS => {
			'ID' => 155
		}
	},
	{#State 110
		DEFAULT => -138
	},
	{#State 111
		DEFAULT => -169
	},
	{#State 112
		DEFAULT => -164
	},
	{#State 113
		ACTIONS => {
			'CLCURLY' => 156
		}
	},
	{#State 114
		ACTIONS => {
			'CLCURLY' => 157
		}
	},
	{#State 115
		ACTIONS => {
			'ID' => 158,
			'PREPROCESSOR' => 16,
			'RAW_CODE' => 34,
			'OPSPECIAL' => 30,
			'COMMENT' => 6,
			'CLCURLY' => 160
		},
		GOTOS => {
			'enum_element' => 159,
			'special_block' => 12,
			'raw' => 161,
			'special_block_start' => 32
		}
	},
	{#State 116
		DEFAULT => -30,
		GOTOS => {
			'enum_element_list' => 162
		}
	},
	{#State 117
		ACTIONS => {
			'CLCURLY' => 163
		}
	},
	{#State 118
		DEFAULT => -91
	},
	{#State 119
		ACTIONS => {
			'OPSPECIAL' => 30
		},
		GOTOS => {
			'special_block' => 164,
			'special_block_start' => 32
		}
	},
	{#State 120
		DEFAULT => -94
	},
	{#State 121
		ACTIONS => {
			'OPSPECIAL' => 30
		},
		GOTOS => {
			'special_block' => 165,
			'special_block_start' => 32
		}
	},
	{#State 122
		ACTIONS => {
			'OPCURLY' => 166
		}
	},
	{#State 123
		DEFAULT => -95
	},
	{#State 124
		DEFAULT => -93
	},
	{#State 125
		ACTIONS => {
			'OPSPECIAL' => 30
		},
		GOTOS => {
			'special_block' => 167,
			'special_block_start' => 32
		}
	},
	{#State 126
		DEFAULT => -96
	},
	{#State 127
		DEFAULT => -92
	},
	{#State 128
		DEFAULT => -83
	},
	{#State 129
		ACTIONS => {
			'OPCURLY' => 168
		}
	},
	{#State 130
		ACTIONS => {
			'CLCURLY' => 169
		}
	},
	{#State 131
		DEFAULT => -131
	},
	{#State 132
		ACTIONS => {
			'ID' => 25,
			"short" => 17,
			"unsigned" => 47,
			"const" => 10,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		GOTOS => {
			'type_name' => 13,
			'class_name' => 1,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'type' => 170
		}
	},
	{#State 133
		ACTIONS => {
			'OPCURLY' => 137,
			'OPSPECIAL' => 30,
			'SEMICOLON' => 171
		},
		GOTOS => {
			'simple_block' => 139,
			'special_block' => 138,
			'special_block_start' => 32
		}
	},
	{#State 134
		DEFAULT => -22,
		GOTOS => {
			'mixed_blocks' => 172
		}
	},
	{#State 135
		DEFAULT => -113
	},
	{#State 136
		DEFAULT => -108
	},
	{#State 137
		ACTIONS => {
			'ID' => 173
		}
	},
	{#State 138
		DEFAULT => -20
	},
	{#State 139
		DEFAULT => -21
	},
	{#State 140
		ACTIONS => {
			'OPCURLY' => 174,
			'SEMICOLON' => 175
		}
	},
	{#State 141
		ACTIONS => {
			'OPCURLY' => 176,
			'p_any' => 3,
			'p_catch' => 129
		},
		GOTOS => {
			'perc_any' => 178,
			'perc_catch' => 177
		}
	},
	{#State 142
		ACTIONS => {
			"protected" => 146,
			"private" => 145,
			"public" => 143
		},
		GOTOS => {
			'base_class' => 179
		}
	},
	{#State 143
		ACTIONS => {
			'ID' => 25,
			'p_name' => 19
		},
		GOTOS => {
			'perc_name' => 181,
			'class_name' => 180,
			'class_name_rename' => 182
		}
	},
	{#State 144
		DEFAULT => -42
	},
	{#State 145
		ACTIONS => {
			'ID' => 25,
			'p_name' => 19
		},
		GOTOS => {
			'perc_name' => 181,
			'class_name' => 180,
			'class_name_rename' => 183
		}
	},
	{#State 146
		ACTIONS => {
			'ID' => 25,
			'p_name' => 19
		},
		GOTOS => {
			'perc_name' => 181,
			'class_name' => 180,
			'class_name_rename' => 184
		}
	},
	{#State 147
		DEFAULT => -100
	},
	{#State 148
		DEFAULT => -97
	},
	{#State 149
		DEFAULT => -103
	},
	{#State 150
		ACTIONS => {
			'ID' => 106,
			'DASH' => 107
		},
		GOTOS => {
			'file_name' => 185
		}
	},
	{#State 151
		ACTIONS => {
			'ID' => 186
		}
	},
	{#State 152
		ACTIONS => {
			'ID' => 188,
			'p_length' => 187
		}
	},
	{#State 153
		ACTIONS => {
			'CLPAR' => 189,
			'COMMA' => 190
		}
	},
	{#State 154
		DEFAULT => -143
	},
	{#State 155
		DEFAULT => -139
	},
	{#State 156
		ACTIONS => {
			'OPCURLY' => 191
		}
	},
	{#State 157
		DEFAULT => -102
	},
	{#State 158
		ACTIONS => {
			'EQUAL' => 192
		},
		DEFAULT => -33
	},
	{#State 159
		ACTIONS => {
			'COMMA' => 193
		},
		DEFAULT => -31
	},
	{#State 160
		ACTIONS => {
			'SEMICOLON' => 194
		}
	},
	{#State 161
		DEFAULT => -35
	},
	{#State 162
		ACTIONS => {
			'ID' => 158,
			'PREPROCESSOR' => 16,
			'RAW_CODE' => 34,
			'OPSPECIAL' => 30,
			'COMMENT' => 6,
			'CLCURLY' => 195
		},
		GOTOS => {
			'enum_element' => 159,
			'special_block' => 12,
			'raw' => 161,
			'special_block_start' => 32
		}
	},
	{#State 163
		DEFAULT => -99
	},
	{#State 164
		DEFAULT => -105
	},
	{#State 165
		DEFAULT => -106
	},
	{#State 166
		ACTIONS => {
			'ID' => 196
		}
	},
	{#State 167
		DEFAULT => -104
	},
	{#State 168
		ACTIONS => {
			'ID' => 25
		},
		GOTOS => {
			'class_name' => 197,
			'class_name_list' => 198
		}
	},
	{#State 169
		DEFAULT => -101
	},
	{#State 170
		DEFAULT => -133
	},
	{#State 171
		DEFAULT => -114
	},
	{#State 172
		ACTIONS => {
			'OPSPECIAL' => 30,
			'OPCURLY' => 137
		},
		DEFAULT => -109,
		GOTOS => {
			'simple_block' => 139,
			'special_block' => 138,
			'special_block_start' => 32
		}
	},
	{#State 173
		ACTIONS => {
			'CLCURLY' => 199
		}
	},
	{#State 174
		ACTIONS => {
			'ID' => 200
		}
	},
	{#State 175
		DEFAULT => -18
	},
	{#State 176
		DEFAULT => -53,
		GOTOS => {
			'class_body_list' => 201
		}
	},
	{#State 177
		DEFAULT => -50
	},
	{#State 178
		DEFAULT => -51
	},
	{#State 179
		DEFAULT => -43
	},
	{#State 180
		DEFAULT => -48
	},
	{#State 181
		ACTIONS => {
			'ID' => 25
		},
		GOTOS => {
			'class_name' => 202
		}
	},
	{#State 182
		DEFAULT => -45
	},
	{#State 183
		DEFAULT => -47
	},
	{#State 184
		DEFAULT => -46
	},
	{#State 185
		DEFAULT => -142
	},
	{#State 186
		DEFAULT => -141
	},
	{#State 187
		ACTIONS => {
			'OPCURLY' => 203
		}
	},
	{#State 188
		ACTIONS => {
			'EQUAL' => 204
		},
		DEFAULT => -148
	},
	{#State 189
		ACTIONS => {
			"const" => 205
		},
		DEFAULT => -69,
		GOTOS => {
			'const' => 206
		}
	},
	{#State 190
		ACTIONS => {
			'ID' => 25,
			"short" => 17,
			"unsigned" => 47,
			"const" => 10,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		GOTOS => {
			'argument' => 207,
			'type_name' => 13,
			'class_name' => 1,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'type' => 152
		}
	},
	{#State 191
		ACTIONS => {
			'ID' => 25,
			"short" => 17,
			"unsigned" => 47,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		GOTOS => {
			'type_name' => 209,
			'class_name' => 208,
			'basic_type' => 39
		}
	},
	{#State 192
		ACTIONS => {
			'ID' => 25,
			'INTEGER' => 212,
			'QUOTED_STRING' => 214,
			'DASH' => 216,
			'FLOAT' => 215
		},
		GOTOS => {
			'class_name' => 210,
			'value' => 213,
			'expression' => 211
		}
	},
	{#State 193
		DEFAULT => -32
	},
	{#State 194
		DEFAULT => -28
	},
	{#State 195
		ACTIONS => {
			'SEMICOLON' => 217
		}
	},
	{#State 196
		ACTIONS => {
			'EQUAL' => 218
		}
	},
	{#State 197
		DEFAULT => -136
	},
	{#State 198
		ACTIONS => {
			'COMMA' => 219,
			'CLCURLY' => 220
		}
	},
	{#State 199
		DEFAULT => -23
	},
	{#State 200
		ACTIONS => {
			'CLCURLY' => 221
		}
	},
	{#State 201
		ACTIONS => {
			'ID' => 236,
			'p_typemap' => 4,
			'p_any' => 3,
			'OPSPECIAL' => 30,
			"virtual" => 237,
			'COMMENT' => 6,
			"class_static" => 223,
			"package_static" => 238,
			"public" => 224,
			'p_exceptionmap' => 33,
			'RAW_CODE' => 34,
			"const" => 10,
			"static" => 242,
			"int" => 37,
			"private" => 229,
			'CLCURLY' => 245,
			'PREPROCESSOR' => 16,
			"short" => 17,
			"unsigned" => 47,
			'p_name' => 19,
			'TILDE' => 232,
			"protected" => 233,
			"long" => 21,
			"char" => 24
		},
		GOTOS => {
			'class_name' => 1,
			'nconsttype' => 27,
			'looks_like_function' => 5,
			'static' => 222,
			'exceptionmap' => 239,
			'special_block_start' => 32,
			'perc_name' => 225,
			'typemap' => 226,
			'class_body_element' => 240,
			'method' => 241,
			'vmethod' => 227,
			'nmethod' => 228,
			'special_block' => 12,
			'access_specifier' => 230,
			'type_name' => 13,
			'ctor' => 231,
			'perc_any' => 243,
			'basic_type' => 39,
			'template' => 14,
			'virtual' => 244,
			'looks_like_renamed_function' => 246,
			'_vmethod' => 247,
			'type' => 22,
			'dtor' => 234,
			'raw' => 248,
			'method_decl' => 235
		}
	},
	{#State 202
		DEFAULT => -49
	},
	{#State 203
		ACTIONS => {
			'ID' => 249
		}
	},
	{#State 204
		ACTIONS => {
			'ID' => 25,
			'INTEGER' => 212,
			'QUOTED_STRING' => 214,
			'DASH' => 216,
			'FLOAT' => 215
		},
		GOTOS => {
			'class_name' => 210,
			'value' => 213,
			'expression' => 250
		}
	},
	{#State 205
		DEFAULT => -68
	},
	{#State 206
		DEFAULT => -74
	},
	{#State 207
		DEFAULT => -144
	},
	{#State 208
		DEFAULT => -121
	},
	{#State 209
		ACTIONS => {
			'CLCURLY' => 251
		}
	},
	{#State 210
		ACTIONS => {
			'OPPAR' => 252
		},
		DEFAULT => -153
	},
	{#State 211
		DEFAULT => -34
	},
	{#State 212
		DEFAULT => -149
	},
	{#State 213
		ACTIONS => {
			'AMP' => 253,
			'PIPE' => 254
		},
		DEFAULT => -158
	},
	{#State 214
		DEFAULT => -152
	},
	{#State 215
		DEFAULT => -151
	},
	{#State 216
		ACTIONS => {
			'INTEGER' => 255
		}
	},
	{#State 217
		DEFAULT => -29
	},
	{#State 218
		ACTIONS => {
			'INTEGER' => 256
		}
	},
	{#State 219
		ACTIONS => {
			'ID' => 25
		},
		GOTOS => {
			'class_name' => 257
		}
	},
	{#State 220
		DEFAULT => -107
	},
	{#State 221
		ACTIONS => {
			'OPCURLY' => 258,
			'OPSPECIAL' => 30
		},
		DEFAULT => -163,
		GOTOS => {
			'special_blocks' => 260,
			'special_block' => 259,
			'special_block_start' => 32
		}
	},
	{#State 222
		ACTIONS => {
			'ID' => 25,
			"class_static" => 223,
			"package_static" => 238,
			"short" => 17,
			"unsigned" => 47,
			"const" => 10,
			'p_name' => 19,
			"long" => 21,
			"static" => 242,
			"int" => 37,
			"char" => 24
		},
		GOTOS => {
			'type_name' => 13,
			'class_name' => 1,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'looks_like_function' => 5,
			'static' => 222,
			'perc_name' => 261,
			'looks_like_renamed_function' => 246,
			'nmethod' => 262,
			'type' => 22
		}
	},
	{#State 223
		DEFAULT => -72
	},
	{#State 224
		ACTIONS => {
			'COLON' => 263
		}
	},
	{#State 225
		ACTIONS => {
			'ID' => 236,
			"virtual" => 237,
			"short" => 17,
			"unsigned" => 47,
			"const" => 10,
			'p_name' => 19,
			'TILDE' => 232,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		GOTOS => {
			'type_name' => 13,
			'class_name' => 1,
			'ctor' => 266,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'looks_like_function' => 58,
			'virtual' => 244,
			'perc_name' => 264,
			'_vmethod' => 247,
			'dtor' => 267,
			'vmethod' => 265,
			'type' => 22
		}
	},
	{#State 226
		DEFAULT => -57
	},
	{#State 227
		DEFAULT => -65
	},
	{#State 228
		DEFAULT => -64
	},
	{#State 229
		ACTIONS => {
			'COLON' => 268
		}
	},
	{#State 230
		DEFAULT => -59
	},
	{#State 231
		DEFAULT => -66
	},
	{#State 232
		ACTIONS => {
			'ID' => 269
		}
	},
	{#State 233
		ACTIONS => {
			'COLON' => 270
		}
	},
	{#State 234
		DEFAULT => -67
	},
	{#State 235
		ACTIONS => {
			'SEMICOLON' => 271
		}
	},
	{#State 236
		ACTIONS => {
			'DCOLON' => 70,
			'OPPAR' => 272
		},
		DEFAULT => -134,
		GOTOS => {
			'class_suffix' => 69
		}
	},
	{#State 237
		DEFAULT => -70
	},
	{#State 238
		DEFAULT => -71
	},
	{#State 239
		DEFAULT => -58
	},
	{#State 240
		DEFAULT => -54
	},
	{#State 241
		DEFAULT => -55
	},
	{#State 242
		DEFAULT => -73
	},
	{#State 243
		ACTIONS => {
			'SEMICOLON' => 273
		}
	},
	{#State 244
		ACTIONS => {
			'ID' => 25,
			"virtual" => 237,
			"short" => 17,
			"unsigned" => 47,
			"const" => 10,
			'p_name' => 19,
			'TILDE' => 232,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		GOTOS => {
			'type_name' => 13,
			'class_name' => 1,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'looks_like_function' => 274,
			'virtual' => 277,
			'perc_name' => 275,
			'type' => 22,
			'dtor' => 276
		}
	},
	{#State 245
		DEFAULT => -41
	},
	{#State 246
		DEFAULT => -84,
		GOTOS => {
			'function_metadata' => 278
		}
	},
	{#State 247
		DEFAULT => -87
	},
	{#State 248
		DEFAULT => -56
	},
	{#State 249
		ACTIONS => {
			'CLCURLY' => 279
		}
	},
	{#State 250
		DEFAULT => -147
	},
	{#State 251
		ACTIONS => {
			'OPCURLY' => 280
		}
	},
	{#State 252
		ACTIONS => {
			'ID' => 25,
			'INTEGER' => 212,
			'QUOTED_STRING' => 214,
			'DASH' => 216,
			'FLOAT' => 215
		},
		DEFAULT => -157,
		GOTOS => {
			'class_name' => 210,
			'value_list' => 281,
			'value' => 282
		}
	},
	{#State 253
		ACTIONS => {
			'ID' => 25,
			'INTEGER' => 212,
			'QUOTED_STRING' => 214,
			'DASH' => 216,
			'FLOAT' => 215
		},
		GOTOS => {
			'class_name' => 210,
			'value' => 283
		}
	},
	{#State 254
		ACTIONS => {
			'ID' => 25,
			'INTEGER' => 212,
			'QUOTED_STRING' => 214,
			'DASH' => 216,
			'FLOAT' => 215
		},
		GOTOS => {
			'class_name' => 210,
			'value' => 284
		}
	},
	{#State 255
		DEFAULT => -150
	},
	{#State 256
		ACTIONS => {
			'CLCURLY' => 285
		}
	},
	{#State 257
		DEFAULT => -137
	},
	{#State 258
		ACTIONS => {
			'p_any' => 95
		},
		GOTOS => {
			'perc_any_arg' => 96,
			'perc_any_args' => 286
		}
	},
	{#State 259
		DEFAULT => -161
	},
	{#State 260
		ACTIONS => {
			'OPSPECIAL' => 30,
			'SEMICOLON' => 288
		},
		GOTOS => {
			'special_block' => 287,
			'special_block_start' => 32
		}
	},
	{#State 261
		ACTIONS => {
			'ID' => 25,
			"short" => 17,
			"unsigned" => 47,
			"const" => 10,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		GOTOS => {
			'type_name' => 13,
			'class_name' => 1,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'looks_like_function' => 58,
			'type' => 22
		}
	},
	{#State 262
		DEFAULT => -86
	},
	{#State 263
		DEFAULT => -61
	},
	{#State 264
		ACTIONS => {
			'ID' => 289,
			'TILDE' => 232,
			'p_name' => 19,
			"virtual" => 237
		},
		GOTOS => {
			'perc_name' => 264,
			'ctor' => 266,
			'_vmethod' => 247,
			'dtor' => 267,
			'vmethod' => 265,
			'virtual' => 244
		}
	},
	{#State 265
		DEFAULT => -88
	},
	{#State 266
		DEFAULT => -79
	},
	{#State 267
		DEFAULT => -81
	},
	{#State 268
		DEFAULT => -63
	},
	{#State 269
		ACTIONS => {
			'OPPAR' => 290
		}
	},
	{#State 270
		DEFAULT => -62
	},
	{#State 271
		DEFAULT => -39
	},
	{#State 272
		ACTIONS => {
			'ID' => 25,
			"short" => 17,
			"const" => 10,
			"unsigned" => 47,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		DEFAULT => -145,
		GOTOS => {
			'type_name' => 13,
			'class_name' => 1,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'arg_list' => 291,
			'argument' => 154,
			'type' => 152
		}
	},
	{#State 273
		DEFAULT => -60
	},
	{#State 274
		ACTIONS => {
			'EQUAL' => 292
		},
		DEFAULT => -84,
		GOTOS => {
			'function_metadata' => 293
		}
	},
	{#State 275
		ACTIONS => {
			'TILDE' => 232,
			'p_name' => 19,
			"virtual" => 237
		},
		GOTOS => {
			'perc_name' => 275,
			'dtor' => 267,
			'virtual' => 277
		}
	},
	{#State 276
		DEFAULT => -82
	},
	{#State 277
		ACTIONS => {
			'TILDE' => 232,
			'p_name' => 19,
			"virtual" => 237
		},
		GOTOS => {
			'perc_name' => 275,
			'dtor' => 276,
			'virtual' => 277
		}
	},
	{#State 278
		ACTIONS => {
			'p_any' => 3,
			'p_alias' => 122,
			'p_code' => 125,
			'p_cleanup' => 119,
			'p_postcall' => 121,
			'p_catch' => 129
		},
		DEFAULT => -85,
		GOTOS => {
			'perc_postcall' => 124,
			'perc_code' => 118,
			'perc_any' => 126,
			'perc_cleanup' => 127,
			'perc_catch' => 120,
			'_function_metadata' => 128,
			'perc_alias' => 123
		}
	},
	{#State 279
		DEFAULT => -146
	},
	{#State 280
		ACTIONS => {
			'ID' => 294
		}
	},
	{#State 281
		ACTIONS => {
			'CLPAR' => 295,
			'COMMA' => 296
		}
	},
	{#State 282
		DEFAULT => -155
	},
	{#State 283
		DEFAULT => -159
	},
	{#State 284
		DEFAULT => -160
	},
	{#State 285
		DEFAULT => -98
	},
	{#State 286
		ACTIONS => {
			'p_any' => 95,
			'CLCURLY' => 297
		},
		GOTOS => {
			'perc_any_arg' => 135
		}
	},
	{#State 287
		DEFAULT => -162
	},
	{#State 288
		DEFAULT => -16
	},
	{#State 289
		ACTIONS => {
			'OPPAR' => 272
		}
	},
	{#State 290
		ACTIONS => {
			'CLPAR' => 298
		}
	},
	{#State 291
		ACTIONS => {
			'CLPAR' => 299,
			'COMMA' => 190
		}
	},
	{#State 292
		ACTIONS => {
			'INTEGER' => 300
		}
	},
	{#State 293
		ACTIONS => {
			'p_any' => 3,
			'p_alias' => 122,
			'p_code' => 125,
			'p_cleanup' => 119,
			'p_postcall' => 121,
			'p_catch' => 129
		},
		DEFAULT => -89,
		GOTOS => {
			'perc_postcall' => 124,
			'perc_code' => 118,
			'perc_any' => 126,
			'perc_cleanup' => 127,
			'perc_catch' => 120,
			'_function_metadata' => 128,
			'perc_alias' => 123
		}
	},
	{#State 294
		ACTIONS => {
			'CLCURLY' => 301
		}
	},
	{#State 295
		DEFAULT => -154
	},
	{#State 296
		ACTIONS => {
			'ID' => 25,
			'INTEGER' => 212,
			'QUOTED_STRING' => 214,
			'DASH' => 216,
			'FLOAT' => 215
		},
		GOTOS => {
			'class_name' => 210,
			'value' => 302
		}
	},
	{#State 297
		ACTIONS => {
			'SEMICOLON' => 303
		}
	},
	{#State 298
		DEFAULT => -84,
		GOTOS => {
			'function_metadata' => 304
		}
	},
	{#State 299
		DEFAULT => -84,
		GOTOS => {
			'function_metadata' => 305
		}
	},
	{#State 300
		DEFAULT => -84,
		GOTOS => {
			'function_metadata' => 306
		}
	},
	{#State 301
		DEFAULT => -22,
		GOTOS => {
			'mixed_blocks' => 307
		}
	},
	{#State 302
		DEFAULT => -156
	},
	{#State 303
		DEFAULT => -17
	},
	{#State 304
		ACTIONS => {
			'p_any' => 3,
			'p_alias' => 122,
			'p_code' => 125,
			'p_cleanup' => 119,
			'p_postcall' => 121,
			'p_catch' => 129
		},
		DEFAULT => -80,
		GOTOS => {
			'perc_postcall' => 124,
			'perc_code' => 118,
			'perc_any' => 126,
			'perc_cleanup' => 127,
			'perc_catch' => 120,
			'_function_metadata' => 128,
			'perc_alias' => 123
		}
	},
	{#State 305
		ACTIONS => {
			'p_any' => 3,
			'p_alias' => 122,
			'p_code' => 125,
			'p_cleanup' => 119,
			'p_postcall' => 121,
			'p_catch' => 129
		},
		DEFAULT => -78,
		GOTOS => {
			'perc_postcall' => 124,
			'perc_code' => 118,
			'perc_any' => 126,
			'perc_cleanup' => 127,
			'perc_catch' => 120,
			'_function_metadata' => 128,
			'perc_alias' => 123
		}
	},
	{#State 306
		ACTIONS => {
			'p_any' => 3,
			'p_alias' => 122,
			'p_code' => 125,
			'p_cleanup' => 119,
			'p_postcall' => 121,
			'p_catch' => 129
		},
		DEFAULT => -90,
		GOTOS => {
			'perc_postcall' => 124,
			'perc_code' => 118,
			'perc_any' => 126,
			'perc_cleanup' => 127,
			'perc_catch' => 120,
			'_function_metadata' => 128,
			'perc_alias' => 123
		}
	},
	{#State 307
		ACTIONS => {
			'OPCURLY' => 137,
			'OPSPECIAL' => 30,
			'SEMICOLON' => 308
		},
		GOTOS => {
			'simple_block' => 139,
			'special_block' => 138,
			'special_block_start' => 32
		}
	},
	{#State 308
		DEFAULT => -19
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
		 'top', 1, undef
	],
	[#Rule 7
		 'top', 1,
sub
#line 26 "XSP.yp"
{ $_[1]->resolve_typemaps; $_[1]->resolve_exceptions; $_[1] }
	],
	[#Rule 8
		 'directive', 2,
sub
#line 29 "XSP.yp"
{ ExtUtils::XSpp::Node::Module->new( module => $_[1] ) }
	],
	[#Rule 9
		 'directive', 2,
sub
#line 31 "XSP.yp"
{ ExtUtils::XSpp::Node::Package->new( perl_name => $_[1] ) }
	],
	[#Rule 10
		 'directive', 2,
sub
#line 33 "XSP.yp"
{ ExtUtils::XSpp::Node::File->new( file => $_[1] ) }
	],
	[#Rule 11
		 'directive', 2,
sub
#line 35 "XSP.yp"
{ $_[0]->YYData->{PARSER}->load_plugin( $_[1] ); undef }
	],
	[#Rule 12
		 'directive', 2,
sub
#line 37 "XSP.yp"
{ $_[0]->YYData->{PARSER}->include_file( $_[1] ); undef }
	],
	[#Rule 13
		 'directive', 2,
sub
#line 39 "XSP.yp"
{ add_top_level_directive( $_[0], @{$_[1]} ); undef }
	],
	[#Rule 14
		 'directive', 1,
sub
#line 40 "XSP.yp"
{ }
	],
	[#Rule 15
		 'directive', 1,
sub
#line 41 "XSP.yp"
{ }
	],
	[#Rule 16
		 'typemap', 9,
sub
#line 46 "XSP.yp"
{ my $package = "ExtUtils::XSpp::Typemap::" . $_[6];
                      my $type = $_[3]; my $c = 0;
                      my %args = map { "arg" . ++$c => $_ }
                                 map { join( '', @$_ ) }
                                     @{$_[8] || []};
                      my $tm = $package->new( type => $type, %args );
                      ExtUtils::XSpp::Typemap::add_typemap_for_type( $type, $tm );
                      undef }
	],
	[#Rule 17
		 'typemap', 11,
sub
#line 56 "XSP.yp"
{ my $package = "ExtUtils::XSpp::Typemap::" . $_[6];
                      my $type = $_[3];
                      # this assumes that there will be at most one named
                      # block for each directive inside the typemap
                      for( my $i = 1; $i <= $#{$_[9]}; $i += 2 ) {
                          $_[9][$i] = join "\n", @{$_[9][$i][0]}
                              if    ref( $_[9][$i] ) eq 'ARRAY'
                                 && ref( $_[9][$i][0] ) eq 'ARRAY';
                      }
                      my $tm = $package->new( type => $type, @{$_[9]} );
                      ExtUtils::XSpp::Typemap::add_typemap_for_type( $type, $tm );
                      undef }
	],
	[#Rule 18
		 'typemap', 5,
sub
#line 69 "XSP.yp"
{ my $type = $_[3]; # add simple and reference typemaps for this type
                      my $tm = ExtUtils::XSpp::Typemap::simple->new( type => $type );
                      ExtUtils::XSpp::Typemap::add_typemap_for_type( $type, $tm );
                      my $reftype = make_ref($type->clone);
                      $tm = ExtUtils::XSpp::Typemap::reference->new( type => $reftype );
                      ExtUtils::XSpp::Typemap::add_typemap_for_type( $reftype, $tm );
                      undef }
	],
	[#Rule 19
		 'exceptionmap', 12,
sub
#line 81 "XSP.yp"
{ my $package = "ExtUtils::XSpp::Exception::" . $_[9];
                      my $type = make_type($_[6]); my $c = 0;
                      my %args = map { "arg" . ++$c => $_ }
                                 map { join( "\n", @$_ ) }
                                     @{$_[11] || []};
                      my $e = $package->new( name => $_[3], type => $type, %args );
                      ExtUtils::XSpp::Exception->add_exception( $e );
                      undef }
	],
	[#Rule 20
		 'mixed_blocks', 2,
sub
#line 91 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 21
		 'mixed_blocks', 2,
sub
#line 93 "XSP.yp"
{ [ @{$_[1]}, [ $_[2] ] ] }
	],
	[#Rule 22
		 'mixed_blocks', 0,
sub
#line 94 "XSP.yp"
{ [] }
	],
	[#Rule 23
		 'simple_block', 3,
sub
#line 97 "XSP.yp"
{ $_[2] }
	],
	[#Rule 24
		 'raw', 1,
sub
#line 99 "XSP.yp"
{ add_data_raw( $_[0], [ $_[1] ] ) }
	],
	[#Rule 25
		 'raw', 1,
sub
#line 100 "XSP.yp"
{ add_data_comment( $_[0], $_[1] ) }
	],
	[#Rule 26
		 'raw', 1,
sub
#line 101 "XSP.yp"
{ ExtUtils::XSpp::Node::Preprocessor->new
                              ( rows   => [ $_[1][0] ],
                                symbol => $_[1][1],
                                ) }
	],
	[#Rule 27
		 'raw', 1,
sub
#line 105 "XSP.yp"
{ add_data_raw( $_[0], [ @{$_[1]} ] ) }
	],
	[#Rule 28
		 'enum', 5,
sub
#line 109 "XSP.yp"
{ ExtUtils::XSpp::Node::Enum->new
                ( elements  => $_[3],
                  condition => $_[0]->get_conditional,
                  ) }
	],
	[#Rule 29
		 'enum', 6,
sub
#line 114 "XSP.yp"
{ ExtUtils::XSpp::Node::Enum->new
                ( name      => $_[2],
                  elements  => $_[4],
                  condition => $_[0]->get_conditional,
                  ) }
	],
	[#Rule 30
		 'enum_element_list', 0,
sub
#line 122 "XSP.yp"
{ [] }
	],
	[#Rule 31
		 'enum_element_list', 2,
sub
#line 124 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 32
		 'enum_element_list', 3,
sub
#line 126 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 33
		 'enum_element', 1,
sub
#line 131 "XSP.yp"
{ ExtUtils::XSpp::Node::EnumValue->new
                ( name => $_[1],
                  condition => $_[0]->get_conditional,
                  ) }
	],
	[#Rule 34
		 'enum_element', 3,
sub
#line 136 "XSP.yp"
{ ExtUtils::XSpp::Node::EnumValue->new
                ( name      => $_[1],
                  value     => $_[3],
                  condition => $_[0]->get_conditional,
                  ) }
	],
	[#Rule 35
		 'enum_element', 1, undef
	],
	[#Rule 36
		 'class', 2, undef
	],
	[#Rule 37
		 'class', 2, undef
	],
	[#Rule 38
		 'function', 2, undef
	],
	[#Rule 39
		 'method', 2, undef
	],
	[#Rule 40
		 'decorate_class', 2,
sub
#line 149 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 41
		 'class_decl', 7,
sub
#line 152 "XSP.yp"
{ create_class( $_[0], $_[2], $_[3], $_[4], $_[6],
                                $_[0]->get_conditional ) }
	],
	[#Rule 42
		 'base_classes', 2,
sub
#line 156 "XSP.yp"
{ [ $_[2] ] }
	],
	[#Rule 43
		 'base_classes', 3,
sub
#line 157 "XSP.yp"
{ push @{$_[1]}, $_[3] if $_[3]; $_[1] }
	],
	[#Rule 44
		 'base_classes', 0, undef
	],
	[#Rule 45
		 'base_class', 2,
sub
#line 161 "XSP.yp"
{ $_[2] }
	],
	[#Rule 46
		 'base_class', 2,
sub
#line 162 "XSP.yp"
{ $_[2] }
	],
	[#Rule 47
		 'base_class', 2,
sub
#line 163 "XSP.yp"
{ $_[2] }
	],
	[#Rule 48
		 'class_name_rename', 1,
sub
#line 167 "XSP.yp"
{ create_class( $_[0], $_[1], [], [] ) }
	],
	[#Rule 49
		 'class_name_rename', 2,
sub
#line 168 "XSP.yp"
{ my $klass = create_class( $_[0], $_[2], [], [] );
                             $klass->set_perl_name( $_[1] );
                             $klass
                             }
	],
	[#Rule 50
		 'class_metadata', 2,
sub
#line 174 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 51
		 'class_metadata', 2,
sub
#line 175 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 52
		 'class_metadata', 0,
sub
#line 176 "XSP.yp"
{ [] }
	],
	[#Rule 53
		 'class_body_list', 0,
sub
#line 180 "XSP.yp"
{ [] }
	],
	[#Rule 54
		 'class_body_list', 2,
sub
#line 182 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 55
		 'class_body_element', 1, undef
	],
	[#Rule 56
		 'class_body_element', 1, undef
	],
	[#Rule 57
		 'class_body_element', 1, undef
	],
	[#Rule 58
		 'class_body_element', 1, undef
	],
	[#Rule 59
		 'class_body_element', 1, undef
	],
	[#Rule 60
		 'class_body_element', 2,
sub
#line 188 "XSP.yp"
{ ExtUtils::XSpp::Node::PercAny->new( @{$_[1]} ) }
	],
	[#Rule 61
		 'access_specifier', 2,
sub
#line 192 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 62
		 'access_specifier', 2,
sub
#line 193 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 63
		 'access_specifier', 2,
sub
#line 194 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 64
		 'method_decl', 1, undef
	],
	[#Rule 65
		 'method_decl', 1, undef
	],
	[#Rule 66
		 'method_decl', 1, undef
	],
	[#Rule 67
		 'method_decl', 1, undef
	],
	[#Rule 68
		 'const', 1,
sub
#line 199 "XSP.yp"
{ 1 }
	],
	[#Rule 69
		 'const', 0,
sub
#line 200 "XSP.yp"
{ 0 }
	],
	[#Rule 70
		 'virtual', 1, undef
	],
	[#Rule 71
		 'static', 1, undef
	],
	[#Rule 72
		 'static', 1, undef
	],
	[#Rule 73
		 'static', 1,
sub
#line 206 "XSP.yp"
{ 'package_static' }
	],
	[#Rule 74
		 'looks_like_function', 6,
sub
#line 211 "XSP.yp"
{
              return { ret_type  => $_[1],
                       name      => $_[2],
                       arguments => $_[4],
                       const     => $_[6],
                       };
          }
	],
	[#Rule 75
		 'looks_like_renamed_function', 1, undef
	],
	[#Rule 76
		 'looks_like_renamed_function', 2,
sub
#line 222 "XSP.yp"
{ $_[2]->{perl_name} = $_[1]; $_[2] }
	],
	[#Rule 77
		 'function_decl', 2,
sub
#line 225 "XSP.yp"
{ add_data_function( $_[0],
                                         name      => $_[1]->{name},
                                         perl_name => $_[1]->{perl_name},
                                         ret_type  => $_[1]->{ret_type},
                                         arguments => $_[1]->{arguments},
                                         condition => $_[0]->get_conditional,
                                         @{$_[2]} ) }
	],
	[#Rule 78
		 'ctor', 5,
sub
#line 234 "XSP.yp"
{ add_data_ctor( $_[0], name      => $_[1],
                                            arguments => $_[3],
                                            condition => $_[0]->get_conditional,
                                            @{ $_[5] } ) }
	],
	[#Rule 79
		 'ctor', 2,
sub
#line 238 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 80
		 'dtor', 5,
sub
#line 241 "XSP.yp"
{ add_data_dtor( $_[0], name  => $_[2],
                                            condition => $_[0]->get_conditional,
                                            @{ $_[5] },
                                      ) }
	],
	[#Rule 81
		 'dtor', 2,
sub
#line 245 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 82
		 'dtor', 2,
sub
#line 246 "XSP.yp"
{ $_[2]->set_virtual( 1 ); $_[2] }
	],
	[#Rule 83
		 'function_metadata', 2,
sub
#line 248 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 84
		 'function_metadata', 0,
sub
#line 249 "XSP.yp"
{ [] }
	],
	[#Rule 85
		 'nmethod', 2,
sub
#line 254 "XSP.yp"
{ my $m = add_data_method
                        ( $_[0],
                          name      => $_[1]->{name},
                          perl_name => $_[1]->{perl_name},
                          ret_type  => $_[1]->{ret_type},
                          arguments => $_[1]->{arguments},
                          const     => $_[1]->{const},
                          condition => $_[0]->get_conditional,
                          @{$_[2]},
                          );
            $m
          }
	],
	[#Rule 86
		 'nmethod', 2,
sub
#line 267 "XSP.yp"
{ $_[2]->set_static( $_[1] ); $_[2] }
	],
	[#Rule 87
		 'vmethod', 1, undef
	],
	[#Rule 88
		 'vmethod', 2,
sub
#line 272 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 89
		 '_vmethod', 3,
sub
#line 277 "XSP.yp"
{ my $m = add_data_method
                        ( $_[0],
                          name      => $_[2]->{name},
                          perl_name => $_[2]->{perl_name},
                          ret_type  => $_[2]->{ret_type},
                          arguments => $_[2]->{arguments},
                          const     => $_[2]->{const},
                          condition => $_[0]->get_conditional,
                          @{$_[3]},
                          );
            $m->set_virtual( 1 );
            $m
          }
	],
	[#Rule 90
		 '_vmethod', 5,
sub
#line 291 "XSP.yp"
{ my $m = add_data_method
                        ( $_[0],
                          name      => $_[2]->{name},
                          perl_name => $_[2]->{perl_name},
                          ret_type  => $_[2]->{ret_type},
                          arguments => $_[2]->{arguments},
                          const     => $_[2]->{const},
                          condition => $_[0]->get_conditional,
                          @{$_[5]},
                          );
            die "Invalid pure virtual method" unless $_[4] eq '0';
            $m->set_virtual( 2 );
            $m
          }
	],
	[#Rule 91
		 '_function_metadata', 1, undef
	],
	[#Rule 92
		 '_function_metadata', 1, undef
	],
	[#Rule 93
		 '_function_metadata', 1, undef
	],
	[#Rule 94
		 '_function_metadata', 1, undef
	],
	[#Rule 95
		 '_function_metadata', 1, undef
	],
	[#Rule 96
		 '_function_metadata', 1, undef
	],
	[#Rule 97
		 'perc_name', 4,
sub
#line 315 "XSP.yp"
{ $_[3] }
	],
	[#Rule 98
		 'perc_alias', 6,
sub
#line 316 "XSP.yp"
{ [ alias => [$_[3], $_[5]] ] }
	],
	[#Rule 99
		 'perc_package', 4,
sub
#line 317 "XSP.yp"
{ $_[3] }
	],
	[#Rule 100
		 'perc_module', 4,
sub
#line 318 "XSP.yp"
{ $_[3] }
	],
	[#Rule 101
		 'perc_file', 4,
sub
#line 319 "XSP.yp"
{ $_[3] }
	],
	[#Rule 102
		 'perc_loadplugin', 4,
sub
#line 320 "XSP.yp"
{ $_[3] }
	],
	[#Rule 103
		 'perc_include', 4,
sub
#line 321 "XSP.yp"
{ $_[3] }
	],
	[#Rule 104
		 'perc_code', 2,
sub
#line 322 "XSP.yp"
{ [ code => $_[2] ] }
	],
	[#Rule 105
		 'perc_cleanup', 2,
sub
#line 323 "XSP.yp"
{ [ cleanup => $_[2] ] }
	],
	[#Rule 106
		 'perc_postcall', 2,
sub
#line 324 "XSP.yp"
{ [ postcall => $_[2] ] }
	],
	[#Rule 107
		 'perc_catch', 4,
sub
#line 325 "XSP.yp"
{ [ map {(catch => $_)} @{$_[3]} ] }
	],
	[#Rule 108
		 'perc_any', 4,
sub
#line 330 "XSP.yp"
{ [ any => $_[1], any_named_arguments => $_[3] ] }
	],
	[#Rule 109
		 'perc_any', 5,
sub
#line 332 "XSP.yp"
{ [ any => $_[1], any_positional_arguments  => [ $_[3], @{$_[5]} ] ] }
	],
	[#Rule 110
		 'perc_any', 3,
sub
#line 334 "XSP.yp"
{ [ any => $_[1], any_positional_arguments  => [ $_[2], @{$_[3]} ] ] }
	],
	[#Rule 111
		 'perc_any', 1,
sub
#line 336 "XSP.yp"
{ [ any => $_[1] ] }
	],
	[#Rule 112
		 'perc_any_args', 1,
sub
#line 340 "XSP.yp"
{ $_[1] }
	],
	[#Rule 113
		 'perc_any_args', 2,
sub
#line 341 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 114
		 'perc_any_arg', 3,
sub
#line 345 "XSP.yp"
{ [ $_[1] => $_[2] ] }
	],
	[#Rule 115
		 'type', 2,
sub
#line 349 "XSP.yp"
{ make_const( $_[2] ) }
	],
	[#Rule 116
		 'type', 1, undef
	],
	[#Rule 117
		 'nconsttype', 2,
sub
#line 354 "XSP.yp"
{ make_ptr( $_[1] ) }
	],
	[#Rule 118
		 'nconsttype', 2,
sub
#line 355 "XSP.yp"
{ make_ref( $_[1] ) }
	],
	[#Rule 119
		 'nconsttype', 1,
sub
#line 356 "XSP.yp"
{ make_type( $_[1] ) }
	],
	[#Rule 120
		 'nconsttype', 1, undef
	],
	[#Rule 121
		 'type_name', 1, undef
	],
	[#Rule 122
		 'type_name', 1, undef
	],
	[#Rule 123
		 'type_name', 1,
sub
#line 363 "XSP.yp"
{ 'unsigned int' }
	],
	[#Rule 124
		 'type_name', 2,
sub
#line 364 "XSP.yp"
{ 'unsigned' . ' ' . $_[2] }
	],
	[#Rule 125
		 'basic_type', 1, undef
	],
	[#Rule 126
		 'basic_type', 1, undef
	],
	[#Rule 127
		 'basic_type', 1, undef
	],
	[#Rule 128
		 'basic_type', 1, undef
	],
	[#Rule 129
		 'basic_type', 2, undef
	],
	[#Rule 130
		 'basic_type', 2, undef
	],
	[#Rule 131
		 'template', 4,
sub
#line 370 "XSP.yp"
{ make_template( $_[1], $_[3] ) }
	],
	[#Rule 132
		 'type_list', 1,
sub
#line 374 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 133
		 'type_list', 3,
sub
#line 375 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 134
		 'class_name', 1, undef
	],
	[#Rule 135
		 'class_name', 2,
sub
#line 379 "XSP.yp"
{ $_[1] . '::' . $_[2] }
	],
	[#Rule 136
		 'class_name_list', 1,
sub
#line 382 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 137
		 'class_name_list', 3,
sub
#line 383 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 138
		 'class_suffix', 2,
sub
#line 386 "XSP.yp"
{ $_[2] }
	],
	[#Rule 139
		 'class_suffix', 3,
sub
#line 387 "XSP.yp"
{ $_[1] . '::' . $_[3] }
	],
	[#Rule 140
		 'file_name', 1,
sub
#line 389 "XSP.yp"
{ '-' }
	],
	[#Rule 141
		 'file_name', 3,
sub
#line 390 "XSP.yp"
{ $_[1] . '.' . $_[3] }
	],
	[#Rule 142
		 'file_name', 3,
sub
#line 391 "XSP.yp"
{ $_[1] . '/' . $_[3] }
	],
	[#Rule 143
		 'arg_list', 1,
sub
#line 393 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 144
		 'arg_list', 3,
sub
#line 394 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 145
		 'arg_list', 0, undef
	],
	[#Rule 146
		 'argument', 5,
sub
#line 398 "XSP.yp"
{ make_argument( @_[0, 1], "length($_[4])" ) }
	],
	[#Rule 147
		 'argument', 4,
sub
#line 400 "XSP.yp"
{ make_argument( @_[0, 1, 2, 4] ) }
	],
	[#Rule 148
		 'argument', 2,
sub
#line 401 "XSP.yp"
{ make_argument( @_ ) }
	],
	[#Rule 149
		 'value', 1, undef
	],
	[#Rule 150
		 'value', 2,
sub
#line 404 "XSP.yp"
{ '-' . $_[2] }
	],
	[#Rule 151
		 'value', 1, undef
	],
	[#Rule 152
		 'value', 1, undef
	],
	[#Rule 153
		 'value', 1, undef
	],
	[#Rule 154
		 'value', 4,
sub
#line 408 "XSP.yp"
{ "$_[1]($_[3])" }
	],
	[#Rule 155
		 'value_list', 1, undef
	],
	[#Rule 156
		 'value_list', 3,
sub
#line 413 "XSP.yp"
{ "$_[1], $_[2]" }
	],
	[#Rule 157
		 'value_list', 0,
sub
#line 414 "XSP.yp"
{ "" }
	],
	[#Rule 158
		 'expression', 1, undef
	],
	[#Rule 159
		 'expression', 3,
sub
#line 420 "XSP.yp"
{ "$_[1] & $_[3]" }
	],
	[#Rule 160
		 'expression', 3,
sub
#line 422 "XSP.yp"
{ "$_[1] | $_[3]" }
	],
	[#Rule 161
		 'special_blocks', 1,
sub
#line 426 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 162
		 'special_blocks', 2,
sub
#line 428 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 163
		 'special_blocks', 0, undef
	],
	[#Rule 164
		 'special_block', 3,
sub
#line 432 "XSP.yp"
{ $_[2] }
	],
	[#Rule 165
		 'special_block', 2,
sub
#line 434 "XSP.yp"
{ [] }
	],
	[#Rule 166
		 'special_block_start', 1,
sub
#line 437 "XSP.yp"
{ push_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 167
		 'special_block_end', 1,
sub
#line 439 "XSP.yp"
{ pop_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 168
		 'lines', 1,
sub
#line 441 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 169
		 'lines', 2,
sub
#line 442 "XSP.yp"
{ push @{$_[1]}, $_[2]; $_[1] }
	]
],
                                  @_);
    bless($self,$class);
}

#line 444 "XSP.yp"


use ExtUtils::XSpp::Lexer;

1;
