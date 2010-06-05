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
		DEFAULT => -117
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
		DEFAULT => -107,
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
		DEFAULT => -74
	},
	{#State 6
		DEFAULT => -24
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
		DEFAULT => -26
	},
	{#State 13
		DEFAULT => -115
	},
	{#State 14
		DEFAULT => -116
	},
	{#State 15
		ACTIONS => {
			'OPCURLY' => 63
		}
	},
	{#State 16
		DEFAULT => -25
	},
	{#State 17
		ACTIONS => {
			"int" => 64
		},
		DEFAULT => -124
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
		DEFAULT => -123
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
		DEFAULT => -121
	},
	{#State 25
		ACTIONS => {
			'DCOLON' => 70
		},
		DEFAULT => -130,
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
		DEFAULT => -112
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
		DEFAULT => -162
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
		DEFAULT => -23
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
		DEFAULT => -122
	},
	{#State 38
		ACTIONS => {
			'SEMICOLON' => 81
		}
	},
	{#State 39
		DEFAULT => -118
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
		DEFAULT => -82,
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
		DEFAULT => -119,
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
		DEFAULT => -21,
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
		DEFAULT => -75
	},
	{#State 59
		DEFAULT => -39
	},
	{#State 60
		ACTIONS => {
			'COLON' => 102
		},
		DEFAULT => -43,
		GOTOS => {
			'base_classes' => 101
		}
	},
	{#State 61
		ACTIONS => {
			'STAR' => 73,
			'AMP' => 72
		},
		DEFAULT => -111
	},
	{#State 62
		DEFAULT => -36
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
		DEFAULT => -126
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
		DEFAULT => -125
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
		DEFAULT => -131
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
		DEFAULT => -114
	},
	{#State 73
		DEFAULT => -113
	},
	{#State 74
		DEFAULT => -9
	},
	{#State 75
		DEFAULT => -163
	},
	{#State 76
		DEFAULT => -164
	},
	{#State 77
		DEFAULT => -161
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
		DEFAULT => -35
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
		DEFAULT => -29,
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
			'p_code' => 123,
			'p_cleanup' => 119,
			'p_any' => 3,
			'p_catch' => 127,
			'p_postcall' => 121
		},
		DEFAULT => -76,
		GOTOS => {
			'perc_postcall' => 122,
			'perc_code' => 118,
			'perc_any' => 124,
			'perc_cleanup' => 125,
			'perc_catch' => 120,
			'_function_metadata' => 126
		}
	},
	{#State 89
		ACTIONS => {
			'ID' => 106,
			'DASH' => 107
		},
		GOTOS => {
			'file_name' => 128
		}
	},
	{#State 90
		DEFAULT => -120
	},
	{#State 91
		DEFAULT => -37
	},
	{#State 92
		DEFAULT => -12
	},
	{#State 93
		DEFAULT => -128
	},
	{#State 94
		ACTIONS => {
			'CLANG' => 129,
			'COMMA' => 130
		}
	},
	{#State 95
		DEFAULT => -21,
		GOTOS => {
			'mixed_blocks' => 131
		}
	},
	{#State 96
		DEFAULT => -108
	},
	{#State 97
		ACTIONS => {
			'CLCURLY' => 132
		}
	},
	{#State 98
		ACTIONS => {
			'p_any' => 95,
			'CLCURLY' => 134
		},
		GOTOS => {
			'perc_any_arg' => 133
		}
	},
	{#State 99
		ACTIONS => {
			'OPSPECIAL' => 30,
			'OPCURLY' => 135
		},
		DEFAULT => -106,
		GOTOS => {
			'simple_block' => 137,
			'special_block' => 136,
			'special_block_start' => 32
		}
	},
	{#State 100
		ACTIONS => {
			'CLCURLY' => 138
		}
	},
	{#State 101
		ACTIONS => {
			'COMMA' => 140
		},
		DEFAULT => -51,
		GOTOS => {
			'class_metadata' => 139
		}
	},
	{#State 102
		ACTIONS => {
			"protected" => 144,
			"private" => 143,
			"public" => 141
		},
		GOTOS => {
			'base_class' => 142
		}
	},
	{#State 103
		ACTIONS => {
			'CLCURLY' => 145
		}
	},
	{#State 104
		ACTIONS => {
			'CLCURLY' => 146
		}
	},
	{#State 105
		ACTIONS => {
			'CLCURLY' => 147
		}
	},
	{#State 106
		ACTIONS => {
			'DOT' => 149,
			'SLASH' => 148
		}
	},
	{#State 107
		DEFAULT => -136
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
		DEFAULT => -141,
		GOTOS => {
			'type_name' => 13,
			'class_name' => 1,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'arg_list' => 151,
			'argument' => 152,
			'type' => 150
		}
	},
	{#State 109
		ACTIONS => {
			'ID' => 153
		}
	},
	{#State 110
		DEFAULT => -134
	},
	{#State 111
		DEFAULT => -165
	},
	{#State 112
		DEFAULT => -160
	},
	{#State 113
		ACTIONS => {
			'CLCURLY' => 154
		}
	},
	{#State 114
		ACTIONS => {
			'CLCURLY' => 155
		}
	},
	{#State 115
		ACTIONS => {
			'ID' => 156,
			'PREPROCESSOR' => 16,
			'RAW_CODE' => 34,
			'OPSPECIAL' => 30,
			'COMMENT' => 6,
			'CLCURLY' => 158
		},
		GOTOS => {
			'enum_element' => 157,
			'special_block' => 12,
			'raw' => 159,
			'special_block_start' => 32
		}
	},
	{#State 116
		DEFAULT => -29,
		GOTOS => {
			'enum_element_list' => 160
		}
	},
	{#State 117
		ACTIONS => {
			'CLCURLY' => 161
		}
	},
	{#State 118
		DEFAULT => -89
	},
	{#State 119
		ACTIONS => {
			'OPSPECIAL' => 30
		},
		GOTOS => {
			'special_block' => 162,
			'special_block_start' => 32
		}
	},
	{#State 120
		DEFAULT => -92
	},
	{#State 121
		ACTIONS => {
			'OPSPECIAL' => 30
		},
		GOTOS => {
			'special_block' => 163,
			'special_block_start' => 32
		}
	},
	{#State 122
		DEFAULT => -91
	},
	{#State 123
		ACTIONS => {
			'OPSPECIAL' => 30
		},
		GOTOS => {
			'special_block' => 164,
			'special_block_start' => 32
		}
	},
	{#State 124
		DEFAULT => -93
	},
	{#State 125
		DEFAULT => -90
	},
	{#State 126
		DEFAULT => -81
	},
	{#State 127
		ACTIONS => {
			'OPCURLY' => 165
		}
	},
	{#State 128
		ACTIONS => {
			'CLCURLY' => 166
		}
	},
	{#State 129
		DEFAULT => -127
	},
	{#State 130
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
			'type' => 167
		}
	},
	{#State 131
		ACTIONS => {
			'OPCURLY' => 135,
			'OPSPECIAL' => 30,
			'SEMICOLON' => 168
		},
		GOTOS => {
			'simple_block' => 137,
			'special_block' => 136,
			'special_block_start' => 32
		}
	},
	{#State 132
		DEFAULT => -21,
		GOTOS => {
			'mixed_blocks' => 169
		}
	},
	{#State 133
		DEFAULT => -109
	},
	{#State 134
		DEFAULT => -104
	},
	{#State 135
		ACTIONS => {
			'ID' => 170
		}
	},
	{#State 136
		DEFAULT => -19
	},
	{#State 137
		DEFAULT => -20
	},
	{#State 138
		ACTIONS => {
			'OPCURLY' => 171
		}
	},
	{#State 139
		ACTIONS => {
			'OPCURLY' => 172,
			'p_any' => 3,
			'p_catch' => 127
		},
		GOTOS => {
			'perc_any' => 174,
			'perc_catch' => 173
		}
	},
	{#State 140
		ACTIONS => {
			"protected" => 144,
			"private" => 143,
			"public" => 141
		},
		GOTOS => {
			'base_class' => 175
		}
	},
	{#State 141
		ACTIONS => {
			'ID' => 25,
			'p_name' => 19
		},
		GOTOS => {
			'perc_name' => 177,
			'class_name' => 176,
			'class_name_rename' => 178
		}
	},
	{#State 142
		DEFAULT => -41
	},
	{#State 143
		ACTIONS => {
			'ID' => 25,
			'p_name' => 19
		},
		GOTOS => {
			'perc_name' => 177,
			'class_name' => 176,
			'class_name_rename' => 179
		}
	},
	{#State 144
		ACTIONS => {
			'ID' => 25,
			'p_name' => 19
		},
		GOTOS => {
			'perc_name' => 177,
			'class_name' => 176,
			'class_name_rename' => 180
		}
	},
	{#State 145
		DEFAULT => -96
	},
	{#State 146
		DEFAULT => -94
	},
	{#State 147
		DEFAULT => -99
	},
	{#State 148
		ACTIONS => {
			'ID' => 106,
			'DASH' => 107
		},
		GOTOS => {
			'file_name' => 181
		}
	},
	{#State 149
		ACTIONS => {
			'ID' => 182
		}
	},
	{#State 150
		ACTIONS => {
			'ID' => 184,
			'p_length' => 183
		}
	},
	{#State 151
		ACTIONS => {
			'CLPAR' => 185,
			'COMMA' => 186
		}
	},
	{#State 152
		DEFAULT => -139
	},
	{#State 153
		DEFAULT => -135
	},
	{#State 154
		ACTIONS => {
			'OPCURLY' => 187
		}
	},
	{#State 155
		DEFAULT => -98
	},
	{#State 156
		ACTIONS => {
			'EQUAL' => 188
		},
		DEFAULT => -32
	},
	{#State 157
		ACTIONS => {
			'COMMA' => 189
		},
		DEFAULT => -30
	},
	{#State 158
		ACTIONS => {
			'SEMICOLON' => 190
		}
	},
	{#State 159
		DEFAULT => -34
	},
	{#State 160
		ACTIONS => {
			'ID' => 156,
			'PREPROCESSOR' => 16,
			'RAW_CODE' => 34,
			'OPSPECIAL' => 30,
			'COMMENT' => 6,
			'CLCURLY' => 191
		},
		GOTOS => {
			'enum_element' => 157,
			'special_block' => 12,
			'raw' => 159,
			'special_block_start' => 32
		}
	},
	{#State 161
		DEFAULT => -95
	},
	{#State 162
		DEFAULT => -101
	},
	{#State 163
		DEFAULT => -102
	},
	{#State 164
		DEFAULT => -100
	},
	{#State 165
		ACTIONS => {
			'ID' => 25
		},
		GOTOS => {
			'class_name' => 192,
			'class_name_list' => 193
		}
	},
	{#State 166
		DEFAULT => -97
	},
	{#State 167
		DEFAULT => -129
	},
	{#State 168
		DEFAULT => -110
	},
	{#State 169
		ACTIONS => {
			'OPSPECIAL' => 30,
			'OPCURLY' => 135
		},
		DEFAULT => -105,
		GOTOS => {
			'simple_block' => 137,
			'special_block' => 136,
			'special_block_start' => 32
		}
	},
	{#State 170
		ACTIONS => {
			'CLCURLY' => 194
		}
	},
	{#State 171
		ACTIONS => {
			'ID' => 195
		}
	},
	{#State 172
		DEFAULT => -52,
		GOTOS => {
			'class_body_list' => 196
		}
	},
	{#State 173
		DEFAULT => -49
	},
	{#State 174
		DEFAULT => -50
	},
	{#State 175
		DEFAULT => -42
	},
	{#State 176
		DEFAULT => -47
	},
	{#State 177
		ACTIONS => {
			'ID' => 25
		},
		GOTOS => {
			'class_name' => 197
		}
	},
	{#State 178
		DEFAULT => -44
	},
	{#State 179
		DEFAULT => -46
	},
	{#State 180
		DEFAULT => -45
	},
	{#State 181
		DEFAULT => -138
	},
	{#State 182
		DEFAULT => -137
	},
	{#State 183
		ACTIONS => {
			'OPCURLY' => 198
		}
	},
	{#State 184
		ACTIONS => {
			'EQUAL' => 199
		},
		DEFAULT => -144
	},
	{#State 185
		ACTIONS => {
			"const" => 200
		},
		DEFAULT => -68,
		GOTOS => {
			'const' => 201
		}
	},
	{#State 186
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
			'argument' => 202,
			'type_name' => 13,
			'class_name' => 1,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'type' => 150
		}
	},
	{#State 187
		ACTIONS => {
			'ID' => 25,
			"short" => 17,
			"unsigned" => 47,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		GOTOS => {
			'type_name' => 204,
			'class_name' => 203,
			'basic_type' => 39
		}
	},
	{#State 188
		ACTIONS => {
			'ID' => 25,
			'INTEGER' => 207,
			'QUOTED_STRING' => 209,
			'DASH' => 211,
			'FLOAT' => 210
		},
		GOTOS => {
			'class_name' => 205,
			'value' => 208,
			'expression' => 206
		}
	},
	{#State 189
		DEFAULT => -31
	},
	{#State 190
		DEFAULT => -27
	},
	{#State 191
		ACTIONS => {
			'SEMICOLON' => 212
		}
	},
	{#State 192
		DEFAULT => -132
	},
	{#State 193
		ACTIONS => {
			'COMMA' => 213,
			'CLCURLY' => 214
		}
	},
	{#State 194
		DEFAULT => -22
	},
	{#State 195
		ACTIONS => {
			'CLCURLY' => 215
		}
	},
	{#State 196
		ACTIONS => {
			'ID' => 230,
			'p_typemap' => 4,
			'p_any' => 3,
			'OPSPECIAL' => 30,
			"virtual" => 231,
			'COMMENT' => 6,
			"class_static" => 217,
			"package_static" => 232,
			"public" => 218,
			'p_exceptionmap' => 33,
			'RAW_CODE' => 34,
			"const" => 10,
			"static" => 236,
			"int" => 37,
			"private" => 223,
			'CLCURLY' => 239,
			'PREPROCESSOR' => 16,
			"short" => 17,
			"unsigned" => 47,
			'p_name' => 19,
			'TILDE' => 226,
			"protected" => 227,
			"long" => 21,
			"char" => 24
		},
		GOTOS => {
			'class_name' => 1,
			'nconsttype' => 27,
			'looks_like_function' => 5,
			'static' => 216,
			'exceptionmap' => 233,
			'special_block_start' => 32,
			'perc_name' => 219,
			'typemap' => 220,
			'class_body_element' => 234,
			'method' => 235,
			'vmethod' => 221,
			'nmethod' => 222,
			'special_block' => 12,
			'access_specifier' => 224,
			'type_name' => 13,
			'ctor' => 225,
			'perc_any' => 237,
			'basic_type' => 39,
			'template' => 14,
			'virtual' => 238,
			'looks_like_renamed_function' => 240,
			'_vmethod' => 241,
			'type' => 22,
			'dtor' => 228,
			'raw' => 242,
			'method_decl' => 229
		}
	},
	{#State 197
		DEFAULT => -48
	},
	{#State 198
		ACTIONS => {
			'ID' => 243
		}
	},
	{#State 199
		ACTIONS => {
			'ID' => 25,
			'INTEGER' => 207,
			'QUOTED_STRING' => 209,
			'DASH' => 211,
			'FLOAT' => 210
		},
		GOTOS => {
			'class_name' => 205,
			'value' => 208,
			'expression' => 244
		}
	},
	{#State 200
		DEFAULT => -67
	},
	{#State 201
		DEFAULT => -73
	},
	{#State 202
		DEFAULT => -140
	},
	{#State 203
		DEFAULT => -117
	},
	{#State 204
		ACTIONS => {
			'CLCURLY' => 245
		}
	},
	{#State 205
		ACTIONS => {
			'OPPAR' => 246
		},
		DEFAULT => -149
	},
	{#State 206
		DEFAULT => -33
	},
	{#State 207
		DEFAULT => -145
	},
	{#State 208
		ACTIONS => {
			'AMP' => 247,
			'PIPE' => 248
		},
		DEFAULT => -154
	},
	{#State 209
		DEFAULT => -148
	},
	{#State 210
		DEFAULT => -147
	},
	{#State 211
		ACTIONS => {
			'INTEGER' => 249
		}
	},
	{#State 212
		DEFAULT => -28
	},
	{#State 213
		ACTIONS => {
			'ID' => 25
		},
		GOTOS => {
			'class_name' => 250
		}
	},
	{#State 214
		DEFAULT => -103
	},
	{#State 215
		ACTIONS => {
			'OPCURLY' => 251,
			'OPSPECIAL' => 30
		},
		DEFAULT => -159,
		GOTOS => {
			'special_blocks' => 253,
			'special_block' => 252,
			'special_block_start' => 32
		}
	},
	{#State 216
		ACTIONS => {
			'ID' => 25,
			"class_static" => 217,
			"package_static" => 232,
			"short" => 17,
			"unsigned" => 47,
			"const" => 10,
			'p_name' => 19,
			"long" => 21,
			"static" => 236,
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
			'static' => 216,
			'perc_name' => 254,
			'looks_like_renamed_function' => 240,
			'nmethod' => 255,
			'type' => 22
		}
	},
	{#State 217
		DEFAULT => -71
	},
	{#State 218
		ACTIONS => {
			'COLON' => 256
		}
	},
	{#State 219
		ACTIONS => {
			'ID' => 230,
			"virtual" => 231,
			"short" => 17,
			"unsigned" => 47,
			"const" => 10,
			'p_name' => 19,
			'TILDE' => 226,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		GOTOS => {
			'type_name' => 13,
			'class_name' => 1,
			'ctor' => 259,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'looks_like_function' => 58,
			'virtual' => 238,
			'perc_name' => 257,
			'_vmethod' => 241,
			'dtor' => 260,
			'vmethod' => 258,
			'type' => 22
		}
	},
	{#State 220
		DEFAULT => -56
	},
	{#State 221
		DEFAULT => -64
	},
	{#State 222
		DEFAULT => -63
	},
	{#State 223
		ACTIONS => {
			'COLON' => 261
		}
	},
	{#State 224
		DEFAULT => -58
	},
	{#State 225
		DEFAULT => -65
	},
	{#State 226
		ACTIONS => {
			'ID' => 262
		}
	},
	{#State 227
		ACTIONS => {
			'COLON' => 263
		}
	},
	{#State 228
		DEFAULT => -66
	},
	{#State 229
		ACTIONS => {
			'SEMICOLON' => 264
		}
	},
	{#State 230
		ACTIONS => {
			'DCOLON' => 70,
			'OPPAR' => 265
		},
		DEFAULT => -130,
		GOTOS => {
			'class_suffix' => 69
		}
	},
	{#State 231
		DEFAULT => -69
	},
	{#State 232
		DEFAULT => -70
	},
	{#State 233
		DEFAULT => -57
	},
	{#State 234
		DEFAULT => -53
	},
	{#State 235
		DEFAULT => -54
	},
	{#State 236
		DEFAULT => -72
	},
	{#State 237
		ACTIONS => {
			'SEMICOLON' => 266
		}
	},
	{#State 238
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
			'looks_like_function' => 267,
			'type' => 22
		}
	},
	{#State 239
		DEFAULT => -40
	},
	{#State 240
		DEFAULT => -82,
		GOTOS => {
			'function_metadata' => 268
		}
	},
	{#State 241
		DEFAULT => -85
	},
	{#State 242
		DEFAULT => -55
	},
	{#State 243
		ACTIONS => {
			'CLCURLY' => 269
		}
	},
	{#State 244
		DEFAULT => -143
	},
	{#State 245
		ACTIONS => {
			'OPCURLY' => 270
		}
	},
	{#State 246
		ACTIONS => {
			'ID' => 25,
			'INTEGER' => 207,
			'QUOTED_STRING' => 209,
			'DASH' => 211,
			'FLOAT' => 210
		},
		DEFAULT => -153,
		GOTOS => {
			'class_name' => 205,
			'value_list' => 271,
			'value' => 272
		}
	},
	{#State 247
		ACTIONS => {
			'ID' => 25,
			'INTEGER' => 207,
			'QUOTED_STRING' => 209,
			'DASH' => 211,
			'FLOAT' => 210
		},
		GOTOS => {
			'class_name' => 205,
			'value' => 273
		}
	},
	{#State 248
		ACTIONS => {
			'ID' => 25,
			'INTEGER' => 207,
			'QUOTED_STRING' => 209,
			'DASH' => 211,
			'FLOAT' => 210
		},
		GOTOS => {
			'class_name' => 205,
			'value' => 274
		}
	},
	{#State 249
		DEFAULT => -146
	},
	{#State 250
		DEFAULT => -133
	},
	{#State 251
		ACTIONS => {
			'p_any' => 95
		},
		GOTOS => {
			'perc_any_arg' => 96,
			'perc_any_args' => 275
		}
	},
	{#State 252
		DEFAULT => -157
	},
	{#State 253
		ACTIONS => {
			'OPSPECIAL' => 30,
			'SEMICOLON' => 277
		},
		GOTOS => {
			'special_block' => 276,
			'special_block_start' => 32
		}
	},
	{#State 254
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
	{#State 255
		DEFAULT => -84
	},
	{#State 256
		DEFAULT => -60
	},
	{#State 257
		ACTIONS => {
			'ID' => 278,
			'TILDE' => 226,
			'p_name' => 19,
			"virtual" => 231
		},
		GOTOS => {
			'perc_name' => 257,
			'ctor' => 259,
			'_vmethod' => 241,
			'dtor' => 260,
			'vmethod' => 258,
			'virtual' => 238
		}
	},
	{#State 258
		DEFAULT => -86
	},
	{#State 259
		DEFAULT => -78
	},
	{#State 260
		DEFAULT => -80
	},
	{#State 261
		DEFAULT => -62
	},
	{#State 262
		ACTIONS => {
			'OPPAR' => 279
		}
	},
	{#State 263
		DEFAULT => -61
	},
	{#State 264
		DEFAULT => -38
	},
	{#State 265
		ACTIONS => {
			'ID' => 25,
			"short" => 17,
			"const" => 10,
			"unsigned" => 47,
			"long" => 21,
			"int" => 37,
			"char" => 24
		},
		DEFAULT => -141,
		GOTOS => {
			'type_name' => 13,
			'class_name' => 1,
			'basic_type' => 39,
			'nconsttype' => 27,
			'template' => 14,
			'arg_list' => 280,
			'argument' => 152,
			'type' => 150
		}
	},
	{#State 266
		DEFAULT => -59
	},
	{#State 267
		ACTIONS => {
			'EQUAL' => 281
		},
		DEFAULT => -82,
		GOTOS => {
			'function_metadata' => 282
		}
	},
	{#State 268
		ACTIONS => {
			'p_code' => 123,
			'p_cleanup' => 119,
			'p_any' => 3,
			'p_catch' => 127,
			'p_postcall' => 121
		},
		DEFAULT => -83,
		GOTOS => {
			'perc_postcall' => 122,
			'perc_code' => 118,
			'perc_any' => 124,
			'perc_cleanup' => 125,
			'perc_catch' => 120,
			'_function_metadata' => 126
		}
	},
	{#State 269
		DEFAULT => -142
	},
	{#State 270
		ACTIONS => {
			'ID' => 283
		}
	},
	{#State 271
		ACTIONS => {
			'CLPAR' => 284,
			'COMMA' => 285
		}
	},
	{#State 272
		DEFAULT => -151
	},
	{#State 273
		DEFAULT => -155
	},
	{#State 274
		DEFAULT => -156
	},
	{#State 275
		ACTIONS => {
			'p_any' => 95,
			'CLCURLY' => 286
		},
		GOTOS => {
			'perc_any_arg' => 133
		}
	},
	{#State 276
		DEFAULT => -158
	},
	{#State 277
		DEFAULT => -16
	},
	{#State 278
		ACTIONS => {
			'OPPAR' => 265
		}
	},
	{#State 279
		ACTIONS => {
			'CLPAR' => 287
		}
	},
	{#State 280
		ACTIONS => {
			'CLPAR' => 288,
			'COMMA' => 186
		}
	},
	{#State 281
		ACTIONS => {
			'INTEGER' => 289
		}
	},
	{#State 282
		ACTIONS => {
			'p_code' => 123,
			'p_cleanup' => 119,
			'p_any' => 3,
			'p_catch' => 127,
			'p_postcall' => 121
		},
		DEFAULT => -87,
		GOTOS => {
			'perc_postcall' => 122,
			'perc_code' => 118,
			'perc_any' => 124,
			'perc_cleanup' => 125,
			'perc_catch' => 120,
			'_function_metadata' => 126
		}
	},
	{#State 283
		ACTIONS => {
			'CLCURLY' => 290
		}
	},
	{#State 284
		DEFAULT => -150
	},
	{#State 285
		ACTIONS => {
			'ID' => 25,
			'INTEGER' => 207,
			'QUOTED_STRING' => 209,
			'DASH' => 211,
			'FLOAT' => 210
		},
		GOTOS => {
			'class_name' => 205,
			'value' => 291
		}
	},
	{#State 286
		ACTIONS => {
			'SEMICOLON' => 292
		}
	},
	{#State 287
		DEFAULT => -82,
		GOTOS => {
			'function_metadata' => 293
		}
	},
	{#State 288
		DEFAULT => -82,
		GOTOS => {
			'function_metadata' => 294
		}
	},
	{#State 289
		DEFAULT => -82,
		GOTOS => {
			'function_metadata' => 295
		}
	},
	{#State 290
		DEFAULT => -21,
		GOTOS => {
			'mixed_blocks' => 296
		}
	},
	{#State 291
		DEFAULT => -152
	},
	{#State 292
		DEFAULT => -17
	},
	{#State 293
		ACTIONS => {
			'p_code' => 123,
			'p_cleanup' => 119,
			'p_any' => 3,
			'p_catch' => 127,
			'p_postcall' => 121
		},
		DEFAULT => -79,
		GOTOS => {
			'perc_postcall' => 122,
			'perc_code' => 118,
			'perc_any' => 124,
			'perc_cleanup' => 125,
			'perc_catch' => 120,
			'_function_metadata' => 126
		}
	},
	{#State 294
		ACTIONS => {
			'p_code' => 123,
			'p_cleanup' => 119,
			'p_any' => 3,
			'p_catch' => 127,
			'p_postcall' => 121
		},
		DEFAULT => -77,
		GOTOS => {
			'perc_postcall' => 122,
			'perc_code' => 118,
			'perc_any' => 124,
			'perc_cleanup' => 125,
			'perc_catch' => 120,
			'_function_metadata' => 126
		}
	},
	{#State 295
		ACTIONS => {
			'p_code' => 123,
			'p_cleanup' => 119,
			'p_any' => 3,
			'p_catch' => 127,
			'p_postcall' => 121
		},
		DEFAULT => -88,
		GOTOS => {
			'perc_postcall' => 122,
			'perc_code' => 118,
			'perc_any' => 124,
			'perc_cleanup' => 125,
			'perc_catch' => 120,
			'_function_metadata' => 126
		}
	},
	{#State 296
		ACTIONS => {
			'OPCURLY' => 135,
			'OPSPECIAL' => 30,
			'SEMICOLON' => 297
		},
		GOTOS => {
			'simple_block' => 137,
			'special_block' => 136,
			'special_block_start' => 32
		}
	},
	{#State 297
		DEFAULT => -18
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
                              if ref( $_[9][$i] ) && ref( $_[9][$i][0] );
                      }
                      my $tm = $package->new( type => $type, @{$_[9]} );
                      ExtUtils::XSpp::Typemap::add_typemap_for_type( $type, $tm );
                      undef }
	],
	[#Rule 18
		 'exceptionmap', 12,
sub
#line 72 "XSP.yp"
{ my $package = "ExtUtils::XSpp::Exception::" . $_[9];
                      my $type = make_type($_[6]); my $c = 0;
                      my %args = map { "arg" . ++$c => $_ }
                                 map { join( "\n", @$_ ) }
                                     @{$_[11] || []};
                      my $e = $package->new( name => $_[3], type => $type, %args );
                      ExtUtils::XSpp::Exception->add_exception( $e );
                      undef }
	],
	[#Rule 19
		 'mixed_blocks', 2,
sub
#line 82 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 20
		 'mixed_blocks', 2,
sub
#line 84 "XSP.yp"
{ [ @{$_[1]}, [ $_[2] ] ] }
	],
	[#Rule 21
		 'mixed_blocks', 0,
sub
#line 85 "XSP.yp"
{ [] }
	],
	[#Rule 22
		 'simple_block', 3,
sub
#line 88 "XSP.yp"
{ $_[2] }
	],
	[#Rule 23
		 'raw', 1,
sub
#line 90 "XSP.yp"
{ add_data_raw( $_[0], [ $_[1] ] ) }
	],
	[#Rule 24
		 'raw', 1,
sub
#line 91 "XSP.yp"
{ add_data_comment( $_[0], $_[1] ) }
	],
	[#Rule 25
		 'raw', 1,
sub
#line 92 "XSP.yp"
{ ExtUtils::XSpp::Node::Preprocessor->new
                              ( rows   => [ $_[1][0] ],
                                symbol => $_[1][1],
                                ) }
	],
	[#Rule 26
		 'raw', 1,
sub
#line 96 "XSP.yp"
{ add_data_raw( $_[0], [ @{$_[1]} ] ) }
	],
	[#Rule 27
		 'enum', 5,
sub
#line 100 "XSP.yp"
{ ExtUtils::XSpp::Node::Enum->new
                ( elements  => $_[3],
                  condition => $_[0]->get_conditional,
                  ) }
	],
	[#Rule 28
		 'enum', 6,
sub
#line 105 "XSP.yp"
{ ExtUtils::XSpp::Node::Enum->new
                ( name      => $_[2],
                  elements  => $_[4],
                  condition => $_[0]->get_conditional,
                  ) }
	],
	[#Rule 29
		 'enum_element_list', 0,
sub
#line 113 "XSP.yp"
{ [] }
	],
	[#Rule 30
		 'enum_element_list', 2,
sub
#line 115 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 31
		 'enum_element_list', 3,
sub
#line 117 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 32
		 'enum_element', 1,
sub
#line 122 "XSP.yp"
{ ExtUtils::XSpp::Node::EnumValue->new
                ( name => $_[1],
                  condition => $_[0]->get_conditional,
                  ) }
	],
	[#Rule 33
		 'enum_element', 3,
sub
#line 127 "XSP.yp"
{ ExtUtils::XSpp::Node::EnumValue->new
                ( name      => $_[1],
                  value     => $_[3],
                  condition => $_[0]->get_conditional,
                  ) }
	],
	[#Rule 34
		 'enum_element', 1, undef
	],
	[#Rule 35
		 'class', 2, undef
	],
	[#Rule 36
		 'class', 2, undef
	],
	[#Rule 37
		 'function', 2, undef
	],
	[#Rule 38
		 'method', 2, undef
	],
	[#Rule 39
		 'decorate_class', 2,
sub
#line 140 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 40
		 'class_decl', 7,
sub
#line 143 "XSP.yp"
{ create_class( $_[0], $_[2], $_[3], $_[4], $_[6],
                                $_[0]->get_conditional ) }
	],
	[#Rule 41
		 'base_classes', 2,
sub
#line 147 "XSP.yp"
{ [ $_[2] ] }
	],
	[#Rule 42
		 'base_classes', 3,
sub
#line 148 "XSP.yp"
{ push @{$_[1]}, $_[3] if $_[3]; $_[1] }
	],
	[#Rule 43
		 'base_classes', 0, undef
	],
	[#Rule 44
		 'base_class', 2,
sub
#line 152 "XSP.yp"
{ $_[2] }
	],
	[#Rule 45
		 'base_class', 2,
sub
#line 153 "XSP.yp"
{ $_[2] }
	],
	[#Rule 46
		 'base_class', 2,
sub
#line 154 "XSP.yp"
{ $_[2] }
	],
	[#Rule 47
		 'class_name_rename', 1,
sub
#line 158 "XSP.yp"
{ create_class( $_[0], $_[1], [], [] ) }
	],
	[#Rule 48
		 'class_name_rename', 2,
sub
#line 159 "XSP.yp"
{ my $klass = create_class( $_[0], $_[2], [], [] );
                             $klass->set_perl_name( $_[1] );
                             $klass
                             }
	],
	[#Rule 49
		 'class_metadata', 2,
sub
#line 165 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 50
		 'class_metadata', 2,
sub
#line 166 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 51
		 'class_metadata', 0,
sub
#line 167 "XSP.yp"
{ [] }
	],
	[#Rule 52
		 'class_body_list', 0,
sub
#line 171 "XSP.yp"
{ [] }
	],
	[#Rule 53
		 'class_body_list', 2,
sub
#line 173 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
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
		 'class_body_element', 1, undef
	],
	[#Rule 59
		 'class_body_element', 2,
sub
#line 179 "XSP.yp"
{ ExtUtils::XSpp::Node::PercAny->new( @{$_[1]} ) }
	],
	[#Rule 60
		 'access_specifier', 2,
sub
#line 183 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 61
		 'access_specifier', 2,
sub
#line 184 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 62
		 'access_specifier', 2,
sub
#line 185 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
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
		 'method_decl', 1, undef
	],
	[#Rule 67
		 'const', 1,
sub
#line 190 "XSP.yp"
{ 1 }
	],
	[#Rule 68
		 'const', 0,
sub
#line 191 "XSP.yp"
{ 0 }
	],
	[#Rule 69
		 'virtual', 1, undef
	],
	[#Rule 70
		 'static', 1, undef
	],
	[#Rule 71
		 'static', 1, undef
	],
	[#Rule 72
		 'static', 1,
sub
#line 197 "XSP.yp"
{ 'package_static' }
	],
	[#Rule 73
		 'looks_like_function', 6,
sub
#line 202 "XSP.yp"
{
              return { ret_type  => $_[1],
                       name      => $_[2],
                       arguments => $_[4],
                       const     => $_[6],
                       };
          }
	],
	[#Rule 74
		 'looks_like_renamed_function', 1, undef
	],
	[#Rule 75
		 'looks_like_renamed_function', 2,
sub
#line 213 "XSP.yp"
{ $_[2]->{perl_name} = $_[1]; $_[2] }
	],
	[#Rule 76
		 'function_decl', 2,
sub
#line 216 "XSP.yp"
{ add_data_function( $_[0],
                                         name      => $_[1]->{name},
                                         perl_name => $_[1]->{perl_name},
                                         ret_type  => $_[1]->{ret_type},
                                         arguments => $_[1]->{arguments},
                                         condition => $_[0]->get_conditional,
                                         @{$_[2]} ) }
	],
	[#Rule 77
		 'ctor', 5,
sub
#line 225 "XSP.yp"
{ add_data_ctor( $_[0], name      => $_[1],
                                            arguments => $_[3],
                                            condition => $_[0]->get_conditional,
                                            @{ $_[5] } ) }
	],
	[#Rule 78
		 'ctor', 2,
sub
#line 229 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 79
		 'dtor', 5,
sub
#line 232 "XSP.yp"
{ add_data_dtor( $_[0], name  => $_[2],
                                            condition => $_[0]->get_conditional,
                                            @{ $_[5] },
                                      ) }
	],
	[#Rule 80
		 'dtor', 2,
sub
#line 236 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 81
		 'function_metadata', 2,
sub
#line 238 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 82
		 'function_metadata', 0,
sub
#line 239 "XSP.yp"
{ [] }
	],
	[#Rule 83
		 'nmethod', 2,
sub
#line 244 "XSP.yp"
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
	[#Rule 84
		 'nmethod', 2,
sub
#line 257 "XSP.yp"
{ $_[2]->set_static( $_[1] ); $_[2] }
	],
	[#Rule 85
		 'vmethod', 1, undef
	],
	[#Rule 86
		 'vmethod', 2,
sub
#line 262 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 87
		 '_vmethod', 3,
sub
#line 267 "XSP.yp"
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
	[#Rule 88
		 '_vmethod', 5,
sub
#line 281 "XSP.yp"
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
		 '_function_metadata', 1, undef
	],
	[#Rule 94
		 'perc_name', 4,
sub
#line 304 "XSP.yp"
{ $_[3] }
	],
	[#Rule 95
		 'perc_package', 4,
sub
#line 305 "XSP.yp"
{ $_[3] }
	],
	[#Rule 96
		 'perc_module', 4,
sub
#line 306 "XSP.yp"
{ $_[3] }
	],
	[#Rule 97
		 'perc_file', 4,
sub
#line 307 "XSP.yp"
{ $_[3] }
	],
	[#Rule 98
		 'perc_loadplugin', 4,
sub
#line 308 "XSP.yp"
{ $_[3] }
	],
	[#Rule 99
		 'perc_include', 4,
sub
#line 309 "XSP.yp"
{ $_[3] }
	],
	[#Rule 100
		 'perc_code', 2,
sub
#line 310 "XSP.yp"
{ [ code => $_[2] ] }
	],
	[#Rule 101
		 'perc_cleanup', 2,
sub
#line 311 "XSP.yp"
{ [ cleanup => $_[2] ] }
	],
	[#Rule 102
		 'perc_postcall', 2,
sub
#line 312 "XSP.yp"
{ [ postcall => $_[2] ] }
	],
	[#Rule 103
		 'perc_catch', 4,
sub
#line 313 "XSP.yp"
{ [ map {(catch => $_)} @{$_[3]} ] }
	],
	[#Rule 104
		 'perc_any', 4,
sub
#line 318 "XSP.yp"
{ [ any => $_[1], any_named_arguments => $_[3] ] }
	],
	[#Rule 105
		 'perc_any', 5,
sub
#line 320 "XSP.yp"
{ [ any => $_[1], any_positional_arguments  => [ $_[3], @{$_[5]} ] ] }
	],
	[#Rule 106
		 'perc_any', 3,
sub
#line 322 "XSP.yp"
{ [ any => $_[1], any_positional_arguments  => [ $_[2], @{$_[3]} ] ] }
	],
	[#Rule 107
		 'perc_any', 1,
sub
#line 324 "XSP.yp"
{ [ any => $_[1] ] }
	],
	[#Rule 108
		 'perc_any_args', 1,
sub
#line 328 "XSP.yp"
{ $_[1] }
	],
	[#Rule 109
		 'perc_any_args', 2,
sub
#line 329 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 110
		 'perc_any_arg', 3,
sub
#line 333 "XSP.yp"
{ [ $_[1] => $_[2] ] }
	],
	[#Rule 111
		 'type', 2,
sub
#line 337 "XSP.yp"
{ make_const( $_[2] ) }
	],
	[#Rule 112
		 'type', 1, undef
	],
	[#Rule 113
		 'nconsttype', 2,
sub
#line 342 "XSP.yp"
{ make_ptr( $_[1] ) }
	],
	[#Rule 114
		 'nconsttype', 2,
sub
#line 343 "XSP.yp"
{ make_ref( $_[1] ) }
	],
	[#Rule 115
		 'nconsttype', 1,
sub
#line 344 "XSP.yp"
{ make_type( $_[1] ) }
	],
	[#Rule 116
		 'nconsttype', 1, undef
	],
	[#Rule 117
		 'type_name', 1, undef
	],
	[#Rule 118
		 'type_name', 1, undef
	],
	[#Rule 119
		 'type_name', 1,
sub
#line 351 "XSP.yp"
{ 'unsigned int' }
	],
	[#Rule 120
		 'type_name', 2,
sub
#line 352 "XSP.yp"
{ 'unsigned' . ' ' . $_[2] }
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
		 'basic_type', 1, undef
	],
	[#Rule 125
		 'basic_type', 2, undef
	],
	[#Rule 126
		 'basic_type', 2, undef
	],
	[#Rule 127
		 'template', 4,
sub
#line 358 "XSP.yp"
{ make_template( $_[1], $_[3] ) }
	],
	[#Rule 128
		 'type_list', 1,
sub
#line 362 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 129
		 'type_list', 3,
sub
#line 363 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 130
		 'class_name', 1, undef
	],
	[#Rule 131
		 'class_name', 2,
sub
#line 367 "XSP.yp"
{ $_[1] . '::' . $_[2] }
	],
	[#Rule 132
		 'class_name_list', 1,
sub
#line 370 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 133
		 'class_name_list', 3,
sub
#line 371 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 134
		 'class_suffix', 2,
sub
#line 374 "XSP.yp"
{ $_[2] }
	],
	[#Rule 135
		 'class_suffix', 3,
sub
#line 375 "XSP.yp"
{ $_[1] . '::' . $_[3] }
	],
	[#Rule 136
		 'file_name', 1,
sub
#line 377 "XSP.yp"
{ '-' }
	],
	[#Rule 137
		 'file_name', 3,
sub
#line 378 "XSP.yp"
{ $_[1] . '.' . $_[3] }
	],
	[#Rule 138
		 'file_name', 3,
sub
#line 379 "XSP.yp"
{ $_[1] . '/' . $_[3] }
	],
	[#Rule 139
		 'arg_list', 1,
sub
#line 381 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 140
		 'arg_list', 3,
sub
#line 382 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 141
		 'arg_list', 0, undef
	],
	[#Rule 142
		 'argument', 5,
sub
#line 386 "XSP.yp"
{ make_argument( @_[0, 1], "length($_[4])" ) }
	],
	[#Rule 143
		 'argument', 4,
sub
#line 388 "XSP.yp"
{ make_argument( @_[0, 1, 2, 4] ) }
	],
	[#Rule 144
		 'argument', 2,
sub
#line 389 "XSP.yp"
{ make_argument( @_ ) }
	],
	[#Rule 145
		 'value', 1, undef
	],
	[#Rule 146
		 'value', 2,
sub
#line 392 "XSP.yp"
{ '-' . $_[2] }
	],
	[#Rule 147
		 'value', 1, undef
	],
	[#Rule 148
		 'value', 1, undef
	],
	[#Rule 149
		 'value', 1, undef
	],
	[#Rule 150
		 'value', 4,
sub
#line 396 "XSP.yp"
{ "$_[1]($_[3])" }
	],
	[#Rule 151
		 'value_list', 1, undef
	],
	[#Rule 152
		 'value_list', 3,
sub
#line 401 "XSP.yp"
{ "$_[1], $_[2]" }
	],
	[#Rule 153
		 'value_list', 0,
sub
#line 402 "XSP.yp"
{ "" }
	],
	[#Rule 154
		 'expression', 1, undef
	],
	[#Rule 155
		 'expression', 3,
sub
#line 408 "XSP.yp"
{ "$_[1] & $_[3]" }
	],
	[#Rule 156
		 'expression', 3,
sub
#line 410 "XSP.yp"
{ "$_[1] | $_[3]" }
	],
	[#Rule 157
		 'special_blocks', 1,
sub
#line 414 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 158
		 'special_blocks', 2,
sub
#line 416 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 159
		 'special_blocks', 0, undef
	],
	[#Rule 160
		 'special_block', 3,
sub
#line 420 "XSP.yp"
{ $_[2] }
	],
	[#Rule 161
		 'special_block', 2,
sub
#line 422 "XSP.yp"
{ [] }
	],
	[#Rule 162
		 'special_block_start', 1,
sub
#line 425 "XSP.yp"
{ push_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 163
		 'special_block_end', 1,
sub
#line 427 "XSP.yp"
{ pop_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 164
		 'lines', 1,
sub
#line 429 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 165
		 'lines', 2,
sub
#line 430 "XSP.yp"
{ push @{$_[1]}, $_[2]; $_[1] }
	]
],
                                  @_);
    bless($self,$class);
}

#line 432 "XSP.yp"


use ExtUtils::XSpp::Lexer;

1;
