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
			'ID' => 24,
			'p_typemap' => 3,
			'OPSPECIAL' => 29,
			'COMMENT' => 5,
			'p_exceptionmap' => 32,
			"class" => 7,
			'RAW_CODE' => 33,
			"const" => 9,
			"int" => 36,
			'p_module' => 14,
			'p_package' => 42,
			"enum" => 41,
			'p_loadplugin' => 40,
			'PREPROCESSOR' => 15,
			"short" => 16,
			'p_file' => 44,
			"unsigned" => 45,
			'p_name' => 18,
			'p_include' => 19,
			"long" => 20,
			"char" => 23
		},
		GOTOS => {
			'perc_loadplugin' => 25,
			'class_name' => 1,
			'top_list' => 2,
			'perc_package' => 28,
			'function' => 27,
			'nconsttype' => 26,
			'looks_like_function' => 4,
			'exceptionmap' => 30,
			'special_block_start' => 31,
			'perc_name' => 6,
			'class_decl' => 34,
			'typemap' => 8,
			'enum' => 35,
			'decorate_class' => 10,
			'special_block' => 11,
			'perc_module' => 37,
			'type_name' => 12,
			'perc_file' => 39,
			'basic_type' => 38,
			'template' => 13,
			'looks_like_renamed_function' => 43,
			'top' => 17,
			'function_decl' => 46,
			'perc_include' => 47,
			'directive' => 48,
			'type' => 21,
			'class' => 22,
			'raw' => 49
		}
	},
	{#State 1
		ACTIONS => {
			'OPANG' => 50
		},
		DEFAULT => -116
	},
	{#State 2
		ACTIONS => {
			'ID' => 24,
			'' => 51,
			'p_typemap' => 3,
			'OPSPECIAL' => 29,
			'COMMENT' => 5,
			'p_exceptionmap' => 32,
			"class" => 7,
			'RAW_CODE' => 33,
			"const" => 9,
			"int" => 36,
			'p_module' => 14,
			"enum" => 41,
			'p_package' => 42,
			'p_loadplugin' => 40,
			'PREPROCESSOR' => 15,
			"short" => 16,
			'p_file' => 44,
			"unsigned" => 45,
			'p_name' => 18,
			'p_include' => 19,
			"long" => 20,
			"char" => 23
		},
		GOTOS => {
			'perc_loadplugin' => 25,
			'class_name' => 1,
			'function' => 27,
			'perc_package' => 28,
			'nconsttype' => 26,
			'looks_like_function' => 4,
			'exceptionmap' => 30,
			'special_block_start' => 31,
			'perc_name' => 6,
			'class_decl' => 34,
			'typemap' => 8,
			'enum' => 35,
			'decorate_class' => 10,
			'special_block' => 11,
			'perc_module' => 37,
			'type_name' => 12,
			'perc_file' => 39,
			'basic_type' => 38,
			'template' => 13,
			'looks_like_renamed_function' => 43,
			'top' => 52,
			'function_decl' => 46,
			'perc_include' => 47,
			'directive' => 48,
			'type' => 21,
			'class' => 22,
			'raw' => 49
		}
	},
	{#State 3
		ACTIONS => {
			'OPCURLY' => 53
		}
	},
	{#State 4
		DEFAULT => -73
	},
	{#State 5
		DEFAULT => -23
	},
	{#State 6
		ACTIONS => {
			'ID' => 24,
			"class" => 7,
			"short" => 16,
			"const" => 9,
			"unsigned" => 45,
			"long" => 20,
			"int" => 36,
			"char" => 23
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 38,
			'nconsttype' => 26,
			'template' => 13,
			'looks_like_function' => 54,
			'class_decl' => 55,
			'type' => 21
		}
	},
	{#State 7
		ACTIONS => {
			'ID' => 56
		}
	},
	{#State 8
		DEFAULT => -13
	},
	{#State 9
		ACTIONS => {
			'ID' => 24,
			"short" => 16,
			"unsigned" => 45,
			"long" => 20,
			"int" => 36,
			"char" => 23
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 38,
			'nconsttype' => 57,
			'template' => 13
		}
	},
	{#State 10
		ACTIONS => {
			'SEMICOLON' => 58
		}
	},
	{#State 11
		DEFAULT => -25
	},
	{#State 12
		DEFAULT => -114
	},
	{#State 13
		DEFAULT => -115
	},
	{#State 14
		ACTIONS => {
			'OPCURLY' => 59
		}
	},
	{#State 15
		DEFAULT => -24
	},
	{#State 16
		ACTIONS => {
			"int" => 60
		},
		DEFAULT => -123
	},
	{#State 17
		DEFAULT => -1
	},
	{#State 18
		ACTIONS => {
			'OPCURLY' => 61
		}
	},
	{#State 19
		ACTIONS => {
			'OPCURLY' => 62
		}
	},
	{#State 20
		ACTIONS => {
			"int" => 63
		},
		DEFAULT => -122
	},
	{#State 21
		ACTIONS => {
			'ID' => 64
		}
	},
	{#State 22
		DEFAULT => -4
	},
	{#State 23
		DEFAULT => -120
	},
	{#State 24
		ACTIONS => {
			'DCOLON' => 66
		},
		DEFAULT => -129,
		GOTOS => {
			'class_suffix' => 65
		}
	},
	{#State 25
		ACTIONS => {
			'SEMICOLON' => 67
		}
	},
	{#State 26
		ACTIONS => {
			'STAR' => 69,
			'AMP' => 68
		},
		DEFAULT => -111
	},
	{#State 27
		DEFAULT => -7
	},
	{#State 28
		ACTIONS => {
			'SEMICOLON' => 70
		}
	},
	{#State 29
		DEFAULT => -161
	},
	{#State 30
		DEFAULT => -14
	},
	{#State 31
		ACTIONS => {
			'CLSPECIAL' => 71,
			'line' => 72
		},
		GOTOS => {
			'special_block_end' => 73,
			'lines' => 74
		}
	},
	{#State 32
		ACTIONS => {
			'OPCURLY' => 75
		}
	},
	{#State 33
		DEFAULT => -22
	},
	{#State 34
		ACTIONS => {
			'SEMICOLON' => 76
		}
	},
	{#State 35
		DEFAULT => -6
	},
	{#State 36
		DEFAULT => -121
	},
	{#State 37
		ACTIONS => {
			'SEMICOLON' => 77
		}
	},
	{#State 38
		DEFAULT => -117
	},
	{#State 39
		ACTIONS => {
			'SEMICOLON' => 78
		}
	},
	{#State 40
		ACTIONS => {
			'OPCURLY' => 79
		}
	},
	{#State 41
		ACTIONS => {
			'ID' => 81,
			'OPCURLY' => 80
		}
	},
	{#State 42
		ACTIONS => {
			'OPCURLY' => 82
		}
	},
	{#State 43
		DEFAULT => -81,
		GOTOS => {
			'function_metadata' => 83
		}
	},
	{#State 44
		ACTIONS => {
			'OPCURLY' => 84
		}
	},
	{#State 45
		ACTIONS => {
			"short" => 16,
			"long" => 20,
			"int" => 36,
			"char" => 23
		},
		DEFAULT => -118,
		GOTOS => {
			'basic_type' => 85
		}
	},
	{#State 46
		ACTIONS => {
			'SEMICOLON' => 86
		}
	},
	{#State 47
		ACTIONS => {
			'SEMICOLON' => 87
		}
	},
	{#State 48
		DEFAULT => -5
	},
	{#State 49
		DEFAULT => -3
	},
	{#State 50
		ACTIONS => {
			'ID' => 24,
			"short" => 16,
			"unsigned" => 45,
			"const" => 9,
			"long" => 20,
			"int" => 36,
			"char" => 23
		},
		GOTOS => {
			'type_list' => 89,
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 38,
			'nconsttype' => 26,
			'template' => 13,
			'type' => 88
		}
	},
	{#State 51
		DEFAULT => 0
	},
	{#State 52
		DEFAULT => -2
	},
	{#State 53
		ACTIONS => {
			'ID' => 24,
			"short" => 16,
			"unsigned" => 45,
			"const" => 9,
			"long" => 20,
			"int" => 36,
			"char" => 23
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 38,
			'nconsttype' => 26,
			'template' => 13,
			'type' => 90
		}
	},
	{#State 54
		DEFAULT => -74
	},
	{#State 55
		DEFAULT => -38
	},
	{#State 56
		ACTIONS => {
			'COLON' => 92
		},
		DEFAULT => -42,
		GOTOS => {
			'base_classes' => 91
		}
	},
	{#State 57
		ACTIONS => {
			'STAR' => 69,
			'AMP' => 68
		},
		DEFAULT => -110
	},
	{#State 58
		DEFAULT => -35
	},
	{#State 59
		ACTIONS => {
			'ID' => 24
		},
		GOTOS => {
			'class_name' => 93
		}
	},
	{#State 60
		DEFAULT => -125
	},
	{#State 61
		ACTIONS => {
			'ID' => 24
		},
		GOTOS => {
			'class_name' => 94
		}
	},
	{#State 62
		ACTIONS => {
			'ID' => 96,
			'DASH' => 97
		},
		GOTOS => {
			'file_name' => 95
		}
	},
	{#State 63
		DEFAULT => -124
	},
	{#State 64
		ACTIONS => {
			'OPPAR' => 98
		}
	},
	{#State 65
		ACTIONS => {
			'DCOLON' => 99
		},
		DEFAULT => -130
	},
	{#State 66
		ACTIONS => {
			'ID' => 100
		}
	},
	{#State 67
		DEFAULT => -11
	},
	{#State 68
		DEFAULT => -113
	},
	{#State 69
		DEFAULT => -112
	},
	{#State 70
		DEFAULT => -9
	},
	{#State 71
		DEFAULT => -162
	},
	{#State 72
		DEFAULT => -163
	},
	{#State 73
		DEFAULT => -160
	},
	{#State 74
		ACTIONS => {
			'CLSPECIAL' => 71,
			'line' => 101
		},
		GOTOS => {
			'special_block_end' => 102
		}
	},
	{#State 75
		ACTIONS => {
			'ID' => 103
		}
	},
	{#State 76
		DEFAULT => -34
	},
	{#State 77
		DEFAULT => -8
	},
	{#State 78
		DEFAULT => -10
	},
	{#State 79
		ACTIONS => {
			'ID' => 24
		},
		GOTOS => {
			'class_name' => 104
		}
	},
	{#State 80
		DEFAULT => -28,
		GOTOS => {
			'enum_element_list' => 105
		}
	},
	{#State 81
		ACTIONS => {
			'OPCURLY' => 106
		}
	},
	{#State 82
		ACTIONS => {
			'ID' => 24
		},
		GOTOS => {
			'class_name' => 107
		}
	},
	{#State 83
		ACTIONS => {
			'p_code' => 114,
			'p_cleanup' => 110,
			'p_any' => 109,
			'p_catch' => 118,
			'p_postcall' => 112
		},
		DEFAULT => -75,
		GOTOS => {
			'perc_postcall' => 113,
			'perc_code' => 108,
			'perc_any' => 115,
			'perc_cleanup' => 116,
			'perc_catch' => 111,
			'_function_metadata' => 117
		}
	},
	{#State 84
		ACTIONS => {
			'ID' => 96,
			'DASH' => 97
		},
		GOTOS => {
			'file_name' => 119
		}
	},
	{#State 85
		DEFAULT => -119
	},
	{#State 86
		DEFAULT => -36
	},
	{#State 87
		DEFAULT => -12
	},
	{#State 88
		DEFAULT => -127
	},
	{#State 89
		ACTIONS => {
			'CLANG' => 120,
			'COMMA' => 121
		}
	},
	{#State 90
		ACTIONS => {
			'CLCURLY' => 122
		}
	},
	{#State 91
		ACTIONS => {
			'COMMA' => 124
		},
		DEFAULT => -50,
		GOTOS => {
			'class_metadata' => 123
		}
	},
	{#State 92
		ACTIONS => {
			"protected" => 128,
			"private" => 127,
			"public" => 125
		},
		GOTOS => {
			'base_class' => 126
		}
	},
	{#State 93
		ACTIONS => {
			'CLCURLY' => 129
		}
	},
	{#State 94
		ACTIONS => {
			'CLCURLY' => 130
		}
	},
	{#State 95
		ACTIONS => {
			'CLCURLY' => 131
		}
	},
	{#State 96
		ACTIONS => {
			'DOT' => 133,
			'SLASH' => 132
		}
	},
	{#State 97
		DEFAULT => -135
	},
	{#State 98
		ACTIONS => {
			'ID' => 24,
			"short" => 16,
			"const" => 9,
			"unsigned" => 45,
			"long" => 20,
			"int" => 36,
			"char" => 23
		},
		DEFAULT => -140,
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 38,
			'nconsttype' => 26,
			'template' => 13,
			'arg_list' => 135,
			'argument' => 136,
			'type' => 134
		}
	},
	{#State 99
		ACTIONS => {
			'ID' => 137
		}
	},
	{#State 100
		DEFAULT => -133
	},
	{#State 101
		DEFAULT => -164
	},
	{#State 102
		DEFAULT => -159
	},
	{#State 103
		ACTIONS => {
			'CLCURLY' => 138
		}
	},
	{#State 104
		ACTIONS => {
			'CLCURLY' => 139
		}
	},
	{#State 105
		ACTIONS => {
			'ID' => 140,
			'PREPROCESSOR' => 15,
			'RAW_CODE' => 33,
			'OPSPECIAL' => 29,
			'COMMENT' => 5,
			'CLCURLY' => 142
		},
		GOTOS => {
			'enum_element' => 141,
			'special_block' => 11,
			'raw' => 143,
			'special_block_start' => 31
		}
	},
	{#State 106
		DEFAULT => -28,
		GOTOS => {
			'enum_element_list' => 144
		}
	},
	{#State 107
		ACTIONS => {
			'CLCURLY' => 145
		}
	},
	{#State 108
		DEFAULT => -88
	},
	{#State 109
		ACTIONS => {
			'OPSPECIAL' => 29,
			'OPCURLY' => 146
		},
		DEFAULT => -106,
		GOTOS => {
			'special_block' => 147,
			'special_block_start' => 31
		}
	},
	{#State 110
		ACTIONS => {
			'OPSPECIAL' => 29
		},
		GOTOS => {
			'special_block' => 148,
			'special_block_start' => 31
		}
	},
	{#State 111
		DEFAULT => -91
	},
	{#State 112
		ACTIONS => {
			'OPSPECIAL' => 29
		},
		GOTOS => {
			'special_block' => 149,
			'special_block_start' => 31
		}
	},
	{#State 113
		DEFAULT => -90
	},
	{#State 114
		ACTIONS => {
			'OPSPECIAL' => 29
		},
		GOTOS => {
			'special_block' => 150,
			'special_block_start' => 31
		}
	},
	{#State 115
		DEFAULT => -92
	},
	{#State 116
		DEFAULT => -89
	},
	{#State 117
		DEFAULT => -80
	},
	{#State 118
		ACTIONS => {
			'OPCURLY' => 151
		}
	},
	{#State 119
		ACTIONS => {
			'CLCURLY' => 152
		}
	},
	{#State 120
		DEFAULT => -126
	},
	{#State 121
		ACTIONS => {
			'ID' => 24,
			"short" => 16,
			"unsigned" => 45,
			"const" => 9,
			"long" => 20,
			"int" => 36,
			"char" => 23
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 38,
			'nconsttype' => 26,
			'template' => 13,
			'type' => 153
		}
	},
	{#State 122
		ACTIONS => {
			'OPCURLY' => 154
		}
	},
	{#State 123
		ACTIONS => {
			'OPCURLY' => 155,
			'p_any' => 109,
			'p_catch' => 118
		},
		GOTOS => {
			'perc_any' => 157,
			'perc_catch' => 156
		}
	},
	{#State 124
		ACTIONS => {
			"protected" => 128,
			"private" => 127,
			"public" => 125
		},
		GOTOS => {
			'base_class' => 158
		}
	},
	{#State 125
		ACTIONS => {
			'ID' => 24,
			'p_name' => 18
		},
		GOTOS => {
			'perc_name' => 160,
			'class_name' => 159,
			'class_name_rename' => 161
		}
	},
	{#State 126
		DEFAULT => -40
	},
	{#State 127
		ACTIONS => {
			'ID' => 24,
			'p_name' => 18
		},
		GOTOS => {
			'perc_name' => 160,
			'class_name' => 159,
			'class_name_rename' => 162
		}
	},
	{#State 128
		ACTIONS => {
			'ID' => 24,
			'p_name' => 18
		},
		GOTOS => {
			'perc_name' => 160,
			'class_name' => 159,
			'class_name_rename' => 163
		}
	},
	{#State 129
		DEFAULT => -95
	},
	{#State 130
		DEFAULT => -93
	},
	{#State 131
		DEFAULT => -98
	},
	{#State 132
		ACTIONS => {
			'ID' => 96,
			'DASH' => 97
		},
		GOTOS => {
			'file_name' => 164
		}
	},
	{#State 133
		ACTIONS => {
			'ID' => 165
		}
	},
	{#State 134
		ACTIONS => {
			'ID' => 167,
			'p_length' => 166
		}
	},
	{#State 135
		ACTIONS => {
			'CLPAR' => 168,
			'COMMA' => 169
		}
	},
	{#State 136
		DEFAULT => -138
	},
	{#State 137
		DEFAULT => -134
	},
	{#State 138
		ACTIONS => {
			'OPCURLY' => 170
		}
	},
	{#State 139
		DEFAULT => -97
	},
	{#State 140
		ACTIONS => {
			'EQUAL' => 171
		},
		DEFAULT => -31
	},
	{#State 141
		ACTIONS => {
			'COMMA' => 172
		},
		DEFAULT => -29
	},
	{#State 142
		ACTIONS => {
			'SEMICOLON' => 173
		}
	},
	{#State 143
		DEFAULT => -33
	},
	{#State 144
		ACTIONS => {
			'ID' => 140,
			'PREPROCESSOR' => 15,
			'RAW_CODE' => 33,
			'OPSPECIAL' => 29,
			'COMMENT' => 5,
			'CLCURLY' => 174
		},
		GOTOS => {
			'enum_element' => 141,
			'special_block' => 11,
			'raw' => 143,
			'special_block_start' => 31
		}
	},
	{#State 145
		DEFAULT => -94
	},
	{#State 146
		ACTIONS => {
			'ID' => 177,
			'p_any' => 175
		},
		GOTOS => {
			'perc_any_arg' => 176,
			'perc_any_args' => 178
		}
	},
	{#State 147
		DEFAULT => -20,
		GOTOS => {
			'mixed_blocks' => 179
		}
	},
	{#State 148
		DEFAULT => -100
	},
	{#State 149
		DEFAULT => -101
	},
	{#State 150
		DEFAULT => -99
	},
	{#State 151
		ACTIONS => {
			'ID' => 24
		},
		GOTOS => {
			'class_name' => 180,
			'class_name_list' => 181
		}
	},
	{#State 152
		DEFAULT => -96
	},
	{#State 153
		DEFAULT => -128
	},
	{#State 154
		ACTIONS => {
			'ID' => 182
		}
	},
	{#State 155
		DEFAULT => -51,
		GOTOS => {
			'class_body_list' => 183
		}
	},
	{#State 156
		DEFAULT => -48
	},
	{#State 157
		DEFAULT => -49
	},
	{#State 158
		DEFAULT => -41
	},
	{#State 159
		DEFAULT => -46
	},
	{#State 160
		ACTIONS => {
			'ID' => 24
		},
		GOTOS => {
			'class_name' => 184
		}
	},
	{#State 161
		DEFAULT => -43
	},
	{#State 162
		DEFAULT => -45
	},
	{#State 163
		DEFAULT => -44
	},
	{#State 164
		DEFAULT => -137
	},
	{#State 165
		DEFAULT => -136
	},
	{#State 166
		ACTIONS => {
			'OPCURLY' => 185
		}
	},
	{#State 167
		ACTIONS => {
			'EQUAL' => 186
		},
		DEFAULT => -143
	},
	{#State 168
		ACTIONS => {
			"const" => 187
		},
		DEFAULT => -67,
		GOTOS => {
			'const' => 188
		}
	},
	{#State 169
		ACTIONS => {
			'ID' => 24,
			"short" => 16,
			"unsigned" => 45,
			"const" => 9,
			"long" => 20,
			"int" => 36,
			"char" => 23
		},
		GOTOS => {
			'argument' => 189,
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 38,
			'nconsttype' => 26,
			'template' => 13,
			'type' => 134
		}
	},
	{#State 170
		ACTIONS => {
			'ID' => 24,
			"short" => 16,
			"unsigned" => 45,
			"long" => 20,
			"int" => 36,
			"char" => 23
		},
		GOTOS => {
			'type_name' => 191,
			'class_name' => 190,
			'basic_type' => 38
		}
	},
	{#State 171
		ACTIONS => {
			'ID' => 24,
			'INTEGER' => 194,
			'QUOTED_STRING' => 196,
			'DASH' => 198,
			'FLOAT' => 197
		},
		GOTOS => {
			'class_name' => 192,
			'value' => 195,
			'expression' => 193
		}
	},
	{#State 172
		DEFAULT => -30
	},
	{#State 173
		DEFAULT => -26
	},
	{#State 174
		ACTIONS => {
			'SEMICOLON' => 199
		}
	},
	{#State 175
		DEFAULT => -20,
		GOTOS => {
			'mixed_blocks' => 200
		}
	},
	{#State 176
		DEFAULT => -107
	},
	{#State 177
		ACTIONS => {
			'CLCURLY' => 201
		}
	},
	{#State 178
		ACTIONS => {
			'p_any' => 175,
			'CLCURLY' => 203
		},
		GOTOS => {
			'perc_any_arg' => 202
		}
	},
	{#State 179
		ACTIONS => {
			'OPSPECIAL' => 29,
			'OPCURLY' => 204
		},
		DEFAULT => -105,
		GOTOS => {
			'simple_block' => 206,
			'special_block' => 205,
			'special_block_start' => 31
		}
	},
	{#State 180
		DEFAULT => -131
	},
	{#State 181
		ACTIONS => {
			'COMMA' => 207,
			'CLCURLY' => 208
		}
	},
	{#State 182
		ACTIONS => {
			'CLCURLY' => 209
		}
	},
	{#State 183
		ACTIONS => {
			'ID' => 224,
			'p_typemap' => 3,
			'p_any' => 109,
			'OPSPECIAL' => 29,
			"virtual" => 225,
			'COMMENT' => 5,
			"class_static" => 211,
			"package_static" => 226,
			"public" => 212,
			'p_exceptionmap' => 32,
			'RAW_CODE' => 33,
			"const" => 9,
			"static" => 230,
			"int" => 36,
			"private" => 217,
			'CLCURLY' => 233,
			'PREPROCESSOR' => 15,
			"short" => 16,
			"unsigned" => 45,
			'p_name' => 18,
			'TILDE' => 220,
			"protected" => 221,
			"long" => 20,
			"char" => 23
		},
		GOTOS => {
			'class_name' => 1,
			'nconsttype' => 26,
			'looks_like_function' => 4,
			'static' => 210,
			'exceptionmap' => 227,
			'special_block_start' => 31,
			'perc_name' => 213,
			'typemap' => 214,
			'class_body_element' => 228,
			'method' => 229,
			'vmethod' => 215,
			'nmethod' => 216,
			'special_block' => 11,
			'access_specifier' => 218,
			'type_name' => 12,
			'ctor' => 219,
			'perc_any' => 231,
			'basic_type' => 38,
			'template' => 13,
			'virtual' => 232,
			'looks_like_renamed_function' => 234,
			'_vmethod' => 235,
			'type' => 21,
			'dtor' => 222,
			'raw' => 236,
			'method_decl' => 223
		}
	},
	{#State 184
		DEFAULT => -47
	},
	{#State 185
		ACTIONS => {
			'ID' => 237
		}
	},
	{#State 186
		ACTIONS => {
			'ID' => 24,
			'INTEGER' => 194,
			'QUOTED_STRING' => 196,
			'DASH' => 198,
			'FLOAT' => 197
		},
		GOTOS => {
			'class_name' => 192,
			'value' => 195,
			'expression' => 238
		}
	},
	{#State 187
		DEFAULT => -66
	},
	{#State 188
		DEFAULT => -72
	},
	{#State 189
		DEFAULT => -139
	},
	{#State 190
		DEFAULT => -116
	},
	{#State 191
		ACTIONS => {
			'CLCURLY' => 239
		}
	},
	{#State 192
		ACTIONS => {
			'OPPAR' => 240
		},
		DEFAULT => -148
	},
	{#State 193
		DEFAULT => -32
	},
	{#State 194
		DEFAULT => -144
	},
	{#State 195
		ACTIONS => {
			'AMP' => 241,
			'PIPE' => 242
		},
		DEFAULT => -153
	},
	{#State 196
		DEFAULT => -147
	},
	{#State 197
		DEFAULT => -146
	},
	{#State 198
		ACTIONS => {
			'INTEGER' => 243
		}
	},
	{#State 199
		DEFAULT => -27
	},
	{#State 200
		ACTIONS => {
			'OPCURLY' => 204,
			'OPSPECIAL' => 29,
			'SEMICOLON' => 244
		},
		GOTOS => {
			'simple_block' => 206,
			'special_block' => 205,
			'special_block_start' => 31
		}
	},
	{#State 201
		DEFAULT => -20,
		GOTOS => {
			'mixed_blocks' => 245
		}
	},
	{#State 202
		DEFAULT => -108
	},
	{#State 203
		DEFAULT => -103
	},
	{#State 204
		ACTIONS => {
			'ID' => 246
		}
	},
	{#State 205
		DEFAULT => -18
	},
	{#State 206
		DEFAULT => -19
	},
	{#State 207
		ACTIONS => {
			'ID' => 24
		},
		GOTOS => {
			'class_name' => 247
		}
	},
	{#State 208
		DEFAULT => -102
	},
	{#State 209
		ACTIONS => {
			'OPCURLY' => 248,
			'OPSPECIAL' => 29
		},
		DEFAULT => -158,
		GOTOS => {
			'special_blocks' => 250,
			'special_block' => 249,
			'special_block_start' => 31
		}
	},
	{#State 210
		ACTIONS => {
			'ID' => 24,
			"class_static" => 211,
			"package_static" => 226,
			"short" => 16,
			"unsigned" => 45,
			"const" => 9,
			'p_name' => 18,
			"long" => 20,
			"static" => 230,
			"int" => 36,
			"char" => 23
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 38,
			'nconsttype' => 26,
			'template' => 13,
			'looks_like_function' => 4,
			'static' => 210,
			'perc_name' => 251,
			'looks_like_renamed_function' => 234,
			'nmethod' => 252,
			'type' => 21
		}
	},
	{#State 211
		DEFAULT => -70
	},
	{#State 212
		ACTIONS => {
			'COLON' => 253
		}
	},
	{#State 213
		ACTIONS => {
			'ID' => 224,
			"virtual" => 225,
			"short" => 16,
			"unsigned" => 45,
			"const" => 9,
			'p_name' => 18,
			'TILDE' => 220,
			"long" => 20,
			"int" => 36,
			"char" => 23
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'ctor' => 256,
			'basic_type' => 38,
			'nconsttype' => 26,
			'template' => 13,
			'looks_like_function' => 54,
			'virtual' => 232,
			'perc_name' => 254,
			'_vmethod' => 235,
			'dtor' => 257,
			'vmethod' => 255,
			'type' => 21
		}
	},
	{#State 214
		DEFAULT => -55
	},
	{#State 215
		DEFAULT => -63
	},
	{#State 216
		DEFAULT => -62
	},
	{#State 217
		ACTIONS => {
			'COLON' => 258
		}
	},
	{#State 218
		DEFAULT => -57
	},
	{#State 219
		DEFAULT => -64
	},
	{#State 220
		ACTIONS => {
			'ID' => 259
		}
	},
	{#State 221
		ACTIONS => {
			'COLON' => 260
		}
	},
	{#State 222
		DEFAULT => -65
	},
	{#State 223
		ACTIONS => {
			'SEMICOLON' => 261
		}
	},
	{#State 224
		ACTIONS => {
			'DCOLON' => 66,
			'OPPAR' => 262
		},
		DEFAULT => -129,
		GOTOS => {
			'class_suffix' => 65
		}
	},
	{#State 225
		DEFAULT => -68
	},
	{#State 226
		DEFAULT => -69
	},
	{#State 227
		DEFAULT => -56
	},
	{#State 228
		DEFAULT => -52
	},
	{#State 229
		DEFAULT => -53
	},
	{#State 230
		DEFAULT => -71
	},
	{#State 231
		ACTIONS => {
			'SEMICOLON' => 263
		}
	},
	{#State 232
		ACTIONS => {
			'ID' => 24,
			"short" => 16,
			"unsigned" => 45,
			"const" => 9,
			"long" => 20,
			"int" => 36,
			"char" => 23
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 38,
			'nconsttype' => 26,
			'template' => 13,
			'looks_like_function' => 264,
			'type' => 21
		}
	},
	{#State 233
		DEFAULT => -39
	},
	{#State 234
		DEFAULT => -81,
		GOTOS => {
			'function_metadata' => 265
		}
	},
	{#State 235
		DEFAULT => -84
	},
	{#State 236
		DEFAULT => -54
	},
	{#State 237
		ACTIONS => {
			'CLCURLY' => 266
		}
	},
	{#State 238
		DEFAULT => -142
	},
	{#State 239
		ACTIONS => {
			'OPCURLY' => 267
		}
	},
	{#State 240
		ACTIONS => {
			'ID' => 24,
			'INTEGER' => 194,
			'QUOTED_STRING' => 196,
			'DASH' => 198,
			'FLOAT' => 197
		},
		DEFAULT => -152,
		GOTOS => {
			'class_name' => 192,
			'value_list' => 268,
			'value' => 269
		}
	},
	{#State 241
		ACTIONS => {
			'ID' => 24,
			'INTEGER' => 194,
			'QUOTED_STRING' => 196,
			'DASH' => 198,
			'FLOAT' => 197
		},
		GOTOS => {
			'class_name' => 192,
			'value' => 270
		}
	},
	{#State 242
		ACTIONS => {
			'ID' => 24,
			'INTEGER' => 194,
			'QUOTED_STRING' => 196,
			'DASH' => 198,
			'FLOAT' => 197
		},
		GOTOS => {
			'class_name' => 192,
			'value' => 271
		}
	},
	{#State 243
		DEFAULT => -145
	},
	{#State 244
		DEFAULT => -109
	},
	{#State 245
		ACTIONS => {
			'OPSPECIAL' => 29,
			'OPCURLY' => 204
		},
		DEFAULT => -104,
		GOTOS => {
			'simple_block' => 206,
			'special_block' => 205,
			'special_block_start' => 31
		}
	},
	{#State 246
		ACTIONS => {
			'CLCURLY' => 272
		}
	},
	{#State 247
		DEFAULT => -132
	},
	{#State 248
		ACTIONS => {
			'p_any' => 175
		},
		GOTOS => {
			'perc_any_arg' => 176,
			'perc_any_args' => 273
		}
	},
	{#State 249
		DEFAULT => -156
	},
	{#State 250
		ACTIONS => {
			'OPSPECIAL' => 29,
			'SEMICOLON' => 275
		},
		GOTOS => {
			'special_block' => 274,
			'special_block_start' => 31
		}
	},
	{#State 251
		ACTIONS => {
			'ID' => 24,
			"short" => 16,
			"unsigned" => 45,
			"const" => 9,
			"long" => 20,
			"int" => 36,
			"char" => 23
		},
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 38,
			'nconsttype' => 26,
			'template' => 13,
			'looks_like_function' => 54,
			'type' => 21
		}
	},
	{#State 252
		DEFAULT => -83
	},
	{#State 253
		DEFAULT => -59
	},
	{#State 254
		ACTIONS => {
			'ID' => 276,
			'TILDE' => 220,
			'p_name' => 18,
			"virtual" => 225
		},
		GOTOS => {
			'perc_name' => 254,
			'ctor' => 256,
			'_vmethod' => 235,
			'dtor' => 257,
			'vmethod' => 255,
			'virtual' => 232
		}
	},
	{#State 255
		DEFAULT => -85
	},
	{#State 256
		DEFAULT => -77
	},
	{#State 257
		DEFAULT => -79
	},
	{#State 258
		DEFAULT => -61
	},
	{#State 259
		ACTIONS => {
			'OPPAR' => 277
		}
	},
	{#State 260
		DEFAULT => -60
	},
	{#State 261
		DEFAULT => -37
	},
	{#State 262
		ACTIONS => {
			'ID' => 24,
			"short" => 16,
			"const" => 9,
			"unsigned" => 45,
			"long" => 20,
			"int" => 36,
			"char" => 23
		},
		DEFAULT => -140,
		GOTOS => {
			'type_name' => 12,
			'class_name' => 1,
			'basic_type' => 38,
			'nconsttype' => 26,
			'template' => 13,
			'arg_list' => 278,
			'argument' => 136,
			'type' => 134
		}
	},
	{#State 263
		DEFAULT => -58
	},
	{#State 264
		ACTIONS => {
			'EQUAL' => 279
		},
		DEFAULT => -81,
		GOTOS => {
			'function_metadata' => 280
		}
	},
	{#State 265
		ACTIONS => {
			'p_code' => 114,
			'p_cleanup' => 110,
			'p_any' => 109,
			'p_catch' => 118,
			'p_postcall' => 112
		},
		DEFAULT => -82,
		GOTOS => {
			'perc_postcall' => 113,
			'perc_code' => 108,
			'perc_any' => 115,
			'perc_cleanup' => 116,
			'perc_catch' => 111,
			'_function_metadata' => 117
		}
	},
	{#State 266
		DEFAULT => -141
	},
	{#State 267
		ACTIONS => {
			'ID' => 281
		}
	},
	{#State 268
		ACTIONS => {
			'CLPAR' => 282,
			'COMMA' => 283
		}
	},
	{#State 269
		DEFAULT => -150
	},
	{#State 270
		DEFAULT => -154
	},
	{#State 271
		DEFAULT => -155
	},
	{#State 272
		DEFAULT => -21
	},
	{#State 273
		ACTIONS => {
			'p_any' => 175,
			'CLCURLY' => 284
		},
		GOTOS => {
			'perc_any_arg' => 202
		}
	},
	{#State 274
		DEFAULT => -157
	},
	{#State 275
		DEFAULT => -15
	},
	{#State 276
		ACTIONS => {
			'OPPAR' => 262
		}
	},
	{#State 277
		ACTIONS => {
			'CLPAR' => 285
		}
	},
	{#State 278
		ACTIONS => {
			'CLPAR' => 286,
			'COMMA' => 169
		}
	},
	{#State 279
		ACTIONS => {
			'INTEGER' => 287
		}
	},
	{#State 280
		ACTIONS => {
			'p_code' => 114,
			'p_cleanup' => 110,
			'p_any' => 109,
			'p_catch' => 118,
			'p_postcall' => 112
		},
		DEFAULT => -86,
		GOTOS => {
			'perc_postcall' => 113,
			'perc_code' => 108,
			'perc_any' => 115,
			'perc_cleanup' => 116,
			'perc_catch' => 111,
			'_function_metadata' => 117
		}
	},
	{#State 281
		ACTIONS => {
			'CLCURLY' => 288
		}
	},
	{#State 282
		DEFAULT => -149
	},
	{#State 283
		ACTIONS => {
			'ID' => 24,
			'INTEGER' => 194,
			'QUOTED_STRING' => 196,
			'DASH' => 198,
			'FLOAT' => 197
		},
		GOTOS => {
			'class_name' => 192,
			'value' => 289
		}
	},
	{#State 284
		ACTIONS => {
			'SEMICOLON' => 290
		}
	},
	{#State 285
		DEFAULT => -81,
		GOTOS => {
			'function_metadata' => 291
		}
	},
	{#State 286
		DEFAULT => -81,
		GOTOS => {
			'function_metadata' => 292
		}
	},
	{#State 287
		DEFAULT => -81,
		GOTOS => {
			'function_metadata' => 293
		}
	},
	{#State 288
		DEFAULT => -20,
		GOTOS => {
			'mixed_blocks' => 294
		}
	},
	{#State 289
		DEFAULT => -151
	},
	{#State 290
		DEFAULT => -16
	},
	{#State 291
		ACTIONS => {
			'p_code' => 114,
			'p_cleanup' => 110,
			'p_any' => 109,
			'p_catch' => 118,
			'p_postcall' => 112
		},
		DEFAULT => -78,
		GOTOS => {
			'perc_postcall' => 113,
			'perc_code' => 108,
			'perc_any' => 115,
			'perc_cleanup' => 116,
			'perc_catch' => 111,
			'_function_metadata' => 117
		}
	},
	{#State 292
		ACTIONS => {
			'p_code' => 114,
			'p_cleanup' => 110,
			'p_any' => 109,
			'p_catch' => 118,
			'p_postcall' => 112
		},
		DEFAULT => -76,
		GOTOS => {
			'perc_postcall' => 113,
			'perc_code' => 108,
			'perc_any' => 115,
			'perc_cleanup' => 116,
			'perc_catch' => 111,
			'_function_metadata' => 117
		}
	},
	{#State 293
		ACTIONS => {
			'p_code' => 114,
			'p_cleanup' => 110,
			'p_any' => 109,
			'p_catch' => 118,
			'p_postcall' => 112
		},
		DEFAULT => -87,
		GOTOS => {
			'perc_postcall' => 113,
			'perc_code' => 108,
			'perc_any' => 115,
			'perc_cleanup' => 116,
			'perc_catch' => 111,
			'_function_metadata' => 117
		}
	},
	{#State 294
		ACTIONS => {
			'OPCURLY' => 204,
			'OPSPECIAL' => 29,
			'SEMICOLON' => 295
		},
		GOTOS => {
			'simple_block' => 206,
			'special_block' => 205,
			'special_block_start' => 31
		}
	},
	{#State 295
		DEFAULT => -17
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
		 'directive', 1,
sub
#line 38 "XSP.yp"
{ }
	],
	[#Rule 14
		 'directive', 1,
sub
#line 39 "XSP.yp"
{ }
	],
	[#Rule 15
		 'typemap', 9,
sub
#line 44 "XSP.yp"
{ my $package = "ExtUtils::XSpp::Typemap::" . $_[6];
                      my $type = $_[3]; my $c = 0;
                      my %args = map { "arg" . ++$c => $_ }
                                 map { join( '', @$_ ) }
                                     @{$_[8] || []};
                      my $tm = $package->new( type => $type, %args );
                      ExtUtils::XSpp::Typemap::add_typemap_for_type( $type, $tm );
                      undef }
	],
	[#Rule 16
		 'typemap', 11,
sub
#line 54 "XSP.yp"
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
	[#Rule 17
		 'exceptionmap', 12,
sub
#line 70 "XSP.yp"
{ my $package = "ExtUtils::XSpp::Exception::" . $_[9];
                      my $type = make_type($_[6]); my $c = 0;
                      my %args = map { "arg" . ++$c => $_ }
                                 map { join( "\n", @$_ ) }
                                     @{$_[11] || []};
                      my $e = $package->new( name => $_[3], type => $type, %args );
                      ExtUtils::XSpp::Exception->add_exception( $e );
                      undef }
	],
	[#Rule 18
		 'mixed_blocks', 2,
sub
#line 80 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 19
		 'mixed_blocks', 2,
sub
#line 82 "XSP.yp"
{ [ @{$_[1]}, [ $_[2] ] ] }
	],
	[#Rule 20
		 'mixed_blocks', 0,
sub
#line 83 "XSP.yp"
{ [] }
	],
	[#Rule 21
		 'simple_block', 3,
sub
#line 86 "XSP.yp"
{ $_[2] }
	],
	[#Rule 22
		 'raw', 1,
sub
#line 88 "XSP.yp"
{ add_data_raw( $_[0], [ $_[1] ] ) }
	],
	[#Rule 23
		 'raw', 1,
sub
#line 89 "XSP.yp"
{ add_data_comment( $_[0], $_[1] ) }
	],
	[#Rule 24
		 'raw', 1,
sub
#line 90 "XSP.yp"
{ ExtUtils::XSpp::Node::Preprocessor->new
                              ( rows   => [ $_[1][0] ],
                                symbol => $_[1][1],
                                ) }
	],
	[#Rule 25
		 'raw', 1,
sub
#line 94 "XSP.yp"
{ add_data_raw( $_[0], [ @{$_[1]} ] ) }
	],
	[#Rule 26
		 'enum', 5,
sub
#line 98 "XSP.yp"
{ ExtUtils::XSpp::Node::Enum->new
                ( elements  => $_[3],
                  condition => $_[0]->get_conditional,
                  ) }
	],
	[#Rule 27
		 'enum', 6,
sub
#line 103 "XSP.yp"
{ ExtUtils::XSpp::Node::Enum->new
                ( name      => $_[2],
                  elements  => $_[4],
                  condition => $_[0]->get_conditional,
                  ) }
	],
	[#Rule 28
		 'enum_element_list', 0,
sub
#line 111 "XSP.yp"
{ [] }
	],
	[#Rule 29
		 'enum_element_list', 2,
sub
#line 113 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 30
		 'enum_element_list', 3,
sub
#line 115 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 31
		 'enum_element', 1,
sub
#line 120 "XSP.yp"
{ ExtUtils::XSpp::Node::EnumValue->new
                ( name => $_[1],
                  condition => $_[0]->get_conditional,
                  ) }
	],
	[#Rule 32
		 'enum_element', 3,
sub
#line 125 "XSP.yp"
{ ExtUtils::XSpp::Node::EnumValue->new
                ( name      => $_[1],
                  value     => $_[3],
                  condition => $_[0]->get_conditional,
                  ) }
	],
	[#Rule 33
		 'enum_element', 1, undef
	],
	[#Rule 34
		 'class', 2, undef
	],
	[#Rule 35
		 'class', 2, undef
	],
	[#Rule 36
		 'function', 2, undef
	],
	[#Rule 37
		 'method', 2, undef
	],
	[#Rule 38
		 'decorate_class', 2,
sub
#line 138 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 39
		 'class_decl', 7,
sub
#line 141 "XSP.yp"
{ create_class( $_[0], $_[2], $_[3], $_[4], $_[6],
                                $_[0]->get_conditional ) }
	],
	[#Rule 40
		 'base_classes', 2,
sub
#line 145 "XSP.yp"
{ [ $_[2] ] }
	],
	[#Rule 41
		 'base_classes', 3,
sub
#line 146 "XSP.yp"
{ push @{$_[1]}, $_[3] if $_[3]; $_[1] }
	],
	[#Rule 42
		 'base_classes', 0, undef
	],
	[#Rule 43
		 'base_class', 2,
sub
#line 150 "XSP.yp"
{ $_[2] }
	],
	[#Rule 44
		 'base_class', 2,
sub
#line 151 "XSP.yp"
{ $_[2] }
	],
	[#Rule 45
		 'base_class', 2,
sub
#line 152 "XSP.yp"
{ $_[2] }
	],
	[#Rule 46
		 'class_name_rename', 1,
sub
#line 156 "XSP.yp"
{ create_class( $_[0], $_[1], [], [] ) }
	],
	[#Rule 47
		 'class_name_rename', 2,
sub
#line 157 "XSP.yp"
{ my $klass = create_class( $_[0], $_[2], [], [] );
                             $klass->set_perl_name( $_[1] );
                             $klass
                             }
	],
	[#Rule 48
		 'class_metadata', 2,
sub
#line 163 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 49
		 'class_metadata', 2,
sub
#line 164 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 50
		 'class_metadata', 0,
sub
#line 165 "XSP.yp"
{ [] }
	],
	[#Rule 51
		 'class_body_list', 0,
sub
#line 169 "XSP.yp"
{ [] }
	],
	[#Rule 52
		 'class_body_list', 2,
sub
#line 171 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 53
		 'class_body_element', 1, undef
	],
	[#Rule 54
		 'class_body_element', 1, undef
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
		 'class_body_element', 2,
sub
#line 177 "XSP.yp"
{ ExtUtils::XSpp::Node::PercAny->new( @{$_[1]} ) }
	],
	[#Rule 59
		 'access_specifier', 2,
sub
#line 181 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 60
		 'access_specifier', 2,
sub
#line 182 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 61
		 'access_specifier', 2,
sub
#line 183 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 62
		 'method_decl', 1, undef
	],
	[#Rule 63
		 'method_decl', 1, undef
	],
	[#Rule 64
		 'method_decl', 1, undef
	],
	[#Rule 65
		 'method_decl', 1, undef
	],
	[#Rule 66
		 'const', 1,
sub
#line 188 "XSP.yp"
{ 1 }
	],
	[#Rule 67
		 'const', 0,
sub
#line 189 "XSP.yp"
{ 0 }
	],
	[#Rule 68
		 'virtual', 1, undef
	],
	[#Rule 69
		 'static', 1, undef
	],
	[#Rule 70
		 'static', 1, undef
	],
	[#Rule 71
		 'static', 1,
sub
#line 195 "XSP.yp"
{ 'package_static' }
	],
	[#Rule 72
		 'looks_like_function', 6,
sub
#line 200 "XSP.yp"
{
              return { ret_type  => $_[1],
                       name      => $_[2],
                       arguments => $_[4],
                       const     => $_[6],
                       };
          }
	],
	[#Rule 73
		 'looks_like_renamed_function', 1, undef
	],
	[#Rule 74
		 'looks_like_renamed_function', 2,
sub
#line 211 "XSP.yp"
{ $_[2]->{perl_name} = $_[1]; $_[2] }
	],
	[#Rule 75
		 'function_decl', 2,
sub
#line 214 "XSP.yp"
{ add_data_function( $_[0],
                                         name      => $_[1]->{name},
                                         perl_name => $_[1]->{perl_name},
                                         ret_type  => $_[1]->{ret_type},
                                         arguments => $_[1]->{arguments},
                                         condition => $_[0]->get_conditional,
                                         @{$_[2]} ) }
	],
	[#Rule 76
		 'ctor', 5,
sub
#line 223 "XSP.yp"
{ add_data_ctor( $_[0], name      => $_[1],
                                            arguments => $_[3],
                                            condition => $_[0]->get_conditional,
                                            @{ $_[5] } ) }
	],
	[#Rule 77
		 'ctor', 2,
sub
#line 227 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 78
		 'dtor', 5,
sub
#line 230 "XSP.yp"
{ add_data_dtor( $_[0], name  => $_[2],
                                            condition => $_[0]->get_conditional,
                                            @{ $_[5] },
                                      ) }
	],
	[#Rule 79
		 'dtor', 2,
sub
#line 234 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 80
		 'function_metadata', 2,
sub
#line 236 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 81
		 'function_metadata', 0,
sub
#line 237 "XSP.yp"
{ [] }
	],
	[#Rule 82
		 'nmethod', 2,
sub
#line 242 "XSP.yp"
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
	[#Rule 83
		 'nmethod', 2,
sub
#line 255 "XSP.yp"
{ $_[2]->set_static( $_[1] ); $_[2] }
	],
	[#Rule 84
		 'vmethod', 1, undef
	],
	[#Rule 85
		 'vmethod', 2,
sub
#line 260 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 86
		 '_vmethod', 3,
sub
#line 265 "XSP.yp"
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
	[#Rule 87
		 '_vmethod', 5,
sub
#line 279 "XSP.yp"
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
	[#Rule 88
		 '_function_metadata', 1, undef
	],
	[#Rule 89
		 '_function_metadata', 1, undef
	],
	[#Rule 90
		 '_function_metadata', 1, undef
	],
	[#Rule 91
		 '_function_metadata', 1, undef
	],
	[#Rule 92
		 '_function_metadata', 1, undef
	],
	[#Rule 93
		 'perc_name', 4,
sub
#line 302 "XSP.yp"
{ $_[3] }
	],
	[#Rule 94
		 'perc_package', 4,
sub
#line 303 "XSP.yp"
{ $_[3] }
	],
	[#Rule 95
		 'perc_module', 4,
sub
#line 304 "XSP.yp"
{ $_[3] }
	],
	[#Rule 96
		 'perc_file', 4,
sub
#line 305 "XSP.yp"
{ $_[3] }
	],
	[#Rule 97
		 'perc_loadplugin', 4,
sub
#line 306 "XSP.yp"
{ $_[3] }
	],
	[#Rule 98
		 'perc_include', 4,
sub
#line 307 "XSP.yp"
{ $_[3] }
	],
	[#Rule 99
		 'perc_code', 2,
sub
#line 308 "XSP.yp"
{ [ code => $_[2] ] }
	],
	[#Rule 100
		 'perc_cleanup', 2,
sub
#line 309 "XSP.yp"
{ [ cleanup => $_[2] ] }
	],
	[#Rule 101
		 'perc_postcall', 2,
sub
#line 310 "XSP.yp"
{ [ postcall => $_[2] ] }
	],
	[#Rule 102
		 'perc_catch', 4,
sub
#line 311 "XSP.yp"
{ [ map {(catch => $_)} @{$_[3]} ] }
	],
	[#Rule 103
		 'perc_any', 4,
sub
#line 316 "XSP.yp"
{ [ any => $_[1], any_named_arguments => $_[3] ] }
	],
	[#Rule 104
		 'perc_any', 5,
sub
#line 318 "XSP.yp"
{ [ any => $_[1], any_positional_arguments  => [ $_[3], @{$_[5]} ] ] }
	],
	[#Rule 105
		 'perc_any', 3,
sub
#line 320 "XSP.yp"
{ [ any => $_[1], any_positional_arguments  => [ $_[2], @{$_[3]} ] ] }
	],
	[#Rule 106
		 'perc_any', 1,
sub
#line 322 "XSP.yp"
{ [ any => $_[1] ] }
	],
	[#Rule 107
		 'perc_any_args', 1,
sub
#line 326 "XSP.yp"
{ $_[1] }
	],
	[#Rule 108
		 'perc_any_args', 2,
sub
#line 327 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 109
		 'perc_any_arg', 3,
sub
#line 331 "XSP.yp"
{ [ $_[1] => $_[2] ] }
	],
	[#Rule 110
		 'type', 2,
sub
#line 335 "XSP.yp"
{ make_const( $_[2] ) }
	],
	[#Rule 111
		 'type', 1, undef
	],
	[#Rule 112
		 'nconsttype', 2,
sub
#line 340 "XSP.yp"
{ make_ptr( $_[1] ) }
	],
	[#Rule 113
		 'nconsttype', 2,
sub
#line 341 "XSP.yp"
{ make_ref( $_[1] ) }
	],
	[#Rule 114
		 'nconsttype', 1,
sub
#line 342 "XSP.yp"
{ make_type( $_[1] ) }
	],
	[#Rule 115
		 'nconsttype', 1, undef
	],
	[#Rule 116
		 'type_name', 1, undef
	],
	[#Rule 117
		 'type_name', 1, undef
	],
	[#Rule 118
		 'type_name', 1,
sub
#line 349 "XSP.yp"
{ 'unsigned int' }
	],
	[#Rule 119
		 'type_name', 2,
sub
#line 350 "XSP.yp"
{ 'unsigned' . ' ' . $_[2] }
	],
	[#Rule 120
		 'basic_type', 1, undef
	],
	[#Rule 121
		 'basic_type', 1, undef
	],
	[#Rule 122
		 'basic_type', 1, undef
	],
	[#Rule 123
		 'basic_type', 1, undef
	],
	[#Rule 124
		 'basic_type', 2, undef
	],
	[#Rule 125
		 'basic_type', 2, undef
	],
	[#Rule 126
		 'template', 4,
sub
#line 356 "XSP.yp"
{ make_template( $_[1], $_[3] ) }
	],
	[#Rule 127
		 'type_list', 1,
sub
#line 360 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 128
		 'type_list', 3,
sub
#line 361 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 129
		 'class_name', 1, undef
	],
	[#Rule 130
		 'class_name', 2,
sub
#line 365 "XSP.yp"
{ $_[1] . '::' . $_[2] }
	],
	[#Rule 131
		 'class_name_list', 1,
sub
#line 368 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 132
		 'class_name_list', 3,
sub
#line 369 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 133
		 'class_suffix', 2,
sub
#line 372 "XSP.yp"
{ $_[2] }
	],
	[#Rule 134
		 'class_suffix', 3,
sub
#line 373 "XSP.yp"
{ $_[1] . '::' . $_[3] }
	],
	[#Rule 135
		 'file_name', 1,
sub
#line 375 "XSP.yp"
{ '-' }
	],
	[#Rule 136
		 'file_name', 3,
sub
#line 376 "XSP.yp"
{ $_[1] . '.' . $_[3] }
	],
	[#Rule 137
		 'file_name', 3,
sub
#line 377 "XSP.yp"
{ $_[1] . '/' . $_[3] }
	],
	[#Rule 138
		 'arg_list', 1,
sub
#line 379 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 139
		 'arg_list', 3,
sub
#line 380 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 140
		 'arg_list', 0, undef
	],
	[#Rule 141
		 'argument', 5,
sub
#line 384 "XSP.yp"
{ make_argument( @_[0, 1], "length($_[4])" ) }
	],
	[#Rule 142
		 'argument', 4,
sub
#line 386 "XSP.yp"
{ make_argument( @_[0, 1, 2, 4] ) }
	],
	[#Rule 143
		 'argument', 2,
sub
#line 387 "XSP.yp"
{ make_argument( @_ ) }
	],
	[#Rule 144
		 'value', 1, undef
	],
	[#Rule 145
		 'value', 2,
sub
#line 390 "XSP.yp"
{ '-' . $_[2] }
	],
	[#Rule 146
		 'value', 1, undef
	],
	[#Rule 147
		 'value', 1, undef
	],
	[#Rule 148
		 'value', 1, undef
	],
	[#Rule 149
		 'value', 4,
sub
#line 394 "XSP.yp"
{ "$_[1]($_[3])" }
	],
	[#Rule 150
		 'value_list', 1, undef
	],
	[#Rule 151
		 'value_list', 3,
sub
#line 399 "XSP.yp"
{ "$_[1], $_[2]" }
	],
	[#Rule 152
		 'value_list', 0,
sub
#line 400 "XSP.yp"
{ "" }
	],
	[#Rule 153
		 'expression', 1, undef
	],
	[#Rule 154
		 'expression', 3,
sub
#line 406 "XSP.yp"
{ "$_[1] & $_[3]" }
	],
	[#Rule 155
		 'expression', 3,
sub
#line 408 "XSP.yp"
{ "$_[1] | $_[3]" }
	],
	[#Rule 156
		 'special_blocks', 1,
sub
#line 412 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 157
		 'special_blocks', 2,
sub
#line 414 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 158
		 'special_blocks', 0, undef
	],
	[#Rule 159
		 'special_block', 3,
sub
#line 418 "XSP.yp"
{ $_[2] }
	],
	[#Rule 160
		 'special_block', 2,
sub
#line 420 "XSP.yp"
{ [] }
	],
	[#Rule 161
		 'special_block_start', 1,
sub
#line 423 "XSP.yp"
{ push_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 162
		 'special_block_end', 1,
sub
#line 425 "XSP.yp"
{ pop_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 163
		 'lines', 1,
sub
#line 427 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 164
		 'lines', 2,
sub
#line 428 "XSP.yp"
{ push @{$_[1]}, $_[2]; $_[1] }
	]
],
                                  @_);
    bless($self,$class);
}

#line 430 "XSP.yp"


use ExtUtils::XSpp::Lexer;

1;
