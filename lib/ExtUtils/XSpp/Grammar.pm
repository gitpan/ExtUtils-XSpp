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
			'ID' => 21,
			'p_typemap' => 3,
			'OPSPECIAL' => 25,
			"class" => 5,
			'RAW_CODE' => 27,
			"const" => 7,
			"int" => 29,
			'p_module' => 11,
			'p_package' => 33,
			'p_loadplugin' => 34,
			"short" => 13,
			'p_file' => 35,
			"unsigned" => 37,
			'p_name' => 15,
			'p_include' => 16,
			"long" => 17,
			"char" => 20
		},
		GOTOS => {
			'perc_loadplugin' => 22,
			'class_name' => 1,
			'top_list' => 2,
			'perc_package' => 24,
			'function' => 23,
			'special_block_start' => 26,
			'perc_name' => 4,
			'class_decl' => 28,
			'typemap' => 6,
			'decorate_class' => 8,
			'special_block' => 9,
			'perc_module' => 30,
			'type_name' => 10,
			'perc_file' => 32,
			'basic_type' => 31,
			'decorate_function' => 12,
			'top' => 14,
			'function_decl' => 36,
			'perc_include' => 38,
			'directive' => 39,
			'type' => 18,
			'class' => 19,
			'raw' => 40
		}
	},
	{#State 1
		DEFAULT => -71
	},
	{#State 2
		ACTIONS => {
			'ID' => 21,
			'' => 41,
			'p_typemap' => 3,
			'OPSPECIAL' => 25,
			"class" => 5,
			'RAW_CODE' => 27,
			"const" => 7,
			"int" => 29,
			'p_module' => 11,
			'p_loadplugin' => 34,
			'p_package' => 33,
			"short" => 13,
			'p_file' => 35,
			"unsigned" => 37,
			'p_name' => 15,
			'p_include' => 16,
			"long" => 17,
			"char" => 20
		},
		GOTOS => {
			'perc_loadplugin' => 22,
			'class_name' => 1,
			'function' => 23,
			'perc_package' => 24,
			'special_block_start' => 26,
			'perc_name' => 4,
			'class_decl' => 28,
			'typemap' => 6,
			'decorate_class' => 8,
			'special_block' => 9,
			'perc_module' => 30,
			'type_name' => 10,
			'perc_file' => 32,
			'basic_type' => 31,
			'decorate_function' => 12,
			'top' => 42,
			'function_decl' => 36,
			'perc_include' => 38,
			'directive' => 39,
			'type' => 18,
			'class' => 19,
			'raw' => 40
		}
	},
	{#State 3
		ACTIONS => {
			'OPCURLY' => 43
		}
	},
	{#State 4
		ACTIONS => {
			'ID' => 21,
			"class" => 5,
			"short" => 13,
			"const" => 7,
			'p_name' => 15,
			"unsigned" => 37,
			"long" => 17,
			"int" => 29,
			"char" => 20
		},
		GOTOS => {
			'type_name' => 10,
			'class_name' => 1,
			'basic_type' => 31,
			'function' => 45,
			'decorate_function' => 12,
			'perc_name' => 4,
			'class_decl' => 28,
			'function_decl' => 36,
			'decorate_class' => 8,
			'type' => 18,
			'class' => 44
		}
	},
	{#State 5
		ACTIONS => {
			'ID' => 46
		}
	},
	{#State 6
		DEFAULT => -12
	},
	{#State 7
		ACTIONS => {
			'ID' => 21,
			"short" => 13,
			"unsigned" => 37,
			"long" => 17,
			"int" => 29,
			"char" => 20
		},
		GOTOS => {
			'type_name' => 47,
			'class_name' => 1,
			'basic_type' => 31
		}
	},
	{#State 8
		DEFAULT => -17
	},
	{#State 9
		DEFAULT => -15
	},
	{#State 10
		DEFAULT => -70
	},
	{#State 11
		ACTIONS => {
			'OPCURLY' => 48
		}
	},
	{#State 12
		DEFAULT => -19
	},
	{#State 13
		ACTIONS => {
			"int" => 49
		},
		DEFAULT => -78
	},
	{#State 14
		DEFAULT => -1
	},
	{#State 15
		ACTIONS => {
			'OPCURLY' => 50
		}
	},
	{#State 16
		ACTIONS => {
			'OPCURLY' => 51
		}
	},
	{#State 17
		ACTIONS => {
			"int" => 52
		},
		DEFAULT => -77
	},
	{#State 18
		ACTIONS => {
			'ID' => 55,
			'STAR' => 54,
			'AMP' => 53
		}
	},
	{#State 19
		DEFAULT => -4
	},
	{#State 20
		DEFAULT => -75
	},
	{#State 21
		ACTIONS => {
			'DCOLON' => 57
		},
		DEFAULT => -81,
		GOTOS => {
			'class_suffix' => 56
		}
	},
	{#State 22
		ACTIONS => {
			'SEMICOLON' => 58
		}
	},
	{#State 23
		DEFAULT => -6
	},
	{#State 24
		ACTIONS => {
			'SEMICOLON' => 59
		}
	},
	{#State 25
		DEFAULT => -106
	},
	{#State 26
		ACTIONS => {
			'CLSPECIAL' => 60,
			'line' => 61
		},
		GOTOS => {
			'special_block_end' => 62,
			'lines' => 63
		}
	},
	{#State 27
		DEFAULT => -14
	},
	{#State 28
		DEFAULT => -16
	},
	{#State 29
		DEFAULT => -76
	},
	{#State 30
		ACTIONS => {
			'SEMICOLON' => 64
		}
	},
	{#State 31
		DEFAULT => -73
	},
	{#State 32
		ACTIONS => {
			'SEMICOLON' => 65
		}
	},
	{#State 33
		ACTIONS => {
			'OPCURLY' => 66
		}
	},
	{#State 34
		ACTIONS => {
			'OPCURLY' => 67
		}
	},
	{#State 35
		ACTIONS => {
			'OPCURLY' => 68
		}
	},
	{#State 36
		DEFAULT => -18
	},
	{#State 37
		ACTIONS => {
			"short" => 13,
			"long" => 17,
			"int" => 29,
			"char" => 20
		},
		DEFAULT => -72,
		GOTOS => {
			'basic_type' => 69
		}
	},
	{#State 38
		ACTIONS => {
			'SEMICOLON' => 70
		}
	},
	{#State 39
		DEFAULT => -5
	},
	{#State 40
		DEFAULT => -3
	},
	{#State 41
		DEFAULT => 0
	},
	{#State 42
		DEFAULT => -2
	},
	{#State 43
		ACTIONS => {
			'ID' => 21,
			"short" => 13,
			"unsigned" => 37,
			"const" => 7,
			"long" => 17,
			"int" => 29,
			"char" => 20
		},
		GOTOS => {
			'type_name' => 10,
			'class_name' => 1,
			'basic_type' => 31,
			'type' => 71
		}
	},
	{#State 44
		DEFAULT => -22
	},
	{#State 45
		DEFAULT => -23
	},
	{#State 46
		ACTIONS => {
			'COLON' => 73
		},
		DEFAULT => -31,
		GOTOS => {
			'base_classes' => 72
		}
	},
	{#State 47
		DEFAULT => -67
	},
	{#State 48
		ACTIONS => {
			'ID' => 21
		},
		GOTOS => {
			'class_name' => 74
		}
	},
	{#State 49
		DEFAULT => -80
	},
	{#State 50
		ACTIONS => {
			'ID' => 21
		},
		GOTOS => {
			'class_name' => 75
		}
	},
	{#State 51
		ACTIONS => {
			'ID' => 77,
			'DASH' => 78
		},
		GOTOS => {
			'file_name' => 76
		}
	},
	{#State 52
		DEFAULT => -79
	},
	{#State 53
		DEFAULT => -69
	},
	{#State 54
		DEFAULT => -68
	},
	{#State 55
		ACTIONS => {
			'OPPAR' => 79
		}
	},
	{#State 56
		ACTIONS => {
			'DCOLON' => 80
		},
		DEFAULT => -82
	},
	{#State 57
		ACTIONS => {
			'ID' => 81
		}
	},
	{#State 58
		DEFAULT => -10
	},
	{#State 59
		DEFAULT => -8
	},
	{#State 60
		DEFAULT => -107
	},
	{#State 61
		DEFAULT => -108
	},
	{#State 62
		DEFAULT => -105
	},
	{#State 63
		ACTIONS => {
			'CLSPECIAL' => 60,
			'line' => 82
		},
		GOTOS => {
			'special_block_end' => 83
		}
	},
	{#State 64
		DEFAULT => -7
	},
	{#State 65
		DEFAULT => -9
	},
	{#State 66
		ACTIONS => {
			'ID' => 21
		},
		GOTOS => {
			'class_name' => 84
		}
	},
	{#State 67
		ACTIONS => {
			'ID' => 21
		},
		GOTOS => {
			'class_name' => 85
		}
	},
	{#State 68
		ACTIONS => {
			'ID' => 77,
			'DASH' => 78
		},
		GOTOS => {
			'file_name' => 86
		}
	},
	{#State 69
		DEFAULT => -74
	},
	{#State 70
		DEFAULT => -11
	},
	{#State 71
		ACTIONS => {
			'STAR' => 54,
			'AMP' => 53,
			'CLCURLY' => 87
		}
	},
	{#State 72
		ACTIONS => {
			'OPCURLY' => 88,
			"," => 89
		}
	},
	{#State 73
		ACTIONS => {
			"protected" => 93,
			"private" => 92,
			"public" => 90
		},
		GOTOS => {
			'base_class' => 91
		}
	},
	{#State 74
		ACTIONS => {
			'CLCURLY' => 94
		}
	},
	{#State 75
		ACTIONS => {
			'CLCURLY' => 95
		}
	},
	{#State 76
		ACTIONS => {
			'CLCURLY' => 96
		}
	},
	{#State 77
		ACTIONS => {
			'DOT' => 98,
			'SLASH' => 97
		}
	},
	{#State 78
		DEFAULT => -85
	},
	{#State 79
		ACTIONS => {
			'ID' => 21,
			"short" => 13,
			"const" => 7,
			"unsigned" => 37,
			"long" => 17,
			"int" => 29,
			"char" => 20
		},
		DEFAULT => -90,
		GOTOS => {
			'argument' => 101,
			'type_name' => 10,
			'class_name' => 1,
			'basic_type' => 31,
			'type' => 99,
			'arg_list' => 100
		}
	},
	{#State 80
		ACTIONS => {
			'ID' => 102
		}
	},
	{#State 81
		DEFAULT => -83
	},
	{#State 82
		DEFAULT => -109
	},
	{#State 83
		DEFAULT => -104
	},
	{#State 84
		ACTIONS => {
			'CLCURLY' => 103
		}
	},
	{#State 85
		ACTIONS => {
			'CLCURLY' => 104
		}
	},
	{#State 86
		ACTIONS => {
			'CLCURLY' => 105
		}
	},
	{#State 87
		ACTIONS => {
			'OPCURLY' => 106
		}
	},
	{#State 88
		ACTIONS => {
			'ID' => 119,
			'p_typemap' => 3,
			'OPSPECIAL' => 25,
			"virtual" => 121,
			"class_static" => 107,
			"package_static" => 122,
			"public" => 109,
			'RAW_CODE' => 27,
			"const" => 7,
			"int" => 29,
			"private" => 112,
			'CLCURLY' => 127,
			"short" => 13,
			"unsigned" => 37,
			'TILDE' => 115,
			'p_name' => 15,
			"protected" => 116,
			"long" => 17,
			"char" => 20
		},
		GOTOS => {
			'decorate_method' => 120,
			'class_name' => 1,
			'static' => 108,
			'special_block_start' => 26,
			'perc_name' => 110,
			'typemap' => 111,
			'class_body_element' => 123,
			'class_body_list' => 125,
			'method' => 124,
			'special_block' => 9,
			'access_specifier' => 113,
			'type_name' => 10,
			'ctor' => 114,
			'basic_type' => 31,
			'virtual' => 126,
			'function_decl' => 128,
			'type' => 18,
			'dtor' => 117,
			'raw' => 129,
			'method_decl' => 118
		}
	},
	{#State 89
		ACTIONS => {
			"protected" => 93,
			"private" => 92,
			"public" => 90
		},
		GOTOS => {
			'base_class' => 130
		}
	},
	{#State 90
		ACTIONS => {
			'ID' => 131
		}
	},
	{#State 91
		DEFAULT => -29
	},
	{#State 92
		ACTIONS => {
			'ID' => 132
		}
	},
	{#State 93
		ACTIONS => {
			'ID' => 133
		}
	},
	{#State 94
		DEFAULT => -61
	},
	{#State 95
		DEFAULT => -59
	},
	{#State 96
		DEFAULT => -64
	},
	{#State 97
		ACTIONS => {
			'ID' => 77,
			'DASH' => 78
		},
		GOTOS => {
			'file_name' => 134
		}
	},
	{#State 98
		ACTIONS => {
			'ID' => 135
		}
	},
	{#State 99
		ACTIONS => {
			'ID' => 137,
			'STAR' => 54,
			'AMP' => 53,
			'p_length' => 136
		}
	},
	{#State 100
		ACTIONS => {
			'CLPAR' => 138,
			'COMMA' => 139
		}
	},
	{#State 101
		DEFAULT => -88
	},
	{#State 102
		DEFAULT => -84
	},
	{#State 103
		DEFAULT => -60
	},
	{#State 104
		DEFAULT => -63
	},
	{#State 105
		DEFAULT => -62
	},
	{#State 106
		ACTIONS => {
			'ID' => 140
		}
	},
	{#State 107
		DEFAULT => -51
	},
	{#State 108
		ACTIONS => {
			'ID' => 119,
			"virtual" => 121,
			"class_static" => 107,
			"package_static" => 122,
			"short" => 13,
			"unsigned" => 37,
			"const" => 7,
			'p_name' => 15,
			'TILDE' => 115,
			"long" => 17,
			"int" => 29,
			"char" => 20
		},
		GOTOS => {
			'decorate_method' => 120,
			'type_name' => 10,
			'class_name' => 1,
			'ctor' => 114,
			'basic_type' => 31,
			'static' => 108,
			'virtual' => 126,
			'perc_name' => 110,
			'function_decl' => 128,
			'method' => 141,
			'type' => 18,
			'dtor' => 117,
			'method_decl' => 118
		}
	},
	{#State 109
		ACTIONS => {
			'COLON' => 142
		}
	},
	{#State 110
		ACTIONS => {
			'ID' => 119,
			"virtual" => 121,
			"class_static" => 107,
			"package_static" => 122,
			"short" => 13,
			"unsigned" => 37,
			"const" => 7,
			'p_name' => 15,
			'TILDE' => 115,
			"long" => 17,
			"int" => 29,
			"char" => 20
		},
		GOTOS => {
			'decorate_method' => 120,
			'type_name' => 10,
			'class_name' => 1,
			'ctor' => 114,
			'basic_type' => 31,
			'static' => 108,
			'virtual' => 126,
			'perc_name' => 110,
			'function_decl' => 128,
			'method' => 143,
			'type' => 18,
			'dtor' => 117,
			'method_decl' => 118
		}
	},
	{#State 111
		DEFAULT => -39
	},
	{#State 112
		ACTIONS => {
			'COLON' => 144
		}
	},
	{#State 113
		DEFAULT => -40
	},
	{#State 114
		DEFAULT => -45
	},
	{#State 115
		ACTIONS => {
			'ID' => 145
		}
	},
	{#State 116
		ACTIONS => {
			'COLON' => 146
		}
	},
	{#State 117
		DEFAULT => -46
	},
	{#State 118
		DEFAULT => -20
	},
	{#State 119
		ACTIONS => {
			'DCOLON' => 57,
			'OPPAR' => 147
		},
		DEFAULT => -81,
		GOTOS => {
			'class_suffix' => 56
		}
	},
	{#State 120
		DEFAULT => -21
	},
	{#State 121
		DEFAULT => -49
	},
	{#State 122
		DEFAULT => -50
	},
	{#State 123
		DEFAULT => -35
	},
	{#State 124
		DEFAULT => -37
	},
	{#State 125
		ACTIONS => {
			'ID' => 119,
			'p_typemap' => 3,
			'OPSPECIAL' => 25,
			"virtual" => 121,
			"class_static" => 107,
			"package_static" => 122,
			"public" => 109,
			'RAW_CODE' => 27,
			"const" => 7,
			"int" => 29,
			"private" => 112,
			'CLCURLY' => 149,
			"short" => 13,
			"unsigned" => 37,
			'TILDE' => 115,
			'p_name' => 15,
			"protected" => 116,
			"long" => 17,
			"char" => 20
		},
		GOTOS => {
			'decorate_method' => 120,
			'class_name' => 1,
			'static' => 108,
			'special_block_start' => 26,
			'perc_name' => 110,
			'typemap' => 111,
			'class_body_element' => 148,
			'method' => 124,
			'special_block' => 9,
			'access_specifier' => 113,
			'type_name' => 10,
			'ctor' => 114,
			'basic_type' => 31,
			'virtual' => 126,
			'function_decl' => 128,
			'type' => 18,
			'dtor' => 117,
			'raw' => 129,
			'method_decl' => 118
		}
	},
	{#State 126
		ACTIONS => {
			'ID' => 119,
			"virtual" => 121,
			"class_static" => 107,
			"package_static" => 122,
			"short" => 13,
			"unsigned" => 37,
			"const" => 7,
			'p_name' => 15,
			'TILDE' => 115,
			"long" => 17,
			"int" => 29,
			"char" => 20
		},
		GOTOS => {
			'decorate_method' => 120,
			'type_name' => 10,
			'class_name' => 1,
			'ctor' => 114,
			'basic_type' => 31,
			'static' => 108,
			'virtual' => 126,
			'perc_name' => 110,
			'function_decl' => 128,
			'method' => 150,
			'type' => 18,
			'dtor' => 117,
			'method_decl' => 118
		}
	},
	{#State 127
		ACTIONS => {
			'SEMICOLON' => 151
		}
	},
	{#State 128
		DEFAULT => -44
	},
	{#State 129
		DEFAULT => -38
	},
	{#State 130
		DEFAULT => -30
	},
	{#State 131
		DEFAULT => -32
	},
	{#State 132
		DEFAULT => -34
	},
	{#State 133
		DEFAULT => -33
	},
	{#State 134
		DEFAULT => -87
	},
	{#State 135
		DEFAULT => -86
	},
	{#State 136
		ACTIONS => {
			'OPCURLY' => 152
		}
	},
	{#State 137
		ACTIONS => {
			'EQUAL' => 153
		},
		DEFAULT => -93
	},
	{#State 138
		ACTIONS => {
			"const" => 154
		},
		DEFAULT => -48,
		GOTOS => {
			'const' => 155
		}
	},
	{#State 139
		ACTIONS => {
			'ID' => 21,
			"short" => 13,
			"unsigned" => 37,
			"const" => 7,
			"long" => 17,
			"int" => 29,
			"char" => 20
		},
		GOTOS => {
			'argument' => 156,
			'type_name' => 10,
			'class_name' => 1,
			'basic_type' => 31,
			'type' => 99
		}
	},
	{#State 140
		ACTIONS => {
			'CLCURLY' => 157
		}
	},
	{#State 141
		DEFAULT => -25
	},
	{#State 142
		DEFAULT => -41
	},
	{#State 143
		DEFAULT => -24
	},
	{#State 144
		DEFAULT => -43
	},
	{#State 145
		ACTIONS => {
			'OPPAR' => 158
		}
	},
	{#State 146
		DEFAULT => -42
	},
	{#State 147
		ACTIONS => {
			'ID' => 21,
			"short" => 13,
			"const" => 7,
			"unsigned" => 37,
			"long" => 17,
			"int" => 29,
			"char" => 20
		},
		DEFAULT => -90,
		GOTOS => {
			'argument' => 101,
			'type_name' => 10,
			'class_name' => 1,
			'basic_type' => 31,
			'type' => 99,
			'arg_list' => 159
		}
	},
	{#State 148
		DEFAULT => -36
	},
	{#State 149
		ACTIONS => {
			'SEMICOLON' => 160
		}
	},
	{#State 150
		DEFAULT => -26
	},
	{#State 151
		DEFAULT => -28
	},
	{#State 152
		ACTIONS => {
			'ID' => 161
		}
	},
	{#State 153
		ACTIONS => {
			'ID' => 165,
			'INTEGER' => 162,
			'QUOTED_STRING' => 164,
			'DASH' => 167,
			'FLOAT' => 166
		},
		GOTOS => {
			'value' => 163
		}
	},
	{#State 154
		DEFAULT => -47
	},
	{#State 155
		DEFAULT => -56,
		GOTOS => {
			'metadata' => 168
		}
	},
	{#State 156
		DEFAULT => -89
	},
	{#State 157
		ACTIONS => {
			'OPSPECIAL' => 25
		},
		DEFAULT => -103,
		GOTOS => {
			'special_blocks' => 170,
			'special_block' => 169,
			'special_block_start' => 26
		}
	},
	{#State 158
		ACTIONS => {
			'CLPAR' => 171
		}
	},
	{#State 159
		ACTIONS => {
			'CLPAR' => 172,
			'COMMA' => 139
		}
	},
	{#State 160
		DEFAULT => -27
	},
	{#State 161
		ACTIONS => {
			'CLCURLY' => 173
		}
	},
	{#State 162
		DEFAULT => -94
	},
	{#State 163
		DEFAULT => -92
	},
	{#State 164
		DEFAULT => -97
	},
	{#State 165
		ACTIONS => {
			'DCOLON' => 174,
			'OPPAR' => 175
		},
		DEFAULT => -98
	},
	{#State 166
		DEFAULT => -96
	},
	{#State 167
		ACTIONS => {
			'INTEGER' => 176
		}
	},
	{#State 168
		ACTIONS => {
			'p_code' => 180,
			'p_cleanup' => 178,
			'SEMICOLON' => 181
		},
		GOTOS => {
			'_metadata' => 179,
			'perc_code' => 177,
			'perc_cleanup' => 182
		}
	},
	{#State 169
		DEFAULT => -101
	},
	{#State 170
		ACTIONS => {
			'OPSPECIAL' => 25,
			'SEMICOLON' => 184
		},
		GOTOS => {
			'special_block' => 183,
			'special_block_start' => 26
		}
	},
	{#State 171
		DEFAULT => -56,
		GOTOS => {
			'metadata' => 185
		}
	},
	{#State 172
		DEFAULT => -56,
		GOTOS => {
			'metadata' => 186
		}
	},
	{#State 173
		DEFAULT => -91
	},
	{#State 174
		ACTIONS => {
			'ID' => 187
		}
	},
	{#State 175
		ACTIONS => {
			'ID' => 165,
			'INTEGER' => 162,
			'QUOTED_STRING' => 164,
			'DASH' => 167,
			'FLOAT' => 166
		},
		GOTOS => {
			'value' => 188
		}
	},
	{#State 176
		DEFAULT => -95
	},
	{#State 177
		DEFAULT => -57
	},
	{#State 178
		ACTIONS => {
			'OPSPECIAL' => 25
		},
		GOTOS => {
			'special_block' => 189,
			'special_block_start' => 26
		}
	},
	{#State 179
		DEFAULT => -55
	},
	{#State 180
		ACTIONS => {
			'OPSPECIAL' => 25
		},
		GOTOS => {
			'special_block' => 190,
			'special_block_start' => 26
		}
	},
	{#State 181
		DEFAULT => -52
	},
	{#State 182
		DEFAULT => -58
	},
	{#State 183
		DEFAULT => -102
	},
	{#State 184
		DEFAULT => -13
	},
	{#State 185
		ACTIONS => {
			'p_code' => 180,
			'p_cleanup' => 178,
			'SEMICOLON' => 191
		},
		GOTOS => {
			'_metadata' => 179,
			'perc_code' => 177,
			'perc_cleanup' => 182
		}
	},
	{#State 186
		ACTIONS => {
			'p_code' => 180,
			'p_cleanup' => 178,
			'SEMICOLON' => 192
		},
		GOTOS => {
			'_metadata' => 179,
			'perc_code' => 177,
			'perc_cleanup' => 182
		}
	},
	{#State 187
		DEFAULT => -99
	},
	{#State 188
		ACTIONS => {
			'CLPAR' => 193
		}
	},
	{#State 189
		DEFAULT => -66
	},
	{#State 190
		DEFAULT => -65
	},
	{#State 191
		DEFAULT => -54
	},
	{#State 192
		DEFAULT => -53
	},
	{#State 193
		DEFAULT => -100
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
{ add_data_raw( $_[0], [ @{$_[1]} ] ) }
	],
	[#Rule 16
		 'class', 1, undef
	],
	[#Rule 17
		 'class', 1, undef
	],
	[#Rule 18
		 'function', 1, undef
	],
	[#Rule 19
		 'function', 1, undef
	],
	[#Rule 20
		 'method', 1, undef
	],
	[#Rule 21
		 'method', 1, undef
	],
	[#Rule 22
		 'decorate_class', 2,
sub
#line 58 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 23
		 'decorate_function', 2,
sub
#line 59 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 24
		 'decorate_method', 2,
sub
#line 60 "XSP.yp"
{ $_[2]->set_perl_name( $_[1] ); $_[2] }
	],
	[#Rule 25
		 'decorate_method', 2,
sub
#line 61 "XSP.yp"
{ $_[2]->set_static( $_[1] ); $_[2] }
	],
	[#Rule 26
		 'decorate_method', 2,
sub
#line 62 "XSP.yp"
{ $_[2]->set_virtual( 1 ); $_[2] }
	],
	[#Rule 27
		 'class_decl', 7,
sub
#line 65 "XSP.yp"
{ create_class( $_[0], $_[2], $_[3], $_[5] ) }
	],
	[#Rule 28
		 'class_decl', 6,
sub
#line 67 "XSP.yp"
{ create_class( $_[0], $_[2], $_[3], [] ) }
	],
	[#Rule 29
		 'base_classes', 2, undef
	],
	[#Rule 30
		 'base_classes', 3, undef
	],
	[#Rule 31
		 'base_classes', 0, undef
	],
	[#Rule 32
		 'base_class', 2,
sub
#line 75 "XSP.yp"
{ $_[2] }
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
		 'class_body_list', 1,
sub
#line 82 "XSP.yp"
{ $_[1] ? [ $_[1] ] : [] }
	],
	[#Rule 36
		 'class_body_list', 2,
sub
#line 84 "XSP.yp"
{ push @{$_[1]}, $_[2] if $_[2]; $_[1] }
	],
	[#Rule 37
		 'class_body_element', 1, undef
	],
	[#Rule 38
		 'class_body_element', 1, undef
	],
	[#Rule 39
		 'class_body_element', 1, undef
	],
	[#Rule 40
		 'class_body_element', 1, undef
	],
	[#Rule 41
		 'access_specifier', 2,
sub
#line 90 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 42
		 'access_specifier', 2,
sub
#line 91 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 43
		 'access_specifier', 2,
sub
#line 92 "XSP.yp"
{ ExtUtils::XSpp::Node::Access->new( access => $_[1] ) }
	],
	[#Rule 44
		 'method_decl', 1,
sub
#line 96 "XSP.yp"
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
	[#Rule 45
		 'method_decl', 1, undef
	],
	[#Rule 46
		 'method_decl', 1, undef
	],
	[#Rule 47
		 'const', 1, undef
	],
	[#Rule 48
		 'const', 0, undef
	],
	[#Rule 49
		 'virtual', 1, undef
	],
	[#Rule 50
		 'static', 1, undef
	],
	[#Rule 51
		 'static', 1, undef
	],
	[#Rule 52
		 'function_decl', 8,
sub
#line 120 "XSP.yp"
{ add_data_function( $_[0],
                                         name      => $_[2],
                                         ret_type  => $_[1],
                                         arguments => $_[4],
                                         @{ $_[7] } ) }
	],
	[#Rule 53
		 'ctor', 6,
sub
#line 127 "XSP.yp"
{ add_data_ctor( $_[0], name      => $_[1],
                                            arguments => $_[3],
                                            @{ $_[5] } ) }
	],
	[#Rule 54
		 'dtor', 6,
sub
#line 132 "XSP.yp"
{ add_data_dtor( $_[0], name  => $_[2],
                                            @{ $_[5] },
                                      ) }
	],
	[#Rule 55
		 'metadata', 2,
sub
#line 136 "XSP.yp"
{ [ @{$_[1]}, @{$_[2]} ] }
	],
	[#Rule 56
		 'metadata', 0,
sub
#line 137 "XSP.yp"
{ [] }
	],
	[#Rule 57
		 '_metadata', 1, undef
	],
	[#Rule 58
		 '_metadata', 1, undef
	],
	[#Rule 59
		 'perc_name', 4,
sub
#line 144 "XSP.yp"
{ $_[3] }
	],
	[#Rule 60
		 'perc_package', 4,
sub
#line 145 "XSP.yp"
{ $_[3] }
	],
	[#Rule 61
		 'perc_module', 4,
sub
#line 146 "XSP.yp"
{ $_[3] }
	],
	[#Rule 62
		 'perc_file', 4,
sub
#line 147 "XSP.yp"
{ $_[3] }
	],
	[#Rule 63
		 'perc_loadplugin', 4,
sub
#line 148 "XSP.yp"
{ $_[3] }
	],
	[#Rule 64
		 'perc_include', 4,
sub
#line 149 "XSP.yp"
{ $_[3] }
	],
	[#Rule 65
		 'perc_code', 2,
sub
#line 150 "XSP.yp"
{ [ code => $_[2] ] }
	],
	[#Rule 66
		 'perc_cleanup', 2,
sub
#line 151 "XSP.yp"
{ [ cleanup => $_[2] ] }
	],
	[#Rule 67
		 'type', 2,
sub
#line 153 "XSP.yp"
{ make_const( make_type( $_[2] ) ) }
	],
	[#Rule 68
		 'type', 2,
sub
#line 154 "XSP.yp"
{ make_ptr( $_[1] ) }
	],
	[#Rule 69
		 'type', 2,
sub
#line 155 "XSP.yp"
{ make_ref( $_[1] ) }
	],
	[#Rule 70
		 'type', 1,
sub
#line 156 "XSP.yp"
{ make_type( join(' ', @_[1..$#_]) ) }
	],
	[#Rule 71
		 'type_name', 1, undef
	],
	[#Rule 72
		 'type_name', 1, undef
	],
	[#Rule 73
		 'type_name', 1, undef
	],
	[#Rule 74
		 'type_name', 2,
sub
#line 159 "XSP.yp"
{ join ' ', @_[1..$#_]; }
	],
	[#Rule 75
		 'basic_type', 1, undef
	],
	[#Rule 76
		 'basic_type', 1, undef
	],
	[#Rule 77
		 'basic_type', 1, undef
	],
	[#Rule 78
		 'basic_type', 1, undef
	],
	[#Rule 79
		 'basic_type', 2, undef
	],
	[#Rule 80
		 'basic_type', 2,
sub
#line 162 "XSP.yp"
{ join ' ', @_[1..$#_]; }
	],
	[#Rule 81
		 'class_name', 1, undef
	],
	[#Rule 82
		 'class_name', 2,
sub
#line 165 "XSP.yp"
{ $_[1] . '::' . $_[2] }
	],
	[#Rule 83
		 'class_suffix', 2,
sub
#line 167 "XSP.yp"
{ $_[2] }
	],
	[#Rule 84
		 'class_suffix', 3,
sub
#line 168 "XSP.yp"
{ $_[1] . '::' . $_[3] }
	],
	[#Rule 85
		 'file_name', 1,
sub
#line 170 "XSP.yp"
{ '-' }
	],
	[#Rule 86
		 'file_name', 3,
sub
#line 171 "XSP.yp"
{ $_[1] . '.' . $_[3] }
	],
	[#Rule 87
		 'file_name', 3,
sub
#line 172 "XSP.yp"
{ $_[1] . '/' . $_[3] }
	],
	[#Rule 88
		 'arg_list', 1,
sub
#line 174 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 89
		 'arg_list', 3,
sub
#line 175 "XSP.yp"
{ push @{$_[1]}, $_[3]; $_[1] }
	],
	[#Rule 90
		 'arg_list', 0, undef
	],
	[#Rule 91
		 'argument', 5,
sub
#line 179 "XSP.yp"
{ make_argument( @_[0, 1], "length($_[4])" ) }
	],
	[#Rule 92
		 'argument', 4,
sub
#line 181 "XSP.yp"
{ make_argument( @_[0, 1, 2, 4] ) }
	],
	[#Rule 93
		 'argument', 2,
sub
#line 182 "XSP.yp"
{ make_argument( @_ ) }
	],
	[#Rule 94
		 'value', 1, undef
	],
	[#Rule 95
		 'value', 2,
sub
#line 185 "XSP.yp"
{ '-' . $_[2] }
	],
	[#Rule 96
		 'value', 1, undef
	],
	[#Rule 97
		 'value', 1, undef
	],
	[#Rule 98
		 'value', 1, undef
	],
	[#Rule 99
		 'value', 3,
sub
#line 189 "XSP.yp"
{ $_[1] . '::' . $_[3] }
	],
	[#Rule 100
		 'value', 4,
sub
#line 190 "XSP.yp"
{ "$_[1]($_[3])" }
	],
	[#Rule 101
		 'special_blocks', 1,
sub
#line 195 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 102
		 'special_blocks', 2,
sub
#line 197 "XSP.yp"
{ [ @{$_[1]}, $_[2] ] }
	],
	[#Rule 103
		 'special_blocks', 0, undef
	],
	[#Rule 104
		 'special_block', 3,
sub
#line 201 "XSP.yp"
{ $_[2] }
	],
	[#Rule 105
		 'special_block', 2,
sub
#line 203 "XSP.yp"
{ [] }
	],
	[#Rule 106
		 'special_block_start', 1,
sub
#line 206 "XSP.yp"
{ push_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 107
		 'special_block_end', 1,
sub
#line 208 "XSP.yp"
{ pop_lex_mode( $_[0], 'special' ) }
	],
	[#Rule 108
		 'lines', 1,
sub
#line 210 "XSP.yp"
{ [ $_[1] ] }
	],
	[#Rule 109
		 'lines', 2,
sub
#line 211 "XSP.yp"
{ push @{$_[1]}, $_[2]; $_[1] }
	]
],
                                  @_);
    bless($self,$class);
}

#line 213 "XSP.yp"


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
               '%name'       => 'p_name',
               '%typemap'    => 'p_typemap',
               '%file'       => 'p_file',
               '%module'     => 'p_module',
               '%code'       => 'p_code',
               '%cleanup'    => 'p_cleanup',
               '%package'    => 'p_package',
               '%length'     => 'p_length',
               '%loadplugin' => 'p_loadplugin',
               '%include'    => 'p_include',
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
  my $v = readline $_[0]->YYData->{LEX}{FH};
  my $buf = $_[0]->YYData->{LEX}{BUFFER};

  unless( defined $v ) {
    if( $_[0]->YYData->{LEX}{NEXT} ) {
      $_[0]->YYData->{LEX} = $_[0]->YYData->{LEX}{NEXT};
      $buf = $_[0]->YYData->{LEX}{BUFFER};

      return $buf if length $$buf;
      return read_more( $_[0] );
    } else {
      return;
    }
  }

  $$buf .= $v;

  return $buf;
}

sub yylex {
  my $data = $_[0]->YYData->{LEX};
  my $buf = $data->{BUFFER};

  for(;;) {
    if( !length( $$buf ) && !( $buf = read_more( $_[0] ) ) ) {
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
      } elsif( $$buf =~ /^\/\*/ ) {
        my $raw = '';
        for(; length( $$buf ) || ( $buf = read_more( $_[0] ) ); $$buf = '') {
          if( $$buf =~ s/(.*?\*\/)// ) {
              return ( 'RAW_CODE', $raw . '##' . $1 );
          }
          $raw .= '##' . $$buf;
        }
      } elsif( $$buf =~ s/^( \%}
                      | \%{ | {\%
                      | \%name | \%typemap | \%module  | \%code
                      | \%file | \%cleanup | \%package | \%length
                      | \%loadplugin | \%include
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

  print STDERR "Error: line " . $fh->input_line_number . " (Current token type: '",
    $_[0]->YYCurtok, "') (Current value: '",
    $_[0]->YYCurval, '\') Buffer: "', ( $buf ? $$buf : '--empty buffer--' ),
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
