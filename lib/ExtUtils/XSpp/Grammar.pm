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
			'ID' => 20,
			'p_module' => 11,
			'p_typemap' => 3,
			'p_package' => 31,
			'OPSPECIAL' => 23,
			"class" => 5,
			"short" => 13,
			'p_file' => 32,
			'RAW_CODE' => 25,
			"unsigned" => 34,
			"const" => 7,
			'p_name' => 15,
			"long" => 16,
			"int" => 28,
			"char" => 19
		},
		GOTOS => {
			'class_name' => 1,
			'top_list' => 2,
			'perc_package' => 22,
			'function' => 21,
			'special_block_start' => 24,
			'perc_name' => 4,
			'class_decl' => 26,
			'typemap' => 6,
			'decorate_class' => 8,
			'special_block' => 9,
			'perc_module' => 27,
			'type_name' => 10,
			'basic_type' => 30,
			'perc_file' => 29,
			'decorate_function' => 12,
			'top' => 14,
			'function_decl' => 33,
			'directive' => 35,
			'class' => 17,
			'type' => 18,
			'raw' => 36
		}
	},
	{#State 1
		DEFAULT => -67
	},
	{#State 2
		ACTIONS => {
			'ID' => 20,
			'' => 37,
			'p_typemap' => 3,
			'OPSPECIAL' => 23,
			"class" => 5,
			'RAW_CODE' => 25,
			"const" => 7,
			"int" => 28,
			'p_module' => 11,
			'p_package' => 31,
			"short" => 13,
			'p_file' => 32,
			'p_name' => 15,
			"unsigned" => 34,
			"long" => 16,
			"char" => 19
		},
		GOTOS => {
			'class_name' => 1,
			'function' => 21,
			'perc_package' => 22,
			'special_block_start' => 24,
			'perc_name' => 4,
			'class_decl' => 26,
			'typemap' => 6,
			'decorate_class' => 8,
			'special_block' => 9,
			'perc_module' => 27,
			'type_name' => 10,
			'perc_file' => 29,
			'basic_type' => 30,
			'decorate_function' => 12,
			'top' => 38,
			'function_decl' => 33,
			'directive' => 35,
			'type' => 18,
			'class' => 17,
			'raw' => 36
		}
	},
	{#State 3
		ACTIONS => {
			'OPCURLY' => 39
		}
	},
	{#State 4
		ACTIONS => {
			'ID' => 20,
			"class" => 5,
			"short" => 13,
			"const" => 7,
			'p_name' => 15,
			"unsigned" => 34,
			"long" => 16,
			"int" => 28,
			"char" => 19
		},
		GOTOS => {
			'type_name' => 10,
			'class_name' => 1,
			'basic_type' => 30,
			'function' => 41,
			'decorate_function' => 12,
			'perc_name' => 4,
			'class_decl' => 26,
			'function_decl' => 33,
			'decorate_class' => 8,
			'type' => 18,
			'class' => 40
		}
	},
	{#State 5
		ACTIONS => {
			'ID' => 42
		}
	},
	{#State 6
		DEFAULT => -10
	},
	{#State 7
		ACTIONS => {
			'ID' => 20,
			"short" => 13,
			"unsigned" => 34,
			"long" => 16,
			"int" => 28,
			"char" => 19
		},
		GOTOS => {
			'type_name' => 43,
			'class_name' => 1,
			'basic_type' => 30
		}
	},
	{#State 8
		DEFAULT => -15
	},
	{#State 9
		DEFAULT => -13
	},
	{#State 10
		DEFAULT => -66
	},
	{#State 11
		ACTIONS => {
			'OPCURLY' => 44
		}
	},
	{#State 12
		DEFAULT => -17
	},
	{#State 13
		ACTIONS => {
			"int" => 45
		},
		DEFAULT => -71
	},
	{#State 14
		DEFAULT => -1
	},
	{#State 15
		ACTIONS => {
			'OPCURLY' => 46
		}
	},
	{#State 16
		ACTIONS => {
			"int" => 47
		},
		DEFAULT => -73
	},
	{#State 17
		DEFAULT => -4
	},
	{#State 18
		ACTIONS => {
			'ID' => 50,
			'STAR' => 49,
			'AMP' => 48
		}
	},
	{#State 19
		DEFAULT => -70
	},
	{#State 20
		ACTIONS => {
			'DCOLON' => 51
		},
		DEFAULT => -77
	},
	{#State 21
		DEFAULT => -6
	},
	{#State 22
		ACTIONS => {
			'SEMICOLON' => 52
		}
	},
	{#State 23
		DEFAULT => -99
	},
	{#State 24
		ACTIONS => {
			'CLSPECIAL' => 53,
			'line' => 54
		},
		GOTOS => {
			'special_block_end' => 55,
			'lines' => 56
		}
	},
	{#State 25
		DEFAULT => -12
	},
	{#State 26
		DEFAULT => -14
	},
	{#State 27
		ACTIONS => {
			'SEMICOLON' => 57
		}
	},
	{#State 28
		DEFAULT => -72
	},
	{#State 29
		ACTIONS => {
			'SEMICOLON' => 58
		}
	},
	{#State 30
		DEFAULT => -68
	},
	{#State 31
		ACTIONS => {
			'OPCURLY' => 59
		}
	},
	{#State 32
		ACTIONS => {
			'OPCURLY' => 60
		}
	},
	{#State 33
		DEFAULT => -16
	},
	{#State 34
		ACTIONS => {
			"short" => 13,
			"unsigned" => 62,
			"long" => 16,
			"int" => 28,
			"char" => 19
		},
		DEFAULT => -74,
		GOTOS => {
			'basic_type' => 61
		}
	},
	{#State 35
		DEFAULT => -5
	},
	{#State 36
		DEFAULT => -3
	},
	{#State 37
		DEFAULT => 0
	},
	{#State 38
		DEFAULT => -2
	},
	{#State 39
		ACTIONS => {
			'ID' => 20,
			"short" => 13,
			"unsigned" => 34,
			"const" => 7,
			"long" => 16,
			"int" => 28,
			"char" => 19
		},
		GOTOS => {
			'type_name' => 10,
			'class_name' => 1,
			'basic_type' => 30,
			'type' => 63
		}
	},
	{#State 40
		DEFAULT => -20
	},
	{#State 41
		DEFAULT => -21
	},
	{#State 42
		ACTIONS => {
			'COLON' => 65
		},
		DEFAULT => -29,
		GOTOS => {
			'base_classes' => 64
		}
	},
	{#State 43
		DEFAULT => -63
	},
	{#State 44
		ACTIONS => {
			'ID' => 20
		},
		GOTOS => {
			'class_name' => 66
		}
	},
	{#State 45
		DEFAULT => -76
	},
	{#State 46
		ACTIONS => {
			'ID' => 20
		},
		GOTOS => {
			'class_name' => 67
		}
	},
	{#State 47
		DEFAULT => -75
	},
	{#State 48
		DEFAULT => -65
	},
	{#State 49
		DEFAULT => -64
	},
	{#State 50
		ACTIONS => {
			'OPPAR' => 68
		}
	},
	{#State 51
		ACTIONS => {
			'ID' => 69
		}
	},
	{#State 52
		DEFAULT => -8
	},
	{#State 53
		DEFAULT => -100
	},
	{#State 54
		DEFAULT => -101
	},
	{#State 55
		DEFAULT => -98
	},
	{#State 56
		ACTIONS => {
			'CLSPECIAL' => 53,
			'line' => 70
		},
		GOTOS => {
			'special_block_end' => 71
		}
	},
	{#State 57
		DEFAULT => -7
	},
	{#State 58
		DEFAULT => -9
	},
	{#State 59
		ACTIONS => {
			'ID' => 20
		},
		GOTOS => {
			'class_name' => 72
		}
	},
	{#State 60
		ACTIONS => {
			'ID' => 74,
			'DASH' => 75
		},
		GOTOS => {
			'file_name' => 73
		}
	},
	{#State 61
		DEFAULT => -69
	},
	{#State 62
		DEFAULT => -74
	},
	{#State 63
		ACTIONS => {
			'STAR' => 49,
			'AMP' => 48,
			'CLCURLY' => 76
		}
	},
	{#State 64
		ACTIONS => {
			'OPCURLY' => 77,
			"," => 78
		}
	},
	{#State 65
		ACTIONS => {
			"protected" => 82,
			"private" => 81,
			"public" => 79
		},
		GOTOS => {
			'base_class' => 80
		}
	},
	{#State 66
		ACTIONS => {
			'CLCURLY' => 83
		}
	},
	{#State 67
		ACTIONS => {
			'CLCURLY' => 84
		}
	},
	{#State 68
		ACTIONS => {
			'ID' => 20,
			"short" => 13,
			"const" => 7,
			"unsigned" => 34,
			"long" => 16,
			"int" => 28,
			"char" => 19
		},
		DEFAULT => -84,
		GOTOS => {
			'argument' => 87,
			'type_name' => 10,
			'class_name' => 1,
			'basic_type' => 30,
			'type' => 85,
			'arg_list' => 86
		}
	},
	{#State 69
		DEFAULT => -78
	},
	{#State 70
		DEFAULT => -102
	},
	{#State 71
		DEFAULT => -97
	},
	{#State 72
		ACTIONS => {
			'CLCURLY' => 88
		}
	},
	{#State 73
		ACTIONS => {
			'CLCURLY' => 89
		}
	},
	{#State 74
		ACTIONS => {
			'DOT' => 91,
			'SLASH' => 90
		}
	},
	{#State 75
		DEFAULT => -79
	},
	{#State 76
		ACTIONS => {
			'OPCURLY' => 92
		}
	},
	{#State 77
		ACTIONS => {
			'ID' => 105,
			'p_typemap' => 3,
			'OPSPECIAL' => 23,
			"virtual" => 107,
			"class_static" => 93,
			"package_static" => 108,
			"public" => 95,
			'RAW_CODE' => 25,
			"const" => 7,
			"int" => 28,
			"private" => 98,
			'CLCURLY' => 113,
			"short" => 13,
			"unsigned" => 34,
			'TILDE' => 101,
			'p_name' => 15,
			"protected" => 102,
			"long" => 16,
			"char" => 19
		},
		GOTOS => {
			'decorate_method' => 106,
			'class_name' => 1,
			'static' => 94,
			'special_block_start' => 24,
			'perc_name' => 96,
			'typemap' => 97,
			'class_body_element' => 109,
			'class_body_list' => 111,
			'method' => 110,
			'special_block' => 9,
			'access_specifier' => 99,
			'type_name' => 10,
			'ctor' => 100,
			'basic_type' => 30,
			'virtual' => 112,
			'function_decl' => 114,
			'type' => 18,
			'dtor' => 103,
			'raw' => 115,
			'method_decl' => 104
		}
	},
	{#State 78
		ACTIONS => {
			"protected" => 82,
			"private" => 81,
			"public" => 79
		},
		GOTOS => {
			'base_class' => 116
		}
	},
	{#State 79
		ACTIONS => {
			'ID' => 117
		}
	},
	{#State 80
		DEFAULT => -27
	},
	{#State 81
		ACTIONS => {
			'ID' => 118
		}
	},
	{#State 82
		ACTIONS => {
			'ID' => 119
		}
	},
	{#State 83
		DEFAULT => -59
	},
	{#State 84
		DEFAULT => -57
	},
	{#State 85
		ACTIONS => {
			'ID' => 120,
			'STAR' => 49,
			'AMP' => 48
		}
	},
	{#State 86
		ACTIONS => {
			'CLPAR' => 121,
			'COMMA' => 122
		}
	},
	{#State 87
		DEFAULT => -82
	},
	{#State 88
		DEFAULT => -58
	},
	{#State 89
		DEFAULT => -60
	},
	{#State 90
		ACTIONS => {
			'ID' => 74,
			'DASH' => 75
		},
		GOTOS => {
			'file_name' => 123
		}
	},
	{#State 91
		ACTIONS => {
			'ID' => 124
		}
	},
	{#State 92
		ACTIONS => {
			'ID' => 125
		}
	},
	{#State 93
		DEFAULT => -49
	},
	{#State 94
		ACTIONS => {
			'ID' => 105,
			"virtual" => 107,
			"class_static" => 93,
			"package_static" => 108,
			"short" => 13,
			"unsigned" => 34,
			"const" => 7,
			'p_name' => 15,
			'TILDE' => 101,
			"long" => 16,
			"int" => 28,
			"char" => 19
		},
		GOTOS => {
			'decorate_method' => 106,
			'type_name' => 10,
			'class_name' => 1,
			'ctor' => 100,
			'basic_type' => 30,
			'static' => 94,
			'virtual' => 112,
			'perc_name' => 96,
			'function_decl' => 114,
			'method' => 126,
			'type' => 18,
			'dtor' => 103,
			'method_decl' => 104
		}
	},
	{#State 95
		ACTIONS => {
			'COLON' => 127
		}
	},
	{#State 96
		ACTIONS => {
			'ID' => 105,
			"virtual" => 107,
			"class_static" => 93,
			"package_static" => 108,
			"short" => 13,
			"unsigned" => 34,
			"const" => 7,
			'p_name' => 15,
			'TILDE' => 101,
			"long" => 16,
			"int" => 28,
			"char" => 19
		},
		GOTOS => {
			'decorate_method' => 106,
			'type_name' => 10,
			'class_name' => 1,
			'ctor' => 100,
			'basic_type' => 30,
			'static' => 94,
			'virtual' => 112,
			'perc_name' => 96,
			'function_decl' => 114,
			'method' => 128,
			'type' => 18,
			'dtor' => 103,
			'method_decl' => 104
		}
	},
	{#State 97
		DEFAULT => -37
	},
	{#State 98
		ACTIONS => {
			'COLON' => 129
		}
	},
	{#State 99
		DEFAULT => -38
	},
	{#State 100
		DEFAULT => -43
	},
	{#State 101
		ACTIONS => {
			'ID' => 130
		}
	},
	{#State 102
		ACTIONS => {
			'COLON' => 131
		}
	},
	{#State 103
		DEFAULT => -44
	},
	{#State 104
		DEFAULT => -18
	},
	{#State 105
		ACTIONS => {
			'DCOLON' => 51,
			'OPPAR' => 132
		},
		DEFAULT => -77
	},
	{#State 106
		DEFAULT => -19
	},
	{#State 107
		DEFAULT => -47
	},
	{#State 108
		DEFAULT => -48
	},
	{#State 109
		DEFAULT => -33
	},
	{#State 110
		DEFAULT => -35
	},
	{#State 111
		ACTIONS => {
			'ID' => 105,
			'p_typemap' => 3,
			'OPSPECIAL' => 23,
			"virtual" => 107,
			"class_static" => 93,
			"package_static" => 108,
			"public" => 95,
			'RAW_CODE' => 25,
			"const" => 7,
			"int" => 28,
			"private" => 98,
			'CLCURLY' => 134,
			"short" => 13,
			"unsigned" => 34,
			'TILDE' => 101,
			'p_name' => 15,
			"protected" => 102,
			"long" => 16,
			"char" => 19
		},
		GOTOS => {
			'decorate_method' => 106,
			'class_name' => 1,
			'static' => 94,
			'special_block_start' => 24,
			'perc_name' => 96,
			'typemap' => 97,
			'class_body_element' => 133,
			'method' => 110,
			'special_block' => 9,
			'access_specifier' => 99,
			'type_name' => 10,
			'ctor' => 100,
			'basic_type' => 30,
			'virtual' => 112,
			'function_decl' => 114,
			'type' => 18,
			'dtor' => 103,
			'raw' => 115,
			'method_decl' => 104
		}
	},
	{#State 112
		ACTIONS => {
			'ID' => 105,
			"virtual" => 107,
			"class_static" => 93,
			"package_static" => 108,
			"short" => 13,
			"unsigned" => 34,
			"const" => 7,
			'p_name' => 15,
			'TILDE' => 101,
			"long" => 16,
			"int" => 28,
			"char" => 19
		},
		GOTOS => {
			'decorate_method' => 106,
			'type_name' => 10,
			'class_name' => 1,
			'ctor' => 100,
			'basic_type' => 30,
			'static' => 94,
			'virtual' => 112,
			'perc_name' => 96,
			'function_decl' => 114,
			'method' => 135,
			'type' => 18,
			'dtor' => 103,
			'method_decl' => 104
		}
	},
	{#State 113
		ACTIONS => {
			'SEMICOLON' => 136
		}
	},
	{#State 114
		DEFAULT => -42
	},
	{#State 115
		DEFAULT => -36
	},
	{#State 116
		DEFAULT => -28
	},
	{#State 117
		DEFAULT => -30
	},
	{#State 118
		DEFAULT => -32
	},
	{#State 119
		DEFAULT => -31
	},
	{#State 120
		ACTIONS => {
			'EQUAL' => 137
		},
		DEFAULT => -85
	},
	{#State 121
		ACTIONS => {
			"const" => 138
		},
		DEFAULT => -46,
		GOTOS => {
			'const' => 139
		}
	},
	{#State 122
		ACTIONS => {
			'ID' => 20,
			"short" => 13,
			"unsigned" => 34,
			"const" => 7,
			"long" => 16,
			"int" => 28,
			"char" => 19
		},
		GOTOS => {
			'argument' => 140,
			'type_name' => 10,
			'class_name' => 1,
			'basic_type' => 30,
			'type' => 85
		}
	},
	{#State 123
		DEFAULT => -81
	},
	{#State 124
		DEFAULT => -80
	},
	{#State 125
		ACTIONS => {
			'CLCURLY' => 141
		}
	},
	{#State 126
		DEFAULT => -23
	},
	{#State 127
		DEFAULT => -39
	},
	{#State 128
		DEFAULT => -22
	},
	{#State 129
		DEFAULT => -41
	},
	{#State 130
		ACTIONS => {
			'OPPAR' => 142
		}
	},
	{#State 131
		DEFAULT => -40
	},
	{#State 132
		ACTIONS => {
			'ID' => 20,
			"short" => 13,
			"const" => 7,
			"unsigned" => 34,
			"long" => 16,
			"int" => 28,
			"char" => 19
		},
		DEFAULT => -84,
		GOTOS => {
			'argument' => 87,
			'type_name' => 10,
			'class_name' => 1,
			'basic_type' => 30,
			'type' => 85,
			'arg_list' => 143
		}
	},
	{#State 133
		DEFAULT => -34
	},
	{#State 134
		ACTIONS => {
			'SEMICOLON' => 144
		}
	},
	{#State 135
		DEFAULT => -24
	},
	{#State 136
		DEFAULT => -26
	},
	{#State 137
		ACTIONS => {
			'ID' => 148,
			'INTEGER' => 145,
			'QUOTED_STRING' => 147,
			'DASH' => 150,
			'FLOAT' => 149
		},
		GOTOS => {
			'value' => 146
		}
	},
	{#State 138
		DEFAULT => -45
	},
	{#State 139
		DEFAULT => -54,
		GOTOS => {
			'metadata' => 151
		}
	},
	{#State 140
		DEFAULT => -83
	},
	{#State 141
		ACTIONS => {
			'OPSPECIAL' => 23
		},
		DEFAULT => -96,
		GOTOS => {
			'special_blocks' => 153,
			'special_block' => 152,
			'special_block_start' => 24
		}
	},
	{#State 142
		ACTIONS => {
			'CLPAR' => 154
		}
	},
	{#State 143
		ACTIONS => {
			'CLPAR' => 155,
			'COMMA' => 122
		}
	},
	{#State 144
		DEFAULT => -25
	},
	{#State 145
		DEFAULT => -87
	},
	{#State 146
		DEFAULT => -86
	},
	{#State 147
		DEFAULT => -90
	},
	{#State 148
		ACTIONS => {
			'DCOLON' => 156,
			'OPPAR' => 157
		},
		DEFAULT => -91
	},
	{#State 149
		DEFAULT => -89
	},
	{#State 150
		ACTIONS => {
			'INTEGER' => 158
		}
	},
	{#State 151
		ACTIONS => {
			'p_code' => 162,
			'p_cleanup' => 160,
			'SEMICOLON' => 163
		},
		GOTOS => {
			'_metadata' => 161,
			'perc_code' => 159,
			'perc_cleanup' => 164
		}
	},
	{#State 152
		DEFAULT => -94
	},
	{#State 153
		ACTIONS => {
			'OPSPECIAL' => 23,
			'SEMICOLON' => 166
		},
		GOTOS => {
			'special_block' => 165,
			'special_block_start' => 24
		}
	},
	{#State 154
		DEFAULT => -54,
		GOTOS => {
			'metadata' => 167
		}
	},
	{#State 155
		DEFAULT => -54,
		GOTOS => {
			'metadata' => 168
		}
	},
	{#State 156
		ACTIONS => {
			'ID' => 169
		}
	},
	{#State 157
		ACTIONS => {
			'ID' => 148,
			'INTEGER' => 145,
			'QUOTED_STRING' => 147,
			'DASH' => 150,
			'FLOAT' => 149
		},
		GOTOS => {
			'value' => 170
		}
	},
	{#State 158
		DEFAULT => -88
	},
	{#State 159
		DEFAULT => -55
	},
	{#State 160
		ACTIONS => {
			'OPSPECIAL' => 23
		},
		GOTOS => {
			'special_block' => 171,
			'special_block_start' => 24
		}
	},
	{#State 161
		DEFAULT => -53
	},
	{#State 162
		ACTIONS => {
			'OPSPECIAL' => 23
		},
		GOTOS => {
			'special_block' => 172,
			'special_block_start' => 24
		}
	},
	{#State 163
		DEFAULT => -50
	},
	{#State 164
		DEFAULT => -56
	},
	{#State 165
		DEFAULT => -95
	},
	{#State 166
		DEFAULT => -11
	},
	{#State 167
		ACTIONS => {
			'p_code' => 162,
			'p_cleanup' => 160,
			'SEMICOLON' => 173
		},
		GOTOS => {
			'_metadata' => 161,
			'perc_code' => 159,
			'perc_cleanup' => 164
		}
	},
	{#State 168
		ACTIONS => {
			'p_code' => 162,
			'p_cleanup' => 160,
			'SEMICOLON' => 174
		},
		GOTOS => {
			'_metadata' => 161,
			'perc_code' => 159,
			'perc_cleanup' => 164
		}
	},
	{#State 169
		DEFAULT => -92
	},
	{#State 170
		ACTIONS => {
			'CLPAR' => 175
		}
	},
	{#State 171
		DEFAULT => -62
	},
	{#State 172
		DEFAULT => -61
	},
	{#State 173
		DEFAULT => -52
	},
	{#State 174
		DEFAULT => -51
	},
	{#State 175
		DEFAULT => -93
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
		 'directive', 1,
sub
#line 34 "XSP.yp"
{ }
	],
	[#Rule 11
		 'typemap', 9,
sub
#line 38 "XSP.yp"
{ my $package = "ExtUtils::XSpp::Typemap::" . $_[6];
                      my $type = $_[3]; my $c = 0;
                      my %args = map { "arg" . ++$c => $_ }
                                 map { join( '', @$_ ) }
                                     @{$_[8] || []};
                      my $tm = $package->new( type => $type, %args );
                      ExtUtils::XSpp::Typemap::add_typemap_for_type( $type, $tm );
                      undef }
	],
	[#Rule 12
		 'raw', 1,
sub
#line 47 "XSP.yp"
{ add_data_raw( $_[0], [ $_[1] ] ) }
	],
	[#Rule 13
		 'raw', 1,
sub
#line 48 "XSP.yp"
{ add_data_raw( $_[0], [ @{$_[1]} ] ) }
	],
	[#Rule 14
		 'class', 1, undef
	],
	[#Rule 15
		 'class', 1, undef
	],
	[#Rule 16
		 'function', 1, undef
	],
	[#Rule 17
		 'function', 1, undef
	],
	[#Rule 18
		 'method', 1, undef
	],
	[#Rule 19
		 'method', 1, undef
	],
	[#Rule 20
		 'decorate_class', 2,
sub
#line 54 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 21
		 'decorate_function', 2,
sub
#line 55 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 22
		 'decorate_method', 2,
sub
#line 56 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 23
		 'decorate_method', 2,
sub
#line 57 "XSP.yp"
{ $_[2]->set_static( $_[1] ); $_[2] }
	],
	[#Rule 24
		 'decorate_method', 2,
sub
#line 58 "XSP.yp"
{ $_[2]->set_virtual( 1 ); $_[2] }
	],
	[#Rule 25
		 'class_decl', 7,
sub
#line 61 "XSP.yp"
{ create_class( $_[0], $_[2], $_[3], $_[5] ) }
	],
	[#Rule 26
		 'class_decl', 6,
sub
#line 63 "XSP.yp"
{ create_class( $_[0], $_[2], $_[3], [] ) }
	],
	[#Rule 27
		 'base_classes', 2, undef
	],
	[#Rule 28
		 'base_classes', 3, undef
	],
	[#Rule 29
		 'base_classes', 0, undef
	],
	[#Rule 30
		 'base_class', 2,
sub
#line 71 "XSP.yp"
{ $_[2] }
	],
	[#Rule 31
		 'base_class', 2,
sub
#line 72 "XSP.yp"
{ $_[2] }
	],
	[#Rule 32
		 'base_class', 2,
sub
#line 73 "XSP.yp"
{ $_[2] }
	],
	[#Rule 33
		 'class_body_list', 1,
sub
#line 78 "XSP.yp"
{ $_[1] ? [ $_[1] ] : [] }
	],
	[#Rule 34
		 'class_body_list', 2,
sub
#line 80 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 35
		 'class_body_element', 1, undef
	],
	[#Rule 36
		 'class_body_element', 1, undef
	],
	[#Rule 37
		 'class_body_element', 1, undef
	],
	[#Rule 38
		 'class_body_element', 1, undef
	],
	[#Rule 39
		 'access_specifier', 2,
sub
#line 86 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 40
		 'access_specifier', 2,
sub
#line 87 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 41
		 'access_specifier', 2,
sub
#line 88 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 42
		 'method_decl', 1,
sub
#line 92 "XSP.yp"
{ my $f = $_[1];
                           my $m = add_data_method
                             ( $_[0],
                               name      => $f->cpp_name,
                               ret_type  => $f->ret_type,
                               arguments => $f->arguments,
                               code      => $f->code,
                               cleanup   => $f->cleanup,
                               );
                           $m
                         }
	],
	[#Rule 43
		 'method_decl', 1, undef
	],
	[#Rule 44
		 'method_decl', 1, undef
	],
	[#Rule 45
		 'const', 1, undef
	],
	[#Rule 46
		 'const', 0, undef
	],
	[#Rule 47
		 'virtual', 1, undef
	],
	[#Rule 48
		 'static', 1, undef
	],
	[#Rule 49
		 'static', 1, undef
	],
	[#Rule 50
		 'function_decl', 8,
sub
#line 116 "XSP.yp"
{ add_data_function( $_[0],
                                         name      => $_[2],
                                         ret_type  => $_[1],
                                         arguments => $_[4],
                                         @{ $_[7] } ) }
	],
	[#Rule 51
		 'ctor', 6,
sub
#line 123 "XSP.yp"
{ add_data_ctor( $_[0], name      => $_[1],
                                            arguments => $_[3],
                                            @{ $_[5] } ) }
	],
	[#Rule 52
		 'dtor', 6,
sub
#line 128 "XSP.yp"
{ add_data_dtor( $_[0], name  => $_[2],
                                            @{ $_[5] },
                                      ) }
	],
	[#Rule 53
		 'metadata', 2,
sub
#line 132 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 54
		 'metadata', 0,
sub
#line 133 "XSP.yp"
{ [] }
	],
	[#Rule 55
		 '_metadata', 1, undef
	],
	[#Rule 56
		 '_metadata', 1, undef
	],
	[#Rule 57
		 'perc_name', 4,
sub
#line 140 "XSP.yp"
{ $_[3] }
	],
	[#Rule 58
		 'perc_package', 4,
sub
#line 141 "XSP.yp"
{ $_[3] }
	],
	[#Rule 59
		 'perc_module', 4,
sub
#line 142 "XSP.yp"
{ $_[3] }
	],
	[#Rule 60
		 'perc_file', 4,
sub
#line 143 "XSP.yp"
{ $_[3] }
	],
	[#Rule 61
		 'perc_code', 2,
sub
#line 144 "XSP.yp"
{ [ code => $_[2] ] }
	],
	[#Rule 62
		 'perc_cleanup', 2,
sub
#line 145 "XSP.yp"
{ [ cleanup => $_[2] ] }
	],
	[#Rule 63
		 'type', 2,
sub
#line 147 "XSP.yp"
{ make_const( make_type( $_[2] ) ) }
	],
	[#Rule 64
		 'type', 2,
sub
#line 148 "XSP.yp"
{ make_ptr( $_[1] ) }
	],
	[#Rule 65
		 'type', 2,
sub
#line 149 "XSP.yp"
{ make_ref( $_[1] ) }
	],
	[#Rule 66
		 'type', 1,
sub
#line 150 "XSP.yp"
{ make_type( $_[1] ) }
	],
	[#Rule 67
		 'type_name', 1, undef
	],
	[#Rule 68
		 'type_name', 1, undef
	],
	[#Rule 69
		 'type_name', 2, undef
	],
	[#Rule 70
		 'basic_type', 1, undef
	],
	[#Rule 71
		 'basic_type', 1, undef
	],
	[#Rule 72
		 'basic_type', 1, undef
	],
	[#Rule 73
		 'basic_type', 1, undef
	],
	[#Rule 74
		 'basic_type', 1, undef
	],
	[#Rule 75
		 'basic_type', 2, undef
	],
	[#Rule 76
		 'basic_type', 2, undef
	],
	[#Rule 77
		 'class_name', 1, undef
	],
	[#Rule 78
		 'class_name', 3,
sub
#line 158 "XSP.yp"
{ $_[1] . '::' . $_[3] }
	],
	[#Rule 79
		 'file_name', 1,
sub
#line 160 "XSP.yp"
{ '-' }
	],
	[#Rule 80
		 'file_name', 3,
sub
#line 161 "XSP.yp"
{ $_[1] . '.' . $_[3] }
	],
	[#Rule 81
		 'file_name', 3,
sub
#line 162 "XSP.yp"
{ $_[1] . '/' . $_[3] }
	],
	[#Rule 82
		 'arg_list', 1,
sub
#line 164 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 83
		 'arg_list', 3,
sub
#line 165 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 84
		 'arg_list', 0, undef
	],
	[#Rule 85
		 'argument', 2,
sub
#line 168 "XSP.yp"
{ make_argument( @_ ) }
	],
	[#Rule 86
		 'argument', 4,
sub
#line 170 "XSP.yp"
{ make_argument( @_[0, 1, 2, 4] ) }
	],
	[#Rule 87
		 'value', 1, undef
	],
	[#Rule 88
		 'value', 2,
sub
#line 173 "XSP.yp"
{ '-' . $_[2] }
	],
	[#Rule 89
		 'value', 1, undef
	],
	[#Rule 90
		 'value', 1, undef
	],
	[#Rule 91
		 'value', 1, undef
	],
	[#Rule 92
		 'value', 3,
sub
#line 177 "XSP.yp"
{ $_[1] . '::' . $_[3] }
	],
	[#Rule 93
		 'value', 4,
sub
#line 178 "XSP.yp"
{ "$_[1]($_[3])" }
	],
	[#Rule 94
		 'special_blocks', 1,
sub
#line 183 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 95
		 'special_blocks', 2,
sub
#line 185 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 96
		 'special_blocks', 0, undef
	],
	[#Rule 97
		 'special_block', 3,
sub
#line 189 "XSP.yp"
{ $_[2] }
	],
	[#Rule 98
		 'special_block', 2,
sub
#line 191 "XSP.yp"
{ [] }
	],
	[#Rule 99
		 'special_block_start', 1,
sub
#line 194 "XSP.yp"
{ push_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 100
		 'special_block_end', 1,
sub
#line 196 "XSP.yp"
{ pop_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 101
		 'lines', 1,
sub
#line 198 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 102
		 'lines', 2,
sub
#line 199 "XSP.yp"
{ push @{$_[1]}, $_[2]; $_[1] }
	]
],
                                  @_);
    bless($self,$class);
}

#line 201 "XSP.yp"


use strict;
use warnings;

use ExtUtils::XSpp::Node;
use ExtUtils::XSpp::Typemap;

my %tokens = ( '::' => 'DCOLON',
               ':'  => 'COLON',
               '%{' => 'OPSPECIAL',
               '%}' => 'CLSPECIAL',
               '{%' => 'OPSPECIAL',
                '{' => 'OPCURLY',
                '}' => 'CLCURLY',
                '(' => 'OPPAR',
                ')' => 'CLPAR',
                ';' => 'SEMICOLON',
                '%' => 'PERC',
                '~' => 'TILDE',
                '*' => 'STAR',
                '&' => 'AMP',
                ',' => 'COMMA',
                '=' => 'EQUAL',
                '/' => 'SLASH',
                '.' => 'DOT',
                '-' => 'DASH',
               # these are here due to my lack of skill with yacc
               '%name' => 'p_name',
               '%typemap' => 'p_typemap',
               '%file' => 'p_file',
               '%module' => 'p_module',
               '%code' => 'p_code',
               '%cleanup' => 'p_cleanup',
               '%package' => 'p_package',
             );

my %keywords = ( const => 1,
                 class => 1,
                 unsigned => 1,
                 short => 1,
                 long => 1,
                 int => 1,
                 char => 1,
                 package_static => 1,
                 class_static => 1,
                 public => 1,
                 private => 1,
                 protected => 1,
                 virtual => 1,
                 );

sub get_lex_mode { return $_[0]->YYData->{LEX}{MODES}[0] || '' }

sub push_lex_mode {
  my( $p, $mode ) = @_;

  push @{$p->YYData->{LEX}{MODES}}, $mode;
}

sub pop_lex_mode {
  my( $p, $mode ) = @_;

  die "Unexpected mode: '$mode'"
    unless get_lex_mode( $p ) eq $mode;

  pop @{$p->YYData->{LEX}{MODES}};
}

sub read_more {
  my( $fh, $buf ) = @_;
  my $v = <$fh>;

  return unless defined $v;

  $$buf .= $v;

  return 1;
}

sub yylex {
  my $data = $_[0]->YYData->{LEX};
  my $fh = $data->{FH};
  my $buf = $data->{BUFFER};

  for(;;) {
    if( !length( $$buf ) && !read_more( $fh, $buf ) ) {
      return ( '', undef );
    }

    if( get_lex_mode( $_[0] ) eq 'special' ) {
      if( $$buf =~ s/^%}// ) {
        return ( 'CLSPECIAL', '%}' );
      } elsif( $$buf =~ s/^([^\n]*)\n$// ) {
        my $line = $1;

        if( $line =~ m/^(.*?)\%}(.*)$/ ) {
          $$buf = "%}$2\n";
          $line = $1;
        }

        return ( 'line', $line );
      }
    } else {
      $$buf =~ s/^[\s\n\r]+//;
      next unless length $$buf;

      if( $$buf =~ s/^([+-]?(?=\d|\.\d)\d*(?:\.\d*)?(?:[Ee](?:[+-]?\d+))?)// ) {
        return ( 'FLOAT', $1 );
      } elsif( $$buf =~ s/^\/\/(.*)(?:\r\n|\r|\n)// ) {
        return ( 'RAW_CODE', '##' . $1 );
      } elsif( $$buf =~ s/^\/\*// ) {
        my $raw = '/*';
        for(; length( $$buf ) || read_more( $fh, $buf ); $$buf = '') {
          if( $$buf =~ s/(.*?\*\/)// ) {
              return ( 'RAW_CODE', $raw . $1 );
          }
          $raw .= $$buf;
        }
      } elsif( $$buf =~ s/^( \%}
                      | \%{ | {\%
                      | \%name | \%typemap | \%module | \%code
                      | \%file | \%cleanup | \%package
                      | [{}();%~*&,=\/\.\-]
                      | :: | :
                       )//x ) {
        return ( $tokens{$1}, $1 );
      } elsif( $$buf =~ s/^(INCLUDE:.*)(?:\r\n|\r|\n)// ) {
        return ( 'RAW_CODE', "$1\n" );
      } elsif( $$buf =~ m/^([a-zA-Z_]\w*)\W/ ) {
        $$buf =~ s/^(\w+)//;

        return ( $1, $1 ) if exists $keywords{$1};

        return ( 'ID', $1 );
      } elsif( $$buf =~ s/^(\d+)// ) {
        return ( 'INTEGER', $1 );
      } elsif( $$buf =~ s/^("[^"]*")// ) {
        return ( 'QUOTED_STRING', $1 );
      } elsif( $$buf =~ s/^(#.*)(?:\r\n|\r|\n)// ) {
        return ( 'RAW_CODE', $1 );
      } else {
        die $$buf;
      }
    }
  }
}

sub yyerror {
  my $data = $_[0]->YYData->{LEX};
  my $buf = $data->{BUFFER};
  my $fh = $data->{FH};
   
  print STDERR "Error: line " . $fh->input_line_number . " (",
    $_[0]->YYCurtok, ') (',
    $_[0]->YYCurval, ') "', ( $buf ? $$buf : '--empty buffer--' ),
      q{"} . "\n";
  print STDERR "Expecting: (", ( join ", ", map { "'$_'" } $_[0]->YYExpect ),
        ")\n";
}

sub make_const { $_[0]->{CONST} = 1; $_[0] }
sub make_ref   { $_[0]->{REFERENCE} = 1; $_[0] }
sub make_ptr   { $_[0]->{POINTER}++; $_[0] }
sub make_type  { ExtUtils::XSpp::Node::Type->new( base => $_[0] ) }

sub add_data_raw {
  my $p = shift;
  my $rows = shift;

  ExtUtils::XSpp::Node::Raw->new( rows => $rows );
}

sub make_argument {
  my( $p, $type, $name, $default ) = @_;

  ExtUtils::XSpp::Node::Argument->new( type    => $type,
                              name    => $name,
                              default => $default );
}

sub create_class {
  my( $parser, $name, $bases, $methods ) = @_;
  my $class = ExtUtils::XSpp::Node::Class->new( cpp_name     => $name,
                                                base_classes => $bases );
  $class->add_methods( @$methods );
  return $class;
}

sub add_data_function {
  my( $parser, %args ) = @_;

  ExtUtils::XSpp::Node::Function->new( cpp_name  => $args{name},
                                class     => $args{class},
                                ret_type  => $args{ret_type},
                                arguments => $args{arguments},
                                code      => $args{code},
                                cleanup   => $args{cleanup},
                                );
}

sub add_data_method {
  my( $parser, %args ) = @_;

  ExtUtils::XSpp::Node::Method->new( cpp_name  => $args{name},
                              ret_type  => $args{ret_type},
                              arguments => $args{arguments},
                              code      => $args{code},
                              cleanup   => $args{cleanup},
                              perl_name => $args{perl_name},
                              );
}

sub add_data_ctor {
  my( $parser, %args ) = @_;

  ExtUtils::XSpp::Node::Constructor->new( cpp_name  => $args{name},
                                   arguments => $args{arguments},
                                   code      => $args{code},
                                   );
}

sub add_data_dtor {
  my( $parser, %args ) = @_;

  ExtUtils::XSpp::Node::Destructor->new( cpp_name  => $args{name},
                                  code      => $args{code},
                                  );
}

sub is_directive {
  my( $p, $d, $name ) = @_;

  return $d->[0] eq $name;
}

#sub assert_directive {
#  my( $p, $d, $name ) = @_;
#
#  if( $d->[0] ne $name )
#    { $p->YYError }
#  1;
#}

1;
